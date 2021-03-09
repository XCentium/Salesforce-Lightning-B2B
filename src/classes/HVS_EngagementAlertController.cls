public class HVS_EngagementAlertController {

    @AuraEnabled
    public static Object createEngagement(String channelAction, String channelType, String channelVehicleId, DateTime engagementDate, String templateId, String targetId) {
        HighVelocityEngagement engagement = new HighVelocityEngagement();
        engagement.ChannelAction=channelAction;
        engagement.ChannelType=channelType;
        engagement.ChannelVehicleId=channelVehicleId;
        engagement.EngagementDateTime=engagementDate;
        engagement.TemplateId = templateId;
        engagement.TargetId = targetId;
        engagement.UserId=UserInfo.getUserId(); 
        
        Database.SaveResult sr = Database.insertImmediate(engagement);
        return new Map<String,Object>{ 'success' => sr.isSuccess(), 'errors' => sr.getErrors(), 'id' => sr.getId() };
    }
}