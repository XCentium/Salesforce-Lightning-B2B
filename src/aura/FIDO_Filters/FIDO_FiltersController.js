({
	ApplyFilter: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.Filter",whichOne);
    },
    back: function(component, event, helper) {
        component.set("v.recid",'');
        var ind = component.get("v.Industry");
        var page = component.get("v.ScreenChoice");
            if (recid != ''){
                if (url.indexOf("KnowtheIDO.app") >= 0) { 
                	window.open('/c/KnowtheIDO.app?Industry='+ind+'&ScreenChoice=' + page,"_self");
                	component.set("v.recid",'');
                }
            }
    },
    ClearFilters: function(component, event, helper) {
        component.set("v.Filter",'');
    	component.set("v.FilterTotal",'0');
    },
    FilterSelect: function(component, event, helper) {
        var menuValue = event.detail.menuItem.get("v.value");
        component.set("v.Filter",menuValue);
    },
    
})