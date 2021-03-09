({
 	loadNewsChannelNames : function(cmp) {
        // get NewsChannelNames
        var action = cmp.get("c.getNewsChannelNames");
        //display spinner
        cmp.set("v.displayLoader",true); 
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.newsChannelNames", response.getReturnValue());
                if(response.getReturnValue() != null){  
                    var newsURL = window.location.href;
			      	if (newsURL.indexOf('channel/') != -1) {
            			var channel = decodeURI(newsURL.substr(newsURL.indexOf('channel/') + 8));
                        cmp.set("v.selectedNewsChannel",channel);
                    }else{
                    	// set first newsChannelName
                    	cmp.set("v.selectedNewsChannel", cmp.get("v.newsChannelNames")[0]);
                        cmp.set("v.encodedSelectedNewsChannel", encodeURIComponent(cmp.get("v.newsChannelNames")[0]));
                    }    
                }
            }
        });    
        $A.enqueueAction(action);
    },
    loadnumDocsByChannel : function(cmp) {
		var action = cmp.get("c.getnumDocsByChannel");
        action.setCallback(this, function(response) {
        	var state = response.getState();
        	if (cmp.isValid() && state === "SUCCESS") {
        		cmp.set("v.numDocsByChannel", response.getReturnValue());
        	}
    	});    
        $A.enqueueAction(action);
    },
    loadFirstNewsChannelRecords : function(cmp) {
    // Load firstNewsChannel records
    	var action = cmp.get("c.getFirstNewsChannelRecords");
        //pass number of news articles to display to apex method
        action.setParams({
            "numDocs" : cmp.get("v.numbberOfArticles")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.newsDocs", response.getReturnValue());
                var isEmpty = $A.util.isEmpty(cmp.get("v.newsDocs"));
                var error = cmp.find("errorMsg");
                if(isEmpty){ 
                    $A.util.removeClass(error, 'hide');
                    $A.util.addClass(error, 'show');
                    cmp.set("v.displayLoader",false);
                }else{
    				$A.util.removeClass(error, 'show');
                    $A.util.addClass(error, 'hide');
				}
                //display More... link
                var cmpTarget = cmp.find("more"); 
                var selectedChannel = cmp.get("v.selectedNewsChannel");
                if(cmp.get("v.numDocsByChannel")[selectedChannel] > cmp.get("v.numbberOfArticles")){
                    $A.util.removeClass(cmpTarget, 'hide');
                    $A.util.addClass(cmpTarget, 'show');
                }else{
                    $A.util.removeClass(cmpTarget, 'show');
                    $A.util.addClass(cmpTarget, 'hide');
                }
             	//hide spinner
                cmp.set("v.displayLoader",false); 
            }
        });    
        $A.enqueueAction(action);
    },
    loadNewsChannelRecordsByChannel: function(cmp) {
        var newsURL = window.location.href;
        if (newsURL.indexOf('channel/') != -1) {
            var selectedChannel = decodeURI(newsURL.substr(newsURL.indexOf('channel/') + 8));
            this.navigateToChannel(cmp);
        }
        // get NewsChannel Records by Channel
        var action = cmp.get("c.getNewsChannelRecordsByChannel");
        //pass slected News Channel and number of news articles to display to apex method
        action.setParams({
            "newsChannel": cmp.get("v.selectedNewsChannel"),
            "numDocs" : cmp.get("v.numbberOfArticles")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.newsDocs", response.getReturnValue());
                //if no records are found then display error message
                var isEmpty = $A.util.isEmpty(cmp.get("v.newsDocs"));
                var error = cmp.find("errorMsg");
                if(isEmpty){ 
                    $A.util.removeClass(error, 'hide');
                    $A.util.addClass(error, 'show');
                    cmp.set("v.displayLoader",false);
                }else{
    				$A.util.removeClass(error, 'show');
                    $A.util.addClass(error, 'hide');
				}
                //display More... link
                var cmpTarget = cmp.find("more"); 
                var selectedChannel = cmp.get("v.selectedNewsChannel");
                if(cmp.get("v.numDocsByChannel")[selectedChannel] > cmp.get("v.numbberOfArticles")){
                    $A.util.removeClass(cmpTarget, 'hide');
                    $A.util.addClass(cmpTarget, 'show');
                }else{
                    $A.util.removeClass(cmpTarget, 'show');
                    $A.util.addClass(cmpTarget, 'hide');
                }
                //hide spinner
                cmp.set("v.displayLoader",false); 
            }
        });    
        $A.enqueueAction(action);
    },
    navigateToChannel: function(cmp) {
        var address = "/recentnews#channel/"+encodeURIComponent(cmp.get("v.selectedNewsChannel"));
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": address 
        });
        urlEvent.fire();
    },
})