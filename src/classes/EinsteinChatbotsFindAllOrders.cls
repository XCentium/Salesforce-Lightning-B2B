public class EinsteinChatbotsFindAllOrders {

    @InvocableMethod(label='Einstein Chatbots - Find All Orders For Contact' description='Returns orders for the specified Contact')
    public static List<List<Order>> findAllOrdersForContact(List<Contact> thiscontact) 
    {
        if(thiscontact == null || thiscontact.size() == 0)
        {
            return null;
        }
                
        Set<Id> contactIds = new Set<Id>();
        for(Contact c : thiscontact)
        {
            contactIds.add(c.Id);
        }
        
        Map<Id, List<Order>> contactOrdersMap = new Map<Id, List<Order>>();
        
        for(Order o : [SELECT Id, Name, TotalAmount, Description, Status, BillToContactId, Shipping_Method__c, OrderNumber FROM Order WHERE BillToContactId in :contactIds ORDER by CreatedDate desc LIMIT 3])
        {
            if(!contactOrdersMap.containsKey(o.BillToContactId))
            {
                contactOrdersMap.put(o.BillToContactId, new List<Order>());  
            }
            contactOrdersMap.get(o.BillToContactId).add(o);
        }

        List<List<Order>> results = new List<List<Order>>();
        for(Contact c : thiscontact)
        {
            List<Order> orders = contactOrdersMap.get(c.Id);
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