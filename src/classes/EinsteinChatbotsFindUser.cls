global class EinsteinChatbotsFindUser
{
    @InvocableMethod(label='Einstein Chatbots - Find User For Contact' description='Returns the Salesforce User associated with the specified Contact')
    global static List<List<User>> getAssets(List<Contact> contacts) 
    {
        List<User> listUsers = new List<User>();
        
        For (Contact currentContact : contacts)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                List<User> Users = [SELECT Id, ContactId FROM User WHERE ContactId = :currentContact.id LIMIT 1];
                if (Users != null && Users.size() > 0)
                {
                    return new List<List<User>>{Users};
                }
                break;
            }
        }
        
        return new List<List<User>>{new List<User>{new User()}};
    }
}