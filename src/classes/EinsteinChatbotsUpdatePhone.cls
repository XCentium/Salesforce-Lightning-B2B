global class EinsteinChatbotsUpdatePhone 
{
    @InvocableMethod(label='Einstein Chatbots - Update Phone' description='Allows the user to change the Phone number for their Community User and Contact')
    global static List<Contact> updatePhone(List<UpdateStringRequest> requests) 
    {
        List<Contact> results = new List<Contact>();
        For (UpdateStringRequest request : requests)
        {
            system.debug('property value:' + request.value);
            if (request.objContact != null && request.objContact.Id != null && String.IsNotBlank(request.value))
            {
                Contact currentContact = request.objContact;
                currentContact.Phone = request.value;
                update currentContact;
                
                //Update user Phone
                List<User> CommunityUser = [SELECT Id, email, Phone FROM USER WHERE ContactId =: request.objContact.id LIMIT 1];
                if (CommunityUser != null && CommunityUser.size() > 0)
                {
                    User CurrentUser = CommunityUser[0];
                    currentUser.Phone = request.value;
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