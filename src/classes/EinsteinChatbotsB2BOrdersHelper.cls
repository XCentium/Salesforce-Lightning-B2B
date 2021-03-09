public class EinsteinChatbotsB2BOrdersHelper {
	public static void addOrderSummaries(List<ccrz__E_Order__c> orders){
        Map<Id, List<ccrz__E_OrderItem__c >> orderItemsMap = new Map<Id, List<ccrz__E_OrderItem__c  >>();
        
        for(ccrz__E_OrderItem__c  item : [select Id
                                                  ,ccrz__Product__c
                                                  ,ccrz__Quantity__c 
                                                  ,ccrz__Order__c 
                                                  from ccrz__E_OrderItem__c 
                                                  where ccrz__Order__c  in :orders]){
            if(!orderItemsMap.containsKey(item.ccrz__Order__c )){
                orderItemsMap.put(item.ccrz__Order__c , new List<ccrz__E_OrderItem__c >());                              
            }
            orderItemsMap.get(item.ccrz__Order__c).add(item);                             
        }
        
        for(ccrz__E_Order__c order : orders){
            List<ccrz__E_OrderItem__c> orderItems = orderItemsMap.get(order.Id);
            if(orderItems == null || orderItems.size() == 0){
                continue;
            }
            String summary = 'Order Items : \n\n';
            for(ccrz__E_OrderItem__c  item : orderItems){
                summary += ''+Integer.valueOf(item.ccrz__Quantity__c)+' '+item.ccrz__Product__c+'\n';
            }
            order.ccrz__Note__c = summary;
        }
    }
}