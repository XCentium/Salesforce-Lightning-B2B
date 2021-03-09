global class EinsteinChatbotsPostWorkOrderMessage
{
    @InvocableMethod(label='Einstein Chatbots - Post Message to WorkOrder' description='Posts a message to the Work Order Chatter Feed')
    global static void Post2WO(List<Post2WORequest> requests) 
    {
        System.debug('Entering Posting method...');   
        List<ServiceAppointment> results = new List<ServiceAppointment>();
        For (Post2WORequest objPost2WORequest : requests)
        {
            //Post simple message to the Work Order
            //FeedItem post = new FeedITem();
            //post.body = objPost2WORequest.message;
            //post.ParentID = objPost2WORequest.objSA.ParentRecordId;
            //insert post;
            
            String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
            String url =  salesforceHost + '/services/data/v23.0/chatter/feeds/record/' + objPost2WORequest.objSA.ParentRecordId + '/feed-items';
            
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(url);
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            req.setBody('{ "body" : { "messageSegments" : [ { "type": "text",  "text" : "' + 'Message from ' + objPost2WORequest.objContact.FirstName + ' ' + objPost2WORequest.objContact.LastName + ':' + '" }, { "type": "text",  "text" : "' + '\\n\'' + objPost2WORequest.message + '\'\\n\\n' + '" }, { "type": "mention", "id" : "' + objPost2WORequest.objServiceResource.RelatedRecordId + '" }] } }');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            return;
        }
    }
    
    global class Post2WORequest
    {
        @InvocableVariable(required=true)
        global string message;
        @InvocableVariable
        global ServiceAppointment objSA;
        @InvocableVariable
        global Contact objContact;
        @InvocableVariable
        global ServiceResource objServiceResource;
    }
}