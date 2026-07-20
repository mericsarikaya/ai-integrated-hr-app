import cds from '@sap/cds';
import { GoogleGenerativeAI } from '@google/generative-ai';

export default cds.service.impl(async function() {
    
    // Entity referansları
    const { Employees, Candidates, JobPostings, ChatMessages, CVAnalysisResults } = this.entities;

    // ============================================================
    // 1. EVENT HANDLERS (VALIDASYONLAR & İŞ KURALLARI)
    // ============================================================

    // Yeni bir çalışan eklenmeden ÖNCE (BEFORE CREATE) çalışır
    this.before('CREATE', Employees, async (req) => {
        const data = req.data;
        
        // 1.1 Email format kontrolü
        if (data.email && !data.email.includes('@')) {
            req.error(400, `Geçersiz email formatı: ${data.email}`, 'email');
        }

        // 1.2 Yaş kontrolü (En az 18 yaşında olmalı)
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

    // Aday durumu güncellendiğinde SONRA (AFTER UPDATE) çalışır
    this.after('UPDATE', Candidates, async (data, req) => {
        // Eğer aday 'ACCEPTED' olduysa, belki iş ilanı kontenjanını azaltabiliriz
        if (data.status === 'ACCEPTED') {
            const tx = cds.transaction(req);
            const job = await tx.run(SELECT.one.from(JobPostings).where({ ID: data.jobPosting_ID }));
            if (job && job.vacancies > 0) {
                await tx.run(UPDATE(JobPostings).set({ vacancies: job.vacancies - 1 }).where({ ID: job.ID }));
                
                // Eğer kontenjan 0 olduysa ilanı kapat
                if (job.vacancies - 1 === 0) {
                    await tx.run(UPDATE(JobPostings).set({ status: 'CLOSED' }).where({ ID: job.ID }));
                }
            }
        }
    });

    // ============================================================
    // 2. CUSTOM ACTIONS (YAPAY ZEKA ENTEGRASYONLARI)
    // ============================================================

    // AI ile CV Analizi
    this.on('analyzeCV', async (req) => {
        const { candidateId } = req.data;
        const tx = cds.transaction(req);
        
        try {
            // 1. Adayı ve ilanı getir
            const candidate = await tx.run(SELECT.one.from(Candidates).where({ ID: candidateId }));
            if (!candidate) return req.error(404, 'Aday bulunamadı');
            if (!candidate.resumeText) return req.error(400, 'Adayın CV metni (resumeText) boş');

            const job = await tx.run(SELECT.one.from(JobPostings).where({ ID: candidate.jobPosting_ID }));

            // --- BURASI GERÇEK GEMINI API ÇAĞRISI İÇİN YER TUTUCUDUR ---
            // Şimdilik Gün 3'te sistemi test etmek için mock bir sonuç döndürüyoruz.
            // Gün 4'te buraya Google Generative AI entegrasyonu yazılacak.
            const mockScore = Math.floor(Math.random() * 40) + 60; // 60-100 arası

            // Analiz sonucunu DB'ye kaydet
            await tx.run(
                INSERT.into(CVAnalysisResults).entries({
                    candidate_ID: candidateId,
                    overallScore: mockScore,
                    skillMatchScore: mockScore - 5,
                    experienceScore: mockScore + 2,
                    educationScore: 90,
                    strengths: '["İletişim", "Teknik Altyapı", "Öğrenmeye açık"]',
                    weaknesses: '["Sektör tecrübesi eksik"]',
                    recommendation: 'Mülakata çağrılması şiddetle önerilir.',
                    analyzedAt: new Date().toISOString()
                })
            );

            return `CV Analizi başarıyla tamamlandı. Adayın uygunluk skoru: ${mockScore}`;
        } catch (error) {
            req.error(500, `Analiz sırasında hata: ${error.message}`);
        }
    });

    // İK Chatbot (RAG) - İleride Gün 4'te doldurulacak
    this.on('askHRBot', async (req) => {
        const { conversationId, question } = req.data;
        
        // Şimdilik sadece soruyu DB'ye kaydedip statik cevap dönüyoruz
        const tx = cds.transaction(req);
        
        // Kullanıcı sorusunu kaydet
        await tx.run(INSERT.into(ChatMessages).entries({
            conversationId: conversationId,
            role: 'user',
            content: question,
            timestamp: new Date().toISOString()
        }));

        // Sistemin cevabını kaydet (Şimdilik Mock)
        const mockResponse = "Merhaba! Ben HR Bot. Henüz AI beynim (Gün 4) takılmadı ama yakında sana gerçek cevaplar vereceğim.";
        await tx.run(INSERT.into(ChatMessages).entries({
            conversationId: conversationId,
            role: 'assistant',
            content: mockResponse,
            timestamp: new Date().toISOString()
        }));

        return mockResponse;
    });

    this.on('calculateAttritionRisk', async (req) => {
         return "İşten ayrılma riski hesaplama algoritması devreye alındı (Mock).";
    });
    
    this.on('analyzeSurvey', async (req) => {
         return "Anket duygu analizi tamamlandı (Mock).";
    });
});