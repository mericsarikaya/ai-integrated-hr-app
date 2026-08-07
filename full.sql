
CREATE TABLE hr_app_Employees (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  employeeNumber NVARCHAR(10),
  userId NVARCHAR(100),
  firstName NVARCHAR(100),
  lastName NVARCHAR(100),
  email NVARCHAR(200),
  phone NVARCHAR(20),
  hireDate DATE_TEXT,
  birthDate DATE_TEXT,
  gender NVARCHAR(10),
  address NVARCHAR(500),
  profilePhoto NVARCHAR(500),
  salary REAL_DECIMAL(12, 2),
  status NVARCHAR(20) DEFAULT 'ACTIVE',
  department_ID NVARCHAR(36),
  position_ID NVARCHAR(36),
  manager_ID NVARCHAR(36),
  attritionRisk REAL_DECIMAL(5, 2) DEFAULT 0,
  riskLevel NVARCHAR(20),
  lastRiskCalcDate TIMESTAMP_TEXT,
  annual_days INTEGER,
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_Departments (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  name NVARCHAR(100),
  costCenter NVARCHAR(20),
  manager_ID NVARCHAR(36),
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_Positions (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  title NVARCHAR(150),
  description NVARCHAR(1000),
  level NVARCHAR(20),
  minSalary REAL_DECIMAL(12, 2),
  maxSalary REAL_DECIMAL(12, 2),
  isActive BOOLEAN DEFAULT TRUE,
  department_ID NVARCHAR(36),
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_JobPostings (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  title NVARCHAR(200),
  description NVARCHAR(5000),
  requirements NVARCHAR(5000),
  status NVARCHAR(20) DEFAULT 'OPEN',
  openDate DATE_TEXT,
  closeDate DATE_TEXT,
  vacancies INTEGER DEFAULT 1,
  position_ID NVARCHAR(36),
  department_ID NVARCHAR(36),
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_Candidates (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  firstName NVARCHAR(100),
  lastName NVARCHAR(100),
  email NVARCHAR(200),
  phone NVARCHAR(20),
  resumeFileName NVARCHAR(255),
  resumeText NCLOB,
  linkedinUrl NVARCHAR(500),
  applicationDate DATE_TEXT,
  status NVARCHAR(20) DEFAULT 'APPLIED',
  interviewDate TIMESTAMP_TEXT,
  interviewNotes NVARCHAR(2000),
  rejectionReason NVARCHAR(500),
  jobPosting_ID NVARCHAR(36),
  resumeFile BLOB,
  mediaType NVARCHAR(255),
  fileName NVARCHAR(255),
  userId NVARCHAR(100),
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_CVAnalysisResults (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  candidate_ID NVARCHAR(36),
  overallScore REAL_DECIMAL(5, 2),
  skillMatchScore REAL_DECIMAL(5, 2),
  experienceScore REAL_DECIMAL(5, 2),
  educationScore REAL_DECIMAL(5, 2),
  strengths NCLOB,
  weaknesses NCLOB,
  recommendation NVARCHAR(2000),
  rawResponse NCLOB,
  analyzedAt TIMESTAMP_TEXT,
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_EmployeeSkills (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  employee_ID NVARCHAR(36),
  skill_ID NVARCHAR(36),
  proficiency INTEGER,
  yearsOfExp REAL_DECIMAL(4, 1),
  certified BOOLEAN DEFAULT FALSE,
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_Skills (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  name NVARCHAR(100),
  category NVARCHAR(50),
  description NVARCHAR(500),
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_PerformanceReviews (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  employee_ID NVARCHAR(36),
  reviewer_ID NVARCHAR(36),
  period NVARCHAR(20),
  reviewDate DATE_TEXT,
  overallRating INTEGER,
  status NVARCHAR(20) DEFAULT 'DRAFT',
  strengths NVARCHAR(2000),
  areasToImprove NVARCHAR(2000),
  managerComments NVARCHAR(2000),
  employeeComments NVARCHAR(2000),
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_Goals (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  employee_ID NVARCHAR(36),
  review_ID NVARCHAR(36),
  title NVARCHAR(200),
  description NVARCHAR(1000),
  targetDate DATE_TEXT,
  status NVARCHAR(20) DEFAULT 'NOT_STARTED',
  weight REAL_DECIMAL(5, 2),
  progress INTEGER DEFAULT 0,
  managerRating INTEGER,
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_AttritionRiskHistory (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  employee_ID NVARCHAR(36),
  riskScore REAL_DECIMAL(5, 2),
  riskLevel NVARCHAR(20),
  topFactors NCLOB,
  suggestedActions NCLOB,
  calculatedAt TIMESTAMP_TEXT,
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_Annuals (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  employee_ID NVARCHAR(36),
  start_date DATE_TEXT,
  end_date DATE_TEXT,
  description NVARCHAR(200),
  approval NVARCHAR(20),
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_Surveys (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  title NVARCHAR(200),
  description NVARCHAR(1000),
  status NVARCHAR(20) DEFAULT 'DRAFT',
  startDate DATE_TEXT,
  endDate DATE_TEXT,
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_SurveyResponses (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  survey_ID NVARCHAR(36),
  employee_ID NVARCHAR(36),
  rating INTEGER,
  openEndedAnswer NCLOB,
  submittedAt TIMESTAMP_TEXT,
  sentiment NVARCHAR(20),
  sentimentScore REAL_DECIMAL(4, 2),
  themes NCLOB,
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_ChatMessages (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  conversationId NVARCHAR(50),
  employee_ID NVARCHAR(36),
  role NVARCHAR(10),
  content NCLOB,
  timestamp TIMESTAMP_TEXT,
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_HRPolicies (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  title NVARCHAR(200),
  category NVARCHAR(50),
  content NCLOB,
  keywords NVARCHAR(500),
  isActive BOOLEAN DEFAULT TRUE,
  PRIMARY KEY(ID)
);

CREATE TABLE hr_app_Passwords (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  authorizationPerson NVARCHAR(200),
  password NVARCHAR(200),
  authorizationLevel NVARCHAR(200),
  PRIMARY KEY(ID)
);

CREATE TABLE DRAFT_DraftAdministrativeData (
  DraftUUID NVARCHAR(36) NOT NULL,
  CreationDateTime TIMESTAMP_TEXT,
  CreatedByUser NVARCHAR(256),
  CreatedByUserDescription NVARCHAR(256),
  DraftIsCreatedByMe BOOLEAN,
  LastChangeDateTime TIMESTAMP_TEXT,
  LastChangedByUser NVARCHAR(256),
  LastChangedByUserDescription NVARCHAR(256),
  InProcessByUser NVARCHAR(256),
  InProcessByUserDescription NVARCHAR(256),
  DraftIsProcessedByMe BOOLEAN,
  DraftMessages NCLOB,
  PRIMARY KEY(DraftUUID)
);

CREATE TABLE HRService_Employees_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  employeeNumber NVARCHAR(10) NULL,
  userId NVARCHAR(100) NULL,
  firstName NVARCHAR(100) NULL,
  lastName NVARCHAR(100) NULL,
  email NVARCHAR(200) NULL,
  phone NVARCHAR(20) NULL,
  hireDate DATE_TEXT NULL,
  birthDate DATE_TEXT NULL,
  gender NVARCHAR(10) NULL,
  address NVARCHAR(500) NULL,
  profilePhoto NVARCHAR(500) NULL,
  salary REAL_DECIMAL(12, 2) NULL,
  status NVARCHAR(20) NULL DEFAULT 'ACTIVE',
  department_ID NVARCHAR(36) NULL,
  position_ID NVARCHAR(36) NULL,
  manager_ID NVARCHAR(36) NULL,
  attritionRisk REAL_DECIMAL(5, 2) NULL DEFAULT 0,
  riskLevel NVARCHAR(20) NULL,
  lastRiskCalcDate TIMESTAMP_TEXT NULL,
  annual_days INTEGER NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE HRService_EmployeeSkills_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  employee_ID NVARCHAR(36) NULL,
  skill_ID NVARCHAR(36) NULL,
  proficiency INTEGER NULL,
  yearsOfExp REAL_DECIMAL(4, 1) NULL,
  certified BOOLEAN NULL DEFAULT FALSE,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE HRService_PerformanceReviews_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  employee_ID NVARCHAR(36) NULL,
  reviewer_ID NVARCHAR(36) NULL,
  period NVARCHAR(20) NULL,
  reviewDate DATE_TEXT NULL,
  overallRating INTEGER NULL,
  status NVARCHAR(20) NULL DEFAULT 'DRAFT',
  strengths NVARCHAR(2000) NULL,
  areasToImprove NVARCHAR(2000) NULL,
  managerComments NVARCHAR(2000) NULL,
  employeeComments NVARCHAR(2000) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE HRService_Goals_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  employee_ID NVARCHAR(36) NULL,
  review_ID NVARCHAR(36) NULL,
  title NVARCHAR(200) NULL,
  description NVARCHAR(1000) NULL,
  targetDate DATE_TEXT NULL,
  status NVARCHAR(20) NULL DEFAULT 'NOT_STARTED',
  weight REAL_DECIMAL(5, 2) NULL,
  progress INTEGER NULL DEFAULT 0,
  managerRating INTEGER NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE HRService_AttritionRiskHistory_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  employee_ID NVARCHAR(36) NULL,
  riskScore REAL_DECIMAL(5, 2) NULL,
  riskLevel NVARCHAR(20) NULL,
  topFactors NCLOB NULL,
  suggestedActions NCLOB NULL,
  calculatedAt TIMESTAMP_TEXT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE HRService_JobPostings_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  title NVARCHAR(200) NULL,
  description NVARCHAR(5000) NULL,
  requirements NVARCHAR(5000) NULL,
  status NVARCHAR(20) NULL DEFAULT 'OPEN',
  openDate DATE_TEXT NULL,
  closeDate DATE_TEXT NULL,
  vacancies INTEGER NULL DEFAULT 1,
  position_ID NVARCHAR(36) NULL,
  department_ID NVARCHAR(36) NULL,
  applyLabel NVARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE HRService_Candidates_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  firstName NVARCHAR(100) NULL,
  lastName NVARCHAR(100) NULL,
  email NVARCHAR(200) NULL,
  phone NVARCHAR(20) NULL,
  resumeFileName NVARCHAR(255) NULL,
  resumeText NCLOB NULL,
  linkedinUrl NVARCHAR(500) NULL,
  applicationDate DATE_TEXT NULL,
  status NVARCHAR(20) NULL DEFAULT 'APPLIED',
  interviewDate TIMESTAMP_TEXT NULL,
  interviewNotes NVARCHAR(2000) NULL,
  rejectionReason NVARCHAR(500) NULL,
  jobPosting_ID NVARCHAR(36) NULL,
  resumeFile BLOB NULL,
  mediaType NVARCHAR(255) NULL,
  fileName NVARCHAR(255) NULL,
  userId NVARCHAR(100) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE HRService_CVAnalysisResults_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  candidate_ID NVARCHAR(36) NULL,
  overallScore REAL_DECIMAL(5, 2) NULL,
  skillMatchScore REAL_DECIMAL(5, 2) NULL,
  experienceScore REAL_DECIMAL(5, 2) NULL,
  educationScore REAL_DECIMAL(5, 2) NULL,
  strengths NCLOB NULL,
  weaknesses NCLOB NULL,
  recommendation NVARCHAR(2000) NULL,
  rawResponse NCLOB NULL,
  analyzedAt TIMESTAMP_TEXT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE HRService_Annuals_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  employee_ID NVARCHAR(36) NULL,
  start_date DATE_TEXT NULL,
  end_date DATE_TEXT NULL,
  description NVARCHAR(200) NULL,
  approval NVARCHAR(20) NULL,
  employeeFullName NVARCHAR(255) NULL,
  remainingLeaveDays INTEGER NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE HRService_MyApplications_drafts (
  ID NVARCHAR(36) NOT NULL,
  firstName NVARCHAR(100) NULL,
  lastName NVARCHAR(100) NULL,
  email NVARCHAR(200) NULL,
  phone NVARCHAR(20) NULL,
  jobPosting_ID NVARCHAR(36) NULL,
  resumeFile BLOB NULL,
  mediaType NVARCHAR(255) NULL,
  fileName NVARCHAR(255) NULL,
  createdAt TIMESTAMP_TEXT NULL,
  status NVARCHAR(20) NULL DEFAULT 'APPLIED',
  createdBy NVARCHAR(255) NULL,
  userId NVARCHAR(100) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE VIEW HRService_Employees AS SELECT
  Employees_0.ID,
  Employees_0.createdAt,
  Employees_0.createdBy,
  Employees_0.modifiedAt,
  Employees_0.modifiedBy,
  Employees_0.employeeNumber,
  Employees_0.userId,
  Employees_0.firstName,
  Employees_0.lastName,
  Employees_0.email,
  Employees_0.phone,
  Employees_0.hireDate,
  Employees_0.birthDate,
  Employees_0.gender,
  Employees_0.address,
  Employees_0.profilePhoto,
  Employees_0.salary,
  Employees_0.status,
  Employees_0.department_ID,
  Employees_0.position_ID,
  Employees_0.manager_ID,
  Employees_0.attritionRisk,
  Employees_0.riskLevel,
  Employees_0.lastRiskCalcDate,
  Employees_0.annual_days
FROM hr_app_Employees AS Employees_0;

CREATE VIEW HRService_Departments AS SELECT
  Departments_0.ID,
  Departments_0.createdAt,
  Departments_0.createdBy,
  Departments_0.modifiedAt,
  Departments_0.modifiedBy,
  Departments_0.name,
  Departments_0.costCenter,
  Departments_0.manager_ID
FROM hr_app_Departments AS Departments_0;

CREATE VIEW HRService_Positions AS SELECT
  Positions_0.ID,
  Positions_0.createdAt,
  Positions_0.createdBy,
  Positions_0.modifiedAt,
  Positions_0.modifiedBy,
  Positions_0.title,
  Positions_0.description,
  Positions_0.level,
  Positions_0.minSalary,
  Positions_0.maxSalary,
  Positions_0.isActive,
  Positions_0.department_ID
FROM hr_app_Positions AS Positions_0;

CREATE VIEW HRService_JobPostings AS SELECT
  JobPostings_0.ID,
  JobPostings_0.createdAt,
  JobPostings_0.createdBy,
  JobPostings_0.modifiedAt,
  JobPostings_0.modifiedBy,
  JobPostings_0.title,
  JobPostings_0.description,
  JobPostings_0.requirements,
  JobPostings_0.status,
  JobPostings_0.openDate,
  JobPostings_0.closeDate,
  JobPostings_0.vacancies,
  JobPostings_0.position_ID,
  JobPostings_0.department_ID,
  'İlana Başvur' AS applyLabel
FROM hr_app_JobPostings AS JobPostings_0;

CREATE VIEW HRService_Candidates AS SELECT
  Candidates_0.ID,
  Candidates_0.createdAt,
  Candidates_0.createdBy,
  Candidates_0.modifiedAt,
  Candidates_0.modifiedBy,
  Candidates_0.firstName,
  Candidates_0.lastName,
  Candidates_0.email,
  Candidates_0.phone,
  Candidates_0.resumeFileName,
  Candidates_0.resumeText,
  Candidates_0.linkedinUrl,
  Candidates_0.applicationDate,
  Candidates_0.status,
  Candidates_0.interviewDate,
  Candidates_0.interviewNotes,
  Candidates_0.rejectionReason,
  Candidates_0.jobPosting_ID,
  Candidates_0.resumeFile,
  Candidates_0.mediaType,
  Candidates_0.fileName,
  Candidates_0.userId
FROM hr_app_Candidates AS Candidates_0;

CREATE VIEW HRService_CVAnalysisResults AS SELECT
  CVAnalysisResults_0.ID,
  CVAnalysisResults_0.createdAt,
  CVAnalysisResults_0.createdBy,
  CVAnalysisResults_0.modifiedAt,
  CVAnalysisResults_0.modifiedBy,
  CVAnalysisResults_0.candidate_ID,
  CVAnalysisResults_0.overallScore,
  CVAnalysisResults_0.skillMatchScore,
  CVAnalysisResults_0.experienceScore,
  CVAnalysisResults_0.educationScore,
  CVAnalysisResults_0.strengths,
  CVAnalysisResults_0.weaknesses,
  CVAnalysisResults_0.recommendation,
  CVAnalysisResults_0.rawResponse,
  CVAnalysisResults_0.analyzedAt
FROM hr_app_CVAnalysisResults AS CVAnalysisResults_0;

CREATE VIEW HRService_EmployeeSkills AS SELECT
  EmployeeSkills_0.ID,
  EmployeeSkills_0.createdAt,
  EmployeeSkills_0.createdBy,
  EmployeeSkills_0.modifiedAt,
  EmployeeSkills_0.modifiedBy,
  EmployeeSkills_0.employee_ID,
  EmployeeSkills_0.skill_ID,
  EmployeeSkills_0.proficiency,
  EmployeeSkills_0.yearsOfExp,
  EmployeeSkills_0.certified
FROM hr_app_EmployeeSkills AS EmployeeSkills_0;

CREATE VIEW HRService_Skills AS SELECT
  Skills_0.ID,
  Skills_0.createdAt,
  Skills_0.createdBy,
  Skills_0.modifiedAt,
  Skills_0.modifiedBy,
  Skills_0.name,
  Skills_0.category,
  Skills_0.description
FROM hr_app_Skills AS Skills_0;

CREATE VIEW HRService_PerformanceReviews AS SELECT
  PerformanceReviews_0.ID,
  PerformanceReviews_0.createdAt,
  PerformanceReviews_0.createdBy,
  PerformanceReviews_0.modifiedAt,
  PerformanceReviews_0.modifiedBy,
  PerformanceReviews_0.employee_ID,
  PerformanceReviews_0.reviewer_ID,
  PerformanceReviews_0.period,
  PerformanceReviews_0.reviewDate,
  PerformanceReviews_0.overallRating,
  PerformanceReviews_0.status,
  PerformanceReviews_0.strengths,
  PerformanceReviews_0.areasToImprove,
  PerformanceReviews_0.managerComments,
  PerformanceReviews_0.employeeComments
FROM hr_app_PerformanceReviews AS PerformanceReviews_0;

CREATE VIEW HRService_Goals AS SELECT
  Goals_0.ID,
  Goals_0.createdAt,
  Goals_0.createdBy,
  Goals_0.modifiedAt,
  Goals_0.modifiedBy,
  Goals_0.employee_ID,
  Goals_0.review_ID,
  Goals_0.title,
  Goals_0.description,
  Goals_0.targetDate,
  Goals_0.status,
  Goals_0.weight,
  Goals_0.progress,
  Goals_0.managerRating
FROM hr_app_Goals AS Goals_0;

CREATE VIEW HRService_AttritionRiskHistory AS SELECT
  AttritionRiskHistory_0.ID,
  AttritionRiskHistory_0.createdAt,
  AttritionRiskHistory_0.createdBy,
  AttritionRiskHistory_0.modifiedAt,
  AttritionRiskHistory_0.modifiedBy,
  AttritionRiskHistory_0.employee_ID,
  AttritionRiskHistory_0.riskScore,
  AttritionRiskHistory_0.riskLevel,
  AttritionRiskHistory_0.topFactors,
  AttritionRiskHistory_0.suggestedActions,
  AttritionRiskHistory_0.calculatedAt
FROM hr_app_AttritionRiskHistory AS AttritionRiskHistory_0;

CREATE VIEW HRService_Annuals AS SELECT
  Annuals_0.ID,
  Annuals_0.createdAt,
  Annuals_0.createdBy,
  Annuals_0.modifiedAt,
  Annuals_0.modifiedBy,
  Annuals_0.employee_ID,
  Annuals_0.start_date,
  Annuals_0.end_date,
  Annuals_0.description,
  Annuals_0.approval,
  employee_1.firstName || ' ' || employee_1.lastName AS employeeFullName,
  employee_1.annual_days AS remainingLeaveDays
FROM (hr_app_Annuals AS Annuals_0 LEFT JOIN hr_app_Employees AS employee_1 ON Annuals_0.employee_ID = employee_1.ID);

CREATE VIEW HRService_PublicJobPostings AS SELECT
  JobPostings_0.ID,
  JobPostings_0.createdAt,
  JobPostings_0.createdBy,
  JobPostings_0.modifiedAt,
  JobPostings_0.modifiedBy,
  JobPostings_0.title,
  JobPostings_0.description,
  JobPostings_0.requirements,
  JobPostings_0.status,
  JobPostings_0.openDate,
  JobPostings_0.closeDate,
  JobPostings_0.vacancies,
  JobPostings_0.position_ID,
  JobPostings_0.department_ID
FROM hr_app_JobPostings AS JobPostings_0;

CREATE VIEW HRService_Surveys AS SELECT
  Surveys_0.ID,
  Surveys_0.createdAt,
  Surveys_0.createdBy,
  Surveys_0.modifiedAt,
  Surveys_0.modifiedBy,
  Surveys_0.title,
  Surveys_0.description,
  Surveys_0.status,
  Surveys_0.startDate,
  Surveys_0.endDate
FROM hr_app_Surveys AS Surveys_0;

CREATE VIEW HRService_SurveyResponses AS SELECT
  SurveyResponses_0.ID,
  SurveyResponses_0.createdAt,
  SurveyResponses_0.createdBy,
  SurveyResponses_0.modifiedAt,
  SurveyResponses_0.modifiedBy,
  SurveyResponses_0.survey_ID,
  SurveyResponses_0.employee_ID,
  SurveyResponses_0.rating,
  SurveyResponses_0.openEndedAnswer,
  SurveyResponses_0.submittedAt,
  SurveyResponses_0.sentiment,
  SurveyResponses_0.sentimentScore,
  SurveyResponses_0.themes
FROM hr_app_SurveyResponses AS SurveyResponses_0;

CREATE VIEW HRService_ChatMessages AS SELECT
  ChatMessages_0.ID,
  ChatMessages_0.createdAt,
  ChatMessages_0.createdBy,
  ChatMessages_0.modifiedAt,
  ChatMessages_0.modifiedBy,
  ChatMessages_0.conversationId,
  ChatMessages_0.employee_ID,
  ChatMessages_0.role,
  ChatMessages_0.content,
  ChatMessages_0.timestamp
FROM hr_app_ChatMessages AS ChatMessages_0;

CREATE VIEW HRService_HRPolicies AS SELECT
  HRPolicies_0.ID,
  HRPolicies_0.createdAt,
  HRPolicies_0.createdBy,
  HRPolicies_0.modifiedAt,
  HRPolicies_0.modifiedBy,
  HRPolicies_0.title,
  HRPolicies_0.category,
  HRPolicies_0.content,
  HRPolicies_0.keywords,
  HRPolicies_0.isActive
FROM hr_app_HRPolicies AS HRPolicies_0;

CREATE VIEW HRService_MyApplications AS SELECT
  Candidates_0.ID,
  Candidates_0.firstName,
  Candidates_0.lastName,
  Candidates_0.email,
  Candidates_0.phone,
  Candidates_0.jobPosting_ID,
  Candidates_0.resumeFile,
  Candidates_0.mediaType,
  Candidates_0.fileName,
  Candidates_0.createdAt,
  Candidates_0.status,
  Candidates_0.createdBy,
  Candidates_0.userId
FROM hr_app_Candidates AS Candidates_0;

CREATE VIEW HRService_DraftAdministrativeData AS SELECT
  DraftAdministrativeData.DraftUUID,
  DraftAdministrativeData.CreationDateTime,
  DraftAdministrativeData.CreatedByUser,
  DraftAdministrativeData.CreatedByUserDescription,
  DraftAdministrativeData.DraftIsCreatedByMe,
  DraftAdministrativeData.LastChangeDateTime,
  DraftAdministrativeData.LastChangedByUser,
  DraftAdministrativeData.LastChangedByUserDescription,
  DraftAdministrativeData.InProcessByUser,
  DraftAdministrativeData.InProcessByUserDescription,
  DraftAdministrativeData.DraftIsProcessedByMe,
  DraftAdministrativeData.DraftMessages
FROM DRAFT_DraftAdministrativeData AS DraftAdministrativeData;

