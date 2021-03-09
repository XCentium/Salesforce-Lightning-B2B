({
    handleClick : function(component, event, helper) {
      var searchText = component.get('v.searchText');
      var action = component.get('c.searchForIds');
      action.setParams({searchText: searchText});
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === 'SUCCESS') {
          var ids = response.getReturnValue();
          sessionStorage.setItem('customSearch--recordIds', JSON.stringify(ids));
            var navEvt = $A.get('e.force:navigateToURL');
            navEvt.setParams({url: '/custom-search-results'});
            navEvt.fire();
        }
      });
      $A.enqueueAction(action);
    },
    resetSelectedContact : function(component, event, helper) {
        component.set("v.SelectedContact", '');
    },
    EditContact : function(component, event, helper) {
        var cmpTarget = component.find('EditContactModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog: function(component, event, helper) {
        var cmpTarget = component.find('EditContactModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget = component.find('ViewAppointmentModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
    },
    
})