({
    doInit : function(component, event) {
        var getIdeaAction = component.get("c.getIdea");
        getIdeaAction.setParams({
        	IdeaId : component.get("v.ideaId")
    	});
        getIdeaAction.setCallback(this, function(a) {
            component.set("v.thisIdea", a.getReturnValue());
        });
        $A.enqueueAction(getIdeaAction);
		
        /* Get Idea comments */
        var getCommentsAction = component.get("c.getComment");
        getCommentsAction.setParams({
        	IdeaId : component.get("v.ideaId")
    	});
        getCommentsAction.setCallback(this, function(a) {
            component.set("v.comments", a.getReturnValue());
        });
        $A.enqueueAction(getCommentsAction);
		
		console.log('Initiating guest user check');
		var isGuestUserMethod = component.get("c.isGuestUser");
        isGuestUserMethod.setCallback(this, function(a) {
            console.log(a.getReturnValue());
            component.set("v.isGuestUser", a.getReturnValue());
        });
        $A.enqueueAction(isGuestUserMethod);
    },
    saveComment : function(component, event){
        var yourComment = component.find("IdeaComment").get("v.value");
		console.log(yourComment);
        
        var getIdeaAction = component.get("c.postComment");
        getIdeaAction.setParams({
        	IdeaId : component.get("v.ideaId"),
            CommentBody : yourComment
    	});
       
        getIdeaAction.setCallback(this, function(a) {
            component.set("v.comments", a.getReturnValue());
            component.find("IdeaComment").set("v.value", "");
            var IdeaList = component.get("v.thisIdea");
            IdeaList.NumComments = a.getReturnValue().length;
            component.set("v.thisIdea", IdeaList);
        });
        $A.enqueueAction(getIdeaAction);
    },
    unlikeComment : function(component, event){
        var VoteId = event.target.getAttribute('data-idValue');

        var action = component.get("c.unlikeThisComment");
        action.setParams({IdeaId : component.get("v.ideaId"),"VoteId" : VoteId});
        action.setCallback(this, function(a) {
            component.set("v.comments", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    likeComment : function(component, event){
        var commentId = event.target.getAttribute('data-idValue');

        var action = component.get("c.likeThisComment");
        action.setParams({IdeaId : component.get("v.ideaId"),"commentId" : commentId});
        action.setCallback(this, function(a) {
            component.set("v.comments", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    deleteComment : function(component, event){
        var commentId = event.target.getAttribute('data-idValue');

        var action = component.get("c.deleteThisComment");
        action.setParams({IdeaId : component.get("v.ideaId"),"commentId" : commentId});
        action.setCallback(this, function(a) {
            component.set("v.comments", a.getReturnValue());
            var IdeaList = component.get("v.thisIdea");
            IdeaList.NumComments = a.getReturnValue().length;
            component.set("v.thisIdea", IdeaList);
        });
        $A.enqueueAction(action);
    },
    promoteAnIdea : function(component, event){
        var IdeaId = event.target.getAttribute('data-idValue');
        console.log('Idea Id: '+IdeaId);
        
        var action = component.get("c.promoteFromIdeaDetails");
        action.setParams({"IdeaId" : IdeaId});
        action.setCallback(this, function(a) {
            component.set("v.thisIdea", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    demoteAnIdea : function(component, event){
        var IdeaId = event.target.getAttribute('data-idValue');
        console.log('Idea Id: '+IdeaId);
        
        var action = component.get("c.demoteFromIdeaDetails");
        action.setParams({"IdeaId" : IdeaId});
        action.setCallback(this, function(a) {
            component.set("v.thisIdea", a.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})