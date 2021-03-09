/* Written by Jesse Chase | jchase@salesforce.com
 * This is used by Next Best Action to check if the Contact has any CC Carts to apply coupon codes to
 */
global class nbaCCcartCheck {
	global class NBAResponse {
        @InvocableVariable
        global Integer numCoupons;
    }
    
    global class NBAInput {
        @InvocableVariable
        global String contactId;
    }
    @InvocableMethod(label='CC Cart Check' description='Return total cc carts available for coupons')
    global static List<NBAResponse> getNBAResults(List<NBAInput> inputs) {
        List<NBAResponse> responses = new List<NBAResponse>();
        
        for(NBAInput input : inputs) {
            NBAResponse response = new NBAResponse();
            
            response.numCoupons = getNumberOfCarts(input.contactId); // Call method to get number coupons on CC Cart
            
            responses.add(response);
        }
        
        return responses;
    }
    private static Integer getNumberOfCarts(Id contId) {
        List<ccrz__E_CartCoupon__c> CCcouponList = new List<ccrz__E_CartCoupon__c>();
        
        Integer couponsSet;
        Id cid;
        Id ccCart;
         
        Schema.SObjectType sobjectType = contId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        
        if(sobjectName == 'Contact'){
            cid = contId;
            ccCart = [Select Id From ccrz__E_Cart__c Where (ccrz__Contact__c = :contId) AND (ccrz__ActiveCart__c = true) LIMIT 1].Id;
        }else if(sobjectName == 'Case'){
            cid = [Select ContactId From Case WHERE Id = :contId].ContactId;
            ccCart = [Select Id From ccrz__E_Cart__c Where (ccrz__Contact__c = :cid) AND (ccrz__ActiveCart__c = true) LIMIT 1].Id; 
        }else if(sobjectName == 'LiveChatTranscript'){
            cid = [Select ContactId From LiveChatTranscript WHERE Id = :contId].ContactId;
            ccCart = [Select Id From ccrz__E_Cart__c Where (ccrz__Contact__c = :cid) AND (ccrz__ActiveCart__c = true) LIMIT 1].Id; 
        }else if(sobjectName == 'MessagingSession'){
            cid = [SELECT EndUserContactId  FROM MessagingSession WHERE Id = :contId].EndUserContactId;
            ccCart = [Select Id From ccrz__E_Cart__c Where (ccrz__Contact__c = :cid) AND (ccrz__ActiveCart__c = true) LIMIT 1].Id; 
        }      
        CCcouponList = [Select Id from ccrz__E_CartCoupon__c WHERE ccrz__Cart__c = :ccCart];     
        return CCcouponList.size();     
    }
}