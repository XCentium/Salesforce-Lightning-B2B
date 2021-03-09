global class Tracker_ChatterPost 
{
    @InvocableMethod(label='Tracker - Chatter Post to Appointment')
    global static List<string> createSA(List<chatterSAActionRequest> requests)
    {
        List<string> results = new List<string>();
        
        try
        {
            for (chatterSAActionRequest request : requests)
            {
                if (request.objContact != null && request.objContact.Id != null && request.objSA != null)
                {
                    //Get the User
                    List<ServiceResource> objSRs = new List<ServiceResource>([SELECT ID, RelatedRecordId  FROM ServiceResource WHERE Tracker_Contact__c =: request.objContact.Id AND RelatedRecordId != null LIMIT 1]);
                    if (objSRs.size() > 0)
                    {
                        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                        
                        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                        
                        mentionSegmentInput.id = objSRs[0].RelatedRecordId;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);
                        
                        textSegmentInput.text = ' added a note:\r\n' + request.strNote;
                        messageBodyInput.messageSegments.add(textSegmentInput);
                        
                        feedItemInput.body = messageBodyInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId = request.objSA.ParentRecordId;
                        
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                        
                    }
                    else
                    {
                        results.add('Invalid Service Resource');
                    }
                }
                else
                {
                    results.add('Invalid Contact and/or Appointment');
                }
            }
        }
        catch (Exception ex)
        {
            results.add(ex.getMessage());
        }
        
        return results;
    }
    
    global class chatterSAActionRequest
    {
        @InvocableVariable(required=false)
        global ServiceAppointment objSA;
        @InvocableVariable(required=false)
        global String strNote;
        @InvocableVariable(required=false)
        global Contact objContact;
    }
}