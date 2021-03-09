({
	navigateToFamily : function(component, event, helper) {
		// It doesn't matter what we clicked on, since our scope has the Family List
		var familyList = component.get("v.familyList");
		var familyKey = component.get("v.familyKey");

		var categorySelected = component.getEvent("categorySelected");
		if (event.getSource().get("v.class") != "tabItem") {
			// If we're in here, they clicked on a particular item
			var productId = event.getSource().get("v.class");
        	categorySelected.setParams({ "Category": familyKey, "FamilyList": familyList, "ItemSelected": productId });
		} else {
        	categorySelected.setParams({ "Category": familyKey, "FamilyList": familyList });
		}
		//console.log("Pre-fire:",categorySelected.getParams());
        categorySelected.fire();
	}
})