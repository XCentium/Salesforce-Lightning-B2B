global class EinsteinChatbotsResetPassword 
{
    @InvocableMethod(label='Einstein Chatbots - Password Reset' description='Resets Community user password based on Contact record')
    global static List<Boolean> isValidContact(List<Contact> requests) 
    {
        List<Boolean> results = new List<Boolean>();
        
        if (requests != null && requests.size() > 0 && String.IsNotBlank(requests[0].id))
        {
            //Get reset user
            List<User> CommunityUser = [SELECT Id FROM USER WHERE ContactId =: requests[0].id LIMIT 1];
            if (CommunityUser != null && CommunityUser.size() > 0)
            {
                system.resetPassword(CommunityUser[0].Id, true);
                return new List<Boolean>{true};
            }
        }
        return new List<Boolean>{false};
    }
}