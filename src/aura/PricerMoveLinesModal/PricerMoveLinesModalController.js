({
    closeModal : function(component, event, helper) {
		component.destroy();
	},
    scopeSelectorChange: function(cmp, evt) { 
        var choice = evt.getSource().get("v.text");
        cmp.set("v.scope",choice);
        
    },
    confirm : function(cmp, evt) { 
        var sourceSection=cmp.get('v.sourceSection');
        var destSection=cmp.get('v.selectedValue');
        var moveLines = cmp.getEvent("moveLines");
        moveLines.setParams({
            'sourceSection' : sourceSection,
            'destSection' : destSection,
            'scope' : cmp.get('v.scope'),
            'action' : 'confirm'
        });
        if (sourceSection!=destSection)
        	moveLines.fire();
        cmp.destroy();
    }    
})