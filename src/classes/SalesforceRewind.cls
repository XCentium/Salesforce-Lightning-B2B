public class SalesforceRewind {
    @AuraEnabled   
    public static String getSessionId() { 
        //This method does two things, it makes sure the PushTopic exists and it also
        //passes back the users session id.
        //First the PushTopic
        List<PushTopic> pts = [SELECT Id FROM PushTopic WHERE Name = 'SalesforceRewindRecords'];
        if(pts.size() > 0) {
            delete pts;
        }
        
        PushTopic pushTopic = new PushTopic();
        pushTopic.Name = 'SalesforceRewindRecords';
        pushTopic.Query = 'SELECT Id, Name FROM Salesforce_Rewind_History_Record__c';
        pushTopic.ApiVersion = 41.0;
        pushTopic.NotifyForOperationCreate = true;
        insert pushTopic;
        
        
        //Now for the SessionId 
        return UserInfo.getSessionId();
    }
    
    @AuraEnabled 
    public static Boolean getRecording() {
        SalesforceRewind__c SFR = SalesforceRewind__c.getInstance();
        return SFR.Recording__c;
    }
    
    @AuraEnabled
    public static Boolean setRecording(Boolean value) {
        List<SalesforceRewind__c> ListSFR = [select Id, Recording__c 
                                             from SalesforceRewind__c limit 1];
        if(ListSFR.size() == 1) 
            ListSFR[0].Recording__c = value;
        else {
            SalesforceRewind__c SFR = new SalesforceRewind__c(Recording__c = value);
            insert SFR;
            ListSFR.add(SFR);
        }
        
        update ListSFR;
        
        return ListSFR[0].Recording__c;
    }
    
    @AuraEnabled
    public static List<Salesforce_Rewind_History_Record__c> getRewindRecords() {
        List<Salesforce_Rewind_History_Record__c> ListSRRecords = [select Id, RecordId__c, Record_Name__c, sObject__c, Status__c, Action__c, CreatedDate, Error__c 
                                                                   from Salesforce_Rewind_History_Record__c 
                                                                   order by CreatedDate]; 
        return ListSRRecords;
    } 
    
    @AuraEnabled
    public static List<Salesforce_Rewind_History_Record__c> deleteAllRecords() {
        List<Salesforce_Rewind_History_Record__c> ListSRRecords = [select Id, Record_Name__c, Status__c, CreatedDate 
                                                                   from Salesforce_Rewind_History_Record__c]; 
        delete ListSRRecords;
        
        return getRewindRecords();
    } 
    
    @AuraEnabled
    public static List<Salesforce_Rewind_History_Record__c> deleteARecord(String recordId) {
        List<Salesforce_Rewind_History_Record__c> ListSRRecords = [select Id, Record_Name__c, Status__c, CreatedDate 
                                                                   from Salesforce_Rewind_History_Record__c 
                                                                   where Id =: recordId];
        delete ListSRRecords;
        
        return getRewindRecords();
    }
    
    @AuraEnabled
    public static Salesforce_Rewind_History_Record__c rewindARecord(String recordId) {       
        Salesforce_Rewind_History_Record__c SRRecord;

        List<Salesforce_Rewind_History_Record__c> ListSRRecords = [select Id, RecordId__c, Record_Name__c, sObject__c, 
                                                                   Status__c, CreatedDate, Action__c,
                                                                   Old_Values__c, New_Values__c
                                                                   from Salesforce_Rewind_History_Record__c 
                                                                   where Id =: recordId];
        if(ListSRRecords.size() == 1) {
            SRRecord = ListSRRecords[0];
            
            try {
                if(SRRecord.Action__c == 'Insert' || SRRecord.Action__c == 'Delete') {
                    List<sObject> ListsObjects;
                    String SOQL_Query = 'select Id from ' + SRRecord.sObject__c + ' where Id = \'' + SRRecord.RecordId__c + '\' ALL ROWS';
                    ListsObjects = Database.query(SOQL_Query);
                    if(ListsObjects.size() == 1) {
                        if(SRRecord.Action__c == 'Insert') {
                            delete ListsObjects[0]; 
                        } else {
                            undelete ListsObjects[0]; 
                        }                       
                    }       
                }
                if(SRRecord.Action__c == 'Update') {
                    //Now we have to construct the old record and the new record, we need the new record as null values aren't recorded
                    //in the old record, so any additional info a user has added won't be removed from a field that used to be null unless 
                    //we make an effort
                    
                    //Firstly, do we have the new and old records data? Might not have if it was too big
                    if(SRRecord.Old_Values__c != null && SRRecord.New_Values__c != null) {
                        //old record
                        sObject oldRecord = (sObject)JSON.deserializeStrict(SRRecord.Old_Values__c, Type.forName(SRRecord.sObject__c));
                        //new record
                        sObject newRecord = (sObject)JSON.deserializeStrict(SRRecord.New_Values__c, Type.forName(SRRecord.sObject__c));
                        
                        //Now run across the attributes of the new one and check all the fields in the old one had values
                        Map<String, Object> newRecordfields = newRecord.getPopulatedFieldsAsMap();
                        Map<String, Object> oldRecordsfields = oldRecord.getPopulatedFieldsAsMap();
                        
                        for (String fieldName : newRecordfields.keySet()){
                            if(!oldRecordsfields.containsKey(fieldName) && !oldRecord.getSobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isCalculated()) {
                                oldRecord.put(fieldName, null);
                            }
                        }
                        //Now, we already have constructed the old representation of the record, so just update it
                        update oldRecord;
                    } else {
                        throw new SalesforceRewind_Exception('The data about the record was too large to store, so we were unable to reconstruct it.');
                    }
                }
                SRRecord.Status__c = 'Undone';
                Update SRRecord;
            } catch(Exception e) {
                SRRecord.Status__c = 'Undoable';
                SRRecord.Error__c = e.getMessage();
                update SRRecord;
            }
        }
        
        return SRRecord;
    }   
    
    public class SalesforceRewind_Exception extends Exception {}   
}