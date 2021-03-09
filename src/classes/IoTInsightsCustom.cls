public class IoTInsightsCustom {
	/** Get Asset IoT Values **/
	@AuraEnabled
    public static List<Asset> getAssetDetails(String rId) {
        return [SELECT Id,Voltage_Critical__c, Voltage_Low__c, Vibration_Excessive__c, Vibration_Warning__c, Temperature_Critical__c, Temperature_Warning__c  FROM Asset WHERE Id = :rId];
    }
}