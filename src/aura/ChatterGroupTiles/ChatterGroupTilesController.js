({
    doInit : function(component) {
        //bgcolor set rgba with opacity 0.9 based on hex color
        var hex = component.get("v.bgcolor").replace('#', '');
    	var r = parseInt(hex.substring(0, 2), 16);
   		var g = parseInt(hex.substring(2, 4), 16);
    	var b = parseInt(hex.substring(4, 6), 16);
		component.set("v.bgcolor", 'rgba('+r+', '+g+', '+b+', 0.9)');

        var action = component.get("c.getGroups");
        action.setParams({ filter: component.get("v.filter"), publiconly : component.get("v.publicOnly")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log("getTiles return",response.getReturnValue());
                component.set("v.discussionGroups", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    gotoGroup :function(component, event){
        var el = event.currentTarget;
        var id = el.dataset.recordid; //id here is from 'data-*' in the element
        //alert(id);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": id
        });
        navEvt.fire();
    }
})