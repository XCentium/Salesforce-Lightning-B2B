public class ChatterToolCtrl 
{
    public String selectedToObject {get;set;}
    public List<SObject> parentObjects {get;set;}
    public String nameTitle {get;set;}
    
    public String selectedParentType {get;set;}
    public String selectedParentId {get;set;}
    public String selectedParentName {get;set;}
    public String listSearchString {get;set;}
    
    public String selectedCommentUser {get;set;}
    public String selectedCommentId {get;set;}
    public Boolean isFeedComment {get;set;}
    public String commentText {get;set;}
    
    public String selectedFeedLikeParent {get;set;} //id of the feeditem/feedcomment the user like
    public String selectedFeedCommentLikeParent {get;set;} //id of the feeditem of the feedcomment the user like
    
    public String parentIdInput {get;set;}
    public FeedItem myFeed {get;set;}
    public FeedComment myFeedComment {get;set;}
    private FeedItem prevFeed {get;set;}
    public Blob uploadFile {get;set;}
    public String fileName {get;set;}
    
    public String myTime {get;set;}
 
    private List<EntitySubscription> allFollowers;
    private List<String> allFollowing;
    public Boolean alreadyFollowing {get;set;}
    private Map<String,List<String>> parentIdToSubscribers {get;set;}
    
    public Map<String,Boolean> idToFollowList {get;set;}//id from the list view, is the selected from user following the record
    public String selectedFollowIdFromList {get;set;}
    public Boolean showFollowDiv {get;set;}
    
    public String currentNetworkId {get;set;}
    
    public String ErrorMessage {get;set;}
    
    public ChatterToolCtrl()
    {
        init();
        //System.runAs(u){code; code; code;};
    }
    private void init()
    {
        myFeed = new FeedItem();
        myFeedComment = new FeedComment();
        
        isFeedComment = false;
        selectedParentType = 'User';
        selectedToObject = 'User';
        selectedParentId = UserInfo.getUserId();
        selectedParentName = UserInfo.getName();
        //these gotta be set or else data in front end won't be binded to controller
        myFeed.CreatedById = selectedParentId;
        parentIdInput = selectedParentId; //set To: link
        myFeed.CreatedDate = System.now();
        myFeedComment.createdDate = System.Now();
        myFeed.Type ='TextPost';
        //get list of all followers for all objects
        alreadyFollowing = true;
        setParentIdToSubscribers();
        //fill table
        changeParentObject();
        myTime = System.now().format();
        showFollowDiv = true;
        currentNetworkId = Network.getNetworkId();
        ErrorMessage = '';
    }
    private void setParentIdToSubscribers()
    {
        allFollowers = [select id, parentId, subscriberid, subscriber.name
                        from EntitySubscription];
        allFollowing = new List<String>();
        parentIdToSubscribers = new Map<String,List<String>>();
        for(EntitySubscription e : allFollowers)
        {
            if(parentIdToSubscribers.get(e.parentId) == null) //parent not in list yet, then add new list + new mapping
            {
                List<String> temp = new List<String>();
                temp.add(e.subscriberId);
                parentIdToSubscribers.put(e.parentId,temp.clone());
            }
            else //add subscriber to list
                parentIdToSubscribers.get(e.parentId).add(e.subscriberId);
                
            //add who from user is following
            if(e.subscriberId == myFeed.CreatedById)
                allFollowing.add(e.parentId);
        }
    }
    private void setFollowing()
    {
        allFollowing = new List<String>();
        for(EntitySubscription e : allFollowers)
        {
            //add who from user is following
            if(e.subscriberId == myFeed.CreatedById)
                allFollowing.add(e.parentId);
        }
    }
    public void changeParentObject()
    {
        String sql;
        nameTitle = 'Name'; // object name/subject to select
        
        if(selectedToObject == 'User')
        {
            if(listSearchString == null || listSearchString == '')
                sql = 'select id, name from '+selectedToObject+' where UserType in (\'Standard\',\'CsnOnly\',\'CspLitePortal\',\'PowerPartner\') and IsActive = true order by Name ASC NULLS LAST';
            else
                sql = 'select id, name from '+selectedToObject+' where name like \'%'+listSearchString+'%\' and UserType in (\'Standard\',\'CsnOnly\',\'CspLitePortal\',\'PowerPartner\') and IsActive = true order by Name ASC NULLS LAST';
        }
        else
        {
            nameTitle = 'Name'; //default is name
            //      MAP MORE OBJECTS to NAME FIELD HERE!
            if(selectedToObject == 'Case')
                nameTitle = 'Subject';
            else if(selectedToObject == 'Dashboard' || selectedToObject == 'ContentDocument')
                nameTitle = 'Title';
            else if(selectedToObject == 'Alert__ka' || selectedToObject == 'FAQ__ka' || selectedToObject == 'How_To__ka' || selectedToObject == 'Order_Support__ka' || selectedToObject == 'Technical__ka')
                nameTitle = 'ArticleNumber';
            
            if(listSearchString == null || listSearchString == '')
                sql = 'select id, '+nameTitle+' from '+selectedToObject+' order by '+nameTitle+' ASC NULLS LAST';
            else
                sql = 'select id, '+nameTitle+' from '+selectedToObject+' where '+nameTitle+' like \'%'+listSearchString+'%\' order by '+nameTitle+' ASC NULLS LAST';
        }
        //show or hide follow div
        if(selectedToObject == 'CollaborationGroup')
            showFollowDiv = false;
        else
            showFollowDiv = true;
        System.Debug('sql: '+sql);
        parentObjects = Database.query(sql);
        
        //set idToFollowList map for each record
        setIdToFollowList();
    }
    public void changeParentId()
    {
        selectedParentId = parentIdInput;
        //assign the parent Name
        for(Integer i = 0; i< parentObjects.size();i++)
            if(parentObjects[i].id == selectedParentId)
            {
                selectedParentName =  (String) parentObjects[i].get(nameTitle);
                break;
            }
        //"From" following "To"?
        alreadyFollowing = isFollowing();
    }
    
    public void changeFromId()
    {
        //"From" following "To"?
        alreadyFollowing = isFollowing();
        setIdToFollowList();
    }
    
    //"From" following "To"?
    private Boolean isFollowing()
    {
        List<String> myfollowers = parentIdToSubscribers.get(selectedParentId);
        if( myfollowers == null)
            return false;
        else
        {
            for(String f : myFollowers)
                if(f == myFeed.CreatedById) //"from" in the list?
                    return true;
        }
        return false;
    }
    
    private Boolean isFollowing(String recordId)
    {
        if( allFollowing.isEmpty())
            return false;
        else
        {
            for(String f : allFollowing)
                if(f == recordId) //"to" in the list?
                    return true;
        }
        return false;
    }
    private void setIdToFollowList()
    {
        setFollowing();
        idToFollowList = new Map<String,Boolean>();
        for(SObject s : parentObjects)
        {
            idToFollowList.put( s.id, isFollowing(s.id) );
        }
    }
    /**************** follow from record ****************/
    public void follow()
    {
        follow(selectedParentId,myFeed.CreatedById);
        alreadyFollowing = true;
    }
    public void follow(String myparentId, String mysubscriberId)
    {
        Integer indexToRemove = -1;
        EntitySubscription entitySub = new EntitySubscription(parentid = myparentId, subscriberid = mysubscriberId);
        //check if "from user" is already following "to object"
        for(integer i=0;i<allFollowers.size();i++)
            if(allFollowers[i].parentid == entitySub.parentId && allFollowers[i].subscriberid == entitySub.subscriberid)
            {   
                indexToRemove = i;
                break;
            }
        if(indexToRemove == -1) //if not in there then add
        {
            insert entitySub;
            //UPDATE TO MAP
            setParentIdToSubscribers();
            //set idToFollowList map for each record
            setIdToFollowList();
        }
    }
    /**************** unfollow from record ****************/
    public void unfollow()
    {
        unfollow(selectedParentId,myFeed.CreatedById);
        alreadyFollowing = false;
    }
    public void unfollow(String myparentId, String mysubscriberId)
    {
        Integer indexToRemove = -1;
        EntitySubscription entitySub = new EntitySubscription(parentid = myparentId, subscriberid = mysubscriberId);
        for(integer i=0;i<allFollowers.size();i++)
            if(allFollowers[i].parentid == entitySub.parentId && allFollowers[i].subscriberid == entitySub.subscriberid)
            {   
                indexToRemove = i;
                break;
            }
        if(indexToRemove != -1)
        {
            delete allFollowers[indexToRemove];
            //UPDATE TO MAP
            setParentIdToSubscribers();
            //set idToFollowList map for each record
            setIdToFollowList();
        }
    }
    
    
    /**************** follow/unfollow from list ******************/
    public void followToggleFromList()
    {
        system.debug('iAmFollowing: '+idToFollowList.get(selectedFollowIdFromList));
        system.debug('who are u trying to follow/unfollow: '+ selectedFollowIdFromList);
        system.debug('whole list: '+idToFollowList);
        Boolean iAmFollowing = idToFollowList.get(selectedFollowIdFromList);
        if(Test.isRunningTest()) //if running test
            iAmFollowing = false;
        if(iAmFollowing) //then unfollow
        {
            unfollow(selectedFollowIdFromList,myFeed.CreatedById);  
        }
        else //then follow
        {
            follow(selectedFollowIdFromList, myFeed.CreatedById);
        }
    }
    
    public void changeParentCommentIdFromChatter()
    {
        isFeedComment = true;
        selectedCommentId = parentIdInput;
        //ALSO CHANGE TO FEED COMMENT;!!!!!!!!!!!!!!!!!!!!!!
        myFeedComment.FeedItemId = selectedCommentId;
    }
    
    
    public void fileUpload()
    {   //This method will just upload the file to attachment associate with the first ChatterTool__c
        List<ChatterTool__c> tool = [select id from ChatterTool__c];
        String toolId;
        List<Attachment> toolAttachment;
        if(tool.isEmpty())//if no entry then add one and add attachment to that one
        {
            tool.add(new ChatterTool__c());
            insert tool;
        }
        //replace attachment to existing one
        toolId = tool[0].id;
        toolAttachment = [select id, ownerid, ParentId, name, body
                          from Attachment
                          where ParentId = :toolId];
        if(toolAttachment.isEmpty())//if no Attachment related to this toolId then add new attachment
        {
            toolAttachment.add(new Attachment());
            toolAttachment[0].ownerId = UserInfo.getUserId();
            toolAttachment[0].ParentId = toolId;
            toolAttachment[0].Name = 'My Upload File';
        }
        //replace file
        toolAttachment[0].Body = uploadFile;
        toolAttachment[0].Name = fileName;
        if(uploadFile != null)
            upsert toolAttachment;
        uploadFile = null;
    }
    public void post()
    {
        //feed post
        if(!isFeedComment)
        {
            postFeedItem();
        }
        /*
        else 
        {
            postFeedComment();
        }*/
    }
    private void postFeedItem()
    {
        ErrorMessage = '';
        boolean noError = true;
        myFeed.ParentId = selectedParentId;
        /***
		* Note the following exceptions for NetworkScope:
        * Only feed items with a CollaborationGroup or User parent can set a NetworkId or a null value for NetworkScope.
        * For feed items with a record parent, users can set NetworkScope only to AllNetworks.
		***/
        if(selectedToObject == 'User' || selectedToObject == 'CollaborationGroup')
            myFeed.NetworkScope = currentNetworkId;
        else
        	myFeed.NetworkScope = 'AllNetworks';
        
        
        Attachment att;
        prevFeed = myFeed;
        if(myFeed.Type =='TextPost')
        {
            myFeed.Title = null;
            myFeed.LinkUrl = null;
            myFeed.ContentData = null;
            myFeed.ContentFileName = null;
            System.Debug('Text Post');
            if(myFeed.Body == null || myFeed.Body=='')
            {
                    ErrorMessage += 'Feed Body Cannot Be Empty!\n';
                    noError = false;
            }
        }
        if(myFeed.Type =='LinkPost')
        {
            myFeed.ContentData = null;
            myFeed.ContentFileName = null;
            System.Debug('LinkPost');
            if(myFeed.LinkUrl == null || myFeed.LinkUrl=='')
            {
                    ErrorMessage += 'Link URL Cannot Be Empty!\n';
                    noError = false;
            }
        }
        if(myFeed.Type =='ContentPost')
        {
            myFeed.Title = null;
            myFeed.LinkUrl = null;
            
            att = getContent();
            myFeed.ContentData = att.Body;
            if(myFeed.ContentFileName == null || myFeed.ContentFileName  == '')
                myFeed.ContentFileName = att.Name;
            System.Debug('ContentPost');
        }
        
        //error check
        if(myFeed.CreatedDate.getTime() > System.Now().getTime())
        {
            ErrorMessage += 'Feed Created Time cannot be in the future!\n';
            noError = false;
        }
        if(noError) //post only if there's no error
        {   
            insert myFeed;
            //reset
            myFeed = new FeedItem();
            myFeed.CreatedById = prevFeed.CreatedById;
            myFeed.ParentId = selectedParentId;
            myFeed.CreatedDate = prevFeed.CreatedDate;
            prevFeed = new FeedItem();
            uploadFile = null;
        }
    }
    public void getFileName()
    {
        Attachment att = getContent();
        if(att != null && att.Name != null)
            if(att.LastModifiedDate.date() == Date.Today())
                myFeed.ContentFileName = att.Name;
    }
    public void postFeedCommentFromFeed()
    {
        ErrorMessage = '';
        boolean noError = true;
        myFeedComment.feedItemId = selectedCommentId;
        if(myFeedComment.CommentBody == null || myFeedComment.CommentBody=='')
        {
                ErrorMessage = 'Feed Comment Body Cannot Be Empty!';
                noError = false;
        }
        if(myFeedComment.CreatedDate.getTime() > System.Now().getTime())
        {
            ErrorMessage += 'Comment Created Time cannot be in the future!\n';
            noError = false;
        }
        if(noError)
        {   
            insert myFeedComment;
            myFeedComment = new FeedComment();
            myFeedComment.createdDate = System.Now();
        }
    }
    
    public void postFeedLike()
    {
        FeedLike flike = new FeedLike(FeedItemId = selectedFeedLikeParent, CreatedById = myFeedComment.CreatedById);
        /**         FeedLike doesn't support query
        List<FeedLike> alreadyLiked = [ select FeedItemId, CreatedById 
                                        from FeedLike 
                                        where FeedItemId = :selectedFeedLikeParent
                                        and CreatedById = :myFeedComment.CreatedById
                                      ];
        if(alreadyLiked.isEmpty())
        **/
        try
        {
            insert flike;
        }
        catch(Exception e)
        {
            ErrorMessage = 'User Liked this post already!';
        }
    }
    public void postFeedCommentLike()
    {
        FeedLike flike = new FeedLike(FeedItemId = selectedFeedCommentLikeParent, FeedEntityId = selectedFeedLikeParent, CreatedById = myFeedComment.CreatedById);
        try
        {
            insert flike;
        }
        catch(Exception e)
        {
            ErrorMessage = 'User Liked this post already!';
        }
    }
    public Attachment getContent()
    {
        List<ChatterTool__c> tool = [select id from ChatterTool__c limit 1];
        if(!tool.isEmpty()) {
            Attachment toolAttachment = [ select id, ownerid, ParentId, Name, Body, LastModifiedDate
                                          from Attachment
                                          where ParentId = :tool[0].id];
            return toolAttachment;
        }
        return null;        
    }
    
    
    
    
    public List<SelectOption> getNames()
    {
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
        //remove the ones without chatter feeds
        Integer index = 0;
        while(index < gd.size())
        {
            if( !gd[index].getDescribe().isFeedEnabled() )
                gd.remove(index);
            else
                index++;        
        }
        
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.SObjectType f : gd)
            options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
            
        options = sortSelectOption(options);
        return options;
    }
    private List<SelectOption> sortSelectOption(List<SelectOption> options)
    {
        Integer listSize = options.size();
        //my own inefficient bubble sort
        for(Integer i=0;i<listSize;i++)
            for(Integer j=0;j<listSize;j++)
                if(options[i].getLabel().compareTo(options[j].getLabel()) < 0)
                {
                    //SWAPPING!
                    SelectOption temp = new SelectOption(options[i].getValue(),options[i].getLabel());
                    options[i].setValue( options[j].getValue() );
                    options[i].setLabel( options[j].getLabel() );
                    options[j].setValue( temp.getValue() );
                    options[j].setLabel( temp.getLabel() );
                }
        return options;
    }
    /*
    public List<SelectOption> getCommunities()
    {
        List<Network> communities = [select id, name from Network where Status = 'Live' order by name ASC];
        List<SelectOption> options = new List<SelectOption>();
        for(Network c : communities)
            options.add(new SelectOption(c.id,c.name));
        return options;
    }*/
    public List<SelectOption> getUsers()
    {
        List<User> users = [select id, name from User where UserType in ('Standard','CsnOnly','CspLitePortal','PowerPartner') and IsActive = true order by Name ASC NULLS LAST];
        List<SelectOption> options = new List<SelectOption>();
        for(User u : users)
            options.add(new SelectOption(u.id,u.name));
        return options;
    }
}