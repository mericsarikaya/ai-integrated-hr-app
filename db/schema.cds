namespace hr.app;

using { managed, cuid } from '@sap/cds/common';

// ============================================================
// ENUM TYPES
// ============================================================

type EmployeeStatus   : String(20) enum { ACTIVE; INACTIVE; ON_LEAVE; TERMINATED; }
type CandidateStatus  : String(20) enum { APPLIED; SCREENING; INTERVIEW; OFFER; ACCEPTED; REJECTED; WITHDRAWN; }
type RiskLevel        : String(20) enum { LOW; MEDIUM; HIGH; CRITICAL; }
type Rating           : Integer    enum { ONE = 1; TWO = 2; THREE = 3; FOUR = 4; FIVE = 5; }
type GoalStatus       : String(20) enum { NOT_STARTED; IN_PROGRESS; COMPLETED; CANCELLED; }
type ReviewStatus     : String(20) enum { DRAFT; SUBMITTED; APPROVED; REJECTED; }
type Sentiment        : String(20) enum { POSITIVE; NEUTRAL; NEGATIVE; }
type JobPostingStatus : String(20) enum { OPEN; CLOSED; ON_HOLD; CANCELLED; }
type SurveyStatus     : String(20) enum { DRAFT; ACTIVE; CLOSED; }

// ============================================================
// DEPARTMENTS
// ============================================================

entity Departments : cuid, managed {
    name          : String(100) @mandatory;
    description   : String(500);
    costCenter    : String(20);
    headCount     : Integer default 0;
    manager       : Association to Employees;
    employees     : Composition of many Employees on employees.department = $self;
    positions     : Composition of many Positions on positions.department = $self;
}

// ============================================================
// POSITIONS
// ============================================================

entity Positions : cuid, managed {
    title         : String(150) @mandatory;
    description   : String(1000);
    level         : String(20);        // Junior, Mid, Senior, Lead, Manager
    minSalary     : Decimal(12,2);
    maxSalary     : Decimal(12,2);
    isActive      : Boolean default true;
    department    : Association to Departments;
    employees     : Association to many Employees on employees.position = $self;
    jobPostings   : Composition of many JobPostings on jobPostings.position = $self;
}

// ============================================================
// EMPLOYEES
// ============================================================

entity Employees : cuid, managed {
    employeeNumber   : String(10)  @mandatory;
    firstName        : String(100) @mandatory;
    lastName         : String(100) @mandatory;
    email            : String(200) @mandatory;
    phone            : String(20);
    hireDate         : Date;
    birthDate        : Date;
    gender           : String(10);
    address          : String(500);
    profilePhoto     : String(500);     // URL veya dosya yolu
    salary           : Decimal(12,2);
    status           : EmployeeStatus default 'ACTIVE';

    // İlişkiler
    department       : Association to Departments;
    position         : Association to Positions;
    manager          : Association to Employees;
    directReports    : Association to many Employees on directReports.manager = $self;
    skills           : Composition of many EmployeeSkills on skills.employee = $self;
    reviews          : Composition of many PerformanceReviews on reviews.employee = $self;
    goals            : Composition of many Goals on goals.employee = $self;

    // AI alanları
    attritionRisk    : Decimal(5,2) default 0;    // 0-100 arası
    riskLevel        : RiskLevel;
    lastRiskCalcDate : Timestamp;
    riskHistory      : Composition of many AttritionRiskHistory on riskHistory.employee = $self;
}

// ============================================================
// SKILLS & EMPLOYEE SKILLS (Beceri Matrisi)
// ============================================================

entity Skills : cuid, managed {
    name          : String(100) @mandatory;
    category      : String(50);       // Technical, Soft, Language vb.
    description   : String(500);
    employeeSkills: Association to many EmployeeSkills on employeeSkills.skill = $self;
}

entity EmployeeSkills : cuid, managed {
    employee      : Association to Employees;
    skill         : Association to Skills;
    proficiency   : Rating;            // 1-5 arası yetkinlik seviyesi
    yearsOfExp    : Decimal(4,1);      // Deneyim yılı
    certified     : Boolean default false;
}

// ============================================================
// JOB POSTINGS (Açık Pozisyon İlanları)
// ============================================================

entity JobPostings : cuid, managed {
    title            : String(200) @mandatory;
    description      : String(5000);
    requirements     : String(5000);
    status           : JobPostingStatus default 'OPEN';
    openDate         : Date;
    closeDate        : Date;
    vacancies        : Integer default 1;
    position         : Association to Positions;
    department       : Association to Departments;
    candidates       : Composition of many Candidates on candidates.jobPosting = $self;
}

// ============================================================
// CANDIDATES (Adaylar)
// ============================================================

