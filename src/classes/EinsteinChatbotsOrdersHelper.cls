public with sharing class EinsteinChatbotsOrdersHelper {

    public static void addOrderSummaries(List<Order> orders){
        Map<Id, List<OrderItem>> orderItemsMap = new Map<Id, List<OrderItem >>();
        
        for(OrderItem item : [select Id
                                                  ,Product2Id
                                                  ,Quantity 
                                                  ,OrderId
                                                  from OrderItem
                                                  where OrderId in :orders]){
            if(!orderItemsMap.containsKey(item.OrderId)){
                orderItemsMap.put(item.OrderId, new List<OrderItem>());                              
            }
            orderItemsMap.get(item.OrderId).add(item);                             
        }
        
        for(Order order : orders){
            List<OrderItem> orderItems = orderItemsMap.get(order.Id);
            if(orderItems == null || orderItems.size() == 0){
                continue;
            }
            String summary = 'Order Items : \n\n';
            for(OrderItem item : orderItems){
                summary += ''+Integer.valueOf(item.Quantity)+' '+item.Product2Id+'\n';
            }
            order.Description = summary;
        }
    }
    
}