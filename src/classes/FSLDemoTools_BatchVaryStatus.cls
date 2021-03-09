global class FSLDemoTools_BatchVaryStatus implements Database.Batchable<sObject> {

//this class is used during the wave dataset build.  it is not used on an ongoing basis

    String objName;
    decimal durationadj;

    global FSLDemoTools_BatchVaryStatus(String o,  decimal num){
        objName=o;
        durationadj=num;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        //Get list of sas

            query='select id,status,actualstarttime,actualendtime,duration,actualduration,schedstarttime,schedendtime, ArrivalWindowStartTime, ArrivalWindowEndTime, EarliestStarttime, duedate from serviceappointment where FSLDemoTools_Wave_Data__c = true and FSLDemoTools_Wave_Week__c = \'2\'';

 
        system.debug('************ Query:'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext info, List<sObject> scope){
        system.debug('*************** Number of records of '+objName+' :'+ scope.size());
        List<sObject> updatedObjects = new List<sObject>();
        List<sObject> newObjects = new List<sObject>();
        
        double slafactor = .095; /* what percent of sas will have actual dates within the sla dates */
        list<string> statuslist = new list<string>();
        statuslist.add('Scheduled');statuslist.add('Completed');statuslist.add('Canceled');statuslist.add('Cannot Complete');
        double compfactor = .8; /* what percent will be completed */
        double cancfactor = .85; /* the next percent will be canceled */
        double ccfactor = .86; /* the next percent will be cannot completed */
               // updatedObjects.add(s);

        for(sObject sObj:scope){
            ServiceAppointment sa = (ServiceAppointment)sObj;
            double statusfactor = math.random();
            sa.earlieststarttime = sa.schedstarttime != null ? sa.schedstarttime : sa.earlieststarttime;
            if (statusfactor < compfactor) 
                sa.status = statuslist[1];
            else 
                if (statusfactor < cancfactor) 
                     sa.status = statuslist[2];
                else 
                    if (statusfactor < ccfactor) 
                        sa.status = statuslist[3];
                    else 
                        sa.status = statuslist[0];
            updatedObjects.add(sa);
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
            mail.setPlainTextBody('Successfully updated status on day 1 service appointments.');
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