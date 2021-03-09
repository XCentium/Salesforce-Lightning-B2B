public class Flow_getProductstoRegister {
	@AuraEnabled 
	public static List<Product2> getProduct() {
        List<Product2> products = new LIST<Product2>();  
        products=[Select Name,Id, purl__c  from Product2 WHERE Available_to_Register__c = TRUE ORDER BY Name DESC]; 
        return products; 
    }
    
    @AuraEnabled 
	public static List<Product2> getOrderProduct(string oid) {
        List<String> productlist = new List<String>();
        List<Product2> products = new List<Product2>();
        
        for(order ord:[SELECT Id,name,(select Id,
               PricebookEntry.Product2.Name,
               Product2.id 
               FROM OrderItems WHERE NOT PricebookEntry.Product2.Name LIKE '%Warranty%' ) from order where id = :oid]){
                   for(OrderItem oi : ord.orderItems){
                       productlist.add(oi.Product2.id);
                   }    
        }
        
        products=[Select Name,Id, purl__c from Product2 WHERE Id IN :productlist  ORDER BY Name DESC]; 
        return products;
    }
    
    @AuraEnabled 
	public static List<OrderItem> getOrderWarrantyProduct(string cid) {
        List<String> productlist = new List<String>();
        List<String> orderItemlist = new List<String>();
        List<OrderItem> products = new List<OrderItem>();
        
        for(order ord:[SELECT Id,name,OrderNumber, (select Id,
               	PricebookEntry.Product2.Name,
               	Product2.id                                                 
               	FROM OrderItems WHERE (NOT PricebookEntry.Product2.Name LIKE '%Warranty%') AND (PricebookEntry.Product2.Available_for_Warranty__c = true) ) 
               FROM order where BillToContactId = :cid AND Status != 'Draft' AND Status != 'Cancelled' AND Status != 'Rejected']){
                   for(OrderItem oi : ord.orderItems){
                       productlist.add(oi.Product2.id);
                       orderItemlist.add(oi.id);
                   }    
        }
        products=[Select Product2.Name,Id, Product2.purl__c, Order.OrderNumber from OrderItem WHERE Id IN :orderItemlist ORDER BY Product2.Name DESC]; 
        
        return products;
    }
    
    @AuraEnabled 
	public static List<OrderItem> getOrderItems(string cid,string oid) {
        List<String> orderItemlist = new List<String>();
        List<OrderItem> products = new List<OrderItem>();
        
        if(oid != '' && oid != null){
            for(order ord:[SELECT Id,name,OrderNumber, (select Id,PricebookEntry.Product2.Name FROM OrderItems WHERE (NOT PricebookEntry.Product2.Name LIKE '%Warranty%') ) 
            	FROM order where Id = :oid AND BillToContactId = :cid AND Status != 'Draft' AND Status != 'Cancelled' AND Status != 'Rejected']){
                	for(OrderItem oi : ord.orderItems){
                    	orderItemlist.add(oi.id);
                    }    
            }
        }else{
            for(order ord:[SELECT Id,name,OrderNumber, (select Id,
                    PricebookEntry.Product2.Name                                                 
                    FROM OrderItems WHERE (NOT PricebookEntry.Product2.Name LIKE '%Warranty%') ) 
                   FROM order where BillToContactId = :cid AND Status != 'Draft' AND Status != 'Cancelled' AND Status != 'Rejected']){
                       for(OrderItem oi : ord.orderItems){
                           orderItemlist.add(oi.id);
                       }    
            }
        }
        products=[Select Product2.Name,Id, Product2.purl__c, Product2.MSRP__c, Order.OrderNumber from OrderItem WHERE Id IN :orderItemlist ORDER BY Order.OrderNumber DESC]; 
        return products;
    }
    
    @AuraEnabled
    public static String getLastCCOrderAvailable(String cid) {
        List<String> orderItemlist = new List<String>();
        String orders ;

        for(ccrz__E_Order__c ord:[SELECT Id, (select Id, ccrz__Order__c                                               
        		FROM ccrz__E_OrderItems__r  WHERE  ccrz__Product__r.Available_for_Promotion__c  = TRUE ) 
               		FROM ccrz__E_Order__c where ccrz__Contact__c = :cid ]){
                       for(ccrz__E_OrderItem__c oi : ord.ccrz__E_OrderItems__r){
                           orderItemlist.add(oi.ccrz__Order__c);
                       }    
        			}
        orders = [Select Id from ccrz__E_Order__c WHERE Id IN :orderItemlist order by CreatedDate desc LIMIT 1].Id; 
        return orders;
    }
    

    @AuraEnabled
    public static List<ccrz__E_Product__c > getccPromotionalProducts(String cid) {
        List<ccrz__E_Product__c> orderItemlist = [SELECT Id, ccrz__ShortDesc__c ,Price__c ,Image_URI__c ,Name FROM ccrz__E_Product__c WHERE Promotional_Item__c = TRUE];
        return orderItemlist;
    }
	@AuraEnabled
    public static List<ccrz__E_Product__c> getccUpsellProducts(String oid) {
        List<String> orderItemlist = new List<String>();
        List<String> ccprodlist = new List<String>();
        
        for(ccrz__E_OrderItem__c ord:[SELECT Id, ccrz__Product__c  FROM ccrz__E_OrderItem__c where ccrz__Order__c  = :oid ]){
        	orderItemlist.add(ord.ccrz__Product__c); 
        }
        
        List<ccrz__E_Product__c > products = [SELECT Id,Available_for_Promotion__c,Name, Product__r.purl__c  FROM ccrz__E_Product__c WHERE Id IN :orderItemlist];
        return products;
    }
    
        
    @AuraEnabled 
	public static List<PriceBookEntry> getWarrantyProduct(String PricebookId) {
        List<PriceBookEntry> pricebookentry = [SELECT Id,Product2.Id, Product2.Name, Product2.MSRP__c, Product2.purl__c
                               FROM PriceBookEntry 
                               WHERE 
                               Name LIKE '%Warranty%' AND Name != 'Basic Warranty & Maintenance'                
                               AND Pricebook2Id = :PricebookId
                               ORDER BY Name ASC];
        return pricebookentry;
    }
}