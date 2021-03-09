({
	init : function(component, event, helper) {
		component.set('v.EngagementDateTime', new Date().toISOString())
	},
    cancel: function(component,event,helper){
            $A.get("e.force:closeQuickAction").fire();  
    },
    save : function(component, event, helper){
        let close = $A.get('e.force:closeQuickAction');
        let refresh = $A.get('e.force:refreshView');
        
        helper.createEngagementHelper(component)
        .then(function(){
            close.fire();
            refresh.fire();            
        })
    }
})