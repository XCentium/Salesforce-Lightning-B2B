({
    onInit : function (component, event, helper) {
        helper.createloginButtons(component);
    },
    toggleCollapsible : function(component, event, helper) {
        let collapsible = component.find('collapsible');
        $A.util.toggleClass(collapsible, 'slds-is-open');
    }
})