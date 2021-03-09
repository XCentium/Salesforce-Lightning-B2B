public class EinsteinChatBotsCancelB2BOrder {
	@InvocableMethod(label='Einstein Chatbots - Cancel B2B Order' description='Cancel B2B Order')
    public static List<ccrz__E_Order__c> cancelB2bOrder(List<ccrz__E_Order__c> requests) 
    {  
        List<ccrz__E_Order__c> results = new List<ccrz__E_Order__c>();
        For (ccrz__E_Order__c objOrder : requests)
        {
            if (objOrder != null && String.IsNotBlank(objOrder.Id))
            {
                objOrder.ccrz__OrderStatus__c  = 'Cancelled';
                update objOrder;
                results.add(objOrder);
                return results; 
            }
            break;
        }
        
        return new List<ccrz__E_Order__c>{new ccrz__E_Order__c()};
    }
}