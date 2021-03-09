public class blogic_Quote_CreateLineItems {

//***************copy Parts Consumed to the Quote Lines when a quote is create from the Work Order
     public static void InsertAfter(SBQQ__Quote__c[] newQuote){
     
           // List<Id> qli = new List<Id>();
            List<Id> wo = new List<Id>();
            List<Id> pb = new List<Id>();
            List<Id> ca = new List<Id>();
            List<Id> qo = new List<Id>();
           
            List<SBQQ__Quote__c> QuoteList = new List<SBQQ__Quote__c>();
            List<ProductRequired> ProductRequiredList = new List<ProductRequired>();
            List<SBQQ__QuoteLine__c> QLIList = new List<SBQQ__QuoteLine__c>();
            List<WorkOrder> WorkOrderList = new List<WorkOrder>();
            List<Pricebook2> PricebookList = new List<Pricebook2>();
            List<Case> CaseList = new List<Case>();
            
           
            
            for (SBQQ__Quote__c qt : newQuote) {
                  if(qt.Work_Order__c != null){
                        qo.add(qt.Id);
                        wo.add(qt.Work_Order__c);
                        pb.add(qt.SBQQ__PriceBook__c);
                        ca.add(qt.Case__c);
                        }
            }
                  
            WorkOrderList = [select Id, Entitlement_Is_Active__c, Pricebook2Id from WorkOrder where Id IN: wo];
            QuoteList = [select Id, SBQQ__PricebookId__c from SBQQ__Quote__c where Id IN: qo];
            QLIList = [select Id, Work_Order__c, Product_Required_Id__c, SBQQ__Discount__c, SBQQ__Quote__c, SBQQ__Product__c, Work_Order_Line_Item__c, SBQQ__Quantity__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: qo];
            ProductRequiredList = [select Id, ParentRecordId, Product2Id, QuantityRequired from ProductRequired where ParentRecordId IN: wo];
            
            
          for (SBQQ__Quote__c quote : QuoteList){
            for(ProductRequired partslist :ProductRequiredList){
             for(WorkOrder wrk :WorkOrderList){
           If(wrk.Entitlement_Is_Active__c == true){
            QLIList.add(new SBQQ__QuoteLine__c  (
                SBQQ__Quote__c = quote.Id,
                SBQQ__Quantity__c = partslist.QuantityRequired,
                SBQQ__Product__c = partslist.Product2Id,               
                SBQQ__Discount__c = 100,
                Product_Required_Id__c = partslist.Id,
                Work_Order__c = wrk.Id
                )
                );
             }
            If(wrk.Entitlement_Is_Active__c == false){
             QLIList.add(new SBQQ__QuoteLine__c  (
                SBQQ__Quote__c = quote.Id,
                SBQQ__Quantity__c = partslist.QuantityRequired,
                SBQQ__Product__c = partslist.Product2Id,
                Work_Order__c = wrk.Id
                )
                );
             }
             }
             }
             }
             insert QLIList;
             
             
             }
            
            
            public static void UpdateAfter(SBQQ__Quote__c[] newQuote){
                       
            List<Id> wo2 = new List<Id>();
            List<Id> pb2 = new List<Id>();
            List<Id> ca2 = new List<Id>();
            List<Id> qo2 = new List<Id>();
            List<Id> ac2 = new List<Id>();
            
            List<SBQQ__Quote__c> QuoteList2 = new List<SBQQ__Quote__c>();
            List<ProductRequired> ProductRequiredList2 = new List<ProductRequired>();
            List<SBQQ__QuoteLine__c> QLIList2 = new List<SBQQ__QuoteLine__c>();
            List<WorkOrder> WorkOrderList2 = new List<WorkOrder>();
            List<WorkOrder> newWorkOrderList = new List<WorkOrder>(); /* CA added to separate existing from new */
            List<Pricebook2> PricebookList2 = new List<Pricebook2>();
            List<Case> CaseList2 = new List<Case>();
            List<Account> AccountList2 = new List<Account>();
            
             for (SBQQ__Quote__c qt2 : newQuote) {
                  if(qt2.SBQQ__Status__c == 'Accepted'){
                        qo2.add(qt2.Id);                    
                        ac2.add(qt2.SBQQ__Account__c);  
                        ca2.add(qt2.Case__c);
                        wo2.add(qt2.Work_Order__c);
                        }
            }
            system.debug('********* debugging ******* ' + wo2);
            WorkOrderList2 = [select Id, WorkTypeId, CaseId, Subject, AccountId, ContactId, AssetId, Entitlement_Is_Active__c, Pricebook2Id from WorkOrder where Id IN: wo2];
            QuoteList2 = [select Id, Work_Order__c,  SBQQ__Account__c, SBQQ__PricebookId__c from SBQQ__Quote__c where Id IN: qo2];
            QLIList2 = [select Id, Product_Required_Id__c, SBQQ__Discount__c, SBQQ__Quote__c, SBQQ__Product__c, Work_Order_Line_Item__c, SBQQ__Quantity__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: qo2];
            ProductRequiredList2 = [select Id, ParentRecordId, Quote__c, Quote_Line__c, Product2Id, QuantityRequired from ProductRequired where ParentRecordId IN: wo2];
            CaseList2 = [select AccountId, ContactId, Subject, Description, AssetId from Case where Id IN: ca2];
            AccountList2 = [select Id, Work_Type_for_Quote_Creation__c, Service_Territory__c, Default_Field_Entitlement__c, Work_Type__c from Account where Id IN: ac2];
            
          for (SBQQ__Quote__c quote2 : QuoteList2){
            for(Case case2 :CaseList2){   
            for(Account acc2 :AccountList2){  
            if (quote2.Work_Order__c == null) {           
            newWorkOrderList.add(new WorkOrder  ( /* CA changed to use new list for inserting new WO */
                AccountId = case2.AccountId,
                Subject = case2.Subject,
                WorkTypeId = acc2.Work_Type_for_Quote_Creation__c,  
                EntitlementId = acc2.Default_Field_Entitlement__c,             
                ContactId = case2.ContactId,
                AssetId = case2.AssetId,
                Pricebook2Id = quote2.SBQQ__PricebookId__c,
                Quote__c = quote2.Id,
                Description = case2.Description,
                CaseId = case2.Id,
                ServiceTerritoryId = acc2.Service_Territory__c
                
                )
                );
             }          
             }
             }
        }
                if (newWorkOrderList.size() > 0) { /* ca added this block to insert the new wo and add them to WorkOrderList2 */
                    insert newWorkOrderList;
                    for (workorder w : newWorkOrderList) {
                        WorkOrderList2.add(w);}
                }
            
            
            for (SBQQ__Quote__c quote3 : QuoteList2){
            for(SBQQ__QuoteLine__c Qli3 :QLIList2){
            for(WorkOrder wrk3 :WorkOrderList2){ 
            if (quote3.Work_Order__c == null ) {           
            ProductRequiredList2.add(new ProductRequired  (
                Quote__c =   quote3.Id,
                Quote_Line__c = Qli3.Id, 
                ParentRecordId  = wrk3.Id,
                QuantityRequired = Qli3.SBQQ__Quantity__c,
                Product2Id = Qli3.SBQQ__Product__c
                          
                )
                );
             }
                        
            If(quote3.Work_Order__c != null && qli3.Product_Required_Id__c == null){
            ProductRequiredList2.add(new ProductRequired  (
                Quote__c =   quote3.Id,
                Quote_Line__c = Qli3.Id, 
                ParentRecordId  = wrk3.Id,
                QuantityRequired = Qli3.SBQQ__Quantity__c,
                Product2Id = Qli3.SBQQ__Product__c
                          
                )
                );
             }
             }
             }
             }
       //     insert ProductRequiredList2;
                if(ProductRequiredList2.size() > 0) {upsert ProductRequiredList2;} /* CA added so we don't insert Products Required that are already there */
            
            
            
            
             }
             
             }


