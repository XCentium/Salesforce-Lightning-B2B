trigger AI_FeedCommentPredictTrigger on FeedComment (after insert) {
    if(Trigger.new.size() == 1){
        if(string.valueOf(trigger.new[0].parentID).startsWith('500')) //is case
        {
            //check if contact on case has a comm user equal to posted user
            Case c = [select id, ContactID from Case where id = :trigger.new[0].parentID];
            User postedUser = [select id, contactID from User where id = :trigger.new[0].createdByID];
            
            if(postedUser.contactID == c.contactID){
                //contact's community user.
                //AI_SvcCloudPredictionHelper.communityUserFeedCommentSentiment(trigger.new[0].id);
            }
        }
    }
}