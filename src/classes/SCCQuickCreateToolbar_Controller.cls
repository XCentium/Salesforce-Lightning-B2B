public with sharing class SCCQuickCreateToolbar_Controller {

    // The record Id in context. This is passed in when exposed as a Console Component
    public String currRecordId {get; set;}

    // The type of object that is currently in context
    public String currObjectType {
        get {
            if (currRecordId != null && currObjectType == null) {
                // Get the key prefix from the id
                String currKeyPrefix = ((String)currRecordId).substring(0, 3);
    
                // Get the record type
                Schema.sObjectType currsObjectType = sObjectByKeyPrefix.get(currKeyPrefix);
                
                currObjectType =  currsObjectType.getDescribe().getName();
            }
            return currObjectType;
        }
        set;
    }

    // sObject representing the current record
    public sObject currRecord {
        get {
            if (currRecord == null && currRecordId!= null) {
                // Support for contacts - uncomment to use
                
                if (currObjectType == 'Contact') {
                    currRecord = Database.query('SELECT ID, AccountId, Name from Contact where id = \'' + currRecordId + '\'');     
                }
                else 
                if (currObjectType!= null) {
                    currRecord = Database.query('SELECT ID, NAME from ' + currObjectType + ' where id = \'' + currRecordId + '\'');
                }
            }
            return currRecord;
        }
        private set;
    }
    

    // List of the available record types for the user
    public List<SelectOption> caseRecordTypes {
        get {
            if (caseRecordTypes!= null) return caseRecordTypes;
        
            // Use dynamic Apex to generate a select list of Record Ids + Name
            Map<Id,Schema.RecordTypeInfo> caseRTMapById = Schema.SObjectType.Case.getRecordTypeInfosById();

            caseRecordTypes = new List<SelectOption>();
            caseRecordTypes.add(new SelectOption('', 'Select One...'));
                
            // Format the select list in case record type name order
            for (RecordType recType: [Select id, Name, DeveloperName, SobjectType from RecordType where SobjectType = 'Case' order by Name]) {
                // Get the schema info for the record type using the record type id
                Schema.RecordTypeInfo caseRT = caseRTMapById.get(recType.id);

                // the record type is available to the logged in user
                // Exclude the Master record type as it shouldn't be visible
                if (caseRT.isAvailable() && caseRT.getName()!= 'Master') { 
                    caseRecordTypes.add(new SelectOption(caseRT.getRecordTypeId(), caseRT.getName()));
                }
            }
            return caseRecordTypes; 
        }
        private set;
    }

    // Generate the URL to open the new subtab in
    public String caseCreateURLPrefix{
        get{
            if(caseCreateURLPrefix == null){
                // Use a page reference to generate the URL
                
                // Prefix to create the case (/500/e)
                PageReference pageRef = new PageReference('/' + Case.sObjectType.getDescribe().getKeyPrefix() + '/e');
                pageRef.getParameters().put('isdtp','vw');
                // return URL
                //pageRef.getParameters().put('retURL','/' + currRecordId );
                
                // add context (e.g. the current account)
                if(currObjectType == 'Account'){
                    pageRef.getParameters().put('def_account_id', currRecordId);
                }
                
                // add context for contacts (uncomment to make it work)
                 else if (currObjectType == 'Contact') {
                    pageRef.getParameters().put('def_contact_id', currRecordId);
                    pageRef.getParameters().put('def_account_id', ((Contact) currRecord).accountid ); // cast the sObject to contact
                }

                // additional parameters to make the URL work properly
                pageRef.getParameters().put('ent', Case.sObjectType.getDescribe().getName());
                caseCreateURLPrefix = pageRef.getURL();
            }
            
            return caseCreateURLPrefix;
        }
        private set;
    }

    // Map of sObject Types by their key prefix
    private static Map<String, Schema.sObjectType> sObjectByKeyPrefix {
        get {
            if (sObjectByKeyPrefix == null) {
                sObjectByKeyPrefix = new Map<String, Schema.sObjectType>();
                for (Schema.SObjectType sObj: Schema.getGlobalDescribe().values()) {
                    sObjectByKeyPrefix.put(sObj.getDescribe().getKeyPrefix(), sObj);
                }
            }
            return sObjectByKeyPrefix;
        }
        
        private set;
    }    

    
    // Constructor
    public SCCQuickCreateToolbar_Controller () {
        // Get the current record Id
        currRecordId = ApexPages.currentPage().getParameters().get('Id');
    }
    
    private static TestMethod void TestMe() {
        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        // create the VF page and put the id parameter in it
        PageReference pref = Page.SCCQuickCreateToolbar;
        Test.setCurrentPage(New PageReference('Page.SCCQuickCreateToolbar'));
        System.currentPageReference().getParameters().put('id', account.id);

        SCCQuickCreateToolbar_Controller con1 = new SCCQuickCreateToolbar_Controller ();
        
        // check that all is OK
        System.assertEquals(con1.currRecordId, account.id);
        System.assertEquals(con1.currObjectType, 'Account');
        System.assertEquals(con1.caseCreateURLPrefix, '/500/e?def_account_id=' + account.id + '&ent=Case&isdtp=vw');
        System.assert(con1.caseRecordTypes!= null);
        System.assert(((Account)con1.currRecord).id == account.id);
        
    }

}