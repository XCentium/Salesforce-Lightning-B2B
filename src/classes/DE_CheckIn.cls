public class DE_CheckIn{
    public Event CheckinEvent {get;set;}

    public Account Hi {get;set;}
    public Account Namer {get;set;}

    public string howdy {get;set;}
    public User u {get;set;}
    
    public DE_CheckIn() {
        Hi = new Account();
        CheckinEvent = new Event();
        
        u = [Select Id, Name, SmallPhotoURL From User Where Id =: UserInfo.getUserID() Limit 1];
    }
    
    public void savecheckin() {
        CheckinEvent.OwnerId = u.Id;
        CheckinEvent.Subject = 'Meeting Check-In';
        CheckinEvent.StartDateTime = DateTime.Now();
        CheckinEvent.DurationInMinutes = 60;
        Namer = new Account();
        Namer = [select id, name from Account where name =: Hi.name Limit 1];
        CheckinEvent.WhatId = Namer.id;
        insert CheckinEvent;
        
        if(CheckinEvent.WhatId != null){
            //Adding a Text post
            FeedItem post = new FeedItem();
            post.ParentId = CheckinEvent.WhatId; //eg. Opportunity id, custom object id..
            post.Body = UserInfo.getName() + ' Checked-In to ' + Hi.name + ' at ' + CheckinEvent.StartDateTime;
            insert post;
        }
        
        FeedItem post = new FeedItem();
            post.ParentId = UserInfo.getUserId(); //eg. Opportunity id, custom object id..
            post.Body = UserInfo.getName() + ' Checked-In to ' + Hi.name+ ' at ' + CheckinEvent.StartDateTime;
            insert post;
    }
}