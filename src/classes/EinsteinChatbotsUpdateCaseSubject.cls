global class EinsteinChatbotsUpdateCaseSubject {
    @InvocableMethod(label='Einstein Chatbots - Update Case Subject' description='Updates the subject of the case')
    global static List<Case> updateCaseSubject(List<ChatbotCaseSubjectRequest> requests) 
    {
        List<Case> results = new List<Case>();
        For (ChatbotCaseSubjectRequest request : requests)
        {
            Case objCase = request.caseObj;
            String subject = request.caseSubject;
            if (objCase != null && String.IsNotBlank(objCase.Id) && String.isNotBlank(subject))
            {
                objCase.Subject = subject;
                update objCase;
                results.add(objCase);
                return results; 
            }
            break;
        }        
        return new List<Case>{new Case()};
    }
    
    global class ChatbotCaseSubjectRequest
    {
        @InvocableVariable(required=true)
        global string caseSubject;
        @InvocableVariable(required=true)
        global Case caseObj;
    }
}