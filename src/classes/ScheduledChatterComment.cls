/********************************************
 * takes a feed comment and schedule it
 *
 *******************************************/
global class ScheduledChatterComment implements Schedulable
{
    public FeedComment fc;
    public Boolean at_mention_present = false;
    public ScheduledChatterComment(FeedComment fComment)
    {
        //system.debug(fComment);
        system.debug(fComment.CommentBody);
        if(fComment.CommentBody!=null){
            at_mention_present = fComment.CommentBody.contains('@[');
            
        }
       
        fc = fComment;
    }
    
    global void execute(SchedulableContext SC) 
    {
        insert fc;
        //System.abortJob(SC.getTriggerID());
        
        if(at_mention_present){
            system.debug('---@mention present--');
            Integer start_pos = fc.CommentBody.lastIndexOf('@[');
            Integer end_pos = fc.CommentBody.lastIndexOf(']');
            String at_mention_id = fc.CommentBody.substring(start_pos+2, end_pos).split(':')[1];
            
            system.debug(at_mention_id);
            
            // Create @mentioned comment using connectapi
            String at_mentioned_substring = fc.CommentBody.substring(start_pos, end_pos);
            //String message = fc.CommentBody.replace(at_mentioned_substring, '');
            List<String> message = fc.CommentBody.split(']');
            
            String text_before_mention = message[0].replace(at_mentioned_substring, '');
            // Check if text is present after @mention
            String text_after_mention = '';
            if(message.size() > 1){
                System.debug('----Text present after @mention-----');
                text_after_mention = message[1];
                System.debug(text_after_mention);
            }
            
            
            system.debug(message);
            System.debug(text_before_mention);
            
            try{
            
            
                // after creating the shell of the feed comment, retrieve the record back in Chatter for Apex
                ConnectApi.Comment comment = ConnectApi.ChatterFeeds.getComment( Network.getNetworkId(), fc.id );
                
                List<ConnectApi.MessageSegmentInput> messageSegmentInputs = new List<ConnectApi.MessageSegmentInput>();
                
                
                if (text_before_mention != null && text_before_mention.length() > 0) {
                    System.debug('----Text present before @mention-----');
                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                    textSegmentInput.text = text_before_mention;
                    messageSegmentInputs.add(textSegmentInput);
                }
                
                if(at_mention_id != null && at_mention_id!=''){
                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInput.id = at_mention_id;
                    messageSegmentInputs.add(mentionSegmentInput);
                }
                else{
                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                    messageSegmentInputs.add(mentionSegmentInput);
                }
                // Add the text after @mention (if present)
                if (text_after_mention != null && text_after_mention!='' && text_after_mention.length() > 0) {
                    System.debug('----Text present after @mention-----');
                    System.debug(text_after_mention);
                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                    textSegmentInput.text = text_after_mention;
                    messageSegmentInputs.add(textSegmentInput);
                }
                system.debug(messageSegmentInputs);
                
                // parse the message and create new message input
                ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                messageInput.messageSegments = messageSegmentInputs;
        
                // define an updated feed element using the rich-text message
                ConnectApi.CommentInput input = new ConnectApi.CommentInput();
        
                input.body = messageInput;
        
                // replace the content of the chatter post
                comment = ConnectApi.ChatterFeeds.updateComment( Network.getNetworkId(), comment.id, input );
        
                System.debug( comment );
            }catch(Exception e){
                system.debug(e.getMessage());
            }
                
        }
        
    }
}