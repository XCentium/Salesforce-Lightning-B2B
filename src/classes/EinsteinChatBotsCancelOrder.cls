public class EinsteinChatBotsCancelOrder {
	@InvocableMethod(label='Einstein Chatbots - Cancel Order' description='Cancel and Order')
    public static List<Order> findOrdersForContact(List<Order> requests) 
    {  
        List<Order> results = new List<Order>();
        For (Order objOrder : requests)
        {
            if (objOrder != null && String.IsNotBlank(objOrder.Id))
            {
                objOrder.Status  = 'Cancelled';
                update objOrder;
                results.add(objOrder);
                return results; 
            }
            break;
        }
        
        return new List<Order>{new Order()};
    }
}