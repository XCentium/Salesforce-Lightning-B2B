public class ContactRecentOrders {
	@AuraEnabled 
	public static List<Product2> getProducts(String ContactID, INTEGER lim) { 
        /*Add last 3 order Id's to Array */
        String[] OrderIds = new String[] {};
        for (Order oId : [
                SELECT Id 
                FROM Order
                WHERE (BillToContactId  = :ContactID OR AccountId = :ContactID)
            	ORDER BY Id ASC 
            	LIMIT 10
                ]) {
            OrderIds.add(oId.Id);
        }
        /*Add All OrderItems to Array from Orders above*/
        String[] ProdIds = new String[] {};
        for (OrderItem ItemId : [
                SELECT Product2Id
                FROM OrderItem
                WHERE OrderId IN :OrderIds
                ]) {
            ProdIds.add(ItemId.Product2Id);
        }
        /*Get Product Information from above OrderItems*/
        List<Product2> products = [
            SELECT Id, Name, Description, purl__c,Resource_File_Image__c 
            FROM Product2
            WHERE Id IN :ProdIds And (NOT purl__c like'%no_product_image%')
            LIMIT :lim 
        ];
        return products;
    }
}