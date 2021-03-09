public with sharing class CommunityIdeaController {
    /*Get the URL to force login*/
    @AuraEnabled
    public static String getLoginURL(String returnURL) {
        PageReference pr = Network.forwardToAuthPage(returnURL);
        return pr.getUrl();
    }
    
    /*Current Community Zone*/
    @AuraEnabled
    public static List<Community> getCurrentCommunityZones() {
        List<Community> zones = new List<Community>();
        try {
            zones = [SELECT CreatedById, CreatedDate, Description, Id, IsActive, LastModifiedById,
                     LastModifiedDate, Name, NetworkId, SystemModstamp 
                     FROM Community WHERE NetworkId = :Network.getNetworkId() AND IsActive = true
                    ];
        } catch (Exception e) {
            System.debug(e);
        }
        
        return zones;
    }
    
    /*Current community Zone Id's*/
    @AuraEnabled
    public static List<Id> getCurrentCommunityZoneIDs() {
        List<Id> zones = new List<Id>();
        try {
            List<Community> zoneRecords = getCurrentCommunityZones();
            zones = new List<Id>();
            for (Community cmt : zoneRecords) {
                zones.add(cmt.Id);
            }
        } catch (Exception e) {
            System.debug(e);
        }
        
        return zones;
    }
    
    /*Get My Ideas*/
    @AuraEnabled
    public static List<Idea> getMyIdeas() {
        List<Idea> myIdeas = new List<Idea>();
        try {
            myIdeas = [SELECT Id, Title, Status, RecordTypeId, CreatedById, CreatedDate, CreatorName,
                    CreatorSmallPhotoUrl, Body, Categories, NumComments, VoteScore, VoteTotal 
                    FROM Idea WHERE CreatedById = :UserInfo.getUserId() AND CommunityId IN :getCurrentCommunityZoneIDs()
                    ORDER BY VoteTotal DESC NULLS LAST LIMIT 10
            ];
        } catch (Exception e) {
            System.debug(e);
        }
        return myIdeas;
    }
    
    /*Get recent Ideas*/
    @AuraEnabled
    public static Integer getTotalIdeas(Integer ideasPerPage, String selectedFilter, Integer selPageNo, String selectedZone) {
        Integer recordsPerPage = integer.valueof(ideasPerPage);
        Integer pageNo = integer.valueof(selPageNo);
        Integer pageoffset = pageNo*recordsPerPage;
        
        Integer TotalIdeas = 0;
        try {
            if(selectedFilter == 'Recent' || selectedFilter == 'Popular'){
                TotalIdeas = [SELECT count() FROM Idea 
                        WHERE IsDeleted = false AND CommunityId = :selectedZone
                ];
            }else if(selectedFilter == 'my'){
                TotalIdeas = [SELECT count() FROM Idea 
                        WHERE IsDeleted = false AND CommunityId = :selectedZone and CreatedById =: userinfo.getuserid()
                ];
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return TotalIdeas;
    }
    
    /*Get recent Ideas*/
    @AuraEnabled
    public static List<Idea> getIdeasList(Integer ideasPerPage, String selectedFilter, Integer selPageNo, String selectedZone) {
        system.debug('----Venky: '+selectedZone);
        Integer recordsPerPage = integer.valueof(ideasPerPage);
        Integer pageNo = integer.valueof(selPageNo);
        Integer pageoffset = pageNo*recordsPerPage;
        List<Idea> IdeasList = new List<Idea>();
        try {
            if(selectedFilter == 'Recent'){
                IdeasList = [SELECT Id, Title, Status, RecordTypeId, CreatedById, CreatedDate, CreatorName,
                        CreatorSmallPhotoUrl, Body, Categories, NumComments, VoteScore, VoteTotal,
                        (Select Id, ParentId, Type, CreatedDate, CreatedById From Votes where CreatedById =: userinfo.getuserid()) 
                        FROM Idea 
                        WHERE IsDeleted = false AND CommunityId = :selectedZone
                        ORDER BY CreatedDate DESC NULLS LAST LIMIT :recordsPerPage offset :pageoffset
                ];
            }else if(selectedFilter == 'Popular'){
                 IdeasList = [SELECT Id, Title, Status, RecordTypeId, CreatedById, CreatedDate, CreatorName,
                        CreatorSmallPhotoUrl, Body, Categories, NumComments, VoteScore, VoteTotal,
                        (Select Id, ParentId, Type, CreatedDate, CreatedById From Votes where CreatedById =: userinfo.getuserid()) 
                        FROM Idea 
                        WHERE IsDeleted = false AND CommunityId = :selectedZone
                        ORDER BY VoteTotal DESC NULLS LAST LIMIT :recordsPerPage offset :pageoffset
                ];
            }else if(selectedFilter == 'my'){
                 IdeasList = [SELECT Id, Title, Status, RecordTypeId, CreatedById, CreatedDate, CreatorName,
                        CreatorSmallPhotoUrl, Body, Categories, NumComments, VoteScore, VoteTotal,
                        (Select Id, ParentId, Type, CreatedDate, CreatedById From Votes where CreatedById =: userinfo.getuserid()) 
                        FROM Idea 
                        WHERE IsDeleted = false AND CommunityId = :selectedZone and CreatedById =: userinfo.getuserid()
                        ORDER BY CreatedDate DESC NULLS LAST LIMIT :recordsPerPage offset :pageoffset
                ];
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return IdeasList;
    }
    
    /*Get one user's Ideas*/
    @AuraEnabled
    public static List<Idea> getUserIdeas(String userId) {
        system.debug('----VUserId: '+ userId);
        List<Idea> IdeasList = new List<Idea>();
        try {
            IdeasList = [
                SELECT 
                    Id,
                    Title,
                    Status,
                    CreatedDate,
                    CreatorName,
                    RecordTypeId
                FROM Idea 
                WHERE 
                    CreatedById = :userId 
                ORDER BY VoteTotal DESC NULLS LAST LIMIT 10
                         ];
        } catch (Exception e) {
            System.debug(e);
        }
        
        return IdeasList;
    }
    
    /*Promote an Idea*/
    @AuraEnabled
    public static String promoteIdea(String IdeaId) {
        List<Idea> recentIdeas = new List<Idea>();
        try {
            Vote newVote = new Vote();
            newVote.Type = 'Up';
            newVote.ParentId = IdeaId;
            insert newVote;
            
        } catch (Exception e) {
            System.debug(e);
        }
        return 'Idea Promoted';
    }
    
    /*Promote an Idea from IdeaDetails page*/
    @AuraEnabled
    public static Idea promoteFromIdeaDetails(String IdeaId) {
        try {
            Vote newVote = new Vote();
            newVote.Type = 'Up';
            newVote.ParentId = IdeaId;
            insert newVote;
            
        } catch (Exception e) {
            System.debug(e);
        }
        return getIdea(IdeaId);
    }
        
    /*Demote an Idea*/
    @AuraEnabled
    public static String demoteIdea(String IdeaId) {
        List<Idea> recentIdeas = new List<Idea>();
        try {
            Vote newVote = new Vote();
            newVote.Type = 'Down';
            newVote.ParentId = IdeaId;
            insert newVote;
            
        } catch (Exception e) {
            System.debug(e);
        }
        return 'Idea Demoted';
    }
    
    /*Demote an Idea from IdeaDetails page*/
    @AuraEnabled
    public static Idea demoteFromIdeaDetails(String IdeaId) {
        try {
            Vote newVote = new Vote();
            newVote.Type = 'Down';
            newVote.ParentId = IdeaId;
            insert newVote;
            
        } catch (Exception e) {
            System.debug(e);
        }
        return getIdea(IdeaId);
    }
    
    /*Get an Idea*/
    @AuraEnabled
    public static Idea getIdea(String IdeaId) {
        Idea thisidea = null;
        try {
            thisIdea = [
                SELECT 
                    Id,
                    Title,
                    Status,
                    RecordTypeId,
                    CreatedById,
                    CreatedDate,
                    CreatorName,
                    CreatorSmallPhotoUrl,
                    Body,
                    Categories,
                    NumComments,
                    VoteScore,
                    VoteTotal,
                    (Select Id, ParentId, Type, CreatedDate, CreatedById From Votes where CreatedById =: userinfo.getuserid()),
                    (Select Id, CommentBody, CreatedBy.Name, CreatedDate, UpVotes From Comments where IsDeleted = false order by CreatedDate)
                FROM 
                    Idea 
                WHERE 
                    Id = :IdeaId
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug(e);
        }
        system.debug('****** thisIdea: '+thisIdea);
        return thisIdea;
    }
    
    
    /*get Idea Comments*/
    @AuraEnabled
    public static List<IdeaComment> getComment(String IdeaId){
        system.debug('ideaId: '+IdeaId);
        List<IdeaComment> IdeaCommentList = [Select Id, CommentBody, CreatedBy.Name, CreatedDate, UpVotes,
                                             (Select Id, ParentId, Type, CreatedDate, CreatedById From Votes where CreatedById =: userinfo.getuserid())
                                             From IdeaComment where IdeaId =: IdeaId and IsDeleted = false order by CreatedDate];
        
        return IdeaCommentList;
    }
    
    /*unlike Idea Comment*/
    @AuraEnabled
    public static List<IdeaComment> unlikeThisComment(String IdeaId, String VoteId){
        delete [select id from Vote where Id =: VoteId]; 
        
        return getComment(ideaId);
    }
    
    /* like Idea Comment*/
    @AuraEnabled
    public static List<IdeaComment> likeThisComment(String IdeaId, String commentId){
        try {
            Vote newVote = new Vote();
            newVote.Type = 'Up';
            newVote.ParentId = commentId;
            insert newVote;
            
        } catch (Exception e) {
            System.debug(e);
        }
        
        return getComment(ideaId);
    }
    
    /*Post Idea Comment*/
    @AuraEnabled
    public static List<IdeaComment> postComment(String IdeaId, String CommentBody){
        system.debug('ideaId: '+IdeaId);
        system.debug('newComment: '+CommentBody);
        IdeaComment newComment = new IdeaComment();
        newComment.IdeaId = IdeaId;
        newComment.CommentBody = CommentBody;
        insert newComment;
        
        return getComment(IdeaId);
    }
    
    /*Delete Idea Comment*/
    @AuraEnabled
    public static List<IdeaComment> deleteThisComment(String IdeaId, String commentId){
        system.debug('commentId: '+commentId);
        delete [select id from IdeaComment where Id =: commentId]; 
        
        return getComment(IdeaId);
    }
    
    /*Post Idea*/
    @AuraEnabled
    public static String postIdea(String title, String description, String zone) {
        Idea newIdea = new Idea();
        system.debug('zone: '+zone);
        try {
            Community Settings = [SELECT Id, Name FROM Community where Id =: zone LIMIT 1];
            newIdea.Title = title;
            newIdea.Body = description;
            newIdea.CommunityId = Settings.Id;
            system.debug('newIdea: '+newIdea);
            insert newIdea;
        } catch (Exception e) {
            System.debug(e);
        }
        return newIdea.Id;
    }
    
    /*Find similar ideas*/
    @AuraEnabled
    public static List<Idea> findSimilarIdeas(String title) {
        List<Idea> similarIdeas;
        try {
            String ideaTitle = '%'+title+'%';
            similarIdeas = [select Id, Title, VoteTotal from Idea where Title LIKE : ideaTitle];
            // There is an API call available for this. See https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_ideas.htm
            // You call it like this:
            // ID[] results = Ideas.findSimilar(Idea idea);
        } catch (Exception e) {
            System.debug(e);
        }
        return similarIdeas;
    }
    
    /* Determines whether the surrent user is a guest or not */
    @AuraEnabled
    public static boolean isGuestUser() {
        String userType = getUserType();
        System.debug('Switching off of user type: ' + userType);
        return (userType == 'Guest' ? true : false);
    }
    
    /* Determines the current user type */
    @AuraEnabled
    public static String getUserType() {
        Id userId = UserInfo.getUserId();
        System.debug('User type for user: ' + UserInfo.getUserType());
        return UserInfo.getUserType();
    }
    
}