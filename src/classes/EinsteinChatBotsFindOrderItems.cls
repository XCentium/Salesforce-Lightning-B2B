public class EinsteinChatBotsFindOrderItems {
	@InvocableMethod(label='Einstein Chatbots - Find Orders Items by Order' description='Returns Order Product Items')
    public static List<List<OrderItem>> findOrderItems(List<Order> orders) 
    {  
        
        Set<Id> orderIds = new Set<Id>();
        for(Order o : orders)
        {
            orderIds.add(o.Id); 
        }
        
        
        List<OrderItem> ListOrderItems = new List<OrderItem>();
        
        For (Order currentOrder : orders)
        {
            if (currentOrder != null && String.IsNotBlank(currentOrder.id))
            {
                List<OrderItem> OrderItems = [SELECT Product_Name__c ,Product2Id, Quantity ,OrderID, ListPrice FROM OrderItem Where OrderId in :orderIds LIMIT 3];
                if (OrderItems != null && OrderItems.size() > 0)
                {
                    return new List<List<OrderItem>>{OrderItems};
                }
                break;
            }
        }
        
        return new List<List<OrderItem>>{new List<OrderItem>{new OrderItem()}};
    }    
}