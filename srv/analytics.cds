using hr.app from '../db/schema';


// Departman KPI'ları
@readonly
service AnalyticsService @(path: '/analytics') {

    // --- Departman Bazlı Çalışan İstatistikleri ---
    entity DepartmentStats as select from app.Employees {
        key department.ID   as departmentId,
        department.name     as departmentName,
        count(ID)           as employeeCount   : Integer,
        avg(attritionRisk)  as avgAttritionRisk : Decimal(5,2),
        avg(salary)         as avgSalary        : Decimal(12,2)
    } where status = 'ACTIVE'
      group by department.ID, department.name;

    // --- Risk Seviyesi Dağılımı ---
    entity RiskDistribution as select from app.Employees {
        key riskLevel,
        count(ID)           as employeeCount   : Integer,
        avg(attritionRisk)  as avgRiskScore     : Decimal(5,2)
    } where status = 'ACTIVE'
      group by riskLevel;

    // --- İşe Alım Hunisi İstatistikleri ---
    entity RecruitmentStats as select from app.Candidates {
        key jobPosting.ID              as jobPostingId,
        jobPosting.title               as jobTitle,
        jobPosting.department.name     as departmentName,
        count(ID)                      as totalApplicants  : Integer,
        avg(cvAnalysis.educationScore) as avgCVScore        : Decimal(5,2)
    } group by jobPosting.ID, jobPosting.title, jobPosting.department.name;

    // --- Performans Trendi ---
    entity PerformanceTrend as select from app.PerformanceReviews {
        key period,
        avg(overallRating)   as avgRating    : Decimal(3,1),
        count(ID)            as reviewCount  : Integer
    } group by period;

    // --- Dashboard KPI Özet ---
    // Bu custom function ile çekilecek, view olarak değil
    function getDashboardKPIs() returns {
        totalEmployees   : Integer;
        activeEmployees  : Integer;
        openPositions    : Integer;
        avgAttritionRisk : Decimal(5,2);
        avgPerformance   : Decimal(3,1);
        totalCandidates  : Integer;
        highRiskCount    : Integer;
    };
}