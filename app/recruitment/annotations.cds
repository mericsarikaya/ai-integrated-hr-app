using HRService as service from '../../srv/service';

annotate service.Candidates with @odata.draft.enabled;
annotate service.Employees with @odata.draft.enabled;
annotate service.JobPostings with @odata.draft.enabled;


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
        Identification: [
            {
                $Type: 'UI.DataFieldForAction',
                Action: 'HRService.Candidates.analyzeCV',
                Label: '🧠 Yapay Zekaya CV Analiz Ettir'
            }
        ],
        FieldGroup#CandidateInfo: {
            Data: [
                { Value: firstName, Label: 'Ad' },
                { Value: lastName, Label: 'Soyad' },
                { Value: email, Label: 'Email' },
                { Value: phone, Label: 'Telefon' },
                { Value: status, Label: 'Durum' },
                { Value: jobPosting.title, Label: 'Başvurulan Pozisyon' },
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

// İK İŞ İLANI YÖNETİMİ (Tam Yetki: Oluştur / Düzenle / Sil)
annotate service.JobPostings with @(
    UI: {
        HeaderInfo: {
            TypeName: 'İş İlanı',
            TypeNamePlural: 'İş İlanları',
            Title: { Value: title },
            Description: { Value: status }
        },
        SelectionFields: [ status, department_ID, position_ID ],
        LineItem: [
            { Value: title, Label: 'İlan Başlığı' },
            { Value: status, Label: 'Durum' },
            { Value: openDate, Label: 'Açılış Tarihi' },
            { Value: closeDate, Label: 'Kapanış Tarihi' },
            { Value: vacancies, Label: 'Kontenjan' }
        ],
        Facets: [
            {
                $Type: 'UI.ReferenceFacet',
                Label: 'İlan Detayları',
                Target: '@UI.FieldGroup#AdminPostingInfo'
            },
            {
                $Type: 'UI.ReferenceFacet',
                Label: 'Bu İlana Gelen Başvurular',
                Target: 'candidates/@UI.LineItem'
            }
        ],
        FieldGroup#AdminPostingInfo: {
            Data: [
                { Value: title, Label: 'İlan Başlığı' },
                { Value: description, Label: 'Genel Açıklama' },
                { Value: requirements, Label: 'Gereksinimler' },
                { Value: status, Label: 'Durum' },
                { Value: openDate, Label: 'Açılış Tarihi' },
                { Value: closeDate, Label: 'Kapanış Tarihi' },
                { Value: vacancies, Label: 'Alınacak Kişi Sayısı' },
                { Value: department_ID, Label: 'Departman' },
                { Value: position_ID, Label: 'Pozisyon' }
            ]
        }
    }
);

annotate service.JobPostings {
    department @(Common.ValueList: {
        CollectionPath: 'Departments',
        Label: 'Departman',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: department_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
        ]
    });
    position @(Common.ValueList: {
        CollectionPath: 'Positions',
        Label: 'Pozisyon',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: position_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'title' }
        ]
    });
};

