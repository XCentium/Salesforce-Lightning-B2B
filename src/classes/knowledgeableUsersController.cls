public class knowledgeableUsersController {
    
    @AuraEnabled
    public static String getNetworkId(){
        String networkId = Network.getNetworkId();
        return networkId;
    }
    
    @AuraEnabled
    public static String[] getTopicSuggestions(String networkId, String feedItemId){
        ConnectApi.TopicSuggestionPage topicsPage = ConnectApi.Topics.getTopicSuggestions(networkId, feedItemId);
        ConnectApi.Topic[] topicsList = new ConnectApi.Topic[]{};
        String[] suggestedIds = new String[]{};
            
        for(ConnectApi.TopicSuggestion ts: topicsPage.topicSuggestions){
            if(ts.existingTopic != null) {
            	topicsList.add( ts.existingTopic );
            }
        }
        
        for(ConnectApi.Topic t: topicsList) {
            String tempString = String.valueOf( t.Id );
            suggestedIds.add(tempString);
        }
        
		return suggestedIds;
    }
    
    @AuraEnabled
    public static String[] getTopics(String feedItemId){
        String[] topicIds = new String[]{};
        
        TopicAssignment[] listedTopics = new TopicAssignment[]{};
        listedTopics = [Select TopicId From TopicAssignment Where EntityId = :feedItemId];
        
        
        for(TopicAssignment ta: listedTopics) {
            topicIds.add(ta.TopicId);
        }
        return topicIds;
    }
    
    @AuraEnabled
    public static String[] getKnowledgeableUsers(String networkId, String topicIds){
        String[] theTopics = topicIds.split(',');
        String[] smartUserIds = new String[]{};
        
        KnowledgeableUser[] smartUsers = new KnowledgeableUser[]{};
        smartUsers = [Select UserId From KnowledgeableUser WHERE NetworkId = :networkId AND TopicId = :theTopics AND UserId != :UserInfo.getUserId()];
        
        for(KnowledgeableUser ku: smartUsers){
            smartUserIds.add(ku.UserId);
        }
        
        return smartUserIds;
    }
    
    @AuraEnabled
    public static User[] getShownUsers(String smartUserIds, Decimal page, Decimal shownPerPage){
        Integer pageLimit = Integer.valueOf(shownPerPage);
        Integer pageOffset = Integer.valueOf((page * pageLimit) - pageLimit);
        String[] theUserIds = smartUserIds.split(',');
        
        User[] returnedUsers = new User[]{};
        returnedUsers = [Select Id, SmallPhotoURL, Alias, ContactId From User Where Id = :theUserIds Limit :pageLimit OFFSET :pageOffset];
        
        return returnedUsers;
    }
}