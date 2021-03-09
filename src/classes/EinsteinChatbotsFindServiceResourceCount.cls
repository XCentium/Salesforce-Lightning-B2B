global class EinsteinChatbotsFindServiceResourceCount
{
    @InvocableMethod(label='Einstein Chatbots - Find Service Resource Count' description='Returns a Count of Service Resources')
    global static List<getSRActionResult> getSR(List<ServiceAppointment> requests) 
    {
        List<getSRActionResult> results = new List<getSRActionResult>();
        For (ServiceAppointment objSA : requests)
        {
            if (objSA != null && String.IsNotBlank(objSA.Id))
            {
                getSRActionResult result = new getSRActionResult();
                //Try to get the Assigned Resource
                try{
                result.RESc = [SELECT COUNT() FROM AssignedResource WHERE ServiceAppointmentId =: objSA.Id];
                }catch (DmlException e) {
                     System.debug('The following exception has occurred: ' + e.getMessage());
                     result.RESc = -1;
                }
                results.add(result);
                return results;
            }
            break;
        }
        
        return new List<getSRActionResult>{new getSRActionResult()};
    }
    
    global class getSRActionResult
    {
        @InvocableVariable(required=true)
        global Integer RESc;
    }
}