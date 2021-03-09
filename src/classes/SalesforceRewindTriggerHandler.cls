public class SalesforceRewindTriggerHandler {   
    //Code to log the insert, update or delete by creating a new record in the Salesforce_Rewind_History_Record__c object.
    public static void publishNotifications(Map<Id, sObject> TOld, List<sObject> TNew, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        SalesforceRewind__c SFR = SalesforceRewind__c.getInstance();
        if(SFR.Recording__c) {
            List<Salesforce_Rewind_History_Record__c> Events = new List<Salesforce_Rewind_History_Record__c>();
            
            If(isInsert || isUpdate) {
                for (sObject obj : TNew) {
                    Salesforce_Rewind_History_Record__c Event = new Salesforce_Rewind_History_Record__c();
                    
                    //Time to find a name value
                    String RecordName = '';
                    if((obj.getSobjectType() == Contact.sObjectType) || (obj.getSobjectType() == Lead.sObjectType)) {
                       RecordName = (String)obj.get('firstname') + ' ' + (String)obj.get('lastname'); 
                    } else if(obj.getSobjectType().getDescribe().fields.getMap().keySet().contains('name')) {
                       RecordName = (String)obj.get('name');
                    } else {
                       RecordName = (String)obj.get('id'); 
                    }
                    
                    Event.Record_Name__c = RecordName;
                    Event.RecordId__c = (String)obj.get('Id');
                    Event.sObject__c = obj.getSObjectType().getDescribe().getName();
                    
                    //Record the new value we have in the field, if it can fit
                    if(JSON.serialize(obj).length() <= 32768) {
                        Event.New_Values__c = JSON.serialize(obj);
                    }
                    
                    If(isInsert) {
                        Event.Action__c = 'Insert';
                    }

                    if(isUpdate) {
                        Event.Action__c = 'Update';
                        
                        //Now we may not be able to save the record if there is too much information for the field, and if so we won't be able to rollback
                        if(JSON.serialize(TOld.get(obj.Id)).length() <= 32768 ) {
                        	Event.Old_Values__c = JSON.serialize(TOld.get(obj.Id));
                        } else {
                            Event.Error__c = 'Values too large to store on record';
                            Event.Status__c = 'Undoable';
                        }
                    }              
                    Events.add(Event);
                }
            }
            
            if(isDelete) {
                for (Id objId : TOld.keySet()) {
                    Salesforce_Rewind_History_Record__c Event = new Salesforce_Rewind_History_Record__c();
                    sObject obj = TOld.get(objId);
                    
                    if(obj.getSobjectType().getDescribe().fields.getMap().keySet().contains('name')) {
                        Event.Record_Name__c = (String)obj.get('name');
                    }
                    
                    Event.RecordId__c = (String)obj.get('Id');
                    Event.sObject__c = obj.getSObjectType().getDescribe().getName();
                    Event.Action__c = 'Delete';
                    if(JSON.serialize(obj).length() < 32769)
                    	Event.Old_Values__c = JSON.serialize(obj);               
                    Events.add(Event);
                }
            }
            try{
                insert Events;
            } catch (DMLException e){
                for (Salesforce_Rewind_History_Record__c event : Events) {
                    event.addError('There was a problem in the SalesforceRewindTriggerHandler');
                }
            } 
        }        
    }
}