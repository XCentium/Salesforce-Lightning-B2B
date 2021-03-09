public with sharing class CopyChatterFeeds
{
    public String selectedParentId {get;set;}  //which record to post feed to
    public String selectedStoryId {get;set;} //which story feeds to grab
    public Integer secondsApart {get;set;} //# of seconds apart when posting feedItems
    public Integer increment {get;set;}
    public CopyChatterFeeds()
    {
        selectedParentId = '';
        //selectedStoryId = '';
        selectedStoryId = '';
        increment = 5;
    }
    public void setIncrementTime(Integer inc)
    {
      increment = inc;
      if(secondsApart == null)
        secondsApart = increment;
    }
    
    public void copyFeedsFromStoryToRecord()
    {
        System.debug('ParentId: '+ selectedParentId);
        System.debug('selectedStoryId: '+ selectedStoryId);
        
        List<FeedComment> storyFeedComments = [SELECT CommentBody,CommentType,CreatedById,CreatedDate,FeedItemId,RelatedRecordId    //parentId is auto fill depends on feedItemId
                                               FROM FeedComment
                                               WHERE ParentId = :selectedStoryId
                                               Order by CreatedDate ASC];
        System.debug(storyFeedComments);                                               
        List<FeedComment> newRecordFeedComments = storyFeedComments.deepClone(false,true,false);
        
        //change newRecordFeedComments.FeedItemId to new one
        for(FeedComment fc: newRecordFeedComments)
        {
            fc.FeedItemId = selectedParentId;
            fc.createdDate = null;
            //create scheduled Comment Post
            ScheduledChatterComment chatComment = new ScheduledChatterComment(fc);
            String schDateTime = calculateScheduleTimeStr(); //X seconds after NOW
            system.schedule('Scheduled FeedComment '+' '+String.valueof(secondsApart)+' '+System.Now()+Math.random(), schDateTime, chatComment); //SCHEDULE THE POST!!!!
        }
        //insert newRecordFeedComments;                      
    }
    
    public String calculateScheduleTimeStr()
    {
        DateTime schDateTime = System.now().addSeconds(secondsApart);
        String scheduleStr = '';
        scheduleStr = schDateTime.format('s m H d M')+ ' ? '+schDateTime.format('yyyy');
        //add  secondsApart seconds to the next schedule time
        secondsApart += increment;
        return scheduleStr;
    }
}