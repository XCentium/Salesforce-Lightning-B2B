({
    doInit: function(component, event, helper) {
    	console.log('ProductCatalogItems: doInit');
    },
	filterByCategory: function(component, event, helper) {
		var category = event.getParam("Category");
		var familyList = event.getParam("FamilyList");
		var itemSelected = event.getParam("ItemSelected");
        // TODO: filter based on category
        component.set("catalogItems",familyList);
        //console.log("filterByCategory");
	},
})