global class EinsteinChatbotsFindB2BLEOrderCount {
    @InvocableMethod(label='Einstein Chatbots - Find B2BLE Order Count for Contact' description='Returns a Count of B2B Orders related to the specified Contact.')
    global static List<getOrderCountActionResult> getCCOrderCount(List<Contact> thisContact) 
    {
        List<getOrderCountActionResult> results = new List<getOrderCountActionResult>();
         User currentUser; 
         getOrderCountActionResult result = new getOrderCountActionResult();
        
        For (Contact currentContact : thisContact)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                
                List<User> Users = [SELECT Id, ContactId FROM User WHERE ContactId = :currentContact.id LIMIT 1];
                
                if (Users != null && Users.size() > 0)
                {
                	currentUser = Users.get(0);
                }else{
                    result.orderCount = -1;
                    results.add(result);
                    return results;
                }
                
               
                try{
                    result.orderCount = [SELECT COUNT() FROM Order WHERE OwnerId   =: currentUser.Id];
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    result.orderCount = -1;
                }
  
                results.add(result);
                return results;
            }
          //  break;
                    result.orderCount = -1;
                    results.add(result);
                    return results;
        }
        
        return new List<getOrderCountActionResult>();
    }
    
    global class getOrderCountActionResult
    {
        @InvocableVariable(required=true)
        global Integer orderCount;
    }

}