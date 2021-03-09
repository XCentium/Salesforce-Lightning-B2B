global class Rider_ScheduleSA 
{
    @InvocableMethod(label='Rider - Schedule Appointment')
    global static List<scheduleSAActionResponse> scheduleSA(List<scheduleSAActionRequest> requests)
    {
        List<scheduleSAActionResponse> results = new List<scheduleSAActionResponse>();
        scheduleSAActionResponse result = new scheduleSAActionResponse();
        
        try
        {
            for (scheduleSAActionRequest request : requests)
            {
                List<FSL__Scheduling_Policy__c> ABPolicys = new List<FSL__Scheduling_Policy__c>([SELECT Id FROM FSL__Scheduling_Policy__c WHERE Name =: request.strSchedulingPolicy]);
                Id policyID = ABPolicys.size() > 0 ? ABPolicys[0].Id : null;
                
                
                //Get timezone of runing user
                TimeZone tz = UserInfo.getTimeZone();
                
                //See if we can get the contact's tz from service territory
                if (request.objContact != null && request.objContact.Rider_ServiceTerritory__c != null)
                {
                    //Get service Territory TimeZone
                    List<ServiceTerritory> objSTs = new List<ServiceTerritory>([SELECT ID, OperatingHours.TimeZone FROM ServiceTerritory WHERE ID =: request.objContact.Rider_ServiceTerritory__c LIMIT 1]);
                    if (objSTs.size() > 0 && String.isNotBlank(objSTs[0].OperatingHours.TimeZone))
                    {
                        tz = Timezone.getTimeZone(objSTs[0].OperatingHours.TimeZone);
                    }
                }
                
                DateTime dtStartSlot;
                DateTime dtEndSlot;
                
                
                if (request.nlpStart != null)
                {
                    //using the nlp time
                    dtStartSlot = request.nlpStart.addseconds(tz.getOffset(request.nlpStart)/-1000);
                    dtEndSlot = dtStartSlot.addMinutes(2);
                }
                else if (request.objSlot != null)
                {
                    dtStartSlot = request.objSlot.StartDateTime.addseconds(tz.getOffset(request.objSlot.StartDateTime)/-1000);
                    dtEndSlot = request.objSlot.EndDateTime.addseconds(tz.getOffset(request.objSlot.EndDateTime)/-1000);
                }
                else
                {
                    result.strError = 'Invalid slot for scheduling...';
                    results.add(result);
                    return results;
                }
                
                ServiceAppointment objSA = [SELECT ID, SchedStartTime, SchedEndTime, ArrivalWindowStartTime, ArrivalWindowEndTime, DurationInMinutes FROM ServiceAppointment WHERE Id =: request.objSA.Id];
                //Cache the arrival times
                DateTime arrivalStart = objSA.ArrivalWindowStartTime;
                DateTime arrivalFinish = objSA.ArrivalWindowEndTime;
                DateTime schStart = objSA.SchedStartTime;
                DateTime schEnd = objSA.SchedEndTime;
                
                objSA.ArrivalWindowStartTime = dtStartSlot;
                objSA.ArrivalWindowEndTime = dtEndSlot;
                update objSA;
                
                FSL.ScheduleResult scheduleResult;
                if (!Test.isRunningTest())
                {
                    scheduleResult = FSL.ScheduleService.Schedule(policyID, objSA.Id);
                }
                if (scheduleResult == null)
                {
                    objSA.ArrivalWindowStartTime = arrivalStart;
                    objSA.ArrivalWindowEndTime = arrivalFinish;
                    objSA.SchedStartTime = schStart;
                    objSA.SchedEndTime = schEnd;
                    update objSA;
                    
                    result.strError = 'Error Scheduling Appointment';
                }
            }
        }
        catch (Exception ex)
        {
            result.strError = ex.getMessage();
        }
        
        results.add(result);
        return results;
    }
    
    global class scheduleSAActionRequest
    {
        @InvocableVariable(required=false)
        global DateTime nlpStart;
        @InvocableVariable(required=false)
        global Event objSlot;
        @InvocableVariable(required=false)
        global ServiceAppointment objSA;
        @InvocableVariable(required=false)
        global Contact objContact;
        @InvocableVariable(required=false)
        global String strSchedulingPolicy;
    }
    
    global class scheduleSAActionResponse
    {
        @InvocableVariable(required=false)
        global string strError;
    }
}