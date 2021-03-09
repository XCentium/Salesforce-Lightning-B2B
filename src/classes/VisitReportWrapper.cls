public class VisitReportWrapper {
    
    //This Map contains list of all AssessmentIds and its Images.
    @AuraEnabled 
    public List<ContentDocumentLink> atImageMap{get;set;}
    @AuraEnabled 
    public List<AssessmentTask> assessmentList{get;set;}
    @AuraEnabled
    public Integer atCount{get;set;}
    @AuraEnabled 
    public Map<Id,String> rsgMap{get;set;}
    
}