import 'dotenv/config';
import cds from '@sap/cds';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const pdfParse = require('pdf-parse');

export default cds.service.impl(async function() {
    
    // Entity referansları
    const { Employees, Candidates, JobPostings, ChatMessages, CVAnalysisResults, HRPolicies } = this.entities;

    // ============================================================
    // 1. EVENT HANDLERS (VALIDASYONLAR & İŞ KURALLARI)
    // ============================================================

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

    // ============================================================
    // 2. CUSTOM ACTIONS (GERÇEK YAPAY ZEKA ENTEGRASYONLARI)
    // ============================================================

    // PDF Yükleme ve Metin Çıkarma
    this.on('uploadCVPDF', async (req) => {
        const { candidateId, pdfBase64 } = req.data;
        const tx = cds.transaction(req);

        try {
            const pdfBuffer = Buffer.from(pdfBase64, 'base64');
            const data = await pdfParse(pdfBuffer);
            const extractedText = data.text;
            
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
    this.on('analyzeCV', async (req) => {
        const { candidateId } = req.data;
        const tx = cds.transaction(req);
        
        try {
            const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
            const model = genAI.getGenerativeModel({ model: "gemini-flash-latest" });

            const candidate = await tx.run(SELECT.one.from(Candidates).where({ ID: candidateId }));
            if (!candidate) return req.error(404, 'Aday bulunamadı');
            if (!candidate.resumeText) return req.error(400, 'Adayın CV metni (resumeText) boş');

            const job = await tx.run(SELECT.one.from(JobPostings).where({ ID: candidate.jobPosting_ID }));
            if (!job) return req.error(404, 'Adayın başvurduğu ilan bulunamadı');

            const prompt = `
                Sen uzman bir İnsan Kaynakları işe alım uzmanısın.
                Aşağıda bir iş ilanının gereksinimleri ve bu ilana başvuran bir adayın CV metni bulunmaktadır.
                
                İŞ İLANI (Aranan Özellikler):
                ${job.requirements}
                
                ADAYIN CV METNİ:
                ${candidate.resumeText}
                
                Lütfen adayın bu ilana uygunluğunu analiz et ve bana AŞAĞIDAKİ JSON FORMATINDA cevap dön. (Sadece JSON dön, dışına başka bir metin yazma).
                
                {
                  "overallScore": 85,
                  "skillMatchScore": 90,
                  "experienceScore": 80,
                  "educationScore": 100,
                  "strengths": ["Güçlü yön 1", "Güçlü yön 2"],
                  "weaknesses": ["Gelişime açık yön 1", "Gelişime açık yön 2"],
                  "recommendation": "İK ekibi için 2 cümlelik nihai öneri (Örn: Mülakata çağrılmalı, çünkü...)"
                }
            `;

            const result = await model.generateContent(prompt);
            const responseText = result.response.text();
            
            const cleanJsonString = responseText.replace(/```json/g, '').replace(/```/g, '').trim();
            const aiData = JSON.parse(cleanJsonString);

            await tx.run(
                INSERT.into(CVAnalysisResults).entries({
                    candidate_ID: candidateId,
                    overallScore: aiData.overallScore,
                    skillMatchScore: aiData.skillMatchScore,
                    experienceScore: aiData.experienceScore,
                    educationScore: aiData.educationScore,
                    strengths: JSON.stringify(aiData.strengths),
                    weaknesses: JSON.stringify(aiData.weaknesses),
                    recommendation: aiData.recommendation,
                    rawResponse: responseText, 
                    analyzedAt: new Date().toISOString()
                })
            );

            return `CV Analizi başarıyla tamamlandı. Adayın Genel Skoru: ${aiData.overallScore}`;
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
});