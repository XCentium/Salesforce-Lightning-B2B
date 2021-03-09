public with sharing class SDOToolsHomepage {

    public User currentUser {get;set;}

    public SDOToolsHomepage() {
        currentUser = [SELECT FirstName, LastName, Name, SmallPhotoUrl, FullPhotoUrl FROM User WHERE Id =: UserInfo.getUserId()];
    }
}