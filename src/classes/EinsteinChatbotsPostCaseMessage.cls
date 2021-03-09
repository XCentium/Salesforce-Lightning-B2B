global class EinsteinChatbotsPostCaseMessage
{
    @InvocableMethod(label='Einstein Chatbots - Post Message to Case' description='Posts a message to the Case Chatter Feed')
    global static void Post2Case(List<Post2CaseRequest> requests) 
    {
        System.debug('Entering Posting method...');   
        For (Post2CaseRequest objPost2CaseRequest : requests)
        {
            String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
            String url =  salesforceHost + '/services/data/v23.0/chatter/feeds/record/' + objPost2CaseRequest.objCase.Id + '/feed-items';
            
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(url);
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            req.setBody('{ "body" : { "messageSegments" : [ { "type": "text",  "text" : "' + 'Message from ' + objPost2CaseRequest.objContact.FirstName + ' ' + objPost2CaseRequest.objContact.LastName + ':' + '" }, { "type": "text",  "text" : "' + '\\n\'' + objPost2CaseRequest.message + '\'\\n\\n' + '" }] } }');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            return;
        }
    }
    
    global class Post2CaseRequest
    {
        @InvocableVariable(required=true)
        global string message;
        @InvocableVariable
        global Case objCase;
        @InvocableVariable
        global Contact objContact;
    }
}