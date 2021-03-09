({
    doInit : function(component, event, helper) {
        let ObjectChoice = component.get('v.ObjectChoice');
        if(ObjectChoice == 'Case'){
            component.set('v.cardLabel','Einstein Recommendations');
            var recid = component.get("v.recordId");
            var action = component.get("c.getRecommendationsbyCase");
            action.setParams({
                "recordId": recid
            });
            action.setCallback(component, function(response) {
                var result = response.getReturnValue();
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.Case",response.getReturnValue());
                } 
            });
            $A.enqueueAction(action);
        }else if(ObjectChoice == 'Contact'){
            component.set('v.cardLabel','Einstein Recommendations');
            if(component.get('v.recId')!= ''){
                var recid = component.get("v.recId");
            }else{
                var recid = component.get("v.recordId");
            }
            console.log("record id is: " + recid);
            var action = component.get("c.getRecommendationsbyContact");
            action.setParams({
                "recordId": recid
            });
            action.setCallback(component, function(response) {
                var result = response.getReturnValue();
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.Contact",response.getReturnValue());
                } 
            });
            $A.enqueueAction(action);
        }
    }, 
    GoToLink1 : function(component, event, helper) {
        console.log('test');
        window.open(component.get("v.ButtonLink1"));
    },
    GoToLink2 : function(component, event, helper) {
        window.open(component.get("v.ButtonLink2"));
    }
 })