public class OM_Cooler_IoT_Controller {
    
    @AuraEnabled
    public static List<Asset> getAssetDetails (String RecId){
        return [SELECT Id,Name,Product2.Name,Product2.purl__c FROM Asset WHERE Id  = :RecId ];
    }
    
    @AuraEnabled
    public static List<IDO_Cooler_Inventory__c> getInventoryProducts (String RecId){
        return [SELECT CC_Product__c,CC_Product__r.Name,Max_Inventory__c,Reorder_Point__c ,SKU__c,Name FROM IDO_Cooler_Inventory__c WHERE Cooler__c  = :RecId ORDER By Name ASC];
    }
    
    @AuraEnabled
    public static Boolean submitNewEvent(String coolerId, Decimal vibration, Decimal extTemp, Decimal intTemp, Decimal voltage, Boolean doorOpen,Decimal preLevel,Decimal duringLevel,Decimal postLevel) {
        System.debug('args: ' + coolerId + ' - ' + vibration + ' - ' + extTemp + ' - ' + intTemp + ' - ' + voltage + ' - ' + doorOpen);
        
        Cooler_IoT_Event__e evt = new Cooler_IoT_Event__e (
            CoolerID__c = coolerId,
            Door_Open__c = doorOpen,
            External_Temperature__c = extTemp,
            Internal_Temperature__c = intTemp,
            Vibration__c = vibration,
            Voltage_Level__c = voltage,
            AlpinePreInventory__c = preLevel,
            AlpineDuringInventory__c = duringLevel, 
            AlpinePostInventory__c = postLevel
        );
        
        System.debug('evt: ' + evt);
        
        // Call method to publish events.
        Database.SaveResult sr = EventBus.publish(evt);
        
        // Inspect publishing result for each event
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
            
            return true;
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
            
            return false;
        }  
    }
    
    @AuraEnabled
    public static List<Asset> fetchCoolerAssets() {
        List<Asset> assetList = [SELECT External_ID__c,Id,Name FROM Asset WHERE Name LIKE '%Cooler%'];
        
        return assetList;
    }
}