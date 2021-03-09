public class recommendedProducts {
	@AuraEnabled 
	public static List<Product2> getProduct(String ProductID,String ProductID2) {
        List<String> ProductList = new List<String>{ProductID,ProductID2};
        List<Product2> products = new LIST<Product2>();  
        products=[Select Name,Id,MSRP__c ,Description,purl__c   from Product2 WHERE Name IN :ProductList ORDER BY Name DESC]; 
        return products; 
    }
}