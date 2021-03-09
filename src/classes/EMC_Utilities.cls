public without sharing class EMC_Utilities {
    
    @AuraEnabled@RemoteAction
    public static String getObjectFields(String sObjectType){
        Schema.DescribeSObjectResult sObj = Schema.getGlobalDescribe().get(sObjectType).getDescribe();
        List<Object> fieldDescribes = new List<Object>();
        Map<String, Schema.SObjectField> fields = sObj.fields.getMap();
        
        for( String key: fields.keySet() ){
            fieldDescribes.add(fields.get(key).getDescribe());
        }

        return JSON.serialize(fieldDescribes);
    }
    
    @AuraEnabled@RemoteAction
    public static String getObjectsFields(List<String> sObjectTypes){
        List<Schema.DescribeSObjectResult> sObjs = Schema.describeSObjects(sObjectTypes);
        Map<String,Object> describedFields = new Map<String,Object>();
        
        for(Schema.DescribeSObjectResult sObj: sObjs){
            List<Map<String, Object>> fieldDescribes = new List<Map<String, Object>>();
            Map<String, Schema.SObjectField> fields = sObj.fields.getMap();
            
            for( String key: fields.keySet() ){
                fieldDescribes.add( new Map<String, Object>{ key => fields.get(key).getDescribe() } );
            }
            
            describedFields.put( sObj.getName(), fieldDescribes );
        }

        return JSON.serialize(describedFields);
    }
    
    @AuraEnabled@RemoteAction
    public static Object queryAllFields(String sObjectType, String recordId){
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(sObjectType).getDescribe();		
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet());
        
        String query = ' SELECT ';
        query += String.join( fieldNames, ',' );
        query += ' FROM ' + describeResult.getName();
        
        if(recordId != null && recordId != ''){
        	query += ' WHERE Id = \'' + recordId + '\'';
 			return Database.query( query )[0];
        }
        
 		return Database.query( query );
        
    }
    
    @AuraEnabled
    public static Object upsertData(String sObjectType, String objectData){
        sObject record = Schema.getGlobalDescribe().get(sObjectType).newSObject();
        
        List<Map<String, String>> objectsMap = (List<Map<String, String>>)JSON.deserialize(objectData, List<Map<String, String>>.class);
        
        for(Map<String,String> objectMap: objectsMap){
            if(objectMap.get('fieldType') == 'boolean'){
                record.put(objectMap.get('field'), objectMap.get('value') == 'true' ? true : false);
            }
            else {
                record.put(objectMap.get('field'), objectMap.get('value'));
            }
        }
        
        upsert record;
        return record;
    }
}