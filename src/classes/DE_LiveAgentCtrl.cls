public class DE_LiveAgentCtrl {
    @AuraEnabled
    public static String LiveAgentButtonId() {
        LiveChatButton lCBId = [SELECT Id FROM LiveChatButton WHERE DeveloperName = 'Community_Chat'];
        System.Debug(lCBId.Id);
        return String.valueOf(lCBId.Id).substring(0, 15);
    }
    @AuraEnabled  
    public static String getLiveAgentDeploymentId() {
        LiveChatDeployment lDId = [SELECT Id, CreatedDate FROM LiveChatDeployment where DeveloperName='Live_Agent_Community_Chat'];
        return String.valueOf(lDId.Id).substring(0, 15);
    }
    @AuraEnabled  
    public static String getOrgId() {
        String Orgid=UserInfo.getOrganizationId();
        return Orgid.substring(0, 15);
    }
}