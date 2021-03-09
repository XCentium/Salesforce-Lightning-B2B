({
    
    subscribeToEvent : function (component) {
        console.log("test component");
        var empApi = component.find("empApi");
        
        // Error handler function that prints the error to the console.
        var errorHandler = function (message) {
            console.log("Received error ",  JSON.stringify(message));
        }.bind(this);
        
        // Register error listener and pass in the error handler function.
        empApi.onError(errorHandler);
        
        // var channel='/event/C360ActivityEvent__e';
        var channel ='/topic/c360ActivityUpdates';
        var sub;
        
        // new events
        var replayId=-1;
        
        var callback = function (message) {
            console.log("in callback");

            var type = message.data.event.type;
            //  var updateType = message.event.type;
            component.set("v.activity", message.data.sobject);
            var activity =  component.get("v.activity");
            var activities = component.get("v.activities");
            //console.log(activity.Id);
            switch (type) {
                case 'created':
                    activities.push(activity);
                    activities.sort(function(a,b) {return (a.days_ago__c  > b.days_ago__c ) ? 1 : ((b.days_ago__c  > a.days_ago__c ) ? -1 : 0);} );
                    component.set("v.activities", activities);

                    break;
                case 'updated':
                    var index = activities.findIndex(x => x.id == activity.id);
                    activities[index] = activity;
                    activities.sort(function(a,b) {return (a.days_ago__c  > b.days_ago__c ) ? 1 : ((b.days_ago__c  > a.days_ago__c ) ? -1 : 0);} );
                    
                    
                    component.set("v.activities", activities);
                    console.log("set activities");
                    break;
                case 'deleted':
                    activities = activities.filter(function( obj ) {
                        return obj.Id !== activity.Id;
                    });
                    component.set("v.activities", activities);
                    console.log("set activities");
                    break;
                default:
                    console.log('Sorry, we are out of ' + expr + '.');
            }

                   
        }.bind(this);
        
        empApi.subscribe(channel, replayId, callback).then(function(value) {
            console.log("Subscribed to channel " + channel);
            sub = value;
            component.set("v.sub", sub);
        });
    },
    
    getActivitiesForAccount : function (component) {
        var action = component.get('c.getActivitiesForAccount');
        var id = component.get('v.recordId');
        
        action.setParams( {recordId : id} ); 
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                
                component.set("v.activities", response.getReturnValue());
                console.log(response.getReturnValue());
                
                
            }
            else {
                console.log("Failed with state" + state);
            }
        })
        $A.enqueueAction(action);
    },
    
    getActivitiesForContact : function (component) {
        var action = component.get('c.getActivitiesForContact');
        var id = component.get('v.recordId');
        console.log(id);
        
        action.setParams( {recordId : id} ); 
                
        action.setCallback(this, function(response){
            	var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    
                  component.set("v.activities", response.getReturnValue());
                  console.log(response.getReturnValue());
                  
                  
                }
                else {
                  console.log("Failed with state" + state);
                }
          })
          $A.enqueueAction(action);
    },
    getContactForAccount: function ( component ) {
        var action = component.get('c.getContactForAccount');
        var id = component.get ('v.recordId');
        
        action.setParams( {recordId : id} ); 
                
        action.setCallback(this, function(response){
            	var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    
                  component.set("v.contactId", response.getReturnValue());
                  console.log(response.getReturnValue());
                  
                  
                }
                else {
                  console.log("Failed with state" + state);
                }
          })
          $A.enqueueAction(action);
        
    }
})