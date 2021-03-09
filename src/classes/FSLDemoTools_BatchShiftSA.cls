global class FSLDemoTools_BatchShiftSA implements Database.Batchable<sObject> {
//this class is used during the process to create the wave dataset.  it is not used on an ongoing basis
    String objName;
    Integer adjdays;

    global FSLDemoTools_BatchShiftSA(String o,  Integer num){
        objName=o;
        adjdays=num;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        //Get list of sas


            query='select id,actualstarttime,actualendtime,duration,actualduration,schedstarttime,schedendtime, ArrivalWindowStartTime, ArrivalWindowEndTime, EarliestStarttime, duedate from serviceappointment where FSLDemoTools_Wave_Data__c = true';

 
        system.debug('************ Query:'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext info, List<sObject> scope){
        system.debug('*************** Number of records of '+objName+' :'+ scope.size());
        List<sObject> updatedObjects = new List<sObject>();
        List<sObject> newObjects = new List<sObject>();
        

               // updatedObjects.add(s);

        for(sObject sObj:scope){
            ServiceAppointment thissa = (ServiceAppointment)sObj;

            thissa.schedstarttime = thissa.schedstarttime != null ? thissa.schedstarttime.addDays(adjdays) : null;
            thissa.schedendtime = thissa.schedendtime !=null ? thissa.schedendtime.addDays(adjdays) : null;
            thissa.arrivalwindowstarttime = thissa.arrivalwindowstarttime !=null ? thissa.arrivalwindowstarttime.addDays(adjdays) : null;
            thissa.arrivalwindowendtime = thissa.arrivalwindowendtime !=null ? thissa.arrivalwindowendtime.addDays(adjdays) : null;
            thissa.EarliestStarttime = thissa.EarliestStarttime != null ? thissa.EarliestStarttime.addDays(adjdays) : null;
            thissa.duedate = thissa.duedate != null ? thissa.duedate.addDays(adjdays) : null;
            thissa.actualstarttime = thissa.actualstarttime != null ? thissa.actualstarttime.addDays(adjdays) : null;
            thissa.actualendtime = thissa.actualendtime != null ? thissa.actualendtime.addDays(adjdays) : null;
            updatedObjects.add(thissa);
        } 
        system.debug('************ updatedObjects:'+updatedObjects);
        update updatedObjects;
    }

    global void finish(Database.BatchableContext info){
        system.debug('*************** Finish method for '+objName);

            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: info.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('FSL Demo Tools: Move Dates for Demo Data - ' + a.Status);
            mail.setPlainTextBody('Successfully updated dates on service appointments.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('*************** Send email: '+mail);

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