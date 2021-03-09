public class Customer360Controller {
    
	@AuraEnabled
    public static SObject getRecordDetails(Id recordId){
        String objectType = String.valueOf(recordId.getSobjectType());
        if(objectType == 'Account'){
            return [Select Id, Name From Account Where Id = :recordId];
        } else {
            return [Select Id, Name From Contact Where Id = :recordId];
        }
    }
    
	@AuraEnabled
    public static List<C360_Address__c> getAccountAddresses(Id recordId){
        String objectType = String.valueOf(recordId.getSobjectType());
        
        String queryString = 'SELECT Id,Email__c,Phone__c, Phone_Type__c,Account__c,City__c,Contact__c,Country__c,Postal_Code__c,State__c,Street__c,Address_Type__c'; 
        queryString += ' FROM C360_Address__c';
        
        if(objectType == 'Account') queryString += ' Where Account__c = :recordId';
        if(objectType == 'Contact') queryString += ' Where Contact__c = :recordId';
        
        return Database.query(queryString);
    }
    
	@AuraEnabled
    public static List<Order> getOrders(Id recordId){
        return [Select Id From Order Where AccountId = :recordId];
    }
    
    @AuraEnabled
    public static Order getOrderDetails(Id recordId){
        try{
            return [Select Id, TotalAmount, Tax__c, Shipping__c, ShippingAddress, Account.Name,LastModifiedDate From Order Where Id = :recordId];
        } catch(Exception e){
            System.debug(e.getMessage());
            return new Order();
        }
    }
    
    
	@AuraEnabled
    public static List<OrderItem> getOrderLineItems(Id recordId){
        return [Select Id, Product2.Name, ListPrice, Quantity, UnitPrice, TotalPrice From OrderItem Where OrderId = :recordId];
    }
}