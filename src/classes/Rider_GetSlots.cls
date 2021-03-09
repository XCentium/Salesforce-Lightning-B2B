global class Rider_GetSlots 
{
    @InvocableMethod(label='Rider - Get Appointment Slots')
    global static List<List<Event>> getSlots(List<getSlotsActionRequest> requests) 
    {
        Integer maxSlots = 8;
        List<List<Event>> results = new List<List<Event>>();
        List<Event> result = new List<Event>();
        
        try
        {
            //First figure out the TZ
            //Default to user's TZ
            TimeZone tz = UserInfo.getTimeZone(); //TimeZone.getTimeZone('America/Los_Angeles');
            
            //Main Loop
            for (getSlotsActionRequest request : requests)
            {
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
                
                //Get the operating hours and policy
                List<OperatingHours> opCalendars = new List<OperatingHours>([SELECT Id, Name, Description, TimeZone, (SELECT StartTime, EndTime, Type, DayOfWeek FROM TimeSlots) FROM OperatingHours WHERE Name =: request.strOperatingHrs]);
                List<FSL__Scheduling_Policy__c> ABPolicys = new List<FSL__Scheduling_Policy__c>([SELECT Id FROM FSL__Scheduling_Policy__c WHERE Name =: request.strSchedulingPolicy]);
                
                if (tz == null || opCalendars.size() == 0)
                {
                    return results;
                }
                
                Id policyID = ABPolicys.size() > 0 ? ABPolicys[0].Id : null;
                
                ServiceAppointment objSA = [SELECT ID, AppointmentNumber, Duration, Subject, Status, WorkTypeId, AccountID, Address, SchedStartTime, SchedEndTime, ParentRecordId, OwnerId, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment WHERE Id =: request.objSA.Id];
                //Cache arrival windows
                DateTime arrivalStart = objSA.ArrivalWindowStartTime;
                DateTime arrivalEnd = objSA.ArrivalWindowEndTime;
                
                //Clear Arrival Times
                objSA.ArrivalWindowStartTime = null;
                objSA.ArrivalWindowEndTime = null;
                update objSA;
                
                List<FSL.AppointmentBookingSlot> mySlots;
                if (!Test.isRunningTest())
                {
                    mySlots = FSL.AppointmentBookingService.GetSlots(objSA.Id, policyID, opCalendars[0], tz, 'Grade', true);
                }
                else
                {
                    //Put a test slot in
                    mySlots = new List<FSL.AppointmentBookingSlot>();
                    FSL.AppointmentBookingSlot testSlot = new FSL.AppointmentBookingSlot();
                    testSlot.Interval = new FSL.TimeInterval(Datetime.now(), Datetime.now().addHours(1));
                    mySlots.add(testSlot);
                }
                
                system.debug('AB Call: Got Slots. Array Size: ' + mySlots.size());
                
                if (mySlots.size() == 0)
                {
                    //No slots
                    return results;
                }
                
                for (integer i = mySlots.size()-1; i >= Math.Max(0, mySlots.size() - maxSlots); i--)
                {
                    FSL.AppointmentBookingSlot currentSlot = mySlots[i];
                    Event newEvent = new Event();
                    //newEvent.Id = String.valueof(i);
                    newEvent.StartDateTime = currentSlot.Interval.Start;
                    newEvent.EndDateTime = currentSlot.Interval.Finish;
                    newEvent.DurationInMinutes = 0;
                    newEvent.Description = newEvent.StartDateTime.formatGMT('EEE MMM d h:mmaaa');
                    result.add(newEvent);
                }
                
                if (mySlots.size() > 0)
                {
                    //Add option to choose their own
                    Event newEvent = new Event();
                    //newEvent.Id = String.valueof(mySlots.size() + 1);
                    newEvent.DurationInMinutes = -1;
                    newEvent.Description = 'Choose another time...';
                    result.add(newEvent);
                }

                //put the arrivals back
                objSA.ArrivalWindowStartTime = arrivalStart;
                objSA.ArrivalWindowEndTime = arrivalEnd;
                update objSA;
                
                break;
            }
        }
        catch (Exception ex)
        {
            system.debug(ex.getMessage());
            result.clear();
        }
        
        results.add(result);
        return results;
    }
    
    global class getSlotsActionRequest
    {
        @InvocableVariable(required=false)
        global Contact objContact;
        @InvocableVariable(required=false)
        global ServiceAppointment objSA;
        @InvocableVariable(required=false)
        global String strOperatingHrs;
        @InvocableVariable(required=false)
        global String strSchedulingPolicy;
    }
}