global class EinsteinChatbotsRescheduleSA
{
    @InvocableMethod(label='Einstein Chatbots - Reschedule Service Appointment' description='Reschedule Service Appointment to the selected slot')
    global static List<ServiceAppointment> rescheduleSA(List<RescheduleActionRequest> requests) 
    {
        List<ServiceAppointment> results = new List<ServiceAppointment>();
        For (RescheduleActionRequest currentSlot : requests)
        {
            if (currentSlot != null && currentSlot.objSA != null && String.IsNotBlank(currentSlot.objSA.Id) && currentSlot.slotTime > DateTime.now())
            {
                FSL__Scheduling_Policy__c ABPolicy = [SELECT Id FROM FSL__Scheduling_Policy__c WHERE Name =:'Customer First'];
                TimeZone tz = UserInfo.getTimeZone();
                DateTime myGMT = currentSlot.slotTime.addseconds(tz.getOffset(currentSlot.slotTime)/-1000);
                ServiceAppointment objSA = currentSlot.objSA;
                objSA.ArrivalWindowStartTime = myGMT;
                objSA.ArrivalWindowEndTime = myGMT.addminutes(Integer.valueOf(objSA.Duration) + 60);
                update objSA;
                FSL.ScheduleService.Schedule(ABPolicy.Id, objSA.Id);
                objSA = [SELECT ID, AppointmentNumber, Duration, Subject, Status, WorkTypeId, AccountID, Address, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE ID =: objSA.Id];
                results.add(objSA);
                return results; 
            }
            break;
        }
        system.debug('Nothing to reschedule...');
        return new List<ServiceAppointment>{requests[0].objSA};
    }
    
    global class RescheduleActionRequest 
    {
        @InvocableVariable(required=true)
        global ServiceAppointment objSA;
        @InvocableVariable(required=true)
        global DateTime slotTime;
    }
}