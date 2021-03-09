global class EinsteinChatbotsFindServiceApptsCount 
{
    @InvocableMethod(label='Einstein Chatbots - Find Service Appointments Count for Contact')
    global static List<getSAcActionResult> getSAc(List<Contact> requests) 
    {
        List<getSAcActionResult> results = new List<getSAcActionResult>();
        
        For (Contact currentContact : requests)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                getSAcActionResult result = new getSAcActionResult();
                try{
                    result.SAcPast = [SELECT COUNT() FROM ServiceAppointment WHERE ContactID =: currentContact.Id AND SchedEndTime <: DateTime.now()];
                    result.SAcFuture = [SELECT COUNT() FROM ServiceAppointment WHERE ContactID =: currentContact.Id AND SchedEndTime >=: DateTime.now()];
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    result.SAcPast = -1;
                    result.SAcFuture = -1;
                }
  
                results.add(result);
                return results;
            }
            break;
        }
        
        return new List<getSAcActionResult>();
    }
    
    global class getSAcActionResult
    {
        @InvocableVariable(required=true)
        global Integer SAcPast;
        @InvocableVariable(required=true)
        global Integer SAcFuture;
    }
}