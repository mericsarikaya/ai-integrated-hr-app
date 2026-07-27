using hr.app from '../db/schema';

service HRService @(path: '/hr') {

    // ============================================================
    // ÇALIŞAN YÖNETİMİ — Employee: READ, HRAdmin: FULL
    // ============================================================

    @(restrict: [
        { grant: 'READ', to: ['Employee', 'HRAdmin'] },
        { grant: '*',    to: 'HRAdmin' }
    ])
    entity Employees as projection on app.Employees;


    @(restrict: [
        { grant: 'READ', to: ['Employee', 'HRAdmin'] },
        { grant: '*',    to: 'HRAdmin' }
    ])
    entity Departments as projection on app.Departments;


    @(restrict: [
        { grant: 'READ', to: ['Employee', 'HRAdmin'] },
        { grant: '*',    to: 'HRAdmin' }
    ])
    entity Positions as projection on app.Positions;


    @(restrict: [
        { grant: 'READ', to: ['Employee', 'HRAdmin'] },
        { grant: '*',    to: 'HRAdmin' }
    ])
    entity Skills as projection on app.Skills;


    @(restrict: [
        { grant: 'READ', to: ['Employee', 'HRAdmin'] },
        { grant: '*',    to: 'HRAdmin' }
    ])
    entity EmployeeSkills as projection on app.EmployeeSkills;

    // ============================================================
    // İŞE ALIM — JobPostings: herkes READ, HRAdmin FULL
    //             Candidates: sadece HRAdmin
    // ============================================================

    @cds.redirection.target
    @(restrict: [
        { grant: 'READ', to: ['Candidate', 'Employee', 'HRAdmin'] },
        { grant: '*',    to: 'HRAdmin' }
    ])
    entity JobPostings as projection on app.JobPostings;
    

    @readonly
    @(requires: ['Candidate', 'Employee', 'HRAdmin'])
    @(Capabilities: {
        InsertRestrictions.Insertable: false,
        UpdateRestrictions.Updatable:  false,
        DeleteRestrictions.Deletable:  false
    })
    entity PublicJobPostings as projection on app.JobPostings excluding { candidates } actions {
        action applyToJob(
            firstName : String(100),
            lastName  : String(100),
            email     : String(200),
            phone     : String(20), 
        ) returns String;
    };

    @cds.redirection.target
    @(restrict: [
        { grant: ['CREATE', 'READ', 'UPDATE'], to: ['Candidate', 'Employee'], where: 'createdBy = $user' },
        { grant: '*', to: 'HRAdmin' }
    ])
    //@odata.draft.enabled
    entity Candidates as projection on app.Candidates actions {
        action analyzeCV() returns String;
    };


    @(requires: 'HRAdmin')
    entity CVAnalysisResults as projection on app.CVAnalysisResults;

    // ============================================================
    // PERFORMANS — Sadece HRAdmin
    // ============================================================

    @(requires: 'HRAdmin')
    entity PerformanceReviews as projection on app.PerformanceReviews;

    @(requires: 'HRAdmin')
    entity Goals as projection on app.Goals;

    // ============================================================
    // ANKETLER — Sadece HRAdmin
    // ============================================================

    @(requires: 'HRAdmin')
    entity Surveys as projection on app.Surveys;

    @(requires: 'HRAdmin')
    entity SurveyResponses as projection on app.SurveyResponses;

    // ============================================================
    // AI & CHATBOT — Herkes erişebilir
    // ============================================================

    @(restrict: [
        { grant: '*', to: ['Candidate', 'Employee', 'HRAdmin'] }
    ])
    entity ChatMessages as projection on app.ChatMessages;

    @(requires: 'HRAdmin')
    entity AttritionRiskHistory as projection on app.AttritionRiskHistory;

    @(restrict: [
        { grant: 'READ', to: ['Candidate', 'Employee', 'HRAdmin'] },
        { grant: '*',    to: 'HRAdmin' }
    ])
    entity HRPolicies as projection on app.HRPolicies;


    @(restrict: [
        { grant: ['CREATE', 'READ', 'UPDATE'], to: 'Candidate', where: 'createdBy = $user' }
    ])
    @odata.draft.enabled
    entity MyApplications as projection on app.Candidates {
        key ID,
        firstName,
        lastName,
        email,
        phone,
        jobPosting,
        jobPosting.title as jobPosting_title,
        resumeFile,
        mediaType,
        fileName,
        applicationDate @readonly,
        status @readonly,
        createdBy
    };
    // ============================================================
    // CUSTOM ACTIONS (AI) — Rol bazlı erişim
    // ============================================================

    @(requires: 'HRAdmin')
    action calculateAttritionRisk(employeeId: UUID) returns String;

    @(requires: ['Candidate', 'Employee', 'HRAdmin'])
    action askHRBot(conversationId: String, question: String) returns String;

    @(requires: 'HRAdmin')
    action analyzeSurvey(surveyId: UUID) returns String;

    @(requires: 'HRAdmin')
    action uploadCVPDF(candidateId: UUID, pdfBase64: LargeString) returns String;

   type UserInfo {
        username: String;
        role: String;
    }
    @(requires: 'authenticated-user')
    function getMyUserInfo() returns UserInfo;

}
