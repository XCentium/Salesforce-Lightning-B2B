({
	search: function(component, event, helper) {
		helper.getsearchResults(component);
		helper.getTopicResults(component);
	},

	topicsClick : function(component, event, helper) {
		var topic = component.find("topics");
		$A.util.addClass(topic,'active');
		var people = component.find("people");
		$A.util.removeClass(people,'active');
		var peoplesection = component.find("peoplesearch");
		$A.util.addClass(peoplesection,'toggle');
		var topicsection = component.find("topicssearch");
		$A.util.removeClass(topicsection,'toggle');
	},

	peopleClick : function(component, event, helper) {
		var topic = component.find("topics");
		$A.util.removeClass(topic,'active');
		var people = component.find("people");
		$A.util.addClass(people,'active');
		var peoplesection = component.find("peoplesearch");
		$A.util.removeClass(peoplesection,'toggle');
		var topicsection = component.find("topicssearch");
		$A.util.addClass(topicsection,'toggle');
	}
})