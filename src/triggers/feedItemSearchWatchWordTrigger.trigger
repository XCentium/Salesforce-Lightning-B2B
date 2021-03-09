trigger feedItemSearchWatchWordTrigger on FeedItem (after insert) 
{
    //List<ChatterCharadesStory__c> stories = [select id,Watch_Word__c from ChatterCharadesStory__c];
    List<Chatter_Story__c > chatterStories = [select id,Watch_Word__c,Active__c,Seconds_Apart_For_Posting__c from Chatter_Story__c];
    Map<String,String> watchWordStrToStoryId = new Map<String,String>();
    Map<String,Integer> storyIdToSeconds = new Map<String,Integer>();
    
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
    
    for(FeedItem f : Trigger.New)
    { 
        for(String watchWord : watchwords)
            if(f.Body!= null && f.Body.containsIgnoreCase(watchWord)) //check if the feeditem body is null
            {
                //found watchword in feedItem.Body
                cpChatterFeedsCtrl.selectedStoryId = watchWordStrToStoryId.get(watchWord); //which story feeds to grab
                cpChatterFeedsCtrl.setIncrementTime( storyIdToSeconds.get(cpChatterFeedsCtrl.selectedStoryId) ); //set increment seconds for that storyId
                cpChatterFeedsCtrl.selectedParentId = f.id; //which record to post feed to
                cpChatterFeedsCtrl.copyFeedsFromStoryToRecord(); //copy feeds!!!!!!!
            }
        
        //reset
        cpChatterFeedsCtrl.selectedParentId = '';
        cpChatterFeedsCtrl.selectedStoryId= '';
    }
}