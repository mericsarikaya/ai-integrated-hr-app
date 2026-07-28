
using { cuid, managed } from '@sap/cds/common';
entity JobPostings : cuid {
    title : String;
}
entity Candidates : cuid, managed {
    firstName : String;
    jobPosting_ID : UUID;
    jobPosting : Association to JobPostings;
}
