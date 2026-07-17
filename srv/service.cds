using hr.app from '../db/schema';

service HRService @(path: '/hr') {

    // Çalışan Yönetimi
    entity Employees          as projection on app.Employees;
    entity Departments        as projection on app.Departments;
    entity Positions          as projection on app.Positions;
    entity Skills             as projection on app.Skills;
    entity EmployeeSkills     as projection on app.EmployeeSkills;

    // İşe Alım
    entity JobPostings        as projection on app.JobPostings;
    entity Candidates         as projection on app.Candidates;
    entity CVAnalysisResults  as projection on app.CVAnalysisResults;

    // Performans
    entity PerformanceReviews as projection on app.PerformanceReviews;
    entity Goals              as projection on app.Goals;

    // Anketler
    entity Surveys            as projection on app.Surveys;
    entity SurveyResponses    as projection on app.SurveyResponses;

    // AI & Chatbot
    entity ChatMessages       as projection on app.ChatMessages;
    entity AttritionRiskHistory as projection on app.AttritionRiskHistory;
    entity HRPolicies         as projection on app.HRPolicies;

    // --- Custom Actions (AI) ---
    action analyzeCV(candidateId: UUID)              returns String;
    action calculateAttritionRisk(employeeId: UUID)  returns String;
    action askHRBot(conversationId: String, question: String) returns String;
    action analyzeSurvey(surveyId: UUID)             returns String;
}