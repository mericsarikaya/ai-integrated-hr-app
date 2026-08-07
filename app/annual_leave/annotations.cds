using HRService as service from '../../srv/service';

annotate service.Annuals with @odata.draft.enabled;

annotate service.Annuals with {
    remainingLeaveDays @readonly @Common.Label: 'Kalan İzin Hakkı';
}

annotate service.Annuals with @(
    UI: {
        HeaderInfo: {
            TypeName: 'İzin',
            TypeNamePlural: 'İzinler',
            Title: { Value: employee.firstName},
            Description: { Value: employee.lastName}
        },
        HeaderFacets: [
            {
                $Type: 'UI.ReferenceFacet',
                Label: 'Kalan İzin Hakkı',
                Target: '@UI.FieldGroup#RemainingLeaveHeader'
            }
        ],
        SelectionFields: [ employee.firstName, employee.lastName],
        LineItem: [
            {Value: start_date, Label: 'Başlangıç Tarihi'},
            {Value: end_date, Label: 'Bitiş Tarihi'},
            {Value: approval, Label: 'Onay Durumu'},
            {Value: remainingLeaveDays, Label: 'Kalan İzin Hakkı', ![@UI.Importance]: #High},
            
            {
                $Type: 'UI.DataFieldForAction',
                Action: 'HRService.approveLeave',
                Label: 'Onayla'
            },
            {
                $Type: 'UI.DataFieldForAction',
                Action: 'HRService.rejectLeave',
                Label: 'Reddet'
            }
        ],
        Facets: [
            {
            $Type: 'UI.ReferenceFacet',
            Label: 'İzin Bilgileri',
            Target: '@UI.FieldGroup#AnnualInfo'
            }
        ],
        FieldGroup#AnnualInfo: {
            Data: [
                {Value: start_date, Label: 'Başlangıç Tarihi'},
                {Value: end_date, Label: 'Bitiş Tarihi'},
                {Value: description, Label: 'Açıklama'},
                {Value: remainingLeaveDays, Label: 'Kalan İzin Hakkı'}
            ]
        },
        FieldGroup#RemainingLeaveHeader: {
            Data: [
                {Value: remainingLeaveDays, Label: 'Kalan İzin Hakkı'}
            ]
        },
        
        Identification: [
            {
                $Type: 'UI.DataFieldForAction',
                Action: 'HRService.approveLeave',
                Label: 'Onayla'
            },
            {
                $Type: 'UI.DataFieldForAction',
                Action: 'HRService.rejectLeave',
                Label: 'Reddet'
            }
        ]
    }
);