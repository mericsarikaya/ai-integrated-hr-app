using HRService as service from '../../srv/service';

annotate service.Employees with @(
    UI: {
        HeaderInfo: {
            TypeName: 'Çalışan',
            TypeNamePlural: 'Çalışanlar',
            Title: { Value: firstName },
            Description: { Value: lastName }
        },
        SelectionFields: [ department_ID, status, attritionRisk ],
        LineItem: [
            { Value: ID, Label: 'Sicil No' },
            { Value: firstName, Label: 'Ad' },
            { Value: lastName, Label: 'Soyad' },
            { Value: department.name, Label: 'Departman' },
            { Value: position.title, Label: 'Pozisyon' },
            { Value: status, Label: 'Durum' },
            { Value: attritionRisk, Label: 'Ayrılma Riski Skoru (AI)' }
        ],
        Facets: [
            {
                $Type: 'UI.CollectionFacet',
                Label: 'Çalışan Bilgileri',
                Facets: [
                    {
                        $Type: 'UI.ReferenceFacet',
                        Label: 'Kişisel Bilgiler',
                        Target: '@UI.FieldGroup#Personal'
                    },
                    {
                        $Type: 'UI.ReferenceFacet',
                        Label: 'İstihdam Bilgileri',
                        Target: '@UI.FieldGroup#Employment'
                    },
                    {
                        $Type: 'UI.ReferenceFacet',
                        Label: 'İşe Alım Bilgileri',
                        Target: '@UI.FieldGroup#Hire'
                    }
                ]
            }
        ],
        FieldGroup#Personal: {
            Data: [
                { Value: firstName, Label: 'Ad' },
                { Value: lastName, Label: 'Soyad' },
                { Value: email, Label: 'Email' },
                { Value: phone, Label: 'Telefon' }
            ]
        },
        FieldGroup#Employment: {
            Data: [
                { Value: department_ID, Label: 'Departman ID' },
                { Value: position_ID, Label: 'Posizyon ID' },
                { Value: hireDate, Label: 'İşe Giriş Tarihi' },
                { Value: status, Label: 'Durum' },
                { Value: attritionRisk, Label: 'Yapay Zeka Risk Skoru' }
            ]
        },
        FieldGroup#Hire: {
            Data: [
                { Value: department_ID },
                { Value: position_ID },
                { Value: hireDate },
                { Value: status },
                { Value: attritionRisk, Label: 'Yapay Zeka Risk Skoru' }
            ]
        }
    }
);