public with sharing class Community_User_Profile_Controller {
    
    public User u {get;set;}
    
    public Community_User_Profile_Controller() {
        u = [Select ID, Name, SmallPhotoURL From User Where ID =: UserInfo.getUserID() Limit 1];
    }
}