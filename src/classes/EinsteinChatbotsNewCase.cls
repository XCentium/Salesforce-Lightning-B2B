global class EinsteinChatbotsNewCase {
    @InvocableMethod(label='Einstein Chatbots - New Case' description='Create New Case for Contact')
    global static List<Case> createContactNewCase(List<UpdateStringRequest> requests) 
    {  
        List<Case> caseQuery = new List<Case>();
        For (UpdateStringRequest request : requests)
        {             
               Case caseObj = new Case();
               		caseObj.ContactId = request.objContact.Id;
               		caseObj.Subject = request.Subject;
                    caseObj.Description = request.Comment;
                    caseObj.Status = 'New';
                    caseObj.Origin = 'Chat';
                    caseObj.Priority = 'Medium';

               insert caseObj;
			   Id caseId = caseObj.Id;

               List<Case> Cases = [SELECT Id, LastModifiedDate, Status, Subject, CaseNumber, Origin, Priority FROM Case WHERE Id = :caseId];
               if (Cases != null && Cases.size() > 0)
               {
               		return Cases;
               }
               break;
        }
        return caseQuery; 
    }
    global class UpdateStringRequest
    {
        @InvocableVariable(required=true)
        global Contact objContact;
        
        @InvocableVariable(required=true) 
        global string Subject;
        
        @InvocableVariable(required=true)
        global string Comment;
    }
}