({
    loadAttributes: function(component) {

        console.log('ckz_PIM_ProductChooser - inside loadAttributes');

        var productDataMap = component.get("v.productDataMap");
        
        //console.log('productDataMap: ' + JSON.stringify(productDataMap));

        var recordId = productDataMap.recordId;
        var isProduct = productDataMap.isProduct;

        console.log('recordId: ' + recordId);
        console.log('isProduct: ' + isProduct);

        component.set("v.recordId", recordId);
        component.set("v.isProduct", isProduct);

        console.log('ckz_PIM_ProductChooser - exit loadAttributes');

    },
    createNewProductDataMap: function(component) {

        console.log('ckz_PIM_ProductChooser - begin createNewProductDataMap()');

        var productDataMap = {};

        var productDetails = {};

        productDetails.name = "";
        productDetails.sku = "";
        productDetails.shortDesc = "";
        productDetails.longDesc = "";
        productDetails.status = "Released";
        productDetails.seoTitle = "";
        productDetails.sfid = null;
        productDetails.selectedStorefronts = [];
        productDetails.productType = "Product";
        productDetails.startDate = null;
        productDetails.endDate = null;

        productDataMap.productDetails = productDetails;

        var priceListEntries = [];
        productDataMap.priceListEntries = priceListEntries;

        var productMediaEntries = [];
        productDataMap.productMediaEntries = productMediaEntries;

        var productCategoryEntries = [];
        productDataMap.productCategoryEntries = productCategoryEntries;

        var relatedProductEntries = [];
        productDataMap.relatedProductEntries = relatedProductEntries;

        var productSpecEntries = [];
        productDataMap.productSpecEntries = productSpecEntries;

        component.set("v.productDataMap", productDataMap);

        var screen = util.getFirstScreen();
        component.set("v.screen", screen);

        util.openComponent(component);

        console.log('ckz_PIM_ProductChooser - exit createNewProductDataMap()');
    },
    /*
    createExistingProductDataMap: function(component, recordId, retainIds) {

        console.log('ckz_PIM_ProductChooser - begin createExistingProductDataMap()');

        // TODO 
        // Turn on the spinner
        // call Apex class to get the data
        // upon return from the call, render the next component.

        component.set('v.showSpinner', true);

        component.set("v.pageMessages", []);

        var action = component.get("c.fetchProductData");

        action.setParams({
            "recordId" : recordId
        });

        action.setCallback(this, function (response) {

            var messages = [];

            component.set('v.showSpinner', false);

            var state = response.getState();

            if (state === 'SUCCESS') {

                var returnValue = response.getReturnValue();

                var errorMsg = null;
                
                if(returnValue.errorMsg) {
                    errorMsg = returnValue.errorMsg;
                    messages.push({'severity' : 'error', 'message' : errorMsg});
                }
                else {
                    var productDataMap = {};

                    var productDetails = {};
                    var priceListEntries = [];
                    var productMediaEntries = [];
                    var productCategoryEntries = [];
                    var relatedProductEntries = [];
                    var productSpecEntries = [];
    
                    if(returnValue.productDetails) {
                        productDetails = returnValue.productDetails;
                    }
    
                    if(returnValue.priceListEntries) {
                        priceListEntries = returnValue.priceListEntries;
                    }
    
                    if(returnValue.productMediaEntries) {
                        productMediaEntries = returnValue.productMediaEntries;
                    }
    
                    if(returnValue.productCategoryEntries) {
                        productCategoryEntries = returnValue.productCategoryEntries;
                    }
    
                    if(returnValue.relatedProductEntries) {
                        relatedProductEntries = returnValue.relatedProductEntries;
                    }
    
                    if(returnValue.productSpecEntries) {
                        productSpecEntries = returnValue.productSpecEntries;
                    }
            
                    productDataMap.productDetails = productDetails;
                    productDataMap.priceListEntries = priceListEntries;
                    productDataMap.productMediaEntries = productMediaEntries;
                    productDataMap.productCategoryEntries = productCategoryEntries;
                    productDataMap.relatedProductEntries = relatedProductEntries;
                    productDataMap.productSpecEntries = productSpecEntries;

                    if(productDetails == {}) {
                        errorMsg = 'Product details not returned.  Something fishy going on.';
                        messages.push({'severity' : 'error', 'message' : errorMsg});
                    }

                    if(productDetails != {}) {
                        if(retainIds == false) {
                            this.clearObjectIds(productDataMap);
                        }
                    }

                    component.set("v.productDataMap", productDataMap);

                    if(messages.length == 0) {
                        var screen = util.getFirstScreen();
                        component.set("v.screen", screen);
                        this.openComponent(component);
                    }
                }

            }
            else {
                var errorMsg = 'Failed with state: ' + state
                console.log(errorMsg);
                messages.push({'severity' : 'error', 'message' : errorMsg});
            }

            component.set("v.pageMessages", messages);

        });

        $A.enqueueAction(action);        

         console.log('ckz_PIM_ProductChooser - exit createExistingProductDataMap()');
    },
    clearObjectIds: function(productDataMap) {
        if(productDataMap.productDetails) {
            var productDetails = productDataMap.productDetails;
            productDetails.sfid = null;
        }

        if(productDataMap.priceListEntries) {
            var priceListEntries = productDataMap.priceListEntries;

            for(var i = 0; i < priceListEntries.length; i++) {
                priceListEntries[i].sfid = null;
            }
        }

        if(productDataMap.productMediaEntries) {
            var productMediaEntries = productDataMap.productMediaEntries;

            for(var i = 0; i < productMediaEntries.length; i++) {
                productMediaEntries[i].sfid = null;
            }
        }

        if(productDataMap.productCategoryEntries) {
            var productCategoryEntries = productDataMap.productCategoryEntries;

            for(var i = 0; i < productCategoryEntries.length; i++) {
                productCategoryEntries[i].sfid = null;
            }
        }

        if(productDataMap.relatedProductEntries) {
            var relatedProductEntries = productDataMap.relatedProductEntries;

            for(var i = 0; i < relatedProductEntries.length; i++) {
                relatedProductEntries[i].sfid = null;
            }
        }

        if(productDataMap.productSpecEntries) {
            var productSpecEntries = productDataMap.productSpecEntries;

            for(var i = 0; i < productSpecEntries.length; i++) {
                productSpecEntries[i].sfid = null;
            }
        }

    },
    openComponent: function(component) {

        var productDataMap = component.get("v.productDataMap");

        var screen = component.get("v.screen");

        var event = component.getEvent("renderPanel");

        event.setParam("type", "c:" + screen);
        event.setParam("attributes", productDataMap);

        event.fire();
    }
    */
})