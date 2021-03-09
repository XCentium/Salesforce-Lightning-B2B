({
    doInit: function(component, event, helper) {
       
       var pref = window.location.pathname.split('/')[1];
       var action = component.get("c.getTopicsWithFollowers"); // method in the apex class
       action.setParams({
            prefix : pref
        });
      action.setCallback(this, function(a) {
            component.set("v.TWF", a.getReturnValue()); // variable in the component
       })

       $A.enqueueAction(action);
    	
       var action2 = component.get("c.hasFollowers");
       action2.setParams({
           pre : pref
       });
       action2.setCallback(this, function(a2){
          component.set("v.isFollowing", a2.getReturnValue());  
       })
       $A.enqueueAction(action2);
        
    }
    
})