public class CommunityLoginCtrl {
    
    @AuraEnabled
    public static Login getNetworks(Id recordId){
        Boolean isPersonAccount = (recordId.getSobjectType() == Schema.Account.SObjectType);
		String contactId;
        
        //Fetch proper user regardless of Person Account or Contact
        if(isPersonAccount){
            contactId = [Select PersonContactId From Account Where Id =: recordId Limit 1].PersonContactId;
        }
        else {
            contactId = recordId;
        }
        
        User loginUser  = [Select Id From User Where ContactId =: contactId Limit 1];
        List<NetworkMember> networks = [Select Network.Name, NetworkId 
                                        From Networkmember 
                                        Where memberid =: loginUser.Id
                                        And Network.Status = 'Live'];
        
        return new Login(loginUser, networks, UserInfo.getOrganizationId());
    }
    
    public class Login {
        @AuraEnabled
        public User loginUser;
        @AuraEnabled
        public List<NetworkMember> networks;
        @AuraEnabled
        public Id orgId;
        
        public Login(User u, List<NetworkMember> n, Id o){
            this.loginUser = u;
            this.networks = n;
            this.orgId = o;
        }
    }
}