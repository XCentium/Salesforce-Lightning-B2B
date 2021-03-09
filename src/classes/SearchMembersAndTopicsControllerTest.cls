@IsTest(seeAllData=true)
public class SearchMembersAndTopicsControllerTest {
     /* public static User createCommunityUser(){

        Profile p = [Select Id  FROM  
                                PROFILE 
                                WHERE 
                                Name = 'Community User'];

            Profile p2 = [Select Id 
                                FROM  
                                PROFILE 
                                WHERE 
                                Name = 'System Administrator'];

            UserRole  r = [Select Id from UserRole  LIMIT 1];

            User user = new User();

            User testportaluser = new User(alias = 'testport', email='testportadm@noemail.com',
            emailencodingkey='UTF-8', lastname='testportadm', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, country='United States',IsActive =true,
            timezonesidkey='America/Los_Angeles', username='testportadm@noemail.com',UserRoleId = r.Id);

            system.RunAs(testportaluser){

                Account ac = new Account(name ='Test Account') ;
                insert ac; 
           
                Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
                insert con;

                user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

            }

            return user;
    }
    
    enum PortalType { CSPLiteUser, PowerPartner, PowerCustomerSuccess, CustomerSuccess }
    
    
    public static User getPortalUser(PortalType portalType, User userWithRole, String username, Contact con, Boolean doInsert) {
        
       
        if(userWithRole == null) {   
            
            if(UserInfo.getUserRoleId() == null) {

                UserRole r = new UserRole(name = 'TEST ROLE');
                Database.insert(r);
                
                userWithRole = new User(alias = 'hasrole', email=username + '@roletest.com', userroleid = r.id,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = '00e36000000IQ9BAAW', 
                                    timezonesidkey='America/Los_Angeles', username=username + '@testorg.com');
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
            
            System.assert(userWithRole.userRoleId != null, 
                          'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
        }

        
        Profile p = [select id 
                      from profile 
                     where usertype = :portalType.name() 
                     limit 1];   
        
        String testemail = username + '@amamama.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail, 
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                           alias='cspu', lastname='lastname', contactId = con.id);
        
        if(doInsert) {
            Database.insert(pu);
        }
        return pu;
    }
    
    public static void testUnit(){
        
        
        Account a;
        Contact c;
        a = new Account(name = 'TEST ACCOUNT');
        insert a;
        c = new Contact(AccountId = a.id, lastname = 'lastname');
        Database.insert(c);
        
        User pu = getPortalUser(PortalType.PowerCustomerSuccess, null, 'TestUser', c, true);
        
        List<Topic> testTopics = new List<Topic>();
        
        List<Object> testUsers = new List<Object>();
        testUsers = SearchMembersAndTopicsController.searchPeople('test');
        testTopics = SearchMembersAndTopicsController.searchTopics('test');
    }
    
    
    public class UserWrapper {

        public User usr {get;set;}
        public NetworkMember networkmember {get;set;}
        public List<UserFeed> lstfeedItem {get;set;}
        public Date membersince {get;set;}
        public String level {get;set;}
        public integer points {get;set;}
        public String imageurl {get;set;}

        public UserWrapper(){
            usr = new User();
            lstfeedItem = new List<UserFeed>();
            points = 0;
        }
    }*/
    
    @IsTest(seeAllData=true)
    public static void testUnit(){
        SearchMembersAndTopicsController.testFill();
    }
}