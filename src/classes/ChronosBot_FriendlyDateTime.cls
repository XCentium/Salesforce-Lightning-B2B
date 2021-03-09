global with sharing class ChronosBot_FriendlyDateTime
{    
    @InvocableMethod(label='Chronos Bot - Friendly DateTime')
    public static List<List<ServiceAppointment>> makeFriendlyDateTime(List<List<ServiceAppointment>> appointmentListList) 
    {
        List<ServiceAppointment> results = new List<ServiceAppointment>();
        for (List<ServiceAppointment> appointmentList : appointmentListList)
        {
            for (ServiceAppointment appointment : appointmentList) 
            {
                if (appointment.ContactId != null)
                {
                    User communityUser = [SELECT Id, TimeZoneSidKey FROM User WHERE ContactId = :appointment.ContactId LIMIT 1];
                    appointment.Description = appointment.SchedStartTime.format('EEEE, MMM d h:mmaaa', communityUser.TimeZoneSidKey) + ' - ' + appointment.SchedEndTime.format('h:mm aaa', communityUser.TimeZoneSidKey);
                } else {
                    TimeZone tz = UserInfo.getTimeZone();
                    appointment.Description = appointment.SchedStartTime.format('EEEE, MMM d h:mmaaa', tz.getID()) + ' - ' + appointment.SchedEndTime.format('h:mm aaa', tz.getID());
                }
                
                results.add(appointment);   
            }
            
            return new List<List<ServiceAppointment>>{results};
        }
        
        return new List<List<ServiceAppointment>>{new List<ServiceAppointment>()};
    }
}