entity Candidates : cuid, managed {
    firstName        : String(100) @mandatory;
    lastName         : String(100) @mandatory;
    email            : String(200) @mandatory;
    phone            : String(20);
    resumeFileName   : String(255);       // Yüklenen CV dosya adı
    resumeText       : LargeString;       // CV'den çıkarılan text (AI analizi için)
    linkedinUrl      : String(500);
    applicationDate  : Date;
    status           : CandidateStatus default 'APPLIED';
    interviewDate    : Timestamp;
    interviewNotes   : String(2000);
    rejectionReason  : String(500);

    // İlişkiler
    jobPosting       : Association to JobPostings;

    // AI analiz sonuçları
    cvAnalysis       : Composition of one CVAnalysisResults on cvAnalysis.candidate = $self;
}

// ============================================================
// CV ANALYSIS RESULTS (AI CV Analiz Sonuçları)
// ============================================================

entity CVAnalysisResults : cuid, managed {
    candidate        : Association to Candidates;
    overallScore     : Decimal(5,2);       // 0-100 arası genel skor
    skillMatchScore  : Decimal(5,2);       // Beceri eşleşme skoru
    experienceScore  : Decimal(5,2);       // Deneyim uyum skoru
    educationScore   : Decimal(5,2);       // Eğitim uyum skoru
    strengths        : LargeString;        // JSON array: güçlü yönler
    weaknesses       : LargeString;        // JSON array: zayıf yönler
    recommendation   : String(2000);       // AI önerisi
    rawResponse      : LargeString;        // AI'dan gelen ham yanıt
    analyzedAt       : Timestamp;
}

// ============================================================
// PERFORMANCE REVIEWS (Performans Değerlendirmeleri)
// ============================================================

entity PerformanceReviews : cuid, managed {
    employee         : Association to Employees;
    reviewer         : Association to Employees;    // Değerlendiren yönetici
    period           : String(20);                  // "2026-H1", "2026-Q2" gibi
    reviewDate       : Date;
    overallRating    : Rating;                      // 1-5 arası
    status           : ReviewStatus default 'DRAFT';
    strengths        : String(2000);
    areasToImprove   : String(2000);
    managerComments  : String(2000);
    employeeComments : String(2000);
    goals            : Association to many Goals on goals.review = $self;
}

// ============================================================
// GOALS (Hedefler)
// ============================================================

entity Goals : cuid, managed {
    employee         : Association to Employees;
    review           : Association to PerformanceReviews;
    title            : String(200) @mandatory;
    description      : String(1000);
    targetDate       : Date;
    status           : GoalStatus default 'NOT_STARTED';
    weight           : Decimal(5,2);     // Hedef ağırlığı (%)
    progress         : Integer default 0; // 0-100 arası ilerleme
    managerRating    : Rating;
}

// ============================================================
// SURVEYS & RESPONSES (Anketler)
// ============================================================

entity Surveys : cuid, managed {
    title            : String(200) @mandatory;
    description      : String(1000);
    status           : SurveyStatus default 'DRAFT';
    startDate        : Date;
    endDate          : Date;
    responses        : Composition of many SurveyResponses on responses.survey = $self;
}

entity SurveyResponses : cuid, managed {
    survey           : Association to Surveys;
    employee         : Association to Employees;
    rating           : Rating;                     // Genel puanlama (1-5)
    openEndedAnswer  : LargeString;                // Açık uçlu yanıt
    submittedAt      : Timestamp;

    // AI duygu analizi sonuçları
    sentiment        : Sentiment;
    sentimentScore   : Decimal(4,2);               // -1.0 ile 1.0 arası
    themes           : LargeString;                // JSON array: tespit edilen temalar
}

// ============================================================
// CHAT MESSAGES (Chatbot Konuşma Geçmişi)
// ============================================================

entity ChatMessages : cuid, managed {
    conversationId   : String(50) @mandatory;       // Oturum bazlı gruplama
    employee         : Association to Employees;
    role             : String(10);                   // 'user' veya 'assistant'
    content          : LargeString @mandatory;
    timestamp        : Timestamp;
}

// ============================================================
// ATTRITION RISK HISTORY (Ayrılma Riski Geçmişi)
// ============================================================

entity AttritionRiskHistory : cuid, managed {
    employee         : Association to Employees;
    riskScore        : Decimal(5,2);                // 0-100
    riskLevel        : RiskLevel;
    topFactors       : LargeString;                 // JSON array: risk faktörleri
    suggestedActions : LargeString;                 // JSON array: önerilen aksiyonlar
    calculatedAt     : Timestamp;
}

// ============================================================
// HR POLICIES (Chatbot Bilgi Bankası)
// ============================================================

entity HRPolicies : cuid, managed {
    title            : String(200) @mandatory;
    category         : String(50);                  // İzin, Yan Haklar, Disiplin vb.
    content          : LargeString @mandatory;       // Politika metni
    keywords         : String(500);                  // Arama için anahtar kelimeler
    isActive         : Boolean default true;
}