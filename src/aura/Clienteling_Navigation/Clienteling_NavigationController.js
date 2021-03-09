({
	handleClick : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.PageShown", whichOne);
        var pref = window.location.pathname.split('/')[1];
		component.set("v.prefix", pref);
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
    }
})