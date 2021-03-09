/**
* Utilization class
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02
*/
public with sharing class SCCUtilityClass {

    /**
    * This method used for check if person type account is enabled or not.
    * @return boolean
    */
    public static Boolean isPersonAccountEnabled(){
      return Schema.SObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
    }

    /**
    * This method check if person account exist or not using account id
    * @return boolean
    */
    public static Boolean isPersonAccountExist(String accountId){
        List<Account> personAccounts = [SELECT Id FROM Account WHERE IsPersonAccount=TRUE AND Id =: accountId];
        if(!personAccounts.isEmpty()){
            return true;
        }else{
            return false;
        }
    }

    /**
    * This method return record type id of account using account name.
    * @Todo. refactor it.
    * @return boolean
    */
    public static RecordType getPersonAccountRecordType(String accountName){
        RecordType recordType = (RecordType)Cache.Org.get('local.SCCConnectorCustomSettings.RecordType'+accountName.replaceAll(' ', ''));
        if(recordType == null){
            try{
                recordType = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND IsPersonType=TRUE AND Name =: accountName];
                Cache.Org.put('local.SCCConnectorCustomSettings.RecordType'+accountName.replaceAll(' ', ''), recordType);
                return recordType;
            }catch(Exception e){
                return recordType;
            }
        }else{
	    return recordType;
        }
    }

    /**
    * This method return account using account id if account is person type account.
    * @return boolean
    */
    public static Account getPersonAccount(String accountId){
        Account acount;
        try{
            acount = [SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount=TRUE AND Id = :accountId];
            return acount;
        }catch(Exception e){
            return acount;
        }
    }

    /**
    * This method return person type account or contact using id
    * @return Sobject
    */
    public static SObject getSojectByRefId(String crmRefId){
        SObject sobj;
        try{
            if(!String.isEmpty(crmRefId)){
                sobj = [SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount=TRUE AND Id = :crmRefId];
        	}
        }catch(Exception e){
            sobj = null;
        }
        //try if contact exist using supplied id.
        try{
            if(!String.isEmpty(crmRefId) && sobj == null){
				sobj = [SELECT Id FROM Contact WHERE Id = :crmRefId];
        	}
        }catch(Exception e){
	        sobj = null;
        }
        return sobj;
    }

    public static Account getDefaultAccount(){
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName('Account')
            .setRelatedFields(new Set<String>{'Id'})
            .setClause('Name = \'Default\'')
            .setLimit('1')
            .getQuery();
        // Checking whether the default account is present or not
        List<Account> defaultAccount = SCCQueryUtilClass.getRecords(query);
        if (defaultAccount != null && defaultAccount.size() > 0) {
            return defaultAccount[0];
        } else {
            return null;
        }
    }

    public static Address__c getContactAddress(String name, String contactId, String accountId){
        Address__c address;
        try{
            if(!String.isEmpty(name) && !String.isEmpty(contactId) && !String.isEmpty(accountId)){
                address = [SELECT Id FROM Address__c WHERE Name = :name AND Contact__c= :contactId AND Account__c= :accountId ];
            }else if(!String.isEmpty(name) && !String.isEmpty(contactId)){
                address = [SELECT Id FROM Address__c WHERE Name = :name AND Contact__c= :contactId ];
            }
            return address;
        }catch(Exception e){
            return address;
        }
    }

    /**
    * This method used to get object attribute mapping values from specified object.
    * @param objectName: String
    * @return Map<String, Schema.SObjectField>.
    */
    public static Map<String, SObject> getAllCustomSettingValues(String objectName, SCCFileLogger logger) {
        String objectAlias = SCCClassAlias.classAliasMap.get(objectName);
        logger.debug('SCCUtilityClass.getAllCustomSettingValues', 'objectName: ' + objectName + ' objectAlias: '+ objectAlias);
        Map<String, SObject> returnMap = (Map<String, SObject>)Cache.Org.get('local.SCCConnectorCustomSettings.all'+objectAlias);
        if(returnMap == null){
            logger.debug('SCCUtilityClass.getAllCustomSettingValues', 'Cache Missed. Getting data from DB');
            returnMap = new Map<String, SObject>();
            String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName(objectAlias + 'FieldMapping__c')
                        .setAllFields()
                        .getQuery();
            List<SObject> objList = SCCQueryUtilClass.getRecords(query);
            logger.debug('SCCUtilityClass.getAllCustomSettingValues', 'query: '+query+ ' Records: '+objList);
            for(SObject obj : objList) {
                returnMap.put((String)obj.get('CC_Attribute__c'), obj);
            }
	    Cache.Org.put('local.SCCConnectorCustomSettings.all'+objectAlias, returnMap);
        }
        return returnMap;
    }

    /**
    * This method used to get object attribute mapping values applicable for sync from specified object.
    * @param objectName: String
    * @return Map<String, Schema.SObjectField>.
    */
    public static Map<String, SObject> getSyncCustomSettingValues(String objectName, Boolean isSync, SCCFileLogger logger) {
        String objectAlias = SCCClassAlias.classAliasMap.get(objectName);
        logger.debug('SCCUtilityClass.getSyncCustomSettingValues', 'objectName: ' + objectName + ' objectAlias: '+ objectAlias);
        Map<String, SObject> returnMap = (Map<String, SObject>)Cache.Org.get('local.SCCConnectorCustomSettings.sync'+objectAlias);
        if(returnMap == null){
            logger.debug('SCCUtilityClass.getSyncCustomSettingValues', 'Cache Missed. Getting data from DB');
			returnMap = new Map<String, SObject>();
            String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName(objectAlias + 'FieldMapping__c')
                        .setAllFields()
                        .setClause('Enable_Sync__c = '+isSync)
                        .getQuery();
            List<SObject> objList = SCCQueryUtilClass.getRecords(query);
            logger.debug('SCCUtilityClass.getSyncCustomSettingValues', 'query: '+query+ ' Records: '+objList);
            for(SObject obj : objList) {
                returnMap.put((String)obj.get('CC_Attribute__c'), obj);
            }
            Cache.Org.put('local.SCCConnectorCustomSettings.sync'+objectAlias, returnMap);
        }
        return returnMap;
    }

    /**
    * This method used to get object attribute mapping values applicable for patch from specified object.
    * @param objectName: String
    * @return Map<String, Schema.SObjectField>.
    */
    public static Map<String, SObject> getPatchCustomSettingValues(String objectName, Boolean isPatch, SCCFileLogger logger) {
        String objectAlias = SCCClassAlias.classAliasMap.get(objectName);
        logger.debug('SCCUtilityClass.getPatchCustomSettingValues', 'objectName: ' + objectName + ' objectAlias: '+ objectAlias);
        Map<String, SObject> returnMap = (Map<String, SObject>)Cache.Org.get('local.SCCConnectorCustomSettings.patch'+objectAlias);
        if(returnMap == null){
			logger.debug('SCCUtilityClass.getPatchCustomSettingValues', 'Cache Missed. Getting data from DB');
            returnMap = new Map<String, SObject>();
            String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName(objectAlias + 'FieldMapping__c')
                        .setAllFields()
                        .setClause('Enable_Patch__c = '+isPatch)
                        .getQuery();
            List<SObject> objList = SCCQueryUtilClass.getRecords(query);
            logger.debug('SCCUtilityClass.getPatchCustomSettingValues', 'query: '+query+ ' Records: '+objList);
            for(SObject obj : objList) {
                returnMap.put((String)obj.get('CC_Attribute__c'), obj);
            }
           	Cache.Org.put('local.SCCConnectorCustomSettings.patch'+objectAlias, returnMap);
        }
        return returnMap;
    }

    /**
    * This method used for returned fields of selected object.
    * @param objectName: String
    * @return Map<String, Schema.SObjectField>.
    */
    public static Map<String, Schema.SObjectField> getFields(String objectName) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        return gd.get(objectName).getDescribe().fields.getMap();
    }

    /**
    * This method used for returned sobject instance dynamically.
    * @param objectName: String
    * @return SObject.
    */
    public static SObject getNewSObject(String objectName) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType objectType = gd.get(objectName);
        SObject obj = objectType.newSObject();
        return obj;
    }

    /**
    * This method used for returned all fields(apinames) of related sobject dynamically.
    * @param objectName: String
    * @return SObject.
    */
    public static List<String> getAllFields(String objectName) {
        List<String> returnList = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = SCCUtilityClass.getFields(objectName);
        for(String key : fieldMap.keySet()) {
            returnList.add(fieldMap.get(key).getDescribe().getName());
        }
        return returnList;
    }

    /**
    * This method used for returned wanted fields(apinames) of related sobject dynamically.
    * @param objectName: String
    * @param fieldApis: Set<String>
    * @return List<String>.
    */
    public static List<String> getWantedFields(String objectName, Set<String> fieldApis) {
        Set<String> fieldApiSet = new Set<String>();
        for(String s : fieldApis) {
            fieldApiSet.add(s.toLowerCase());
        }
        List<String> returnList = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = SCCUtilityClass.getFields(objectName);
        for(String key : fieldMap.keySet()) {
            if(fieldApiSet.contains(key)) {
                returnList.add(fieldMap.get(key).getDescribe().getName());
            }
        }
        return returnList;
    }

    /**
    * This method used for initializing the object.
    * @param jsonMap: Map<String, SObject>
    * @param objectName: String
    * @return SObject.
    */
    public static SObject initializeObject(Map<String, Object> jsonMap, String objectName, Map<String, SObject> fieldMappings, SCCFileLogger logger) {
        logger.debug('SCCUtilityClass.initializeObject','Initializing '+objectName+' jsonMap '+jsonMap);
        return SCCUtilityClass.createObject(jsonMap, objectName, fieldMappings, logger);
    }

    /**
    * This method used for populating fields the object.
    * @param jsonMap: Map<String, SObject>
    * @param objectName: String
    * @return SObject.
    */
    public static SObject createObject(Map<String, Object> jsonMap, String objectName, Map<String, SObject> fieldMappings, SCCFileLogger logger) {
        logger.debug('SCCUtilityClass.createObject','Creating Object '+objectName+' jsonMap '+jsonMap);
        SObject obj = SCCUtilityClass.getNewSObject(objectName);
        for(String key : fieldMappings.keySet()) {
            Object value = SCCJsonUtil.getValueByKey(key, jsonMap, logger);
            if(value!=null) {
                logger.debug('SCCUtilityClass.createObject',key + ' fieldMappings.get(key).get Field_Api_Name__c: ' + (String)fieldMappings.get(key).get('Field_Api_Name__c'));
				SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
                Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
                Schema.SObjectField field = (Schema.SObjectField) mfields.get((String)fieldMappings.get(key).get('Field_Api_Name__c'));
                if(field!=null){
                    Schema.DisplayType fieldType = field.getDescribe().getType();
                    logger.debug('SCCUtilityClass.createObject','mfields: '+mfields+' Schema.SObjectField: '+field+' Schema.DisplayType: '+fieldType);

                    if (fieldType == Schema.DisplayType.STRING ||
                            fieldType == Schema.DisplayType.TEXTAREA ||
                            fieldType == Schema.DisplayType.ID ||
                            fieldType == Schema.DisplayType.PICKLIST ||
                            fieldType == Schema.DisplayType.REFERENCE ||
                            fieldType == Schema.DisplayType.PHONE ||
                            fieldType == Schema.DisplayType.EMAIL ||
                            fieldType == Schema.DisplayType.URL) {
                        obj.put((String) fieldMappings.get(key).get('Field_Api_Name__c'), String.valueOf(value));
                    }
                    if (fieldType == Schema.DisplayType.CURRENCY ||
                            fieldType == Schema.DisplayType.DOUBLE) {
                        obj.put((String) fieldMappings.get(key).get('Field_Api_Name__c'), (Decimal) value);
                    }
                    if (fieldType == Schema.DisplayType.INTEGER) {
                        obj.put((String) fieldMappings.get(key).get('Field_Api_Name__c'), Integer.valueOf(value));
                    }
                    if (fieldType == Schema.DisplayType.BOOLEAN) {
                        obj.put((String) fieldMappings.get(key).get('Field_Api_Name__c'), Boolean.valueOf(value));
                    }
                    if (fieldType == Schema.DisplayType.DATETIME) {
                        obj.put((String) fieldMappings.get(key).get('Field_Api_Name__c'), formatDate(String.valueOf(value)));
                    }
                    if (fieldType == Schema.DisplayType.DATE) {
                        if (((String) value).contains('-')) {
                            obj.put((String) fieldMappings.get(key).get('Field_Api_Name__c'), Date.valueOf((String) value));
                        } else {
                            obj.put((String) fieldMappings.get(key).get('Field_Api_Name__c'), Date.parse((String) value));
                        }
                    }
                }
            }
        }
        return obj;
    }


    /**
    * This method used for populating additional and required fields for contact object
    * @param record: Contact
    * @param jsonMap: Map<String, Object>
    * @return Contact.
    */
    public static Contact additionalFieldsforContact(Contact record, Map<String, Object> jsonMap) {
        if(jsonMap.containsKey('customer_name')) {
            String[] contactName = new List<String>();
            String firstName = '';
            String lastName = '';
            contactName = ((String)jsonMap.get('customer_name')).split(' ');
            firstName = contactName[0];
            for(Integer i = 0; i < contactName.size(); i++) {
                if(i != 0) {
                    lastName += contactName[i] + ' ';
                }
            }
            lastName = lastName.removeEnd(' ');
            record.FirstName = firstName;
            record.LastName  = lastName;
        }

        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName('Account')
            .setRelatedFields(new Set<String>{'Id'})
            .setClause('Name = \'Default\'')
            .setLimit('1')
            .getQuery();
    	record.AccountId = ((List<Account>)SCCQueryUtilClass.getRecords(query))[0].Id;
        record.From_SFCC__c  = true;
        record.Contact_Status__c  = 'Created';
        return record;
    }

    /**
    * This method used for populating additional and required fields for contact object
    * @param record: Account
    * @param jsonMap: Map<String, Object>
    * @return Account.
    */
    public static Account additionalFieldsforAccount(Account record, Map<String, Object> jsonMap) {
        if(jsonMap.containsKey('customer_name')) {
            String[] contactName = new List<String>();
            String firstName = '';
            String lastName = '';
            contactName = ((String)jsonMap.get('customer_name')).split(' ');
            firstName = contactName[0];
            for(Integer i = 0; i < contactName.size(); i++) {
                if(i != 0) {
                    lastName += contactName[i] + ' ';
                }
            }
            lastName = lastName.removeEnd(' ');
            record.FirstName = firstName;
            record.LastName  = lastName;
        }
        return record;
    }

    /**
    * This method parse date string to DateTime
    * @param dateString: String
    * @return DateTime.
    */
    public static Datetime formatDate(String dateString){
        Datetime dateObj = null;
        if(dateString.contains('T')){
            dateString = dateString.replace('T',' ');
            if(dateString.contains('.')){
	            dateString = dateString.substring(0,dateString.indexOf('.'));
            }
			dateObj  = Datetime.valueOf(dateString);
        }else{
 			dateObj  = Datetime.valueOf(dateString);
        }
		return dateObj;
    }

    /**
    * This method queries GlobalSFCCConfigurations custom setting to check the value of Enable_Customer_Synch_Triggers__c flag.
    * @return isEnabled Returns a boolean value describing if the trigger should fire / execute
    */
    public static Boolean isCustomerTriggerEnabled(){

        // Initialize local variables
        Boolean isEnabled;

        // Build the query to retrieve the trigger-enablement details
        String query = SCCQueryUtilClass.getInstance()
          .getQueryInstance()
          .setObjectName('GlobalSFCCConfigurations__c')
          .setRelatedFields(new Set<String>{'Id, Enable_Customer_Synch_Triggers__c'})
          .setLimit('1')
          .getQuery();

        // Execute the query and capture the results
        List<GlobalSFCCConfigurations__c> objList = (List<GlobalSFCCConfigurations__c>)SCCQueryUtilClass.getRecords(query);
        isEnabled = (Boolean) objList[0].Enable_Customer_Synch_Triggers__c;

        // Return the is-enabled property
        return isEnabled;

    }

}