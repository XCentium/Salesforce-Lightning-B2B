({
	init : function(component, event, helper) 
    {
        var thespeed = component.get('v.numSpeed');
        if (thespeed <= 0)
        {
            component.set('v.numSpeed', 5);
        }
        helper.updateProgress(component);
    },
})