/* Written by Jesse Chase | jchase@salesforce.com
 * This is used by Next Best Action to check for any products available for warranty in contact orders 
 */
global with sharing class nbaWarrantyCheck {   
    global class NBAResponse {
        @InvocableVariable
        global Integer numProducts;
    }
    
    global class NBAInput {
        @InvocableVariable
        global String contactId;
    }
    @InvocableMethod(label='Warranty Check' description='Return total warranty available for contact')
    global static List<NBAResponse> getNBAResults(List<NBAInput> inputs) {
        List<NBAResponse> responses = new List<NBAResponse>();
        
        for(NBAInput input : inputs) {
            NBAResponse response = new NBAResponse();
            
            response.numProducts = getNumberOfProducts(input.contactId); // Call method to get number of cases
            
            responses.add(response);
        }
        
        return responses;
    }
    private static Integer getNumberOfProducts(Id contId) {
        List<String> orderItemlist = new List<String>();
        List<OrderItem> products = new List<OrderItem>();
        Id cid;
        Id oid;
         
        Schema.SObjectType sobjectType = contId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        
        if(sobjectName == 'Order'){
            cid = [Select BillToContactId FROM Order WHERE Id = :contId].BillToContactId;
            oid = [Select Id From Order Where Id = :contId].Id;
            
            for(order ord:[SELECT Id,name,OrderNumber, (select Id                                             
               	FROM OrderItems WHERE (NOT PricebookEntry.Product2.Name LIKE '%Warranty%') AND (PricebookEntry.Product2.Available_for_Warranty__c = true) ) 
               FROM order where Id = :oid ]){
                   for(OrderItem oi : ord.orderItems){
                       orderItemlist.add(oi.id);
                   }    
        	}
        }else if(sobjectName == 'Case'){
            cid = [Select ContactId FROM Case WHERE Id = :contId].ContactId;
            
            for(order ord:[SELECT Id,name,OrderNumber, (select Id                                             
               	FROM OrderItems WHERE (NOT PricebookEntry.Product2.Name LIKE '%Warranty%') AND (PricebookEntry.Product2.Available_for_Warranty__c = true) ) 
               FROM order where BillToContactId = :cid AND Status != 'Draft' AND Status != 'Cancelled' AND Status != 'Rejected']){
                   for(OrderItem oi : ord.orderItems){
                       orderItemlist.add(oi.id);
                   }    
        	}
        }else if(sobjectName == 'LiveChatTranscript'){
            cid = [SELECT ContactId FROM LiveChatTranscript WHERE Id = :contId].ContactId;
            
            for(order ord:[SELECT Id,name,OrderNumber, (select Id                                             
               	FROM OrderItems WHERE (NOT PricebookEntry.Product2.Name LIKE '%Warranty%') AND (PricebookEntry.Product2.Available_for_Warranty__c = true) ) 
               FROM order where BillToContactId = :cid AND Status != 'Draft' AND Status != 'Cancelled' AND Status != 'Rejected']){
                   for(OrderItem oi : ord.orderItems){
                       orderItemlist.add(oi.id);
                   }    
        	}
        }else if(sobjectName == 'MessagingSession'){ 
            cid = [SELECT EndUserContactId  FROM MessagingSession WHERE Id = :contId].EndUserContactId;
            
            for(order ord:[SELECT Id,name,OrderNumber, (select Id                                             
               	FROM OrderItems WHERE (NOT PricebookEntry.Product2.Name LIKE '%Warranty%') AND (PricebookEntry.Product2.Available_for_Warranty__c = true) ) 
               FROM order where BillToContactId = :cid AND Status != 'Draft' AND Status != 'Cancelled' AND Status != 'Rejected']){
                   for(OrderItem oi : ord.orderItems){
                       orderItemlist.add(oi.id);
                   }    
        	}
        }else if(sobjectName == 'Account'){
            cid = [Select ContactId FROM Case WHERE Id = :contId].ContactId;
            for(order ord:[SELECT Id,name,OrderNumber, (select Id                                             
               	FROM OrderItems WHERE (NOT PricebookEntry.Product2.Name LIKE '%Warranty%') AND (PricebookEntry.Product2.Available_for_Warranty__c = true) ) 
               FROM order where BillToContactId = :cid AND Status != 'Draft' AND Status != 'Cancelled' AND Status != 'Rejected']){
                   for(OrderItem oi : ord.orderItems){
                       orderItemlist.add(oi.id);
                   }    
            }
        }else if(sobjectName == 'Contact'){
            cid = contId;
            for(order ord:[SELECT Id,name,OrderNumber, (select Id                                             
               	FROM OrderItems WHERE (NOT PricebookEntry.Product2.Name LIKE '%Warranty%') AND (PricebookEntry.Product2.Available_for_Warranty__c = true) ) 
               FROM order where BillToContactId = :cid AND Status != 'Draft' AND Status != 'Cancelled' AND Status != 'Rejected']){
                   for(OrderItem oi : ord.orderItems){
                       orderItemlist.add(oi.id);
                   }    
        	}
        }        
        products=[Select Id from OrderItem WHERE Id IN :orderItemlist ORDER BY Product2.Name DESC];     
        return products.size();     
    }
 
}