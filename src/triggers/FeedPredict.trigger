trigger FeedPredict on FeedItem (after insert) {
    // Used for FSL demos.  If the user has posted on the chatter feed of
    // a Work Order, and the post meets certain criteria, then invoke an
    // Einstein Vision Image Classification on the attachment.
    String woKeyPrefix = WorkOrder.sObjectType.getDescribe().getKeyPrefix();

    // Retrieve custom settings
    FSLVisSet__c setting = FSLVisSet__c.getInstance('Predict');
    String triggerPhrase = String.isBlank(setting.Chatter_Post_Trigger_Phrase__c)? 'Einstein': setting.Chatter_Post_Trigger_Phrase__c; 
        
    
    for (FeedItem f: trigger.new) {
        String parentId = f.parentId;
        String relatedId = f.RelatedRecordId;
        String body = f.Body;
        
        // call vision prediction only if this is a post on a Work Order and
        // the post has an attachment and
        // the body of the post includes the trigger phrase in the custom setting
        if ((parentId.startsWith(woKeyPrefix) && 
            f.Type == 'ContentPost') && 
            (String.isNotBlank(body) && body.containsIgnoreCase(triggerPhrase))) {

            FSLVisionController.getCallVisionContent(parentId, relatedId, f.Id);  
        }
    }
}