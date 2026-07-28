
using { Candidates, JobPostings } from './test_schema';
service HRService {
    entity MyApplications as projection on Candidates {
        key ID,
        firstName,
        jobPosting_ID,
        jobPosting
    };
    annotate MyApplications with {
        jobPosting_ID @(
            Common.ValueListWithFixedValues: true,
            Common.ValueList: {
                CollectionPath: 'JobPostings',
                Parameters: [
                    { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: jobPosting_ID, ValueListProperty: 'ID' }
                ]
            }
        );
    };
}
