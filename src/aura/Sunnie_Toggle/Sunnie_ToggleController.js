({
      doInit: function(component, event, helper) {
        // Fetch the account list from the Apex controller
        helper.getContactInfo(component,event, helper);
      },
    
      selectChange:function(component, event, helper) {
        helper.updateContact(component,event);
      },
})