/* Written by Jesse Chase | jchase@salesforce.com
 * This is used by Next Best Action to check for Alpine Cooler in a cc order for the given contact
 */
global class nbaGoSmartPromotion {
	global class NBAResponse {
        @InvocableVariable
        global Integer numProducts;
    }
    
    global class NBAInput {
        @InvocableVariable
        global String recordId;
    }
    @InvocableMethod(label='GoSmart Promotion Check' description='Check if Alpine Cooler is in Orders and push promotion if so')
    global static List<NBAResponse> getNBAResults(List<NBAInput> inputs) {
        List<NBAResponse> responses = new List<NBAResponse>();
        
        for(NBAInput input : inputs) {
            NBAResponse response = new NBAResponse();
            
            response.numProducts = getNumberOfProducts(input.recordId); // Call method to get number of cases
            
            responses.add(response);
        }
        
        return responses;
    }
    private static Integer getNumberOfProducts(Id contId) {
        List<String> orderItemlist = new List<String>();
        List<ccrz__E_OrderItem__c> products = new List<ccrz__E_OrderItem__c>();
        Id cid;
        Id oid;
         
        Schema.SObjectType sobjectType = contId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        
        if(sobjectName == 'ccrz__E_Order__c'){ 
            for(ccrz__E_Order__c ord:[SELECT Id, (select Id                                             
        		FROM ccrz__E_OrderItems__r  WHERE  ccrz__Product__r.Name LIKE '%Cooler%' ) 
               		FROM ccrz__E_Order__c where Id = :contId ]){
                       for(ccrz__E_OrderItem__c oi : ord.ccrz__E_OrderItems__r){
                           orderItemlist.add(oi.id);
                       }    
        			}  
        }else if(sobjectName == 'Contact'){ 
            for(ccrz__E_Order__c ord:[SELECT Id, (select Id                                             
        	FROM ccrz__E_OrderItems__r WHERE  ccrz__Product__r.Name LIKE '%Cooler%' ) 
               FROM ccrz__E_Order__c where ccrz__Contact__c = :contId ]){
                   for(ccrz__E_OrderItem__c oi : ord.ccrz__E_OrderItems__r){
                       orderItemlist.add(oi.id);
                   }    
        	}  
        }else if(sobjectName == 'Case'){ 
            cid = [SELECT ContactId FROM Case WHERE Id = :contId].ContactId;
            for(ccrz__E_Order__c ord:[SELECT Id, (select Id                                             
        	FROM ccrz__E_OrderItems__r  WHERE  ccrz__Product__r.Name LIKE '%Cooler%' ) 
               FROM ccrz__E_Order__c where ccrz__Contact__c = :cid ]){
                   for(ccrz__E_OrderItem__c oi : ord.ccrz__E_OrderItems__r){
                       orderItemlist.add(oi.id);
                   }    
        	}  
        }else if(sobjectName == 'LiveChatTranscript'){ 
            cid = [SELECT ContactId FROM LiveChatTranscript WHERE Id = :contId].ContactId;
            for(ccrz__E_Order__c ord:[SELECT Id, (select Id                                             
        	FROM ccrz__E_OrderItems__r  WHERE  ccrz__Product__r.Name LIKE '%Cooler%' ) 
               FROM ccrz__E_Order__c where ccrz__Contact__c = :cid ]){
                   for(ccrz__E_OrderItem__c oi : ord.ccrz__E_OrderItems__r){
                       orderItemlist.add(oi.id);
                   }    
        	} 
            
        }else if(sobjectName == 'MessagingSession'){ 
            cid = [SELECT EndUserContactId  FROM MessagingSession WHERE Id = :contId].EndUserContactId;
            for(ccrz__E_Order__c ord:[SELECT Id, (select Id                                             
        	FROM ccrz__E_OrderItems__r  WHERE  ccrz__Product__r.Name LIKE '%Cooler%' ) 
               FROM ccrz__E_Order__c where ccrz__Contact__c = :cid ]){
                   for(ccrz__E_OrderItem__c oi : ord.ccrz__E_OrderItems__r){
                       orderItemlist.add(oi.id);
                   }    
        	} 
            
        }else{
            for(ccrz__E_Order__c ord:[SELECT Id, (select Id                                             
        	FROM ccrz__E_OrderItems__r  WHERE  ccrz__Product__r.Name LIKE '%Cooler%' ) 
               FROM ccrz__E_Order__c where Id = :contId ]){
                   for(ccrz__E_OrderItem__c oi : ord.ccrz__E_OrderItems__r){
                       orderItemlist.add(oi.id);
                   }    
        	}  
        }
        
        products = [Select Id from ccrz__E_OrderItem__c WHERE Id IN :orderItemlist];     
       	return products.size();     
    }
}