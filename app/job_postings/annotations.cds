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

        // Liste Görünümü
        LineItem: [
            { Value: title, Label: 'İlan Başlığı' },
            { Value: status, Label: 'Durum' },
            { Value: openDate, Label: 'Açılış Tarihi' },
            { Value: closeDate, Label: 'Kapanış Tarihi' },
            { Value: vacancies, Label: 'Kontenjan' }
        ],

        // Detay Sayfası
        Facets: [
            {
                $Type: 'UI.ReferenceFacet',
                Label: 'İlan Detayları',
                Target: '@UI.FieldGroup#PostingInfo'
            }
        ],

        // "Başvur" butonu — İlan detay sayfasının üstünde görünür
        Identification: [
            {
                $Type:  'UI.DataFieldForAction',
                Action: 'HRService.PublicJobPostings.applyToJob',
                Label:  '📩 Bu İlana Başvur'
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