global class EinsteinChatbotsFindAssetCount 
{
    @InvocableMethod(label='Einstein Chatbots - Find Asset Count for Contact')
    global static List<getASScActionResult> getASSc(List<Contact> requests) 
    {
        List<getASScActionResult> results = new List<getASScActionResult>();
        
        For (Contact currentContact : requests)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                getASScActionResult result = new getASScActionResult();
                try{
                    result.ASSc = [SELECT COUNT() FROM Asset WHERE ContactId  =: currentContact.Id];
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    result.ASSc = -1;
                }
  
                results.add(result);
                return results;
            }
            break;
        }
        
        return new List<getASScActionResult>();
    }
    
    global class getASScActionResult
    {
        @InvocableVariable(required=true)
        global Integer ASSc;
    }
}