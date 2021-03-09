public class ClientelingBrander {

    @AuraEnabled
    public static List<IDO_Clienteling__c> GetClientelingInfo(String RecId) {
        return [SELECT App_background_color__c ,Logo_Background_Color__c , Secondary_Button_Collor__c, Primary_Button_Color__c ,Hex_Color_Scheme__c FROM IDO_Clienteling__c WHERE ID = :RecId];
    }
    @AuraEnabled
    public static String GetStaticResourceId() { 
        return [SELECT Id FROM StaticResource WHERE Name = 'NTOWhite' LIMIT 1].Id;
    } 
    @AuraEnabled
    public static List<IDO_Clienteling__c> UpdateRecord(String RecId,String AppBackgroundColor,String LogoBackgroundColor,String HeaderBackgroundColor,String PrimaryButtonColor,String SecondaryButtonColor) { 
        IDO_Clienteling__c[] setting = [SELECT ID FROM IDO_Clienteling__c WHERE ID = :RecId];
            for(IDO_Clienteling__c cs: setting) {
                cs.App_background_color__c = AppBackgroundColor;
                cs.Logo_Background_Color__c = LogoBackgroundColor;
                cs.Hex_Color_Scheme__c = HeaderBackgroundColor;
                cs.Primary_Button_Color__c = PrimaryButtonColor;
                cs.Secondary_Button_Collor__c = SecondaryButtonColor;
            }
        /** Attempt to update the setting fields and throw error in debug log if it fails **/
        try{
            update setting;
            return [SELECT App_background_color__c ,Logo_Background_Color__c , Secondary_Button_Collor__c, Primary_Button_Color__c ,Hex_Color_Scheme__c FROM IDO_Clienteling__c WHERE ID = :RecId];
        }catch(exception e){
            System.debug('Update Demo Setting Error: ' + e);
            return null;
        }
            } 
}