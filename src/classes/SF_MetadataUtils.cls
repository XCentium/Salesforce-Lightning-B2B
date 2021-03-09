// This class combines Schema class for describe metadata and MetadataService calls to handle
// the creation of custom objects and fields
public with sharing class SF_MetadataUtils {
    
    public static Boolean objectExists(String objName){
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        return globalDescribe.containsKey(objName.toLowerCase());
    }

    public static Boolean fieldExists(String objName, String fieldName){
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        if(globalDescribe.containsKey(objName.toLowerCase())){
            Schema.sObjectType objType = globalDescribe.get(objName.toLowerCase());            
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{ objType.getDescribe().getName() });
            Schema.DescribeSObjectResult descResultItem = descResult[0];
            Map<String, Schema.SObjectField> fieldMap = descResultItem.fields.getMap();

            return fieldMap.containsKey(fieldName);
        }
        else {
            return false;
        }
    }

    public static List<String> getObjectsWithRulesAndOrWorkflows(List<String> objectsNames, Double apiVersion){
        List<String> listWithObjects = new List<String>();
        Set<String> objWithRulesOrWorkflows = new Set<String>();
        
        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryWorkflow = new MetadataService.ListMetadataQuery();
        queryWorkflow.type_x = 'WorkflowRule';
        queries.add(queryWorkflow);
        MetadataService.ListMetadataQuery queryValidationRule = new MetadataService.ListMetadataQuery();
        queryValidationRule.type_x = 'ValidationRule';
        queries.add(queryValidationRule);
        
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, apiVersion);        
        
        // If there are Workflow Rules and/or Validation Rules in the ORG...
        if(fileProperties != null){
            for(MetadataService.FileProperties fileProperty: fileProperties){
                objWithRulesOrWorkflows.add(fileProperty.fullName.substringBefore('.'));    
            }
    
            for(String obj: objectsNames){
                if(objWithRulesOrWorkflows.contains(obj)){
                    listWithObjects.add(obj);
                }
            }
        }
        
        return listWithObjects;
    }

    // Client passes the session id
    public static List<String> createObject(String objName, String sessionId){
        MetadataService.MetadataPort service = createService(sessionId);
        return SF_MetadataUtils.createObjectAux(objName, service);
    }

    // Current user's session id is used
    public static List<String> createObject(String objName){
        MetadataService.MetadataPort service = createService();
        return SF_MetadataUtils.createObjectAux(objName, service);
    }

    private static List<String> createObjectAux(String objName, MetadataService.MetadataPort service){
        
        List<String> errors = new List<String>();
        List<MetadataService.SaveResult> results;       
        MetadataService.CustomObject cObj = new MetadataService.CustomObject();

        cObj.fullName = objName.endsWith('__c') ? objName : objName + '__c';
        cObj.label = objName;
        cObj.pluralLabel = objName;
        cObj.nameField = new MetadataService.CustomField();
        cObj.nameField.type_x = 'AutoNumber';
        cObj.nameField.label = objName.replace('__c', '') + ' Name';
        cObj.deploymentStatus = 'Deployed';
        cObj.sharingModel = 'ReadWrite';

        results = service.createMetadata(
            new MetadataService.Metadata[] { cObj }
        );

        if(results == null || results.size() == 0 && !results.get(0).success){
            // Return error messages
            if(!System.Test.isRunningTest()){
                for(MetadataService.Error err : results.get(0).errors){
                    errors.add(err.message);
                }
            }
        }

        return errors;
    }

    public static List<String> createField(CustomFieldSpecification fieldSpec){
        MetadataService.MetadataPort service = createService();
        return SF_MetadataUtils.createFieldAux(fieldSpec, service);
    }

    public static List<String> createField(CustomFieldSpecification fieldSpec, String sessionId){
        MetadataService.MetadataPort service = createService(sessionId);
        return SF_MetadataUtils.createFieldAux(fieldSpec, service);
    }

    private static List<String> createFieldAux(CustomFieldSpecification fieldSpec, MetadataService.MetadataPort service){
        
        List<String> errors = new List<String>();
        if(fieldSpec.Name.endsWithIgnoreCase('__c')){
            List<MetadataService.UpsertResult> results;            
            MetadataService.CustomField cField = new MetadataService.CustomField();

            String objectName = fieldSpec.ObjectName;

            cField.externalId = fieldSpec.IsExternalId;
            cField.required = fieldSpec.IsRequired;

            // Default value
            cField.defaultValue = fieldSpec.DefaultValue;

            if(objectName.equalsIgnoreCase('Task') || objectName.equalsIgnoreCase('Event'))
            {
                // Special management for Activity fields
                cField.fullName = 'Activity.' + fieldSpec.Name;
                cField.label = fieldSpec.Label;
                cField.type_x = fieldSpec.Type;
            }
            else{
                cField.fullName = fieldSpec.ObjectName + '.' + fieldSpec.Name;
                cField.label = fieldSpec.Label;
                cField.type_x = fieldSpec.Type;
            }            
                       
            if(fieldSpec.Type.equalsIgnoreCase('Lookup') || fieldSpec.Type.equalsIgnoreCase('MasterDetail')){
                // Master-Detail or Lookup
                cField.referenceTo = fieldSpec.ReferenceTo;
                cField.relationshipName = fieldSpec.ObjectName.replace('__c', '') + 'Related';
                
                // Some fields must not be passed to Metadata API
                cField.defaultValue = null;
                cField.required = null;
                cField.externalId = null;
            }
            else if(fieldSpec.Type.equalsIgnoreCase('Checkbox')){
                // Checkbox
                cField.required = null;
                if(String.isBlank(cField.defaultValue)){
                    cField.defaultValue = 'false';
                }
            }
            else if(fieldSpec.Type.equalsIgnoreCase('Number') || fieldSpec.Type.equalsIgnoreCase('Currency') || fieldSpec.Type.equalsIgnoreCase('Percent')){
                cField.precision = fieldSpec.Precision;
                cField.scale = fieldSpec.Scale;
            }
            else if(fieldSpec.Type.equalsIgnoreCase('Text')){
                cField.length = fieldSpec.Length;
            }
            else if(fieldSpec.Type.equalsIgnoreCase('TextArea')){
                cField.length = fieldSpec.Length;
                cField.visibleLines = 3;
            }
            else if(fieldSpec.Type.equalsIgnoreCase('LongTextArea')){
                cField.length = fieldSpec.Length;
                cField.visibleLines = 3;
            }
            else if(fieldSpec.Type.equalsIgnoreCase('Picklist')){
                Metadataservice.Picklist picklist = new metadataservice.Picklist();
                picklist.sorted = false;

                List<String> pickListValues = fieldSpec.PickListValues.trim().split(',');
                List<Metadataservice.PicklistValue> allValues = new List<Metadataservice.PicklistValue>();

                for(String pValue: pickListValues){
                    Metadataservice.PicklistValue newValue = new metadataservice.PicklistValue();
                    newValue.fullName = pValue;
                    newValue.default_x = false;

                    allValues.add(newValue);
                }

                picklist.picklistValues = allValues;
                cField.pickList = picklist;
            }

            if(String.isNotBlank(fieldSpec.Formula)){
                cField.formula = fieldSpec.Formula;
                cField.length = 0;
            }

            // Field level security for Admin
            MetadataService.Profile admProfile = new MetadataService.Profile();
            admProfile.fullName = 'Admin';
            MetadataService.ProfileTabVisibility[] tvs = new MetadataService.ProfileTabVisibility[]{}; 
            admProfile.tabVisibilities = tvs;
            MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
            fieldSec.field = cField.fullName;
            fieldSec.editable=true;
            admProfile.FieldPermissions = new MetadataService.ProfileFieldLevelSecurity[] { fieldSec } ;

            // FLS for Analytics Cloud Integration User
            MetadataService.Profile aciuProfile = new MetadataService.Profile();
            aciuProfile.fullName = 'Analytics Cloud Integration User';
            MetadataService.ProfileTabVisibility[] aciuTvs = new MetadataService.ProfileTabVisibility[]{}; 
            aciuProfile.tabVisibilities = aciuTvs;
            MetadataService.ProfileFieldLevelSecurity aciuFLS = new MetadataService.ProfileFieldLevelSecurity();
            aciuFLS.field = cField.fullName;
            aciuFLS.editable=true;
            aciuProfile.FieldPermissions = new MetadataService.ProfileFieldLevelSecurity[] { aciuFLS } ;

            results = service.upsertMetadata(
                new MetadataService.Metadata[] { cField, admProfile, aciuProfile }
            );

            if(results == null || results.size() == 0 || !results.get(0).success){
                // Return error messages
                if(!System.Test.isRunningTest()){
                    for(MetadataService.Error err : results.get(0).errors){
                        errors.add(err.message);
                    }
                }   
            }
        }
        else {
            errors.add('Field creation ignored. Cannot create a standard field.');
        }

        return errors;
    }

    public static List<String> assignAccessToField(String objName, String fieldName, String sessionId){
        MetadataService.MetadataPort service = createService(sessionId);
        return SF_MetadataUtils.assignAccessToFieldAux(objName, fieldName, service);
    }
    
    public static List<String> assignAccessToField(String objName, String fieldName){
        MetadataService.MetadataPort service = createService();
        return SF_MetadataUtils.assignAccessToFieldAux(objName, fieldName, service);
    }

    public static List<String> assignAccessToFieldAux(String objName, String fieldName, MetadataService.MetadataPort service){

        List<String> errors = new List<String>();
        List<MetadataService.UpsertResult> results;
        String fieldFullName = '';

        if(objName.equalsIgnoreCase('Task') || objName.equalsIgnoreCase('Event'))
        {
            // Special management for Activity fields
            fieldFullName = 'Activity.' + fieldName;
        }
        else{
            fieldFullName = objName + '.' + fieldName;
        }

        // Field level security for Admin
        MetadataService.Profile admProfile = new MetadataService.Profile();
        admProfile.fullName = 'Admin';
        MetadataService.ProfileTabVisibility[] tvs = new MetadataService.ProfileTabVisibility[]{}; 
        admProfile.tabVisibilities = tvs;
        MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec.field = fieldFullName;
        fieldSec.editable=true;
        admProfile.FieldPermissions = new MetadataService.ProfileFieldLevelSecurity[] { fieldSec } ;

        // FLS for Analytics Cloud Integration User
        MetadataService.Profile aciuProfile = new MetadataService.Profile();
        aciuProfile.fullName = 'Analytics Cloud Integration User';
        MetadataService.ProfileTabVisibility[] aciuTvs = new MetadataService.ProfileTabVisibility[]{}; 
        aciuProfile.tabVisibilities = aciuTvs;
        MetadataService.ProfileFieldLevelSecurity aciuFLS = new MetadataService.ProfileFieldLevelSecurity();
        aciuFLS.field = fieldFullName;
        //aciuFLS.readable = true;
        aciuFLS.editable = true;
        aciuProfile.FieldPermissions = new MetadataService.ProfileFieldLevelSecurity[] { aciuFLS } ;

        results = service.upsertMetadata(
            new MetadataService.Metadata[] { admProfile, aciuProfile }
        );

        if(results == null || results.size() == 0 || !results.get(0).success){
            // Return error messages
            if(!System.Test.isRunningTest()){
                for(MetadataService.Error err : results.get(0).errors){
                    errors.add(err.message);
                }
            }   
        }

        return errors;
    }

    public static List<String> createRecordType(RecordTypeSpecification recordTypeSpec, String sessionId)
    {
        List<String> errors = new List<String>();
        List<MetadataService.UpsertResult> results;

        MetadataService.RecordType recordType = new MetadataService.RecordType();
        recordType.active = true;
        recordType.fullName = recordTypeSpec.ObjectName + '.' + recordTypeSpec.DeveloperName;
        recordType.label = recordTypeSpec.Name;
        recordType.businessProcess = recordTypeSpec.BusinessProcessName;
        recordType.description = recordTypeSpec.Description;

        MetadataService.MetadataPort service = createService(sessionId);
        
        results = service.upsertMetadata(
            new MetadataService.Metadata[] { recordType }
        );


        if(results == null || results.size() == 0 || !results.get(0).success){
            // Return error messages
            if(!System.Test.isRunningTest()){
                for(MetadataService.Error err : results.get(0).errors){
                    errors.add(err.message);
                }
            }   
        }

        return errors;
    }


    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.timeout_x = 120000;
        
        return service;
    }

    public static MetadataService.MetadataPort createService(String sessionId)
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        service.timeout_x = 120000;
        
        return service;
    }

    public static Boolean checkMetadataAPIConnection()
    {
        try {
            MetadataService.MetadataPort service = createService();
            List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
            remoteSites.type_x = 'RemoteSiteSetting';
            queries.add(remoteSites);
            service.listMetadata(queries, 28);
        } 
        catch (System.CalloutException e) {
            return false;
        }

        return true;
    }

    public class CustomFieldSpecification {
        public String ObjectName;
        public String Name;
        public String Label;
        public String Type;
        public String PickListValues;
        public String ReferenceTo;
        public Integer Length;
        public Integer Precision;
        public Integer Scale;
        public Boolean IsExternalId;
        public Boolean IsRequired;
        public String DefaultValue;
        public String Formula;
    }

    public class RecordTypeSpecification {
        public String ObjectName;
        public String DeveloperName;
        public String Name;
        public String Description;
        public String BusinessProcessName;
    }
}