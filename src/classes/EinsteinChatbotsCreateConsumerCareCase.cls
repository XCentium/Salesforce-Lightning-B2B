global class EinsteinChatbotsCreateConsumerCareCase {
    @InvocableMethod(label='Einstein Chatbots - Create Consumer Care Case')
    
    global static List<Case> createChatCase(List<ChatbotCaseRequest> requests)
    {
        List<Case> cases = new List<Case>();
        
        //set case variables based on inputs from bot   
        for (ChatbotCaseRequest request : requests){ 
            /*** Update existing case if one exists ***/
            String caseId = request.objChat.CaseId;
            System.debug('***********Case ID*********** ' + request.objChat.CaseId);
            if(caseId != null){
                Case[] cs = [Select Id, Subject,injury__c,description,product_code_date__c,illness__c,ContactId,Origin  FROM Case WHERE Id = :caseId]; 
                for(Case c: cs) {
                    if (request.caseSubject == null){
                        c.Subject = 'Einstein Bot Case';
                    } else {
                        c.Subject = request.caseSubject;
                    }
                    if (request.illness == TRUE){
                        c.illness__c = request.illness;
                    }
                    
                    c.reason = 'Complaint';
                    
                    if (request.injury == TRUE){
                        c.injury__c = request.injury;
                    }
                    if (request.description != null){
                        c.description = request.description;
                    }    
                    if (request.productcodedate != null){
                        c.product_code_date__c = request.productcodedate;
                    }
                    if (request.objContact != null){
                        c.ContactId = request.objContact.Id;
                    }
                    
                     c.Origin = 'Chat';
                    
                    //if UPC is not null query product and set value of product lookup on the case object
                    if (request.upc != null){
                        Product2[] prod = [Select id from Product2 where UPC_Code__c = :request.upc];
                        if(prod.size() > 0){
                            c.ProductId= prod[0].Id;
                        }    
                    }
                }
                update cs;
                
                Case newCreatedCase = [Select Id, CaseNumber from Case where id=:caseId];
                cases.add(newCreatedCase);
                
                /* Update Chat Transcript to reference newly created Case */
                if(request.chatTranscriptId != ''){
                    LiveChatTranscript [] lct = [Select Id,CaseId  FROM LiveChatTranscript  WHERE Id = :request.chatTranscriptId]; 
                    for(LiveChatTranscript c: lct) {
                       c.CaseId = caseId;  
                    }
                    update lct;
                }

            } 
            /*** If Case Does not exist, create one ***/
            else{
                Case caseObj = new Case();
            
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                          .get('Case').getRecordTypeId();
                          
                caseObj.RecordTypeId = RecordTypeId;
                          
                if (request.caseSubject == null){
                    caseObj.Subject = 'Einstein Bot Case';
                } else {
                    caseObj.subject = request.caseSubject;
                }
                if (request.illness == TRUE){
                    caseObj.illness__c = request.illness;
                }
                
                caseObj.reason = 'Complaint';
                
                if (request.injury == TRUE){
                    caseObj.injury__c = request.injury;
                }
                if (request.description != null){
                    caseObj.description = request.description;
                }    
                if (request.productcodedate != null){
                    caseObj.product_code_date__c = request.productcodedate;
                }
                if (request.objContact != null){
                    caseObj.ContactId = request.objContact.Id;
                }
                
                 caseObj.Origin = 'Chat';
                
                //if UPC is not null query product and set value of product lookup on the case object
                if (request.upc != null){
                    Product2[] prod = [Select id from Product2 where UPC_Code__c = :request.upc];
                    if(prod.size() > 0){
                        caseObj.ProductId= prod[0].Id;
                    }    
                }
                
                
                //create case record
                insert caseObj;
                
                //return newly created case to bot
                Case newCreatedCase = [Select Id, CaseNumber from Case where id=:caseObj.Id];
                cases.add(newCreatedCase);
                
                /* Update Chat Transcript to reference newly created Case */
                if(request.chatTranscriptId != ''){
                    LiveChatTranscript [] lct = [Select Id,CaseId  FROM LiveChatTranscript  WHERE Id = :request.chatTranscriptId]; 
                    for(LiveChatTranscript c: lct) {
                       c.CaseId = caseObj.Id; 
                    }
                    update lct;
                }
                
                
            }           
            
            
        }
        return Cases;
    }
    
    global class ChatbotCaseRequest
    {
        //case variables
        @InvocableVariable
        global string caseSubject;
        @InvocableVariable
        global string description;
        @invocablevariable
        global string productcodedate;
        @InvocableVariable
        global boolean illness;
        @InvocableVariable
        global boolean injury;
        @InvocableVariable
        global string upc;
        
        @InvocableVariable
        global string chatTranscriptId;
        
        //other variables
        @InvocableVariable
        global LiveChatTranscript objChat;
        @InvocableVariable
        global MessagingSession objMessage;
        @InvocableVariable
        global Contact objContact;
        
    }
}