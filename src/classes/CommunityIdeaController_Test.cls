@isTest(SeeAllData=true)
private class CommunityIdeaController_Test {
    
    static testMethod void unitTest(){
        //CommunityIdeaController.getLoginURL('/login');
        CommunityIdeaController.getCurrentCommunityZones();
        CommunityIdeaController.getCurrentCommunityZoneIDs();
        CommunityIdeaController.getMyIdeas();
        CommunityIdeaController.getTotalIdeas(5, 'Popular', 1, CommunityIdeaController.getCurrentCommunityZoneIDs()[0]);
        CommunityIdeaController.getTotalIdeas(5, 'my', 1, CommunityIdeaController.getCurrentCommunityZoneIDs()[0]);
        CommunityIdeaController.getIdeasList(5, 'Popular', 1, CommunityIdeaController.getCurrentCommunityZoneIDs()[0]);
        CommunityIdeaController.getIdeasList(5, 'Recent', 1, CommunityIdeaController.getCurrentCommunityZoneIDs()[0]);
        CommunityIdeaController.getIdeasList(5, 'my', 1, CommunityIdeaController.getCurrentCommunityZoneIDs()[0]);
        Community com = [select Id from Community limit 1];
        Idea newIdea = new Idea(Body='My Idea');
        newIdea.Title = 'Test Idea';
        newIdea.CommunityId = com.Id;
        insert newIdea;
        CommunityIdeaController.getUserIdeas(newIdea.Id);
        CommunityIdeaController.promoteIdea(newIdea.Id);
        CommunityIdeaController.promoteFromIdeaDetails(newIdea.Id);
        CommunityIdeaController.demoteIdea(newIdea.Id);
        CommunityIdeaController.demoteFromIdeaDetails(newIdea.Id);
        CommunityIdeaController.getIdea(newIdea.Id);
        
        IdeaComment newComment = new IdeaComment(IdeaId = newIdea.Id, CommentBody = 'Test Comment');
        insert newComment;
        
        CommunityIdeaController.getComment(newIdea.Id);
        
        Vote newVote = new Vote(Type = 'Up', ParentId = newComment.Id);
        insert newVote;
        
        CommunityIdeaController.unlikeThisComment(newIdea.Id, newVote.Id);
        CommunityIdeaController.likeThisComment(newIdea.Id, newComment.Id);
        CommunityIdeaController.postComment(newIdea.Id, 'Test Comment');
        CommunityIdeaController.deleteThisComment(newIdea.Id, newComment.Id);
        CommunityIdeaController.postIdea('Idea Title', 'Idea body', CommunityIdeaController.getCurrentCommunityZoneIDs()[0]);
        CommunityIdeaController.findSimilarIdeas('Idea Title');
        CommunityIdeaController.isGuestUser();
        CommunityIdeaController.getUserType();
    }
    
}