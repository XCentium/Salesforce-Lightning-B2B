({
	handleClick : function(component, event, helper) {
        var whichOne = event.getSource().getLocalId();
        console.log(component.get("v.PageShown"));
        component.set("v.PageShown", whichOne);
        var pref = window.location.pathname.split('/')[1];
		component.set("v.prefix", pref);
    },
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
    init : function(component, event, helper){
        var action = component.get("c.getAppSettings");
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.appSettings",response.getReturnValue());
                console.log('Settings: '+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    ShowHideMenu : function(component, event, helper){
        var status = component.get('v.menuStatus');
        if(status == 'Closed'){
            var cmpTarget = component.find('primarynav');
            $A.util.removeClass(cmpTarget, 'hidenav');
        	$A.util.addClass(cmpTarget, 'shownav');
            
            var wrapperTarget = component.find('outerwrapper');
            $A.util.removeClass(wrapperTarget, 'sidebarclosedbody');
        	$A.util.addClass(wrapperTarget, 'sidebaropenbody');
            component.set('v.menuStatus','Open');
            console.log('variable is: ' + status);
        }else{
            var cmpTarget = component.find('primarynav');
            $A.util.removeClass(cmpTarget, 'shownav');
        	$A.util.addClass(cmpTarget, 'hidenav');
            
            var wrapperTarget = component.find('outerwrapper');
            $A.util.removeClass(wrapperTarget, 'sidebaropenbody');
        	$A.util.addClass(wrapperTarget, 'sidebarclosedbody');
            component.set('v.menuStatus','Closed'); 
            console.log('variable is: ' + status);
        }
        
    },
    handleValueChange: function(component, evt) {
        var cmpTarget = component.find('primarynav');
        $A.util.removeClass(cmpTarget, 'shownav');
        $A.util.addClass(cmpTarget, 'hidenav');
            
        var wrapperTarget = component.find('outerwrapper');
        $A.util.removeClass(wrapperTarget, 'sidebaropenbody');
        $A.util.addClass(wrapperTarget, 'sidebarclosedbody');
        component.set('v.menuStatus','Closed'); 
    },
    gotoHome : function(component, evt) {
        component.set('v.PageShown','Home');
    }
})