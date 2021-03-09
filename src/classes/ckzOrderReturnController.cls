public with sharing class ckzOrderReturnController {

    @AuraEnabled
    public static Map<String, Object> createCase(String orderId, String subject, String description, String userName, String selectedItemsString) {

        System.debug('orderId: ' + orderId);
        System.debug('userName: ' + userName);

        System.debug('selectedItemsString: ' + selectedItemsString);

        Map<String, Object> responseMap = new Map<String, Object>();

        List<Object> selectedItemsList = (List<Object>)JSON.deserializeUntyped(selectedItemsString);

        responseMap.put('caseDataSaved', false);

        Savepoint sp = Database.setSavepoint();

        try {
            
            if(userName == null || userName == '') {
                throw new CustomException('Case owner name not specified');
            }
            
            List<User> userList = [Select Id, Name from User where Name = :userName];

            if(userList.size() <= 0) {
                throw new CustomException('Case owner name not found: ' + userName);
            }
            
            User user = userList.get(0);

            System.debug('user: ' + user);
            
            //Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order').getRecordTypeId();
            
            Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
            
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
            
            Schema.RecordTypeInfo rtByName = null;
            rtByName = rtMapByName.get('RMA');

            if(rtByName == null) {
                rtByName = rtMapByName.get('Case');
            }

			Id recordTypeId = rtByName.getRecordTypeId();
            
            ccrz__E_Order__c order = null;

            List<ccrz__E_Order__c> orderList = [Select Id, Name, ccrz__Contact__c, ccrz__Account__c from ccrz__E_Order__c where Id = :orderId];

            if(orderList.size() > 0) {
                order = orderList.get(0);
            }

            // Create one case for the return
            Case caseObj = new Case();

            caseObj.AccountId = order.ccrz__Account__c;
            caseObj.ContactId = order.ccrz__Contact__c;

            caseObj.RecordTypeId = recordTypeId;

            caseObj.Subject = subject;
            caseObj.Description = description;

            caseObj.OwnerId = user.Id;

            caseObj.Status = 'New';
            caseObj.Priority = 'Medium';
            caseObj.Origin = 'Web';

            insert caseObj;

            List<Case_Order_Item__c> orderItemList = new List<Case_Order_Item__c>();

            for(Object obj : selectedItemsList) {

                Map<String, Object> orderItemMap = (Map<String, Object>)obj;

                Case_Order_Item__c orderItemObj = new Case_Order_Item__c();
                orderItemObj.CC_Order_Item__c = (String)orderItemMap.get('Id');
                orderItemObj.Case__c = caseObj.Id;

                Object temp = orderItemMap.get('returnQty');
                Integer qty = null;

                if(temp instanceof String) {
                    qty = Integer.valueOf((String)temp);
                }
                else {
                    qty = (Integer)temp;
                }

                System.debug('qty: ' + qty);

                //orderItemObj.Return_Quantity__c = Integer.valueOf((String)orderItemMap.get('returnQty'));
                orderItemObj.Return_Quantity__c = qty;

                orderItemList.add(orderItemObj);
            }

            if(orderItemList.size() > 0) {
                insert orderItemList;

                responseMap.put('caseDataSaved', true);
                //responseMap.put('caseDataSavedMsg', 'Total order items updated: ' + orderItemList.size());

            }

        }
        catch(Exception e) {
            System.debug('rolling back case transactions');
            Database.rollback(sp);

            responseMap.put('caseDataSavedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line Number: ' + e.getLineNumber());
        }

        return responseMap;

    }

//    @AuraEnabled
//    public static Map<String, Object> createCaseOrig(String orderId, String subject, String description, String userName, String selectedItemsString) {
//
//        System.debug('orderId: ' + orderId);
//        System.debug('userName: ' + userName);
//
//        System.debug('selectedItemsString: ' + selectedItemsString);
//
//        Map<String, Object> responseMap = new Map<String, Object>();
//
//        List<Object> selectedItemsList = (List<Object>)JSON.deserializeUntyped(selectedItemsString);
//
//        responseMap.put('caseDataSaved', false);
//
//        Savepoint sp = Database.setSavepoint();
//
//        try {
//
//            if(userName == null || userName == '') {
//                throw new CustomException('Case owner name not specified');
//            }
//
//            List<User> userList = [Select Id, Name from User where Name = :userName];
//
//            if(userList.size() < 0) {
//                throw new CustomException('Case owner name not found: ' + userName);
//            }
//
//            User user = userList.get(0);
//
//            System.debug('user: ' + user);
//
//            //Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order').getRecordTypeId();
//
//            Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
//
//            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
//
//            Schema.RecordTypeInfo rtByName = null;
//            rtByName = rtMapByName.get('RMA');
//
//            if(rtByName == null) {
//                rtByName = rtMapByName.get('Case');
//            }
//
//            Id recordTypeId = rtByName.getRecordTypeId();
//
//            ccrz__E_Order__c order = null;
//
//            List<ccrz__E_Order__c> orderList = [Select Id, Name, ccrz__Contact__c, ccrz__Account__c from ccrz__E_Order__c where Id = :orderId];
//
//            if(orderList.size() > 0) {
//                order = orderList.get(0);
//            }
//
//            // Create one case for the return
//            Case caseObj = new Case();
//
//            caseObj.AccountId = order.ccrz__Account__c;
//            caseObj.ContactId = order.ccrz__Contact__c;
//
//            caseObj.RecordTypeId = recordTypeId;
//
//            caseObj.Subject = subject;
//            caseObj.Description = description;
//
//            caseObj.OwnerId = user.Id;
//
//            caseObj.Status = 'New';
//            caseObj.Priority = 'Medium';
//            caseObj.Origin = 'Web';
//
//            insert caseObj;
//
//            List<ccrz__E_OrderItem__c> orderItemList = new List<ccrz__E_OrderItem__c>();
//
//            for(Object obj : selectedItemsList) {
//
//                Map<String, Object> orderItemMap = (Map<String, Object>)obj;
//
//                ccrz__E_OrderItem__c orderItemObj = new ccrz__E_OrderItem__c();
//                orderItemObj.Id = (String)orderItemMap.get('Id');
//                orderItemObj.Case__c = caseObj.Id;
//
//                orderItemList.add(orderItemObj);
//            }
//
//            if(orderItemList.size() > 0) {
//                update orderItemList;
//
//                responseMap.put('caseDataSaved', true);
//                //responseMap.put('caseDataSavedMsg', 'Total order items updated: ' + orderItemList.size());
//
//            }
//
//        }
//        catch(Exception e) {
//            System.debug('rolling back case transactions');
//            Database.rollback(sp);
//
//            responseMap.put('caseDataSavedMsg', 'Error: ' + e.getMessage());
//            System.debug('Error: ' + e.getMessage());
//            System.debug('Line Number: ' + e.getLineNumber());
//        }
//
//        return responseMap;
//
//    }
    
    public class CustomException extends Exception {}

}