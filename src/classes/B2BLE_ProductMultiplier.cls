public class B2BLE_ProductMultiplier {
  
    @InvocableMethod
    public static void updateCartItem(list<Id> activeCartitemOrId)
    {
        String webstoreId;
        String effectiveAccountId;
        String cartItemId;
        
		System.debug(activeCartitemOrId);
        
        CartItem currentCartItem = null;

        List<CartItem> cartItemList =[select CartId, Product2Id, Quantity, Id from CartItem where id=:activeCartitemOrId];
       
        If(cartItemList.size() > 0) {
            currentCartItem = cartItemList.get(0);
        }
        
        if(currentCartItem != null)
        {
            WebCart  currentCart = [select WebStoreId, AccountId  from WebCart where id=:currentCartItem.CartId];

            webstoreId = currentCart.WebStoreId;
            
            //Check if Multiplier Exists
            B2B_Product_Multiplier__c  currentMultipler = [select Account__c ,Product__c , Multiplier__c  from B2B_Product_Multiplier__c where Account__c=:currentCart.AccountId and Product__c=:currentCartItem.Product2Id ];
            
            if(currentMultipler != null)
            {
                Integer multiplier = Integer.ValueOf(currentMultipler.Multiplier__c);
                Integer currentQuantity = Integer.ValueOf(currentCartItem.Quantity);
                Integer newQuantity = 0;
                
                if(currentQuantity < (multiplier *1) && currentQuantity > 0){
                    newQuantity = multiplier *1;
                }
                 else if(currentQuantity < (multiplier * 2) && currentQuantity > (multiplier *1)){
                    newQuantity = multiplier * 2;
                }
                else if(currentQuantity < (multiplier * 3) && currentQuantity > (multiplier * 2)){
                    newQuantity = multiplier * 3;
                } 
                else if(currentQuantity < (multiplier * 4) && currentQuantity > (multiplier * 3)){
                    newQuantity = multiplier * 4;
                }
                else if(currentQuantity < (multiplier * 5) && currentQuantity > (multiplier * 4)){
                    newQuantity = multiplier * 5;
                }  
                else if(currentQuantity < (multiplier * 6) && currentQuantity > (multiplier * 5)){
                    newQuantity = multiplier * 6;
                } 
                else if(currentQuantity < (multiplier * 7) && currentQuantity > (multiplier * 6)){
                    newQuantity = multiplier * 7;
                } 
                else if(currentQuantity < (multiplier * 8) && currentQuantity > (multiplier * 7)){
                    newQuantity = multiplier * 8;
                } 
                else if(currentQuantity < (multiplier * 9) && currentQuantity > (multiplier * 8)){
                    newQuantity = multiplier * 9;
                }                 
                else if(currentQuantity < (multiplier * 10) && currentQuantity > (multiplier * 9)){
                    newQuantity = multiplier * 10;
                } 
                
                ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
                cartItemInput.productId = currentCartItem.Product2Id;
                cartItemInput.quantity = String.valueOf(newQuantity);
                cartItemInput.type = ConnectApi.CartItemType.Product;
                
                try{
                    ConnectApi.CommerceCart.updateCartItem(webstoreId, effectiveAccountId, currentCartItem.CartId,currentCartItem.Id, cartItemInput);                }
                catch(ConnectApi.ConnectApiException e){
                    
                    System.debug('Error Message : '+e);
                    //ApexPages.addMessages(e);
                    
                }
            }
        }

    }
}