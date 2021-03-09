({
	successIcon : function(component) {
        var target = component.find('actionIcon');
        console.log('success icon triggered:' + target);
        $A.util.removeClass(target, 'fail-icon');
        $A.util.addClass(target, 'success-icon');
		
	},
    failIcon : function(component) {
        var target = component.find('actionIcon');
        console.log('fail icon triggered:' + target);
        $A.util.removeClass(target, 'success-icon');
        $A.util.addClass(target, 'fail-icon');
    }
})