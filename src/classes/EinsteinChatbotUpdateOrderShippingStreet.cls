global class EinsteinChatbotUpdateOrderShippingStreet 
{
	@InvocableMethod(label='Einstein Chatbots - Update Order Shipping Address' description='Update Order Shipping Street Address')
    global static List<Order> updateOrderShippingAddress(List<ShippingAddressUpdate> requests) 
    {  
        List<Order> results = new List<Order>();
        For (ShippingAddressUpdate objOrder : requests)
        {
            if (objOrder != null && objOrder.objSA != null && String.IsNotBlank(objOrder.objSA.Id) && objOrder.Street != null)
            {
                Order objSA = objOrder.objSA;
                objSA.ShippingStreet = objOrder.Street;
                objSA.ShippingCity = objOrder.City;
                objSA.ShippingState = objOrder.State;
                update objSA;
                results.add(objSA);
                return results; 
            }
            break;
        }
        
        return new List<Order>{new Order()};
    }
    global class ShippingAddressUpdate 
    {
        @InvocableVariable(required=true)
        global Order objSA;
        
        @InvocableVariable(required=true)
        global String Street;
        
        @InvocableVariable(required=true)
        global String City;
        
        @InvocableVariable(required=true)
        global String State;
    }
}