({
    doInit: function(cmp, event, helper) {
        helper.subscribeToVoiceToolkit(cmp);
        helper.loadHelperData(cmp, helper);
    },
    
    onDestroy: function(cmp, event, helper) {
        helper.unsubscribeFromVoiceToolkit(cmp);
    },
    
    onInvokeNBA: function(cmp, event, helper) {
        helper.updateNextBestActions(cmp);
    },
    
    // Chat Transcript Customer
    onChatTranscriptCustomer: function(cmp, evt, helper){
        helper.chatConversationEventListener(cmp, evt, 'EndUser');        
    },
    
    // Chat Transcript Agent
    onChatTranscriptAgent: function(cmp, evt, helper){
        helper.chatConversationEventListener(cmp, evt,'Agent');
    }
})