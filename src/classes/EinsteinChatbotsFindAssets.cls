global class EinsteinChatbotsFindAssets
{
    @InvocableMethod(label='Einstein Chatbots - Find Assets For Contact' description='Returns a list of Assets for the specified Contact')
    global static List<List<Asset>> getAssets(List<Contact> contacts) 
    {
        List<Asset> listAssets = new List<Asset>();
        
        For (Contact currentContact : contacts)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                List<Asset> Assets = [SELECT Id, Name, LastModifiedDate, ContactId, Status FROM Asset WHERE Status != 'Closed' ORDER BY LastModifiedDate DESC NULLS FIRST LIMIT 3];
                if (Assets != null && Assets.size() > 0)
                {
                    return new List<List<Asset>>{Assets};
                }
                break;
            }
        }
        
        return new List<List<Asset>>{new List<Asset>{new Asset()}};
    }
}