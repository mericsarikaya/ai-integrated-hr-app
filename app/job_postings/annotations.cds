using HRService as service from '../../srv/service';

// Herkese Açık İş İlanları (Salt Okunur — Oluştur/Sil/Düzenle butonu YOK)
annotate service.PublicJobPostings with @(
    UI: {
        HeaderInfo: {
            TypeName: 'İş İlanı',
            TypeNamePlural: 'İş İlanları',
            Title: { Value: title },
            Description: { Value: status }
        },
        SelectionFields: [ status ],

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
                Target: '@UI.FieldGroup#PostingInfo'
            }
        ],

        FieldGroup#PostingInfo: {
            Data: [
                { Value: title, Label: 'İlan Başlığı' },
                { Value: description, Label: 'Genel Açıklama' },
                { Value: requirements, Label: 'Gereksinimler' },
                { Value: status, Label: 'Durum' },
                { Value: openDate, Label: 'Açılış Tarihi' },
                { Value: closeDate, Label: 'Kapanış Tarihi' },
                { Value: vacancies, Label: 'Alınacak Kişi Sayısı' }
            ]
        }
    }
);