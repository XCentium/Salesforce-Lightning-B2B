public class Clienteling_Add_Products_To_Order {
	@AuraEnabled
    public static List<PriceBookEntry> getProducts(String OrderId) {
        String pbookId = [SELECT Id,Pricebook2Id FROM Order WHERE ID = :OrderId ].Pricebook2Id;
        return [Select Product2Id,ProductCode,UnitPrice ,product2.Id,product2.Name,product2.purl__c,product2.Description,product2.MSRP__c from PriceBookEntry WHERE Pricebook2Id = :pbookId AND IsActive = true AND (NOT Name like '%Warranty%') AND (NOT Name like '%Logo%') AND (NOT Name like '%Bundle%') Order By Name Limit 10];
    }
    @AuraEnabled
    public static List<PriceBookEntry> getSingleProducts(String ProdId, String OrderId) {
        String pbookId = [SELECT Pricebook2Id FROM Order WHERE ID = :OrderId ].Pricebook2Id;
        return [Select Id,ProductCode,Product2Id,UnitPrice ,product2.Id,product2.Name,product2.purl__c,product2.Description FROM PriceBookEntry WHERE Pricebook2Id = :pbookId AND Product2Id = :ProdId];  
    } 
    @AuraEnabled
    public static List<PriceBookEntry> getFilteredProducts(String SearchPhrase,String OrderId) {
        String sp = '%' + SearchPhrase + '%';
        String pbookId = [SELECT Pricebook2Id FROM Order WHERE ID = :OrderId ].Pricebook2Id;
        return [Select Id,ProductCode,Product2Id,UnitPrice ,product2.Id,product2.Name,product2.purl__c,product2.Description,product2.MSRP__c from PriceBookEntry WHERE Pricebook2Id = :pbookId AND IsActive = true AND ((product2.Name LIKE :sp) OR (ProductCode LIKE :sp) OR (product2.Description LIKE :sp)) Order By Name Limit 10];
    }
    @AuraEnabled
    public static List<OrderItem> addProduct(String OrderId, String ProdId, Integer Quantity) {  
        String OId = OrderId; 
		String PId = ProdId;
        Integer quan = Quantity;

		List<OrderItem> oitems = [Select Id,Product2Id,Quantity FROM OrderItem Where OrderId = :OId AND Product2Id = :ProdId AND Quantity > 0];
        if(oitems.isEmpty()) {
            String pbookId = [SELECT Pricebook2Id FROM Order WHERE Id = :OId].Pricebook2Id;
            String EntryId = [SELECT Id FROM PricebookEntry WHERE Product2Id = :PId AND (Pricebook2Id = :pbookId)].Id;
            Decimal up = [SELECT UnitPrice FROM PricebookEntry WHERE Product2Id = :PId AND (Pricebook2Id = :pbookId)].UnitPrice;
    
            OrderItem oi = New OrderItem();
                oi.Quantity = quan;
                oi.Product2Id = PId;
                oi.OrderId  = OId;
                oi.PricebookEntryId = EntryId;
                oi.UnitPrice = up;
                insert oi;  
        }else{
            if(quan > 0){
                OrderItem oitemsupdate = [Select Id,Product2Id,Quantity FROM OrderItem Where OrderId = :OId AND Product2Id = :ProdId];
                oitemsupdate.Quantity = quan;
                update oitemsupdate;
            }
            else{
                OrderItem doomedOItem = [Select Id,Product2Id,Quantity FROM OrderItem Where OrderId = :OId AND Product2Id = :ProdId];
                delete doomedOItem;
            }

        }
        return [SELECT Product2Id,Quantity FROM OrderItem WHERE OrderId = :OrderId];  
    }
    
}