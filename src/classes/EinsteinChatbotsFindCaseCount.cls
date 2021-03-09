global class EinsteinChatbotsFindCaseCount 
{
    @InvocableMethod(label='Einstein Chatbots - Find Case Count For Contact' description='Returns a Count of Cases for the specified Contact')
    global static List<getCAScActionResult> getCASc(List<Contact> requests)
    {
        List<getCAScActionResult> results = new List<getCAScActionResult>();
        for (Contact request : requests) 
        {
            if (request.Id != null)
            {
                 getCAScActionResult result = new getCAScActionResult();
                 try{
                     result.CASc = [SELECT COUNT() FROM Case WHERE ContactId =: request.Id]; 
                 } catch(DmlException e) {
                     System.debug('The following exception has occurred: ' + e.getMessage());
                     result.CASc = -1;
                 }
                 results.add(result);
                 return results;
             }
             break;
         }
         return new List<getCAScActionResult>();
    }

    global class getCAScActionResult
    {
        @InvocableVariable(required=true)
        global Integer CASc;
    }
}