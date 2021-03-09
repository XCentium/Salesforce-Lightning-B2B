({
    onResize : function(component, helper) {
        var flowStages  = component.find('flow-stages');
        if (flowStages) {
            if (flowStages.getElement().offsetWidth > 768) {
                component.set('v.type', 'path');
            } else {
                component.set('v.type', 'base');             
            }
        }
    }
})