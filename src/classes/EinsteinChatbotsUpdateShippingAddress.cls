global class EinsteinChatbotsUpdateShippingAddress {
	@InvocableMethod(label='Einstein Chatbots - Update Order Shipping Address' description='Changes Order Shipping Address')
    public static List<Order> UpdateShippingAddress(List<UpdateStringRequest> requests) 
    {                   
        List<Order> results = new List<Order>();
        
        For (UpdateStringRequest request : requests)
        { 
           if (request.objOrder != null && request.objOrder.Id != null)
           {
               Order o = request.objOrder;
			   o.ShippingStreet  = request.Street;
               o.ShippingCity  = request.City;
               o.ShippingState  = request.State;
               update o;
               results.add(o);
           }
        }  
        return results;    
    }
    
    global class UpdateStringRequest
    {
        @InvocableVariable(required=true)
        global Order objOrder;
        
        @InvocableVariable(required=true) 
        global string Street;
        
        @InvocableVariable(required=true)
        global string City;
        
        @InvocableVariable(required=true)
        global string State;
        
    }
}