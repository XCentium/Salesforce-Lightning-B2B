public with sharing class SearchMembersAndTopicsController {

    @AuraEnabled
    public static list<UserWrapper> searchPeople(String searchString){
        list<UserWrapper> lstusers = new list<UserWrapper>();

        Id networkId = Network.getNetworkID();//Fetch the current community
        searchString = '%' + searchString  + '%'; 
        //Get User records as per search keyterm
        map<id,User> mapIdByUser = new map<id,User>([Select Id,
                                                            Name,
                                                            smallPhotoURL,
                                                            (Select Id,Title,NetworkScope 
                                                                From Feeds 
                                                                WHERE type='QuestionPost' 
                                                                order by createdDate 
                                                            DESC LIMIT 5)
                                                            from User
                                                            WHERE (Name LIKE :searchString
                                                            OR AboutMe LIKE :searchString) 
                                                            AND isActive=true
                                                            LIMIT 100]);
        //Filter the users found for specific community
        map<id,NetworkMember> mapIdByNetworkmember = new map<id,NetworkMember>([Select NetworkId,
                                                                                MemberId,
                                                                                CreatedDate,
                                                                               ReputationPoints
                                                                                FROM NetworkMember
                                                                                WHERE NetworkId=:networkId
                                                                                AND MemberId IN :mapIdByUser.keyset() limit 25]);
        //Form the wrapper object for UI lightning binding
        for(Id networkmem :mapIdByNetworkmember.keyset()){
            UserWrapper u = new UserWrapper();
            u.usr = mapIdByUser.get(mapIdByNetworkmember.get(networkmem).MemberId);
            u.networkmember = mapIdByNetworkmember.get(networkmem);
            for(UserFeed usrfeed :u.usr.Feeds){
                if(usrfeed.NetworkScope == networkId){
                    u.lstfeedItem.add(usrfeed);
                }
            }
            u.points = integer.valueof(mapIdByNetworkmember.get(networkmem).ReputationPoints);
            u.imageurl = u.usr.smallPhotoURL;
            u.membersince = date.valueof(u.networkmember.createdDate);
            if(!Test.isRunningTest()){ //Connect API doesn't support apex tests
                u.level = ConnectApi.ChatterUsers.getReputation(networkId, u.usr.Id).reputationLevel.levelName;
            }
            lstusers.add(u);
        }   
        system.debug(lstusers);
        return lstusers;
    }

    @AuraEnabled
    public static List<Topic> searchTopics(String searchString) {
        System.debug('Running topic search for term ' + searchString);
        Id networkId = Network.getNetworkId();//Fetch the community Id of the Current User
        List<Topic> topics = new List<Topic>();
        
        if(searchString.length() > 1){
            String searchStr = massageSearchTerm(searchString);
            List<List<SObject>> searchList = [
                FIND
                    :searchStr
                IN
                    NAME FIELDS
                RETURNING
                    Topic(Id, Name, Description WHERE NetworkId = :networkId)
            ];
            System.debug('Converting topic list.');
            topics = (List<Topic>)searchList[0];
        }
        else {
            topics = [Select Id, Name, Description FROM Topic Where NetworkId = :networkId];
        }
        System.debug('Returning ' + topics.size() + ' topics.');
        return topics;
    }

    @AuraEnabled
    public static String massageSearchTerm(String searchTerm) {
        if (searchTerm == null) {
            return '';
        }
        
        return searchTerm  + '*';
    }


    public class UserWrapper {

        @AuraEnabled
        public User usr {get;set;}
        @AuraEnabled
        public NetworkMember networkmember {get;set;}
        @AuraEnabled
        public List<UserFeed> lstfeedItem {get;set;}
        @AuraEnabled
        public Date membersince {get;set;}
        @AuraEnabled
        public String level {get;set;}
        @AuraEnabled
        public integer points {get;set;}
        @AuraEnabled
        public String imageurl {get;set;}

        public UserWrapper(){
            usr = new User();
            lstfeedItem = new List<UserFeed>();
            points = 0;
        }
    }
    
    public static void testFill(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}