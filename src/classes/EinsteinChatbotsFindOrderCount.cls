global class EinsteinChatbotsFindOrderCount 
{
    @InvocableMethod(label='Einstein Chatbots - Find Order Count for Contact' description='Returns a Count of Orders related to the specified Contact.')
    global static List<getOrderCountActionResult> getOrderCount(List<Contact> thisContact) 
    {
        List<getOrderCountActionResult> results = new List<getOrderCountActionResult>();
        
        For (Contact currentContact : thisContact)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                getOrderCountActionResult result = new getOrderCountActionResult();
                try{
                    result.orderCount = [SELECT COUNT() FROM Order WHERE BillToContactId  =: currentContact.Id];
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    result.orderCount = -1;
                }
  
                results.add(result);
                return results;
            }
            break;
        }
        
        return new List<getOrderCountActionResult>();
    }
    
    global class getOrderCountActionResult
    {
        @InvocableVariable(required=true)
        global Integer orderCount;
    }
}