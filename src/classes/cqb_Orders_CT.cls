public class cqb_Orders_CT {
    @auraenabled
    public static OrderItem[] getOrders(Id RecId){
        String objName = String.valueOf(RecId.getSObjectType());
        String ContactId;
        switch on objName {
            when 'Contact' {        
                ContactId = String.valueOf(RecId);
            }   
            when 'Case' {       
                ContactId = [Select ContactId from Case Where Id=:RecId].ContactId;
            }
            when 'Account' {        
                ContactId = [Select PersonContactId from Account where Id=:RecId].PersonContactId;
            }           
        }
        
        Order[] myOrders = [Select Id from Order where BillToContactId=:ContactId];
        OrderItem[] uniqueOrderItems = new List<OrderItem>();
        
        for(Order o : myOrders) {
            OrderItem oi = [Select Id, OrderId, Order.OrderNumber, Order.EffectiveDate, Order.Name, Order.TotalAmount, Product2.purl__c from OrderItem Where OrderId=:o.Id Limit 1];
            uniqueOrderItems.add(oi);
        }
        
        return uniqueOrderItems;
    }
}