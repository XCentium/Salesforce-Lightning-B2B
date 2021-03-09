trigger feedCommentSearchWatchWordTrigger on FeedComment (after insert) 
{
    List<Chatter_Story__c > chatterStories = [select id,Watch_Word__c,Active__c,Seconds_Apart_For_Posting__c
                                                                       from Chatter_Story__c ];
    Map<String,String> watchWordStrToStoryId = new Map<String,String>(); //watch word to storyId
    Map<String,Integer> storyIdToSeconds = new Map<String,Integer>(); //storyId to seconds apart
    
    for(Chatter_Story__c s : chatterStories)
    {
        if(s.Active__c)
        {
            watchWordStrToStoryId.put(s.Watch_Word__c,s.id);
            storyIdToSeconds.put(s.id, Integer.valueOf(s.Seconds_Apart_For_Posting__c));
        }
    }
    CopyChatterFeeds cpChatterFeedsCtrl = new CopyChatterFeeds();
    Set<String> watchwords = watchWordStrToStoryId.keySet();
    
    for(FeedComment fc : Trigger.New)
    { 
        for(String watchWord : watchwords)
            if(fc.CommentBody!=null && fc.CommentBody.containsIgnoreCase(watchWord)) //check if the feedcomment body is null
            {
                //found watchword in feedItem.Body
                //which story feeds to grab
                cpChatterFeedsCtrl.selectedStoryId= watchWordStrToStoryId.get(watchWord);
                //set increment seconds for that storyId
                cpChatterFeedsCtrl.setIncrementTime( storyIdToSeconds.get(cpChatterFeedsCtrl.selectedStoryId) );
                cpChatterFeedsCtrl.selectedParentId = fc.FeedItemId; //which record to post feed to
                cpChatterFeedsCtrl.copyFeedsFromStoryToRecord(); //copy feeds!!!!!!!
            }
        
        //reset
        cpChatterFeedsCtrl.selectedParentId = '';
        cpChatterFeedsCtrl.selectedStoryId = '';
    }
}