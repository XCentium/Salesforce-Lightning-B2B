public class EinsteinChatbotsFindB2BOrders {
	@InvocableMethod(label='Einstein Chatbots - Find B2B Orders For Contact' description='Returns B2B rders for the specified Contact')
    public static List<List<ccrz__E_Order__c>> findOrdersForContact(List<Contact> thisContact) 
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
        
        Map<Id, List<ccrz__E_Order__c>> contactOrdersMap = new Map<Id, List<ccrz__E_Order__c>>();
        
        for(ccrz__E_Order__c o : [SELECT Id, Name, ccrz__TotalAmount__c, ccrz__OrderStatus__c, ccrz__Contact__c, ccrz__OrderNumber__c ,ccrz__ShipMethod__c FROM ccrz__E_Order__c WHERE ccrz__Contact__c in :contactIds ORDER by CreatedDate desc LIMIT 3])
        {
            if(!contactOrdersMap.containsKey(o.ccrz__Contact__c))
            {
                contactOrdersMap.put(o.ccrz__Contact__c, new List<ccrz__E_Order__c>());
            }
            contactOrdersMap.get(o.ccrz__Contact__c).add(o);
        }

        List<List<ccrz__E_Order__c>> results = new List<List<ccrz__E_Order__c>>();
        for(Contact currentContact : thisContact)
        {
            List<ccrz__E_Order__c> orders = contactOrdersMap.get(currentContact.Id);
            if(orders == null)
            {
                results.add(new List<ccrz__E_Order__c>());
                continue;
            }
            EinsteinChatbotsB2BOrdersHelper.addOrderSummaries(orders);
            results.add(orders);
        }
        return results;
    }    
}