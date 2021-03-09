public class blogic_Shipment_CreateTransfer {

//***************creating parts to be used when a work order is created for a single asset repair
     public static void InsertAfter(Shipment[] newShipment){
     
            List<Id> shipment = new List<Id>();
            List<Id> prodreq = new List<Id>();
            List<Id> prli = new List<Id>();
            
            List<Shipment> ShipmentList = new List<Shipment>();
            List<ProductRequest> ProductRequestList = new List<ProductRequest>();
            List<ProductRequestLineItem> ProductRequestLineItemList = new List<ProductRequestLineItem>();           
            List<ProductTransfer> ProductTransferList = new List<ProductTransfer>(); 
            
            for (Shipment sh : newShipment) {
                  if(sh.Product_Request__c != null){
                        shipment.add(sh.Id);
                        prodreq.add(sh.Product_Request__c);
                        }
            }
                  
            ShipmentList = [select Id, SourceLocationId, DestinationLocationId from Shipment where Id IN: shipment];
            ProductRequestList = [select Id, SourceLocationId, DestinationLocationId from ProductRequest where Id IN: prodreq];
            ProductRequestLineItemList = [SELECT Id, Product2Id, QuantityRequested, QuantityUnitOfMeasure, DestinationLocationId FROM    
            ProductRequestLineItem WHERE ParentId IN: prodreq];           
            
            for (Shipment ship : ShipmentList){ 
               for (ProductRequest pr : ProductRequestList){
                ship.SourceLocationId = pr.SourceLocationId;
                ship.DestinationLocationId = pr.DestinationLocationId;
                }
               }
             update ShipmentList;
            
            
            for(ProductRequestLineItem prline : ProductRequestLineItemList) {
              for(Shipment ship2 : ShipmentList) {
                ProductTransferList.add (new ProductTransfer (
                       Product2Id=prline.Product2Id, 
                       SourceLocationId=ship2.SourceLocationID,                        
                       DestinationLocationId = ship2.DestinationLocationID, 
                       QuantitySent = prline.QuantityRequested,
                       ProductRequestLineItemId = prline.Id, 
                       QuantityUnitOfMeasure = prline.QuantityUnitOfMeasure,
                       ShipmentId = ship2.Id
                    )
                    );
                }
                }
                insert ProductTransferList;
             }
             }