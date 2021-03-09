public with sharing class DE_LeadPinnedList {
    private final Lead oLead;  

    // The constructor passes in the standard controller defined 
    
    // in the markup below 
    
    public DE_LeadPinnedList(ApexPages.StandardSetController controller) {
        this.oLead = (Lead)controller.getRecord(); 
    }    
    
    public ApexPages.StandardSetController leadRecords {
        get {
            if(leadRecords == null) {
            System.debug('Querying for leads ...');
                leadRecords = new ApexPages.StandardSetController(
                    Database.getQueryLocator([
//                        SELECT Id,Name,Phone,Lead_Rank__c,Status,LeadSource,LastModifiedDate,Company, RecordType.DeveloperName, RecordType.Name
                        SELECT Id,Name,LastName, Phone,Lead_Rank__c,Lead_Quality__c,Status,LeadSource,LastModifiedDate,Company
                        FROM Lead
                        WHERE isConverted=False
                        ORDER BY LastName ASC 

                    ]));
            } else {
            System.debug('Already have leads.');
            }
            return leadRecords;
        }
        private set;
    }
    public List<Lead> getDE_LeadPinnedList() {
         return (List<Lead>) leadRecords.getRecords();
    }  
}