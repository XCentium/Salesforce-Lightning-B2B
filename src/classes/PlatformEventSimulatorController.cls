public class PlatformEventSimulatorController {
    
    @AuraEnabled
    public static void createEvent(sObject objValue) {
        insert objValue;      
    }
    
    @AuraEnabled
    public static void publishEvent(sObject eventValue) {
     	System.debug('Publishing Event  ' + eventValue);
        List<sObject> eventList = new List<sObject>();
        eventList.add(eventValue);
        
       List<Database.SaveResult> results = EventBus.publish(eventList);
        
        // Inspect publishing results
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error returned: ' +  error.getStatusCode() +' - '+  error.getMessage());
                }
            }
        }
       
         
    }
    
     @AuraEnabled
    public static void publishAndPersistEvent(sObject eventValue, sObject objValue) {
     	publishEvent(eventValue);
        insert objValue; 
    }

    @AuraEnabled
    public static List<String> getEventFields(String eventName) {
         System.debug('Event name ' + eventName);
        eventName = eventName.left(eventName.length()-3);
     
        
        List<FieldDefinition> fieldList = [Select DeveloperName, DataType, FieldDefinition.Publisher.isSalesforce From FieldDefinition where EntityDefinition.DeveloperName=: eventName ];
        System.debug(fieldList);
        
        List<String> fieldNames = new List<String>();
        for(FieldDefinition item: fieldList) {
            String name = item.DeveloperName ;
            Boolean isSalesforce =  item.Publisher.IsSalesforce;
            
            if(!isSalesforce && !item.DataType.contains('Lookup')) {
                fieldNames.add(name);
            }
        }
        
        return fieldNames;
    }

     @AuraEnabled
    public static String getLookupFieldName(String objectName, Id recordId) {
        
        if(objectName.contains('__c')) {
        	objectName = objectName.left(objectName.length()-3);
    	}
      
        Schema.SObjectType token = recordId.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
       
        String lookupObjectType =  dr.getName();
      System.debug('Object name ' + objectName  + ' ' + lookupObjectType);
      
     
        String lookupName = null;
        
        List<FieldDefinition> fieldList = [Select Label, QualifiedApiName , DataType, FieldDefinition.Publisher.isSalesforce From FieldDefinition where EntityDefinition.DeveloperName=: objectName ];
        
        List<String> fieldNames = new List<String>();
        for(FieldDefinition item: fieldList) {
            String name = item.QualifiedApiName ;
            Boolean isSalesforce =  item.Publisher.IsSalesforce;
            
            if(item.DataType.contains('Lookup') && item.DataType.contains(lookupObjectType)) {
            
              	lookupName = name;
               // break;
            }
        }
            
	//	lookupName = lookupName + '__c';

        return lookupName;
    }
    
}