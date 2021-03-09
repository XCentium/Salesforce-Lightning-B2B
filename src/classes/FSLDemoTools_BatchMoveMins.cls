global class FSLDemoTools_BatchMoveMins implements Database.Batchable<sObject> {
    String objName;
    Integer minsToAdd;
    Id territoryId;

    global FSLDemoTools_BatchMoveMins(String o, Id t,Integer num){
        objName=o;
        territoryId=t;
        minsToAdd=num;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        //ServiceAppointment
        if(objName=='ServiceAppointment'){
            query='SELECT Id,ArrivalWindowStartTime,ArrivalWindowEndTime,DueDate,EarliestStartTime,SchedEndTime,SchedStartTime from ServiceAppointment Where FSLDemoTools_Master_Data__c = false and ServiceTerritoryId=:territoryId';
        }

        ////ServiceTerritoryMember
        else if(objName=='ServiceTerritoryMember'){
            query='SELECT Id,EffectiveEndDate,EffectiveStartDate from ServiceTerritoryMember Where FSLDemoTools_Master_Data__c = false and TerritoryType=\'R\'';
        }

        //ResourceAbsence
        else if(objName=='ResourceAbsence'){
            query='Select ' + GetAllObjectFields('ResourceAbsence') + ',resourceid From ResourceAbsence where FSLDemoTools_Master_Data__c = false and RecordType.DeveloperName!=\'Break\'and ResourceId in (SELECT ServiceResourceId from ServiceTerritoryMember where ServiceTerritoryId=:territoryId)';//RecordType.DeveloperName 
        }

        system.debug('************ Query:'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext info, List<sObject> scope){
        system.debug('*************** Number of records of '+objName+' :'+ scope.size());
        List<sObject> updatedObjects = new List<sObject>();
        
        if(objName=='ServiceAppointment'){
            for(sObject sObj:scope){
                ServiceAppointment s = (ServiceAppointment)sObj;
                s.ArrivalWindowStartTime = s.ArrivalWindowStartTime != null ? s.ArrivalWindowStartTime.addMinutes(minsToAdd) : null;
                s.ArrivalWindowEndTime = s.ArrivalWindowEndTime != null ? s.ArrivalWindowEndTime.addMinutes(minsToAdd) : null;
                s.DueDate = s.DueDate != null ? s.DueDate.addMinutes(minsToAdd) : null;
                s.EarliestStartTime = s.EarliestStartTime != null ? s.EarliestStartTime.addMinutes(minsToAdd) : null;
                s.SchedEndTime = s.SchedEndTime != null ? s.SchedEndTime.addMinutes(minsToAdd) : null;
                s.SchedStartTime = s.SchedStartTime != null ? s.SchedStartTime.addMinutes(minsToAdd) : null;
                updatedObjects.add(s);
            }
            update updatedObjects;
        }
        else if(objName=='ServiceTerritoryMember'){
            for(sObject sObj:scope){
                ServiceTerritoryMember r = (ServiceTerritoryMember)sObj; 
                r.EffectiveEndDate = r.EffectiveEndDate != null ? r.EffectiveEndDate.addMinutes(minsToAdd) : null;
                r.EffectiveStartDate = r.EffectiveStartDate != null ? r.EffectiveStartDate.addMinutes(minsToAdd) : null;
                updatedObjects.add(r);
            }
        }

            //Need to Clone all existing RAs then delete and then insert the updated cloned ones.
        else if(objName=='ResourceAbsence'){
            system.debug('*************** ResourceAbsence minsToAdd:'+minsToAdd);
            for(sObject sObj:scope){
                ResourceAbsence a = (ResourceAbsence)sObj;
                ResourceAbsence clnEA = a.clone();
                 system.debug('***************  clnEA.End before:'+ clnEA.End);
                 system.debug('***************  clnEA.Start before:'+ clnEA.Start);
                clnEA.End = clnEA.End != null ? clnEA.End.addMinutes(minsToAdd) : null;
                clnEA.Start = clnEA.Start != null ? clnEA.Start.addMinutes(minsToAdd) : null;
                system.debug('***************  clnEA.End after:'+ clnEA.End);
                 system.debug('***************  clnEA.Start after:'+ clnEA.Start);
                updatedObjects.add(clnEA);
            }
            system.debug('*************** ResourceAbsence updatedObjects:'+updatedObjects);
            delete scope;
            insert updatedObjects;
        }
    }

    global void finish(Database.BatchableContext info){
        system.debug('*************** Finish method for '+objName);
        if(objName=='ServiceAppointment'){ //Call the next Batch update
            FSLDemoTools_BatchMoveMins batch = new FSLDemoTools_BatchMoveMins('ServiceTerritoryMember', territoryId, minsToAdd);
            Database.executeBatch(batch);
        }
        else if(objName=='ServiceTerritoryMember'){ //Call the next Batch update
          FSLDemoTools_BatchMoveMins batch = new FSLDemoTools_BatchMoveMins('ResourceAbsence', territoryId,minsToAdd);
          Database.executeBatch(batch);
        }
        else if(objName=='ResourceAbsence'){
            //Send Email
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: info.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('FSL Demo Tools: Move Dates for Demo Data - ' + a.Status);
            mail.setPlainTextBody('Successfully moved all times on Services, Relocations and Employee Absences '+ minsToAdd + ' hours.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('*************** Send email: '+mail);
        }
    }

        private String GetAllObjectFields(String objectName){
        Schema.SObjectType objSchema = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
        String allObjectFields = 'Id';
        for (String fieldName: fieldMap.keySet()) {
            if (fieldMap.get(fieldName).getDescribe().isUpdateable()) allObjectFields += ', ' + fieldName;
        }
        return allObjectFields;
    }
}