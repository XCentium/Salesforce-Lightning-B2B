({
	getsearchResults: function(component) {
		var action = component.get("c.searchPeople");
			var self = this;
			var searchkey = component.get("v.SearchString");
            console.log(searchkey);
        	action.setParams({
	        	"searchString": searchkey
	    	});
			action.setCallback(this, function(response) {
			var state = response.getState();
			console.log('STATE'+state);
			if(response.getReturnValue().length != 0){
					component.set("v.peopleReturned", true);
			}
			if (component.isValid() && state === "SUCCESS") {
				component.set("v.lstusers", response.getReturnValue());
				console.log(response.getReturnValue());
			}else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    $A.logf("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        $A.error("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    $A.error("Unknown error");
                }
            }
		});
		$A.enqueueAction(action);
	},

	getTopicResults : function(component) {
		var action = component.get("c.searchTopics");
			var self = this;
			var topicslst = [];
			var searchkey = component.get("v.SearchString");
            console.log(searchkey);
        	action.setParams({
	        	"searchString": searchkey
	    	});
			action.setCallback(this, function(response) {
			var state = response.getState();
			console.log('STATE'+state);
			if(response.getReturnValue().length != 0){
				component.set("v.topicsReturned", true);
			}
			if (component.isValid() && state === "SUCCESS") {
				for (i = 0; i < response.getReturnValue().length; i++) {
					var topic = {};
        			topic = { 'sobjectType': 'Topic','Name': '' ,'Id' :'','Label' :''};
        			topic.Name = encodeURIComponent(response.getReturnValue()[i].Name);
        			topic.Label = response.getReturnValue()[i].Name;
        			topic.Id = response.getReturnValue()[i].Id;
        			topicslst.push(topic);
			    }
			    console.log('TOPICS..'+topicslst);
				component.set("v.lsttopics", topicslst);
			}else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    $A.logf("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        $A.error("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    $A.error("Unknown error");
                }
            }
		});
		$A.enqueueAction(action);
	},
})