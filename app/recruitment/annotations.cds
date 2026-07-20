using HRService as service from '../../srv/service';

annotate service.Candidates with @odata.draft.enabled;
annotate service.Employees with @odata.draft.enabled;

annotate service.Candidates with @(
    UI: {
        HeaderInfo: {
            TypeName: 'Aday',
            TypeNamePlural: 'Adaylar',
            Title: { Value: firstName },
            Description: { Value: lastName }
        },
        SelectionFields: [ status, jobPosting_ID ],
        LineItem: [
            { Value: firstName, Label: 'Ad' },
            { Value: lastName, Label: 'Soyad' },
            { Value: email, Label: 'Email' },
            { Value: jobPosting.title, Label: 'Başvurulan Pozisyon' },
            { Value: status, Label: 'Durum' }
        ],
        Facets: [
            {
                $Type: 'UI.ReferenceFacet',
                Label: 'Aday Bilgileri',
                Target: '@UI.FieldGroup#CandidateInfo'
            },
            {
                $Type: 'UI.ReferenceFacet',
                Label: 'Yapay Zeka (CV Analizi)',
                Target: 'cvAnalysis/@UI.FieldGroup#AIAnalysis'
            }
        ],
        FieldGroup#CandidateInfo: {
            Data: [
                { Value: firstName },
                { Value: lastName },
                { Value: email },
                { Value: phone },
                { Value: status },
                { Value: resumeFile, Label: 'CV Yükle (PDF)' }
            ]
        }
    }
);

annotate service.CVAnalysisResults with @(
    UI: {
        FieldGroup#AIAnalysis: {
            Data: [
                { Value: overallScore, Label: 'Genel Yapay Zeka Skoru' },
                { Value: skillMatchScore, Label: 'Beceri Eşleşmesi' },
                { Value: experienceScore, Label: 'Deneyim Puanı' },
                { Value: recommendation, Label: 'Nihai Karar (AI)' }
            ]
        }
    }
);