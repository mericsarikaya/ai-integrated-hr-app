import cds from '@sap/cds';

export default cds.service.impl(async function() {
    const Employees = 'hr.app.Employees';
    const JobPostings = 'hr.app.JobPostings';
    const Candidates = 'hr.app.Candidates';

    // Dashboard'daki üst KPI kartlarını (Anahtar Performans Göstergeleri) doldurur
    this.on('getDashboardKPIs', async (req) => {
        const tx = cds.transaction(req);
        
        try {
            // 1. Toplam Çalışan Sayısı
            const totalEmpsResult = await tx.run(SELECT.one`count(ID) as count`.from(Employees));
            
            // 2. Aktif Çalışan Sayısı
            const activeEmpsResult = await tx.run(SELECT.one`count(ID) as count`.from(Employees).where({ status: 'ACTIVE' }));
            
            // 3. Açık İlan Sayısı
            const openJobsResult = await tx.run(SELECT.one`count(ID) as count`.from(JobPostings).where({ status: 'OPEN' }));
            
            // 4. Ortalama Ayrılma Riski (Sadece Aktif çalışanlar için)
            const riskResult = await tx.run(SELECT.one`avg(attritionRisk) as avgRisk`.from(Employees).where({ status: 'ACTIVE' }));
            
            // 5. Yüksek ve Kritik Riskli Çalışan Sayısı
            const highRiskResult = await tx.run(
                SELECT.one`count(ID) as count`
                .from(Employees)
                .where(`status = 'ACTIVE' and (riskLevel = 'HIGH' or riskLevel = 'CRITICAL')`)
            );
            
            // 6. Toplam Başvuru Sayısı
            const candidatesResult = await tx.run(SELECT.one`count(ID) as count`.from(Candidates));

            // Sonuçları CDS yapısında (JSON) döndür
            return {
                totalEmployees: totalEmpsResult.count || 0,
                activeEmployees: activeEmpsResult.count || 0,
                openPositions: openJobsResult.count || 0,
                avgAttritionRisk: riskResult.avgRisk ? parseFloat(riskResult.avgRisk.toFixed(2)) : 0,
                avgPerformance: 3.5, // Şimdilik mock
                totalCandidates: candidatesResult.count || 0,
                highRiskCount: highRiskResult.count || 0
            };

        } catch (error) {
            req.error(500, `KPI'lar çekilirken hata oluştu: ${error.message}`);
        }
    });

});