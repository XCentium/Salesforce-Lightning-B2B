public with sharing class ApplicantPagedController {
    @AuraEnabled
    public Integer pageSize { get;set; }

    @AuraEnabled
    public Integer page { get;set; }

    @AuraEnabled
    public Integer total { get;set; }

    @AuraEnabled
    public List<HR_Applicant__c> applicants { get;set; }
}