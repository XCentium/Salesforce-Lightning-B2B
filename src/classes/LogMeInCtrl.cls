public class LogMeInCtrl {
	
	@AuraEnabled
    public static Login[] getLogins(String sExternalIds){
        String orgId = UserInfo.getOrganizationId();
        
        List<Login> Logins = new List<Login>();
        List<String> externalIds = new List<String>();
        List<User> loginUsers = new List<User>();
        List<NetworkMember> networks = new List<NetworkMember>();
        
        Map<Id, List<NetworkMember>> networkMap = new Map<Id, List<NetworkMember>>();
        
        
        //Change query if 
        externalIds = (List<String>)JSON.deserialize(sExternalIds, List<String>.class);
        
        if(externalIds.size() <= 0){
            //SDO Defaults
            //Internal Users
            externalIds.add('User.007'); //Elliot Executive
            externalIds.add('User.016'); //Cindy Central
            externalIds.add('User.031'); //Tim Service
            externalIds.add('User.102'); //Mark Watson
            
            //Community Users
            externalIds.add('User.075'); //Lauren Boyle
            externalIds.add('User.062'); //Larry Baxter
            externalIds.add('User.059'); //Paul Partner
            externalIds.add('User.002'); //Chet Callaghan
        }
        
        loginUsers = [Select Id, FirstName, LastName, Persona_Description__c,  SmallPhotoUrl, ContactId ,Title, UserType
                      From User 
                      Where External_Id__c IN :externalIds
                      Order By Name ASC];
        networks = [Select MemberId, Network.Name, NetworkId 
                    From NetworkMember 
                    Where MemberId IN: loginUsers 
                    And Network.Status = 'Live'];
        
        for(NetworkMember nm: networks){
            List<NetworkMember> activeNetworks = new List<NetworkMember>();
            
            if(networkMap.containsKey(nm.MemberId)){
                activeNetworks = networkMap.get(nm.MemberId);
                activeNetworks.add(nm);
                networkMap.put(nm.MemberId, activeNetworks);
            }
            else {
                activeNetworks.add(nm);
                networkMap.put(nm.MemberId, activeNetworks);
            }
        }
        
        for(User loginUser: loginUsers){
            NetworkMember[] nw = networkMap.get(loginUser.Id);
        	Logins.add(new Login(loginUser, orgId, nw));
        }
        
        return Logins;
    }
    
    @AuraEnabled
    public static String getOrgId(){
        return UserInfo.getOrganizationId();
    }
    
    @AuraEnabled
    public static Boolean isInternalUser(String userId){
        User u = [Select ContactId From User Where Id = :userId Limit 1];
        System.debug(u.get('ContactId'));
        return u.get('ContactId') == null ? true : false;
    }
    
    public class Login {
        @AuraEnabled
        public User loginUser {get;set;}
        @AuraEnabled
        public String orgId {get;set;}
        @AuraEnabled
        public NetworkMember[] networks {get;set;}
        
        public Login(){
        }
        public Login(User loginUser, String orgId, NetworkMember[] networks){
            this.loginUser = loginUser;
            this.orgId = orgId;
            this.networks = networks;
        }
    }
}