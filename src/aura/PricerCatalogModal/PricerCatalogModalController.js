({
	closeModal : function(component, event, helper) {
		//component.destroy();
		component.hide();
	},
    hide : function(component, event, helper) {
    	helper.hideModal (component,event);
	},
    show : function(component, event, helper) {
        helper.showModal (component,event);
        var args=event.getParam('arguments');
        component.set('v.sendBackData',args.sendBackData);
        component.set('v.pricebookId',args.pricebookId);
	}
})