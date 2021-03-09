public class EinsteinChatbotsFindB2BLEOrders {
    @InvocableMethod(label='Einstein Chatbots - Find B2BLE Orders For Contact' description='Returns B2BLE orders for the specified Contact')
    public static List<List<Order>> findOrdersForContact(List<Contact> thisContact) 
    {
        if(thisContact == null || thisContact.size() == 0)
        {
            return null;
        }
                
        Set<Id> contactIds = new Set<Id>();
        
        User currentUser; 
        User thisUser;
         List<User> Users;
        
        for(Contact currentContact : thisContact)
        {
            contactIds.add(currentContact.Id);

                 Users = [SELECT Id, ContactId FROM User WHERE ContactId = :currentContact.id LIMIT 1];
                
                if (Users != null && Users.size() > 0)
                {
                	currentUser = Users.get(0);
                    system.debug('User Found');
                }else{
                     system.debug('No User Found');
                    return null;
                }
		}  
        
        
        Map<Id, List<Order>> contactOrdersMap = new Map<Id, List<Order>>();
        
        for(Order o : [SELECT Id, Name, TotalAmount, Description, Status, BillToContactId,OwnerId, OrderNumber FROM Order WHERE OwnerId=:currentUser.Id ORDER by CreatedDate desc LIMIT 3])
        {
            if(!contactOrdersMap.containsKey(o.OwnerId))
            {
                contactOrdersMap.put(o.OwnerId, new List<Order>());
            }
            contactOrdersMap.get(o.OwnerId).add(o);
        }

        List<List<Order>> results = new List<List<Order>>();
        
        for(User currentUser2 : Users)
        {
            List<Order> orders = contactOrdersMap.get(currentUser2.Id);
            if(orders == null)
            {
                results.add(new List<Order>());
                continue;
            }
            EinsteinChatbotsOrdersHelper.addOrderSummaries(orders);
            results.add(orders);
        }
        return results;
    }    
}