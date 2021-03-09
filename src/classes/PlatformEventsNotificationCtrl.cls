public class PlatformEventsNotificationCtrl {
    @AuraEnabled
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }
}