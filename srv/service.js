
import 'dotenv/config';
import cds from '@sap/cds';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { createRequire } from 'module';
// import { SELECT } from '@sap/cds/lib/ql/cds-ql';
const require = createRequire(import.meta.url);
const { PDFParse } = require('pdf-parse');

export default cds.service.impl(async function() {

    const { SELECT, INSERT, UPDATE, DELETE } = cds.ql;
    
    // Entity referansları
    const { Employees, Candidates, JobPostings, PublicJobPostings, ChatMessages, CVAnalysisResults, HRPolicies, Annuals,MyApplications } = this.entities;


    this.before('*', (req) => {
        const rawReq = req._?.req || req.http?.req;
        const customId = req.headers?.['x-custom-userid'] || rawReq?.headers?.['x-custom-userid'] || req.user.id;
        
        // Her istekte (if kontrolü yapmadan) ID'yi mutlaka güncelle
        req.user.customId = customId; 
    });


    this.before('READ', MyApplications, (req) => {
        if (!req.user.is('HRAdmin')) {
            req.query.where({ userId: req.user.customId });
        }
    });

    this.before('CREATE', MyApplications, (req) => {
        req.data.userId = req.user.customId;
    });


    this.before('CREATE', Employees, async (req) => {
        const data = req.data;
        
        if (data.email && !data.email.includes('@')) {
            req.error(400, `Geçersiz email formatı: ${data.email}`, 'email');
        }

        if (data.birthDate) {
            const birth = new Date(data.birthDate);
            const today = new Date();
            let age = today.getFullYear() - birth.getFullYear();
            if (today.getMonth() < birth.getMonth() || (today.getMonth() === birth.getMonth() && today.getDate() < birth.getDate())) {
                age--;
            }
            if (age < 18) {
                req.error(400, 'Çalışan 18 yaşından küçük olamaz.', 'birthDate');
            }
        }
    });

    this.after('UPDATE', Candidates, async (data, req) => {
        if (data.status === 'ACCEPTED') {
            const tx = cds.transaction(req);
            const job = await tx.run(SELECT.one.from(JobPostings).where({ ID: data.jobPosting_ID }));
            if (job && job.vacancies > 0) {
                await tx.run(UPDATE(JobPostings).set({ vacancies: job.vacancies - 1 }).where({ ID: job.ID }));
                
                if (job.vacancies - 1 === 0) {
                    await tx.run(UPDATE(JobPostings).set({ status: 'CLOSED' }).where({ ID: job.ID }));
                }
            }
        }
    });


    // PDF Yükleme ve Metin Çıkarma
    this.on('uploadCVPDF', async (req) => {
        const { candidateId, pdfBase64 } = req.data;
        const tx = cds.transaction(req);

        try {
            const pdfBuffer = Buffer.from(pdfBase64, 'base64');
            const parser = new PDFParse({ data: new Uint8Array(pdfBuffer) });
            await parser.load();
            const textResult = await parser.getText();
            const extractedText = textResult.pages.map(p => p.text).join('\n');
            
            if (!extractedText || extractedText.trim() === '') {
                return req.error(400, 'PDF dosyasından hiç metin çıkarılamadı.');
            }

            await tx.run(UPDATE(Candidates).set({ resumeText: extractedText }).where({ ID: candidateId }));

            return `PDF başarıyla okundu! Adayın profiline ${extractedText.length} karakter eklendi.`;
        } catch (error) {
            req.error(500, `PDF okuma hatası: ${error.message}`);
        }
    });
    
    // AI ile CV Analizi
    this.on('analyzeCV','Candidates', async (req) => {
        req.notify('CV analizi başlatıldı');
        const tx = cds.transaction(req);
        
        try {
            const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
            const model = genAI.getGenerativeModel({ model: "gemini-flash-latest" });
            const candidate = await tx.run(SELECT.one.from(req.subject));

        if (!candidate) return req.error(404, 'Aday bulunamadı');
        const candidateId = candidate.ID;
        if (!candidate.resumeText) {
            const fileRow = await tx.run(
                SELECT.one.columns('resumeFile').from('hr.app.Candidates').where({ ID: candidateId })
            );
            if (fileRow && fileRow.resumeFile) {
                let pdfBuffer;
                if (Buffer.isBuffer(fileRow.resumeFile)) {
                    pdfBuffer = fileRow.resumeFile;
                } else if (typeof fileRow.resumeFile.pipe === 'function') {
                    const chunks = [];
                    for await (const chunk of fileRow.resumeFile) {
                        chunks.push(chunk);
                    }
                    pdfBuffer = Buffer.concat(chunks);
                } else {
                    pdfBuffer = Buffer.from(fileRow.resumeFile);
                }
                const parser = new PDFParse({ data: new Uint8Array(pdfBuffer) });
                const doc = await parser.load();
                const textResult = await parser.getText();
                candidate.resumeText = textResult.pages.map(p => p.text).join('\n');
                await tx.run(UPDATE('hr.app.Candidates').set({ resumeText: candidate.resumeText }).where({ ID: candidateId }));
            }
            if (!candidate.resumeText) {
                return req.error(400, 'CV dosyası yüklenmemiş veya PDF okunamadı.');
            }
        }
            const job = await tx.run(SELECT.one.from(JobPostings).where({ ID: candidate.jobPosting_ID }));
            if (!job) return req.error(404, 'Adayın başvurduğu ilan bulunamadı');

            const prompt = `
                Sen uzman bir İnsan Kaynakları işe alım uzmanısın.
                Aşağıda bir iş ilanının gereksinimleri ve bu ilana başvuran bir adayın CV metni bulunmaktadır.
                
                İŞ İLANI (Aranan Özellikler):
                ${job.requirements}
                
                ADAYIN CV METNİ:
                ${candidate.resumeText}
                
                Lütfen adayın bu ilana uygunluğunu objektif bir şekilde analiz et asla iyimser veya kötümser olma neyse o olsun. 
                Pozisyona uygunluğuna, tecrübesine, aldığı eğitimlere kısacası her şeye bak ve bana AŞAĞIDAKİ JSON FORMATINDA cevap dön. (Sadece JSON dön, dışına başka bir metin yazma).
                Ayrıca CV metninde geçen yabancı dilleri ve seviyelerini, adayın mezun olduğu üniversiteyi, bölümünü ve (varsa) yaşadığı lokasyonu da tespit et. CV'de bu bilgilerden biri belirtilmemişse "Belirtilmemiş" yaz.
                
                {
                  "recommendation": "İK ekibi için 2 cümlelik nihai öneri (Örn: Mülakata çağrılmalı, çünkü...)",
                  "languageSkills": "İngilizce: İleri (C1), Almanca: Başlangıç (A1)",
                  "university": "Adayın mezun olduğu üniversite",
                  "major": "Adayın bölümü",
                  "location": "Adayın yaşadığı şehir/lokasyon",
                  "educationScore": 100,
                  "strengths": ["Güçlü yön 1", "Güçlü yön 2"],
                  "weaknesses": ["Gelişime açık yön 1", "Gelişime açık yön 2"]
                }
            `;

            const result = await model.generateContent(prompt);
            const responseText = result.response.text();
            
            const cleanJsonString = responseText.replace(/```json/g, '').replace(/```/g, '').trim();
            const aiData = JSON.parse(cleanJsonString);

            await tx.run(
                INSERT.into(CVAnalysisResults).entries({
                    candidate_ID: candidateId,
                    recommendation: aiData.recommendation,
                    languageSkills: aiData.languageSkills || 'Belirtilmemiş',
                    university: aiData.university || 'Belirtilmemiş',
                    major: aiData.major || 'Belirtilmemiş',
                    location: aiData.location || 'Belirtilmemiş',
                    educationScore: aiData.educationScore,
                    strengths: JSON.stringify(aiData.strengths),
                    weaknesses: JSON.stringify(aiData.weaknesses),
                    rawResponse: responseText, 
                    analyzedAt: new Date().toISOString()
                })
            );

            return `CV Analizi başarıyla tamamlandı. Nihai Karar: ${aiData.recommendation}`;
        } catch (error) {
            req.error(500, `AI Analizi sırasında hata: ${error.message}`);
        }
    });

    // İK Chatbot (RAG: Retrieval-Augmented Generation)
    this.on('askHRBot', async (req) => {
        const { conversationId, question } = req.data;
        const tx = cds.transaction(req);
        
        try {
            const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
            const model = genAI.getGenerativeModel({ model: "gemini-flash-latest" });

            const policies = await tx.run(SELECT.from(HRPolicies).where({ isActive: true }));
            
            let contextText = "ŞİRKET İK POLİTİKALARI (BİLGİ BANKASI):\\n\\n";
            policies.forEach(p => {
                contextText += `--- BAŞLIK: ${p.title} ---\\nİÇERİK: ${p.content}\\n\\n`;
            });

            const prompt = `
                Sen bu şirketin resmi İnsan Kaynakları Asistanısın (Adın: Pusula).
                Çalışanların sana sorduğu soruları, AŞAĞIDA SANA VERİLEN "ŞİRKET İK POLİTİKALARI" metnine dayanarak cevaplamalısın.
                Politikalarda yazmayan bir şey sorulursa "Bu konuda kesin bir bilgiye sahip değilim, lütfen İK departmanı ile görüşün" de.
                Asla politikaların dışına çıkarak kendi kendine kural uydurma. Nazik ve profesyonel ol.
                
                ${contextText}
                
                ÇALIŞANIN SORUSU: "${question}"
                
                CEVABIN:
            `;

            await tx.run(INSERT.into(ChatMessages).entries({
                conversationId: conversationId,
                role: 'user',
                content: question,
                timestamp: new Date().toISOString()
            }));

            // Hata alırsak pes etme, 2 saniye bekleyip 3 kez tekrar dene (Retry Mekanizması)
            let result;
            for (let i = 0; i < 3; i++) {
                try {
                    result = await model.generateContent(prompt);
                    break; // Başarılı olursa döngüden çık
                } catch (err) {
                    if (i === 2) throw err; // 3. denemede de çökerse pes et
                    await new Promise(resolve => setTimeout(resolve, 2000)); // 2 saniye bekle
                }
            }
            const aiAnswer = result.response.text();

            await tx.run(INSERT.into(ChatMessages).entries({
                conversationId: conversationId,
                role: 'assistant',
                content: aiAnswer,
                timestamp: new Date().toISOString()
            }));

            return aiAnswer;
        } catch (error) {
            req.error(500, `Chatbot yanıt verirken hata: ${error.message}`);
        }
    });

    this.on('calculateAttritionRisk', async (req) => {
         return "İşten ayrılma riski hesaplama algoritması devreye alındı (Mock).";
    });
    
    this.on('analyzeSurvey', async (req) => {
         return "Anket duygu analizi tamamlandı (Mock).";
    });

    this.on('applyToJob', 'PublicJobPostings', async (req) => {
        const jobPostingId = req.params[0]?.ID || req.params[0];
        const { firstName, lastName, email, phone } = req.data;
        const tx = cds.transaction(req);
        try {
            // Aynı kişi aynı ilana iki kez başvurmasın
            const existing = await tx.run(
                SELECT.one.from(Candidates).where({ email: email, jobPosting_ID: jobPostingId })
            );
            if (existing) {
                return req.error(409, 'Bu e-posta adresiyle bu ilana zaten başvuru yapılmış.');
            }
            
            // Gerçek kullanıcı ID'sini al (Örn: "aday")
            const realUserId = req.headers['x-custom-userid'] || req.user.id;
            // Adayı Candidates tablosuna ekle
            await tx.run(
                INSERT.into(Candidates).entries({
                    userId:          realUserId, // YENİ EKLENEN SATIR
                    firstName:       firstName,
                    lastName:        lastName,
                    email:           email,
                    phone:           phone,
                    jobPosting_ID:   jobPostingId,
                    applicationDate: new Date().toISOString().split('T')[0],
                    status:          'APPLIED'
                })
            );
            return `Başvurunuz başarıyla alındı! Teşekkürler, ${firstName}.`;
        } catch (error) {
            if (error.code === 409) throw error;
            req.error(500, `Başvuru sırasında hata: ${error.message}`);
        }
    });

    // KULLANICI BİLGİSİNİ VE ROLÜNÜ DÖNEN FONKSİYON
    this.on('getMyUserInfo', (req) => {
        let userRole = 'Candidate'; // Varsayılan aday
        
        if (req.user.is('HRAdmin')) userRole = 'HRAdmin';
        else if (req.user.is('Employee')) userRole = 'Employee';
        
        return {
            username: req.user.id,
            role: userRole
        };
    });


    async function checkManagerPermission(req, employeeId, tx) {
        if (req.user.is('HRAdmin')) return true; 
        const realUserId = req.headers['x-custom-userid'] || req.user.id;
        
        const currentUser = await tx.run(SELECT.one.from(Employees).where({ userId: realUserId }));
        if (!currentUser) return false;
        
        const targetEmployee = await tx.run(SELECT.one.from(Employees).where({ ID: employeeId }));
        if (!targetEmployee) return false;
        
        return targetEmployee.manager_ID === currentUser.ID;
    }
            this.on('approveLeave', 'Annuals', async (req) => {
        const leaveId = req.params[0]?.ID || req.params[0]; 
        const tx = cds.transaction(req);
        
        const leaveRequest = await tx.run(SELECT.one.from(Annuals).where({ ID: leaveId }));
        if (!leaveRequest) return req.error(404, 'İzin kaydı bulunamadı.');
        
        if (leaveRequest.approval === 'APPROVED') return req.error(400, 'Bu izin zaten onaylanmış.');
        
        const hasPermission = await checkManagerPermission(req, leaveRequest.employee_ID, tx);
        if (!hasPermission) {
            return req.error(403, 'Yetkiniz yok. Sadece yöneticisi veya İK yetkilisi onaylayabilir.');
        }

        const startDate = new Date(leaveRequest.start_date);
        const endDate = new Date(leaveRequest.end_date);
        const diffTime = Math.abs(endDate - startDate);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;

        const employee = await tx.run(SELECT.one.from(Employees).where({ ID: leaveRequest.employee_ID }));
        
        if (!employee) return req.error(404, 'Çalışan bulunamadı.');
        
        const currentLeaveDays = employee.annual_days || 0;
        if (currentLeaveDays < diffDays) {
            return req.error(400, `Çalışanın yeterli izin hakkı bulunmamaktadır. Kalan: ${currentLeaveDays}, İstenen: ${diffDays}`);
        }

        await tx.run(UPDATE(Annuals).set({ approval: 'APPROVED' }).where({ ID: leaveId }));
        await tx.run(UPDATE(Employees).set({ annual_days: currentLeaveDays - diffDays }).where({ ID: leaveRequest.employee_ID }));
        
        return `İzin başarıyla onaylandı. ${diffDays} gün çalışanın izin hakkından düşüldü.`;
    });

    this.on('rejectLeave', 'Annuals', async (req) => {
        const leaveId = req.params[0]?.ID || req.params[0];
        const tx = cds.transaction(req);
        
        const leaveRequest = await tx.run(SELECT.one.from(Annuals).where({ ID: leaveId }));
        if (!leaveRequest) return req.error(404, 'İzin kaydı bulunamadı.');
        if (leaveRequest.approval === 'DECLINED') return req.error(400, 'Bu izin zaten reddedilmiş.');
        
        const hasPermission = await checkManagerPermission(req, leaveRequest.employee_ID, tx);
        if (!hasPermission) {
            return req.error(403, 'Yetkiniz yok. Sadece yöneticisi veya İK yetkilisi reddedebilir.');
        }
        await tx.run(UPDATE(Annuals).set({ approval: 'DECLINED' }).where({ ID: leaveId }));
        return 'İzin reddedildi.';
    });

    this.before(['CREATE', 'NEW'], Annuals, async (req) => {
        const tx = cds.transaction(req);
        const realUserId = req.headers['x-custom-userid'] || req.user.id;
        
        const currentEmployee = await tx.run(
            SELECT.one.from(Employees).where({ userId: realUserId })
        );
        
        if (!currentEmployee) {
            return req.error(400, `Giriş yapan kullanıcı (${realUserId}) ile eşleşen bir çalışan bulunamadı.`);
        }
        
        req.data.employee_ID = currentEmployee.ID;
        if (!req.data.approval) req.data.approval = 'APPLIED';
    });

    this.before('READ', Annuals, async (req) => {
        if (req.user.is('HRAdmin')) return; 

        const queryStr = JSON.stringify(req.query.SELECT.where || []);
        if (queryStr.includes('"ID"')) {
            return; 
        }

        const tx = cds.transaction(req);
        const realUserId = req.headers['x-custom-userid'] || req.user.id;
        
        const currentEmployee = await tx.run(SELECT.one.from(Employees).where({ userId: realUserId }));
    
        if (!currentEmployee) {
            req.query.where({ employee_ID: 'GECERSIZ_KULLANICI' });
            return; 
        }

        const subordinates = await tx.run(SELECT.from(Employees).where({ manager_ID: currentEmployee.ID }));
        const allowedEmployeeIds = [currentEmployee.ID, ...subordinates.map(sub => sub.ID)];

        req.query.where({ employee_ID: { 'in': allowedEmployeeIds } });
    });

    this.before(['CREATE', 'NEW'], [Candidates, MyApplications], (req) => {
        const realUserId = req.user.customId;
        req.data.userId = realUserId;
        if (!req.data.status) req.data.status = 'APPLIED';
    });

    this.before('READ', [Candidates, MyApplications], async (req) => {
        if (req.user.is('HRAdmin')) return;
        
        // Fiori Elements'in liste (navigasyon dahil) mi yoksa tekil kayıt mı okuduğunu anlama
        const isNavigation = req.query.SELECT.from && req.query.SELECT.from.ref && req.query.SELECT.from.ref.length > 1;
        const hasWhereId = req.query.SELECT.where && req.query.SELECT.where.some(x => x.ref && x.ref.includes('ID'));
        const hasFromId = req.query.SELECT.from && req.query.SELECT.from.ref && req.query.SELECT.from.ref[0].where;
        
        // Eğer liste veya navigasyon (JobPostings/candidates) sorgusuysa sadece kendini görecek filtreyi ekle
        if (isNavigation || (!hasWhereId && !hasFromId)) {
            const realUserId = req.user.customId;
            req.query.where({ userId: realUserId });
        }
    });

    this.after('READ', [Candidates, MyApplications], (data, req) => {
        if (!data || req.user.is('HRAdmin')) return;
        
        const realUserId = req.user.customId;
        
        // Tekil okumalarda (direkt URL'den ID ile girildiğinde) ek güvenlik kontrolü
        if (!Array.isArray(data)) {
            if (data.userId && data.userId !== realUserId) {
                req.error(403, 'Bu kaydı görüntüleme yetkiniz yok.');
            }
        } else {
            // Liste okumalarında son savunma hattı (Eğer yukarıdaki filtre bir şekilde atlatılırsa)
            for (let i = data.length - 1; i >= 0; i--) {
                if (data[i].userId && data[i].userId !== realUserId) {
                    data.splice(i, 1); // Başkasına ait olanları veriden acımasızca sil
                }
            }
        }
    });
    
    this.on('processCandidate', 'Candidates', async (req) => {
        req.notify('Başvuru Sürece Alındı');
        const p = req.params[req.params.length - 1];
        const candidateId = p?.ID || p;
        const tx = cds.transaction(req);
        
        const candidate = await tx.run(SELECT.one.from(Candidates).where({ ID: candidateId }));
        if (!candidate) return req.error(404, 'Aday bulunamadı.');
        
        await tx.run(UPDATE(Candidates).set({ status: 'IN_PROGRESS' }).where({ ID: candidateId }));
        return 'Aday değerlendirme sürecine alındı.';
    });
    
    this.on('approveCandidate', 'Candidates', async (req) => {
        req.notify('Başvuru Onaylandı');
        const p = req.params[req.params.length - 1];
        const candidateId = p?.ID || p;
        const tx = cds.transaction(req);
        
        const candidate = await tx.run(SELECT.one.from(Candidates).where({ ID: candidateId }));
        if (!candidate) return req.error(404, 'Aday bulunamadı.');
        
        await tx.run(UPDATE(Candidates).set({ status: 'ACCEPTED' }).where({ ID: candidateId }));
        return 'Aday onaylandı ve işe alındı.';
    });

    this.on('rejectCandidate', 'Candidates', async (req) => {
        req.notify('Başvuru Reddedildi');
        const p = req.params[req.params.length - 1];
        const candidateId = p?.ID || p;
        const tx = cds.transaction(req);
        
        const candidate = await tx.run(SELECT.one.from(Candidates).where({ ID: candidateId }));
        if (!candidate) return req.error(404, 'Aday bulunamadı.');
        
        await tx.run(UPDATE(Candidates).set({ status: 'REJECTED' }).where({ ID: candidateId }));
        return 'Aday reddedildi.';
    });

});




