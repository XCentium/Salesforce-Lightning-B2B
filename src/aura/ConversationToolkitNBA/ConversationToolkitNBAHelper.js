({
    subscribeToVoiceToolkit: function(cmp) { 
        cmp._conversationEventListener = $A.getCallback(this.voiceConversationEventListener.bind(this, cmp));
        cmp.find('voiceToolkitApi').addConversationEventListener('TRANSCRIPT', cmp._conversationEventListener);
    },
    
    unsubscribeFromVoiceToolkit: function(cmp) {
        cmp.find('voiceToolkitApi').removeConversationEventListener('TRANSCRIPT', cmp._conversationEventListener);
    },
    
    
    
    invokeNBA: function(cmp, transcriptText) {
        var transcriptVariable = {ConversationKey: transcriptText};
        cmp.find('voiceToolkitApi').updateNextBestActions(cmp.get('v.recordId'), transcriptVariable);
    },
    
    // Voice Transcripts (Customer and Agent)
    voiceConversationEventListener: function(cmp, transcript) {
        var transcriptText = transcript.detail.content.text;
        var speaker = transcript.detail.sender.role;            
        var recordId = cmp.get("v.recordId");
        //Confirm that the component is on a Voice Call Record page
        if (recordId.startsWith("0LQ")){
            this.checkHelperList(cmp, transcriptText, speaker);
        }
    },
    // Chat/Messaging Transcripts (Customer and Agent)
    chatConversationEventListener: function(cmp, evt, speaker) {
        var transcriptText = evt.getParam('content');
        var recordId = cmp.get("v.recordId");
        var chatRecordId = evt.getParam("recordId");       
        //Confirm that the Event came from the Chat that the component is on
        if (recordId.includes(chatRecordId)){
            this.checkHelperList(cmp, transcriptText, speaker);        
        }
    },
    
    loadHelperData: function(cmp, helper) {
        var action = cmp.get("c.getConversationHelperList");
        action.setCallback(this, function(res){
            let state = res.getState();
            let retVal = res.getReturnValue();
            
            if(state === 'SUCCESS'){
                if(retVal){
                    cmp.set('v.helperList', retVal);
                }
            }            
        })
        
        $A.enqueueAction(action);
    },
    
    checkHelperList: function(cmp, transcriptText, speaker){
        var helperList = cmp.get("v.helperList");
        for (var i=0; i < helperList.length; i++){
            var helperItem = helperList[i];            
            var transcriptLower = transcriptText.toLowerCase();
            var helperItemLower = helperItem.Value__c.toLowerCase();
            if (transcriptLower.includes(helperItemLower)){
                if ((speaker == 'EndUser' && helperItem.Customer__c == true) || (speaker == 'Agent' && helperItem.Agent__c == true)){
                    this.invokeNBA(cmp, helperItem.Recommended_Action__c);
                    break;
                }               
            }
        }
    }
})