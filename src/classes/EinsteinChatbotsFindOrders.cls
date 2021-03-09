public with sharing class EinsteinChatbotsFindOrders 
{

    @InvocableMethod(label='Einstein Chatbots - Find Orders For Contact' description='Returns orders for the specified Contact')
    public static List<List<Order>> findOrdersForContact(List<Contact> thisContact) 
    {
        if(thisContact == null || thisContact.size() == 0) 
        {
            return null;
        }
                
        Set<Id> contactIds = new Set<Id>();
        for(Contact currentContact : thisContact)
        {
            contactIds.add(currentContact.Id);
        }
        
        Map<Id, List<Order>> contactOrdersMap = new Map<Id, List<Order>>();
        
        for(Order o : [SELECT Id, Name, TotalAmount, Description, Status, BillToContactId, OrderNumber,Shipping_Method__c FROM Order WHERE BillToContactId in :contactIds ORDER by OrderNumber desc LIMIT 3])
        {
            if(!contactOrdersMap.containsKey(o.BillToContactId))
            {
                contactOrdersMap.put(o.BillToContactId, new List<Order>());
            }
            contactOrdersMap.get(o.BillToContactId).add(o);
        }

        List<List<Order>> results = new List<List<Order>>();
        for(Contact currentContact : thisContact)
        {
            List<Order> orders = contactOrdersMap.get(currentContact.Id);
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