global class EinsteinChatbotsFindCCOrderCount {
	@InvocableMethod(label='Einstein Chatbots - Find CC Order Count for Contact' description='Returns a Count of CC Orders related to the specified Contact.')
    global static List<getOrderCountActionResult> getCCOrderCount(List<Contact> thisContact) 
    {
        List<getOrderCountActionResult> results = new List<getOrderCountActionResult>();
        
        For (Contact currentContact : thisContact)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                getOrderCountActionResult result = new getOrderCountActionResult();
                try{
                    result.orderCount = [SELECT COUNT() FROM ccrz__E_Order__c WHERE ccrz__Contact__c  =: currentContact.Id];
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