/*public class blogic_Quote_CreateLineItems {

//***************copy Parts Consumed to the Quote Lines when a quote is create from the Work Order
     public static void InsertAfter(SBQQ__Quote__c[] newQuote){
     
            List<Id> qli = new List<Id>();
            List<Id> wo = new List<Id>();
            List<Id> pb = new List<Id>();
           
            List<SBQQ__Quote__c> QuoteList = new List<SBQQ__Quote__c>();
            List<ProductRequired> ProductRequiredList = new List<ProductRequired>();
            List<SBQQ__QuoteLine__c> QLIList = new List<SBQQ__QuoteLine__c>();
            List<WorkOrder> WorkOrderList = new List<WorkOrder>();
            List<Pricebook2> PricebookList = new List<Pricebook2>();

            
            for (SBQQ__Quote__c qt : newQuote) {
                  if(qt.Work_Order__c != null){
                        qli.add(qt.Id);
                        wo.add(qt.Work_Order__c);
                        pb.add(qt.SBQQ__PriceBook__c);
                        }
            }
                  
            WorkOrderList = [select Id, Entitlement_Is_Active__c, Pricebook2Id from WorkOrder where Id IN: wo];
            QuoteList = [select Id, SBQQ__PricebookId__c from SBQQ__Quote__c where Id IN: qli];
            QLIList = [select Id, SBQQ__Discount__c, SBQQ__Quote__c, SBQQ__Product__c, Work_Order_Line_Item__c, SBQQ__Quantity__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: qli];
            ProductRequiredList = [select Id, ParentRecordId, Product2Id, QuantityRequired from ProductRequired where ParentRecordId IN: wo];
            
          for (SBQQ__Quote__c quote : QuoteList){
            for(ProductRequired partslist :ProductRequiredList){
             for(WorkOrder wrk :WorkOrderList){
           If(wrk.Entitlement_Is_Active__c == true){
            QLIList.add(new SBQQ__QuoteLine__c  (
                SBQQ__Quote__c = quote.Id,
                SBQQ__Quantity__c = partslist.QuantityRequired,
                SBQQ__Product__c = partslist.Product2Id,               
                SBQQ__Discount__c = 100
                )
                );
             }
            If(wrk.Entitlement_Is_Active__c == false){
             QLIList.add(new SBQQ__QuoteLine__c  (
                SBQQ__Quote__c = quote.Id,
                SBQQ__Quantity__c = partslist.QuantityRequired,
                SBQQ__Product__c = partslist.Product2Id
                )
                );
             }
             }
             }
             }
             insert QLIList;
             }
             }*/