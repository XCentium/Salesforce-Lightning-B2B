trigger AttachmentTrigger on Attachment (after insert) {
    List<News_Announcements__c> newsAnnouncements = new List<News_Announcements__c>();  
    Set<Id> newsAnnouncementsIds = new Set<Id>();  
    for(Attachment att : trigger.New){  
        /*Check if uploaded attachment is related to News_Announcements__c Attachment and same record is already added*/  
        if(att.ParentId.getSobjectType() == News_Announcements__c.SobjectType && (!newsAnnouncementsIds.contains(att.ParentId))){  
            //prepare a News_Announcements__c object for update  
            newsAnnouncements.add(  
                new News_Announcements__c(  
                    Id=att.ParentId,  
                    ImageAttachmentId__c = att.Id  
                )  
            );  
            //add the newsAnnouncementsIds in set to eliminate dupe updates                                     
            newsAnnouncementsIds.add(att.ParentId);  
        }  
    }  
    //finally update News_Announcements__c  
    update newsAnnouncements; 
}