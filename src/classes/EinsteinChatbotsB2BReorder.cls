public class EinsteinChatbotsB2BReorder {
	@InvocableMethod(label='Einstein Chatbots - B2B Reorder' description='Reorder Chosen Order')
    public static List<ccrz__E_Order__c> createB2BReorder(List<ccrz__E_Order__c> requests) 
    {  
        List<ccrz__E_Order__c> Order = new List<ccrz__E_Order__c>();
        For (ccrz__E_Order__c objOrder : requests)
        {
            if (objOrder != null && String.IsNotBlank(objOrder.Id))
            {
                ccrz__E_Order__c NewOrder = [SELECT Name, OwnerId,ccrz__User__c ,ccrz__OrderDate__c,ccrz__TotalAmount__c, ccrz__OrderStatus__c, ccrz__Contact__c ,ccrz__ShipMethod__c FROM ccrz__E_Order__c WHERE Id = :objOrder.Id];
                ccrz__E_Order__c clonedRecord = NewOrder.clone();
                insert clonedRecord;
                
                Id orderId = clonedRecord.Id;
                
                List<ccrz__E_OrderItem__c> items = [SELECT ccrz__Price__c,ccrz__Quantity__c,ccrz__SubAmount__c,ccrz__Product__c,ccrz__AdjustmentAmount__c,ccrz__OrderLineType__c, ccrz__ProductType__c,ccrz__Product_Name__c,ccrz__StoreId__c,ccrz__ItemStatus__c, ccrz__OrderItemId__c,ccrz__OriginalQuantity__c,ccrz__OriginalItemPrice__c FROM ccrz__E_OrderItem__c WHERE ccrz__Order__c = :objOrder.Id]; 
                for (ccrz__E_OrderItem__c i : items) {
                    ccrz__E_OrderItem__c itemObj = new ccrz__E_OrderItem__c();
                        itemObj.ccrz__Price__c = i.ccrz__Price__c;
                        itemObj.ccrz__Quantity__c = i.ccrz__Quantity__c;
                    	itemObj.ccrz__Order__c = orderId;
                        itemObj.ccrz__SubAmount__c = i.ccrz__SubAmount__c;
                        itemObj.ccrz__Product__c = i.ccrz__Product__c;
                        itemObj.ccrz__AdjustmentAmount__c = i.ccrz__AdjustmentAmount__c;
                        itemObj.ccrz__OrderLineType__c = i.ccrz__OrderLineType__c;
                        itemObj.ccrz__ProductType__c = i.ccrz__ProductType__c;
                        itemObj.ccrz__StoreId__c = i.ccrz__StoreId__c;
                        itemObj.ccrz__ItemStatus__c = i.ccrz__ItemStatus__c;
                        itemObj.ccrz__OrderItemId__c = i.ccrz__OrderItemId__c;
                        itemObj.ccrz__OriginalQuantity__c = i.ccrz__OriginalQuantity__c;
                        itemObj.ccrz__OriginalItemPrice__c = i.ccrz__OriginalItemPrice__c;
               		insert itemObj;
                }

                Order = [SELECT Id, Name, ccrz__TotalAmount__c, ccrz__OrderStatus__c, ccrz__Contact__c, ccrz__OrderNumber__c ,ccrz__ShipMethod__c FROM ccrz__E_Order__c WHERE Id = :orderId];
                if (Order != null && Order.size() > 0)
                {
                    return Order;
                }
                break;
            }
        }
        
        return Order;
    }
}