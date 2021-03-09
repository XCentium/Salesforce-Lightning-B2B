global class EinsteinChatbotsFindServiceAppointments 
{
    @InvocableMethod(label='Einstein Chatbots - Find ServiceAppointments for Contact')
    global static List<getSAsActionResult> getSAs(List<Contact> requests) 
    {
        List<getSAsActionResult> results = new List<getSAsActionResult>();
        
        For (Contact currentContact : requests)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                getSAsActionResult result = new getSAsActionResult();
                
                try {
                    result.SAsPast = [SELECT ID, AppointmentNumber, Duration, Subject, Status, WorkTypeId, AccountID, Address, SchedStartTime, SchedEndTime, ParentRecordId, OwnerId, SchStartTimeFormatted__c, SchStartDateFormatted__c, SchEndTimeFormatted__c, SchEndDateFormatted__c FROM ServiceAppointment WHERE ContactID =: currentContact.Id AND SchedEndTime <: DateTime.now() ORDER BY SchedEndTime DESC LIMIT 10];
                    if (result.SAsPast == null || result.SAsPast.size() == 0)
                    {
                        result.SAsPast = new List<ServiceAppointment>();
                    }
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }

                try {
                    result.SAsFuture = [SELECT ID, AppointmentNumber, Duration, Subject, Status, WorkTypeId, AccountID, Address, SchedStartTime, SchedEndTime, ParentRecordId, OwnerId, SchStartTimeFormatted__c, SchStartDateFormatted__c, SchEndTimeFormatted__c, SchEndDateFormatted__c FROM ServiceAppointment WHERE ContactID =: currentContact.Id AND SchedEndTime >=: DateTime.now() ORDER BY SchedEndTime LIMIT 10];
                    if (result.SAsFuture == null || result.SAsFuture.size() == 0)
                    {
                        result.SAsFuture = new List<ServiceAppointment>();
                    }
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
                
                results.add(result);
                return results;
            }
            break;
        }
        
        return new List<getSAsActionResult>();
    }
    
    global class getSAsActionResult
    {
        @InvocableVariable(required=true)
        global List<ServiceAppointment> SAsPast;
        @InvocableVariable(required=true)
        global List<ServiceAppointment> SAsFuture;
    }
}