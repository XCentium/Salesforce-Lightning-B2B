public with sharing class DE_CasePinnedList {
    private final Case oCase;  

    // The constructor passes in the standard controller defined 
    
    // in the markup below 
    
    public DE_CasePinnedList(ApexPages.StandardSetController controller) {
        this.oCase = (Case)controller.getRecord(); 
    }    
    
    public ApexPages.StandardSetController caseRecords {
        get {
            if(caseRecords == null) {
            System.debug('Querying for leads ...');
                caseRecords = new ApexPages.StandardSetController(
                    Database.getQueryLocator([
//                        SELECT Id,Name,Phone,Lead_Rank__c,Status,LeadSource,LastModifiedDate,Company, RecordType.DeveloperName, RecordType.Name
                        SELECT Id,CaseNumber,Channel__c,Subject,Status,Priority,Status_Indicator__c,LastModifiedDate,Account.Name

                        FROM Case
                        ORDER BY CaseNumber DESC

                    ]));
            } else {
            System.debug('Already have leads.');
            }
            return caseRecords;
        }
        private set;
    }
    public List<Case> getDE_CasePinnedList() {
         return (List<Case>) caseRecords.getRecords();
    }  
}