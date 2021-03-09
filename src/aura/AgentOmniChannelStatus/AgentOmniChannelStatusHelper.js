({
	
    fetchUserInfo : function(component) {
        
        /* Fetch User Info */
        var action = component.get("c.getUser");       
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        /*console.log(userId);*/
        
        action.setParams( {recordId : userId} ); 
                
        action.setCallback(this, function(response){
            	var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    
                  component.set("v.user", response.getReturnValue());
                  /*console.log(response.getReturnValue());*/
                }
                else {
                  console.log("Failed with state" + state);
                }
          })
          $A.enqueueAction(action);
    },
    
    fetchUserStatus : function(component) {
        
        /* Fetch User Status */
        var action = component.get("c.getUserStatus");       
        var userId = $A.get("$SObjectType.CurrentUser.Id");
                
        action.setParams( {recordId : userId} ); 
                
        action.setCallback(this, function(response){
            	var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    
                  component.set("v.userStatus", response.getReturnValue());
                    
                    /*Set status busy - offline - available */
                    if(response.getReturnValue().IsCurrentState === false){
                        component.set("v.statusIndicator", "Offline")
                    } else if( response.getReturnValue().IsCurrentState === true && response.getReturnValue().IsAway === true ) {
                        component.set("v.statusIndicator", "Busy")
                    } else {
                        component.set("v.statusIndicator", "Available")                        
                    }
                    
                    
                  /*console.log(response.getReturnValue());*/
                  
                }
                else {
                  console.log("Failed with state" + state);
                }
          })
          $A.enqueueAction(action);
    },
    
    
    getWorkload : function(component) {
                
        /* Get Current Workload */
        
        var omniAPI = component.find("omniToolkit");        
        omniAPI.getAgentWorkload().then(function(result) {
            console.log('Retrieved Agent Configured Capacity and Current Workload successfully');
            console.log('Agent\'s configured capacity is: ' + result.configuredCapacity);
            console.log('Agent\'s currently assigned workload is: ' + result.currentWorkload);
            var currentWorkload = result.currentWorkload;
            var configuredCapacity = result.configuredCapacity;
            var capacity = (configuredCapacity != 0 ? Math.round((currentWorkload / configuredCapacity) * 100) : 0 );
            component.set("v.capacityPercent" , capacity);
            component.set("v.currentWorkload", currentWorkload);
            console.log(capacity);
        }).catch(function(error) {
            console.log('Get Agent Workload failed');
            component.set("v.capacityPercent", 0 );
            component.set("v.currentWorkload", 0 );
        });
		
	},
    
    fetchCases : function(component) {
        
        /* Fetch Cases */
        var action = component.get("c.getCases");       
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        
        action.setParams( {recordId : userId} ); 
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                
                component.set("v.cases", response.getReturnValue());
                /*console.log(response.getReturnValue());*/
                
                
            }
            else {
                console.log("Failed with state" + state);
            }
        })
        $A.enqueueAction(action);
    },
    
    
    
    
})