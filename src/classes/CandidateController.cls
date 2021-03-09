public with sharing class CandidateController {

    @AuraEnabled
    public static ApplicantPagedController findAll(Decimal pageNumber) {
        Integer pageSize = 10;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        
        ApplicantPagedController r =  new ApplicantPagedController();

        r.pageSize = pageSize;

        r.page = (Integer) pageNumber;

        r.total = [SELECT count() FROM HR_Applicant__c 
                      WHERE HR_Headshot_Url__c != null];

        r.applicants = [SELECT Id, Name, HR_Mobile_Phone__c, HR_Mailing_City__c, HR_Mailing_State__c, HR_Headshot_Url__c FROM HR_Applicant__c
                      WHERE HR_Headshot_Url__c != null];

        System.debug('r.applicants returns == ' +r);

        return r;
    }

}