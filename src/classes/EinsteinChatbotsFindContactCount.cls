global class EinsteinChatbotsFindContactCount
{
    @InvocableMethod(label='Einstein Chatbots - Find Contact Count By Email')
    global static List<getCONcActionResult> getCONc(List<string> requests)
    {
        List<getCONcActionResult> results = new List<getCONcActionResult>();
        for (string request : requests) 
        {
            if (String.IsNotBlank(request))
            {
                 getCONcActionResult result = new getCONcActionResult();
                 try{
                     result.CONc = [SELECT COUNT() FROM Contact WHERE email =: request]; 
                 } catch(DmlException e) {
                     System.debug('The following exception has occurred: ' + e.getMessage());
                     result.CONc = -1;
                 }
                 results.add(result);
                 return results;
             }
             break;
         }
         return new List<getCONcActionResult>();
    }

    global class getCONcActionResult
    {
        @InvocableVariable(required=true)
        global Integer CONc;
    }
}