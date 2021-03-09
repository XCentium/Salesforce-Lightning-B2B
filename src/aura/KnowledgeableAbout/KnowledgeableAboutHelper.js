({
    getNetworkName : function(component) {
    	var location = window.location.href;
        var communityName = location.split('/');
		console.log(communityName);
        component.set('v.networkName', communityName[3]);
    },
	getNetworkId : function(component) {
		var action = component.get('c.getNetworkId');
        action.setCallback(this,function(a){
            console.log('getNetworkId: ', a.getReturnValue());
            if (a.getState() === "SUCCESS") {
            	component.set('v.thisNetworkId',a.getReturnValue());
       			console.log('networkId Set!' + a.getReturnValue());
                this.getTopicSuggestions(component);
            }
            else if (a.getState() === "ERROR") {
                console.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
	},
    getTopicSuggestions : function(component) {
		var action = component.get('c.getTopicSuggestions');
        
        action.setParams({
            networkId: component.get('v.thisNetworkId'),
            feedItemId: component.get('v.thisFeedItem')
        });
        
        action.setCallback(this,function(a){
            console.log('getTopicSuggestions: ', a);
            if (a.getState() === "SUCCESS") {
				component.set('v.suggestedTopicIds',a.getReturnValue());
       			console.log('topicSuggestionIds Set!' + component.get('v.suggestedTopicIds'));
                this.getTopics(component);
            }
            else if (a.getState() === "ERROR") {
                console.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    getTopics : function(component) {
		var action = component.get('c.getTopics');
        
        action.setParams({
            feedItemId: component.get('v.thisFeedItem')
        });
        
        action.setCallback(this,function(a){
            console.log('getTopics: ', a);
            if (a.getState() === "SUCCESS") {
            	component.set('v.thisTopicIds',a.getReturnValue());
       			console.log('topicIds Set!' + component.get('v.thisTopicIds'));
                this.getKnowledgeableUsers(component);
            }
            else if (a.getState() === "ERROR") {
                console.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    getKnowledgeableUsers : function(component) {
		var action = component.get('c.getKnowledgeableUsers');
        
        var suggestedIds = component.get('v.suggestedTopicIds')
        var topicIds = component.get('v.thisTopicIds');
        var topicString = topicIds.toString() + ',' + suggestedIds.toString();
        
        action.setParams({
            networkId: component.get('v.thisNetworkId'),
            topicIds: topicString
        });
        
        console.log('action', action);
        
        action.setCallback(this,function(a){
            console.log('getKnowledgeableUsers: ', a);
            if (a.getState() === "SUCCESS") {
                var knowledgeableUsers = a.getReturnValue();
                var usersPerPage = component.get('v.usersPerPage');
            	component.set('v.knowledgeableUsers', knowledgeableUsers);
                component.set('v.pages', knowledgeableUsers.length / usersPerPage);
                this.getShownUsers(component);
            }
            else if (a.getState() === "ERROR") {
                console.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    getShownUsers : function(component) {
		var action = component.get('c.getShownUsers');
        var smartUserIds = component.get('v.knowledgeableUsers');
        var smartUserString = smartUserIds.toString();

        action.setParams({
            smartUserIds: smartUserString,
            page: component.get('v.currentPage'),
            shownPerPage: component.get('v.usersPerPage')
        });
        
        console.log('action', action);
        
        action.setCallback(this,function(a){
            console.log('getShownUsers: ', a);
            if (a.getState() === "SUCCESS") {
                this.hideLoading(component);
            	component.set('v.shownUsers', a.getReturnValue());
            }
            else if (a.getState() === "ERROR") {
                console.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    showLoading: function(component){
        var target = component.find('loadingCon');
        $A.util.addClass(target,'shown');
        component.set('v.finishedLoading', false);
    },
    hideLoading: function(component) {
        var target = component.find('loadingCon');
        $A.util.removeClass(target,'shown');
        component.set('v.finishedLoading', true);
	}
})