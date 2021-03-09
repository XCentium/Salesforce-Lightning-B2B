({
	doInit : function(component, event, helper) {
        helper.isConsoleNavigation(component, event);
        helper.isSubtab(component, event, helper);
    },
    
    handleOpenClose : function(component, event, helper){
        console.log('handleOpenClose: START');
        
        console.log('handleOpenClose: event.getSource()',event.getSource());
        var selectedSection = event.getSource().getLocalId();
        console.log('handleOpenClose: selectedSection',selectedSection);
        
        var newState = !component.get('v.' + selectedSection);
        console.log('handleOpenClose: newState',newState);
        component.set('v.' + selectedSection, newState);
       
        console.log('handleOpenClose: END');
	},
    
    handleComponentEvent : function(component, event){
        console.log('handleComponentEvent: START');
        
        console.log('handleComponentEvent: event.getParam("HideRightSideBar") = ' + event.getParam("HideRightSideBar"));
        console.log('handleComponentEvent: event.getParam("HideLeftSideBar") = ' + event.getParam("HideLeftSideBar"));
        component.set('v.isRightOpen', !event.getParam("HideRightSideBar"));
        component.set('v.isLeftOpen', !event.getParam("HideLeftSideBar"));
       
        console.log('handleComponentEvent: END');
	}
})