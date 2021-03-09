public class blogic_ROLI_CreateTransfer {

//***************creating product transfer for each ROLI that is created
     public static void InsertAfter(ReturnOrderLineItem[] newReturnOrderLineItem){
     
            //List<Id> shipment = new List<Id>();
            List<Id> rma = new List<Id>();
            List<Id> rli = new List<Id>();
            
           // List<Shipment> ShipmentList = new List<Shipment>();
            List<ReturnOrder> ReturnOrderList = new List<ReturnOrder>();
            List<ReturnOrderLineItem> ReturnOrderLineItemList = new List<ReturnOrderLineItem>();           
            List<ProductTransfer> ProductTransferList = new List<ProductTransfer>(); 
            
            for (ReturnOrderLineItem roli : newReturnOrderLineItem) {
                  
                        rli.add(roli.Id);
                        rma.add(roli.ReturnOrderId);
                        
            }
                  
            //ShipmentList = [select Id, SourceLocationId, DestinationLocationId from Shipment where Id IN: shipment];
            ReturnOrderList = [select Id, SourceLocationId, DestinationLocationId from ReturnOrder where Id IN: rma];
            ReturnOrderLineItemList = [SELECT Id, Product2Id, ProductItemId, SourceLocationId, QuantityReturned, QuantityUnitOfMeasure, DestinationLocationId FROM    
            ReturnOrderLineItem WHERE Id IN: rli];           
            
       /*     for (Shipment ship : ShipmentList){ 
               for (ReturnOrder pr : ReturnOrderList){
                ship.SourceLocationId = pr.SourceLocationId;
                ship.DestinationLocationId = pr.DestinationLocationId;
                }
               }
             update ShipmentList; */
            
            for(ReturnOrderLineItem rline1 : ReturnOrderLineItemList) {
                rline1.QuantityUnitOfMeasure = 'Each';                
                }
               
             update ReturnOrderLineItemList;
             
            for(ReturnOrderLineItem rline : ReturnOrderLineItemList) {
                       ProductTransferList.add (new ProductTransfer (
                       Product2Id=rline.Product2Id, 
                       //SourceLocationId=rline.SourceLocationID,                        
                       SourceProductItemId = rline.ProductItemId,
                       DestinationLocationId = rline.DestinationLocationID, 
                       QuantitySent = rline.QuantityReturned,
                       ReturnOrderLineItemId = rline.Id, 
                       QuantityUnitOfMeasure = rline.QuantityUnitOfMeasure
                       
                    )
                    );
                }
                
                insert ProductTransferList;
             }
             }