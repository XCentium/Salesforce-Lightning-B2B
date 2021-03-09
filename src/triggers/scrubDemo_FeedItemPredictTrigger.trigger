trigger scrubDemo_FeedItemPredictTrigger on FeedItem (after insert) {
    if(Trigger.new.size() == 1){
        if(string.valueOf(trigger.new[0].parentID).startsWith('500')) //is case
        {
            //check if contact on case has a comm user equal to posted user
            List<Case> c = [select Id, ContactID from Case Where Id = :trigger.new[0].ParentID];
            User postedUser = [select Id, ContactID from User Where Id = :trigger.new[0].CreatedByID];
            
            if(c != null && c.size() > 0 && postedUser.contactID == c[0].contactID){
                //contact's community user.
                //AI_SvcCloudPredictionHelper.communityUserFeedItemSentiment(trigger.new[0].id);
            }
        }
    }
}