global class EinsteinChatbotsFindLiveChatTranscript {
    @InvocableMethod(label='Einstein Chatbots - Find LiveChatTranscript By Session Id' description='Returns a LiveChatTranscript for the specified Session Id')
    global static List<LiveChatTranscript> findLiveChatTranscriptFromSessionId(List<string> requests) 
    {
        List<LiveChatTranscript> results = new List<LiveChatTranscript>();
        for (string request : requests) 
        {
            if (String.IsNotBlank(request))
            {
                LiveChatTranscript newLiveChatTranscript = findLiveChatTranscriptFromSessionId(request);
                if (newLiveChatTranscript != null && string.isNotBlank(newLiveChatTranscript.Id))
                {
                    results.add(findLiveChatTranscriptFromSessionId(request));   
                }
            }      
        }
        if (results.size() == 0) 
        {
            return new List<LiveChatTranscript>{new LiveChatTranscript()};
        }
        return results;
    }
    
    public static LiveChatTranscript findLiveChatTranscriptFromSessionId(string request) 
    {
        LIST<LiveChatTranscript> newLiveChatTranscript = [SELECT Id, ContactId, CaseId, LeadId FROM LiveChatTranscript WHERE ChatKey =: request LIMIT 1];      
        
        if (newLiveChatTranscript != null && newLiveChatTranscript.size() > 0) {
            return newLiveChatTranscript[0];
        } else {
            return new LiveChatTranscript();
        }
    }
}