public class PlatformEventsChartController {

    @AuraEnabled
	public static String getSessionId() {
 	 return UserInfo.getSessionId();
	} 

  /*     @AuraEnabled
    public static List<FieldDefinition> getEventFields(String eventName) {
      
          System.debug('Event name ' + eventName);

        eventName = eventName.left(eventName.length()-3);
         List<FieldDefinition> fieldList = [Select Label, DeveloperName, DataType, FieldDefinition.Publisher.isSalesforce From FieldDefinition where EntityDefinition.DeveloperName=: eventName ];
    
        System.debug(fieldList);
        
        List<FieldDefinition> fieldNames = new List<FieldDefinition>();
        for(FieldDefinition item: fieldList) {
            FieldDefinition name = item;
            Boolean isSalesforce =  item.Publisher.IsSalesforce;
            
			System.debug(item.DataType);

            System.debug('Field Type ' + item.DataType);
            
            if(!isSalesforce && !item.DataType.contains('Lookup') &&  (item.DataType.contains('Number') || item.DataType.contains('Percent')  || item.DataType.contains('Currency')   ) ) {
                fieldNames.add(name);
            }
        }
        
        return fieldNames;
    }
    
   @AuraEnabled
    public static List<Object> getEventData(String fieldName, String objectName,  String recordId) {
     	
        System.debug('Field Name' + fieldName);
         
        //this was written just so we could write a test class avoiding a custom field 
       String lookupFieldName = PlatformEventSimulatorController.getLookupFieldName(objectName, recordId);
        
         System.debug('Lookup Name ' + lookupFieldName);
       
         List<sObject> sobjList = Database.query('Select CreatedDate, ' + fieldName + ' from ' + objectName + ' where ' + lookupFieldName + '= \'' + recordId + '\' order by CreatedDate ASC limit 100');
        return sobjList;
    }*/
        public class eventDatum{
        public string eventName;
        public string eventLabel;
        public string[] fields;
        public string[] fieldLabels;
        eventDatum(string eventName,  string label, Map<String, Schema.SObjectField> fields, string[] fieldLabels){
            this.eventName = eventName;
            this.eventLabel = label;
            this.fieldLabels = fieldLabels;
            string[] fieldStrings = new string[]{};
            for(Schema.SObjectField f :fields.values()){
                fieldStrings.add(String.valueOf(f));
            } 
            this.fields = fieldStrings;
        }
    }
      @AuraEnabled
    public static String getEventNames() {
        eventDatum[] eventData = new eventDatum[]{};
        for( EntityDefinition e :  [SELECT  QualifiedApiName, label
                                    FROM EntityDefinition 
                                    where keyprefix 
                                    like 'e%' 
                                    order by QualifiedApiName] )
            {
                SObjectType eventType = Schema.getGlobalDescribe().get(e.QualifiedApiName);
                Map<String,Schema.SObjectField> fields = eventType.getDescribe().fields.getMap();
                string[] fieldLabels = new string[]{};
                for (String f : fields.keySet()) {
                   
                    string fieldLabel = fields.get(f).getDescribe().getLabel();
                    fieldLabels.add(fieldLabel);
                }
              
                eventDatum ed = new eventDatum(e.QualifiedApiName, e.Label, fields, fieldLabels);
                eventData.add(ed);
            }
        
        /* List<FieldDefinition> fieldNames = new List<FieldDefinition>();
        for(FieldDefinition item: fieldList) {
            FieldDefinition name = item;
            Boolean isSalesforce =  item.Publisher.IsSalesforce;
            
			System.debug(item.DataType);

            System.debug('Field Type ' + item.DataType);
            
            if(!isSalesforce && !item.DataType.contains('Lookup') &&  (item.DataType.contains('Number') || item.DataType.contains('Percent')  || item.DataType.contains('Currency')   ) ) {
                fieldNames.add(name);
            }
        }*/
        
        system.debug(eventData);
        return JSON.serialize(eventData);
    }
    
    @AuraEnabled
    public static String getFields(string eventName) {
        
        SObjectType eventType = Schema.getGlobalDescribe().get(eventName);
        Map<String,Schema.SObjectField> fields = eventType.getDescribe().fields.getMap();
        
          
        
        System.debug(fields);
        List<Map<string, string>> fieldStringList = new List<Map<string, string>>{};
          //  Integer i =0;
        for(string f : fields.keySet()){
            Map<string, string> newFieldMap = new Map<string, string>{};
            Schema.DisplayType type =  fields.get(f).getDescribe().getType();
               
                 if( type.equals(DisplayType.DOUBLE)|| type.equals(DisplayType.Integer) || type.equals(DisplayType.Currency )    ) {
           
           	 		newFieldMap.put(String.valueof(fields.get(f)), fields.get(f).getDescribe().getLabel());
            		fieldStringList.add(newFieldMap);
                 }
           
        } 
        
        return JSON.serialize(fieldStringList);
    }
   
    
}