global class EinsteinChatbotsUpdateEmail 
{
    @InvocableMethod(label='Einstein Chatbots - Update Email' description='Allows the user to change the email address for their Community User and Contact')
    global static List<Contact> updateEmail(List<UpdateStringRequest> requests) 
    {
        List<Contact> results = new List<Contact>();
        For (UpdateStringRequest request : requests)
        {
            system.debug('property value:' + request.value);
            if (request.objContact != null && request.objContact.Id != null && String.IsNotBlank(request.value))
            {
                Contact currentContact = request.objContact;
                currentContact.email = request.value;
                update currentContact;
                
                //Update user email
                List<User> CommunityUser = [SELECT Id, email FROM USER WHERE ContactId =: request.objContact.id LIMIT 1];
                if (CommunityUser != null && CommunityUser.size() > 0)
                {
                    User CurrentUser = CommunityUser[0];
                    currentUser.Email = request.value;
                    update currentUser;
                }
                return new List<Contact>{currentContact};
                    }
        }
        return new List<Contact>{requests[0].objContact};
            }
    
    global class UpdateStringRequest
    {
        @InvocableVariable(required=true)
        global string value;
        @InvocableVariable(required=true)
        global Contact objContact;
    }
}