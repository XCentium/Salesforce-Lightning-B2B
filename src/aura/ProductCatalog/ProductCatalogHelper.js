({
	createFamilyMap : function(component, products) {
		//console.log("HELPER CREATE MAP");
    	// We need to convert this list of all products into a Map of Products by Family Name
    	// Start by creating map functionality and variable

    	var productsByFamilyMap = new Object();
    	function getFamily(k){
    		return productsByFamilyMap[k];
    	};

    	// Set the first tab to be "Home" and simply show all the products
    	productsByFamilyMap["Home"] = products;
    	// Now we need to split the rest of the products into new arrays by Family, dynamically
    	var productList = [];
    	for (var i = 0; i < products.length; i++) {
    		// Need to hard-set sobjectType on each item
    		products[i].sobjectType = "Product2";
    		// Check if list exists at Map key of Family
    		productList = getFamily(products[i].Family);
    		if($A.util.isEmpty(productList)) {
    			// It's empty, create a list with this product
    			productList = [products[i]];
    		} else {
    			// It's not empty, push the product onto the array
    			productList.push(products[i]);
    		}
    		// Add place our local list into the Map
    		productsByFamilyMap[products[i].Family] = productList;
    	}
    	// Now we need to convert our Map into an Array because Lightning is really stupid in 202
		var array = [];
		for(var k in productsByFamilyMap){
			array.push({key:k, value:productsByFamilyMap[k]});
		}

    	component.set("v.families",array);
    	//console.log(array);
	},
    styleHeader: function(component) {
        var title = component.get("v.title");
        var subtitle = component.get("v.subtitle");
        var logoTitlePosition = component.get("v.logoTitlePosition");

        switch(logoTitlePosition){
            case "Right Aligned":
                component.set("v.logoTitlePosition","slds-text-align--right");
                break;
            case "Center":
                component.set("v.logoTitlePosition","slds-text-align--center");
                break;
            default:
                component.set("v.logoTitlePosition","slds-text-align--left");
        }
    }
})