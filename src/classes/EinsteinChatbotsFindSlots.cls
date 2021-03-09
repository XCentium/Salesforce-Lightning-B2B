global class EinsteinChatbotsFindSlots 
{
    @InvocableMethod(label='Einstein Chatbots - Find Slots for Service Appointment' description='Returns a list slots to reschedule Service Appointment')
    global static List<List<DateTime>> getSlots(List<ServiceAppointment> requests) 
    {
        List<DateTime> results = new List<DateTime>();
        
        For (ServiceAppointment objSA : requests)
        {
            //Validate we can even do this.
            if (objSA != null && String.IsNotBlank(objSA.id))
            {
                //Cache arrival windows
                DateTime arrivalStart = objSA.ArrivalWindowStartTime;
                DateTime arrivalEnd = objSA.ArrivalWindowEndTime;
                
                //Clear Arrival Times
                objSA.ArrivalWindowStartTime = null;
                objSA.ArrivalWindowEndTime = null;
                update objSA;
                
                //Make the service call
                TimeZone tz = UserInfo.getTimeZone(); //TimeZone.getTimeZone('America/Los_Angeles');
                OperatingHours opCalendar = [SELECT Id, Name, Description, TimeZone, (SELECT StartTime, EndTime, Type, DayOfWeek FROM TimeSlots) FROM OperatingHours WHERE Name =: 'Gold Appointments Calendar'];
        FSL__Scheduling_Policy__c ABPolicy = [SELECT Id FROM FSL__Scheduling_Policy__c WHERE Name =:'Customer First'];
                
                if (opCalendar == null || ABPolicy == null)
                {
                    return new List<List<DateTime>>{new List<DateTime>{DateTime.newInstance(0)}};
                }
                
                List<FSL.AppointmentBookingSlot> mySlots = FSL.AppointmentBookingService.GetSlots(objSA.Id, ABPolicy.Id, opCalendar, tz, 'Grade', true);
                system.debug('AB Call: Got Slots. Array Size: ' + mySlots.size());
                
                for (integer i = mySlots.size()-1; i >= Math.Max(0, mySlots.size() - 5); i--)
                {
                    FSL.AppointmentBookingSlot currentSlot = mySlots[i];
                    results.add(currentSlot.Interval.Start);
                }
                
                //put the arrivals back
                objSA.ArrivalWindowStartTime = arrivalStart;
                objSA.ArrivalWindowEndTime = arrivalEnd;
                update objSA;
                
                results.sort();
                if (results.size() > 0)
                {
                    return new List<List<DateTime>>{results};
                }
                break;
            }
        }
        
        return new List<List<DateTime>>{new List<DateTime>{DateTime.newInstance(0)}};
    }
}