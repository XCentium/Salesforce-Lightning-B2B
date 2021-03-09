global class EinsteinChatbotsCloseCase 
{
    @InvocableMethod(label='Einstein Chatbots - Close Case' description='Closes the selected Case')
    global static List<Case> closeCase(List<Case> requests) 
    {
        List<Case> results = new List<Case>();
        For (Case objCase : requests)
        {
            if (objCase != null && String.IsNotBlank(objCase.Id))
            {
                objCase.Status = 'Closed';
                update objCase;
                results.add(objCase);
                return results; 
            }
            break;
        }
        
        return new List<Case>{new Case()};
    } 
}