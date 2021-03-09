public class EinsteinChatbotsShipToStore {
	@InvocableMethod(label='Einstein Chatbots - Ship Order to Store' description='Changes Order Shipping_Method__c Field to Ship to preferred store')
    public static List<Order> shipOrderToStore(List<Order> thisOrder) 
    {           
        if(thisOrder == null || thisOrder.size() == 0)
        {
            return null;
        }
        
        List<Order> results = new List<Order>();
        for(Order currentOrder : thisOrder)
        {
            currentOrder.Shipping_Method__c = 'Pickup - Preferred Store';
            update currentOrder;
            results.add(currentOrder);
        }
        return results;    
    }
}