public class MyTopicsController {
 
    @AuraEnabled
    public static List<TopicWithFollower> getTopicsWithFollowers(String prefix) {
      List<TopicWithFollower> topicsWithFollowers = new List<TopicWithFollower>();
      List<User> us = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
      User u = us.get(0);
      Network myNetwork = [SELECT Id FROM Network where URLPathPrefix =: prefix LIMIT 1];
      List<Topic> myTopics = new List<Topic>();
      List<EntitySubscription> mySubscribes = [SELECT ParentId, NetworkId FROM EntitySubscription WHERE SubscriberId =:u.Id AND NetworkId =: myNetwork.Id LIMIT 1000];
        for(EntitySubscription e: mySubscribes){
      	 Integer i = [SELECT count() FROM EntitySubscription WHERE ParentId =:e.ParentId AND NetworkId =: e.NetworkId LIMIT 1000];
         Topic t = [SELECT Id, Name FROM Topic WHERE Id =: e.ParentId LIMIT 1];
         TopicWithFollower twf = new TopicWithFollower();
         twf.followers= i;
         twf.myTopic = t;
         System.debug('twf: ' + twf);
         topicsWithFollowers.add(twf);
      }
      System.debug('topicwithfollowers: ' + topicsWithFollowers);
      return topicsWithFollowers;
  	}
    
        @AuraEnabled
    public static Boolean hasFollowers(String pre) {
        List<TopicWithFollower> topicsWithFollowers = new List<TopicWithFollower>();
        List<User> us = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        User u = us.get(0);
        Network myNetwork = [SELECT Id FROM Network where URLPathPrefix =: pre LIMIT 1];
        List<Topic> myTopics = new List<Topic>();
        Integer follows = [SELECT Count() FROM EntitySubscription WHERE SubscriberId =:u.Id AND NetworkId =: myNetwork.Id LIMIT 1000];
        if(follows>0){
            return true;
        }
        return false;
    }
    
    
    
}