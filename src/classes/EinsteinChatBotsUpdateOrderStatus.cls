public class EinsteinChatBotsUpdateOrderStatus {
	@InvocableMethod(label='Einstein Chatbots - Update Order Shipping Method' description='Update Order Shipping Method')
    public static List<Order> updateOrderShipping(List<Order> thisOrder) 
    {  
        if(thisOrder == null || thisOrder.size() == 0)
        {
            return null;
        }
        
        List<Order> results = new List<Order>();
        for(Order currentOrder : thisOrder)
        {
            currentOrder.Status = 'Activated';
            update currentOrder;
            results.add(currentOrder);
        }
        return results;
    }
}