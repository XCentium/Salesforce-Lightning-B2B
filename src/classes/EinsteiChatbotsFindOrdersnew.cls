global class EinsteiChatbotsFindOrdersnew {
    @InvocableMethod(label='Einstein Chatbots - Find Orders By Contact - New')
    global static List<Order> findOrdersForContact(List<Contact> thiscontact) 
    {
        List<Order> results = new List<Order>();
        
        if(thiscontact == null || thiscontact.size() == 0)
        {
            return null;
        }
        Set<Id> contactIds = new Set<Id>();
        for(Contact c : thiscontact)
        {
            contactIds.add(c.Id);
        }
        
        
        LIST<Order> newOrders = [SELECT Id, TotalAmount, Description, Status, BillToContactId, OrderNumber, ShippingAddress, ShippingCity,ShippingStreet,ShippingState  FROM Order WHERE BillToContactId in :contactIds ORDER by CreatedDate desc LIMIT 3];      
        
        if (newOrders != null && newOrders.size() > 0) {
            return newOrders;
        } else {
            return results; 
        }
	}
}