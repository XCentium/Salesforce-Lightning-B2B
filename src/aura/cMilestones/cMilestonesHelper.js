({
    loadAllMilestones : function(component) 
    {
		var action = component.get("c.getAllMilestones");
        
    	action.setParams({
            "caseId": component.get("v.recordId")
   		});

   		action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var returnVal = a.getReturnValue();
                for(var i in returnVal){
                    var timeRemaing = parseInt(returnVal[i].TimeRemainingInMins);
                	if(timeRemaing>1440){
                        returnVal[i].TimeRemainingInMins = Math.floor(timeRemaing /1440)+ ' Days';                        
                    }
                    else{
                         returnVal[i].TimeRemainingInMins =Math.floor(timeRemaing/60) + 'h ' + Math.floor(timeRemaing % 60) + 'm';       
                    }
                	var timeSince = parseInt(returnVal[i].TimeSinceTargetInMins);
                    if(timeSince>1440){                        
                        returnVal[i].TimeSinceTargetInMins = Math.floor(timeSince/1440) + ' Days' ;                         
                    }
                    else{
                        returnVal[i].TimeSinceTargetInMins =Math.floor(timeSince/60) + 'h ' + Math.floor(timeSince % 60) + 'm';                    
                    }
                }
                component.set("v.caseMilestones", a.getReturnValue());
               
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
    	});

    	$A.enqueueAction(action);
	},
    loadCurrentMilestones : function(component) 
    {
		var action = component.get("c.getCurrentMilestones");
        
    	action.setParams({
            "caseId": component.get("v.recordId")
   		});

   		action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var returnVal = a.getReturnValue();
                for(var i in returnVal){
                    var timeRemaing = parseInt(returnVal[i].TimeRemainingInMins);
                	if(timeRemaing>1440){
                        returnVal[i].TimeRemainingInMins = Math.floor(timeRemaing /1440)+ ' Days';                        
                    }
                    else{
                         returnVal[i].TimeRemainingInMins =Math.floor(timeRemaing/60) + 'h ' + Math.floor(timeRemaing % 60) + 'm';       
                    }
                	var timeSince = parseInt(returnVal[i].TimeSinceTargetInMins);
                    if(timeSince>1440){                        
                        returnVal[i].TimeSinceTargetInMins = Math.floor(timeSince/1440) + ' Days' ;                         
                    }
                    else{
                        returnVal[i].TimeSinceTargetInMins =Math.floor(timeSince/60) + 'h ' + Math.floor(timeSince % 60) + 'm';                    
                    }
                }
                component.set("v.caseMilestones", a.getReturnValue());
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
    	});

    	$A.enqueueAction(action);
	},
})