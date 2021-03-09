({
	handleSearch : function(component, event, helper) {
      var searchText = component.get('v.searchText');
      component.set("v.PageShown","Customers");  
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
})