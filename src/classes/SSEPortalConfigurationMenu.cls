public class SSEPortalConfigurationMenu {

    public List<User> allUsers {get;set;}
    public List<Org_Template__c> allTemplates{get;set;}
    
    public SSEPortalConfigurationMenu(){
        allUsers = [SELECT id,name,branding_template__c FROM User ORDER BY Name ASC];
        allTemplates = [SELECT id,name FROM Org_Template__c];
    }
    
    //If users don't have associated template, add default one
    public void updateEmptyUsers(){
        if(allTemplates.size() > 0){
            List<User> updatedUsers = new List<User>();
            for(User u : allUsers){
                if(u.branding_template__c == null){
                    u.branding_template__c = allTemplates[0].name;
                    updatedUsers.add(u);
                }
            }
            if(updatedUsers.size() > 0){
                update updatedUsers;
            }
        }
    }
    
    //Save user
    @remoteAction
    public static void updateUser(String userId, String userTemplate){
        User theUser = [SELECT id,name,branding_template__c FROM User WHERE id = :userId];
        theUser.branding_template__c = userTemplate;
        update theUser;
    }
    
    //Test method
    public static testmethod void testSSEPortalConfigurationMenu() {
        SSEPortalConfigurationMenu controller = new SSEPortalConfigurationMenu();
        SSEPortalConfigurationMenu.updateUser(UserInfo.getUserId(), 'Cirrus');
    }
    
}