global class FSLDemoTools_BatchMoveWave implements Database.Batchable<sObject> {

//this class is a clone of FSLDemoTools_BatchMoveDates - only specific to just the serviceappointment object
    Integer daysToAdd;
    String waveWeek;

    global FSLDemoTools_BatchMoveWave(Integer num, String week){
        daysToAdd=num;
        waveWeek=week;

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        query='SELECT Id,ArrivalWindowStartTime,ArrivalWindowEndTime,DueDate,EarliestStartTime,SchedEndTime,SchedStartTime,ActualStartTime, ActualEndTime from ServiceAppointment Where FSLDemoTools_Wave_Data__c = true and FSLDemoTools_master_data__c=false and FSLDemoTools_Wave_Week__c=: waveWeek';

        system.debug('************ Query:'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext info, List<sObject> scope){
        system.debug('*************** Number of records:'+ scope.size());
        List<sObject> updatedObjects = new List<sObject>();
            for(sObject sObj:scope){
                ServiceAppointment s = (ServiceAppointment)sObj;
                s.ArrivalWindowStartTime = s.ArrivalWindowStartTime != null ? s.ArrivalWindowStartTime.addDays(daysToAdd) : null;
                s.ArrivalWindowEndTime = s.ArrivalWindowEndTime != null ? s.ArrivalWindowEndTime.addDays(daysToAdd) : null;
                s.DueDate = s.DueDate != null ? s.DueDate.addDays(daysToAdd) : null;
                s.EarliestStartTime = s.EarliestStartTime != null ? s.EarliestStartTime.addDays(daysToAdd) : null;
                s.SchedEndTime = s.SchedEndTime != null ? s.SchedEndTime.addDays(daysToAdd) : null;
                s.SchedStartTime = s.SchedStartTime != null ? s.SchedStartTime.addDays(daysToAdd) : null;
                updatedObjects.add(s);
            }
      system.debug('************ updatedObjects:'+updatedObjects);
      update updatedObjects;
    }
    

    global void finish(Database.BatchableContext info){
        //system.debug('*************** Finish method for '+objName);

            ////Send Email
            //AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: info.getJobId()];
            //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new String[] {a.CreatedBy.Email};
            //mail.setToAddresses(toAddresses);
            //mail.setSubject('FSL Demo Tools: Move Dates for FSL Wave Demo Data - ' + a.Status);
            //mail.setPlainTextBody('Successfully moved all dates on Services for FSL Wave data so they appear for Last 7 days');
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            //system.debug('*************** Send email: '+mail);
        
    }
}