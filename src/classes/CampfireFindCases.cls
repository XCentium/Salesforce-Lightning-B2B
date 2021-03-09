global class CampfireFindCases 
{
    @InvocableMethod(label='Campfire - Find Cases For Contact' description='Returns a list of Cases for the specified Contact')
    global static List<List<Case>> getCases(List<Contact> contacts) 
    {
        List<Case> listCases = new List<Case>();
        
        For (Contact currentContact : contacts)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                List<Case> Cases = [SELECT Id, Status, Subject FROM Case WHERE Status != 'Closed' AND ContactId =: currentContact.Id ORDER BY LastModifiedDate DESC NULLS FIRST LIMIT 3];
                if (Cases != null && Cases.size() > 0)
                {
                    return new List<List<Case>>{Cases};
                }
                break;
            }
        }
        
        return new List<List<Case>>{new List<Case>{}};
    }
}