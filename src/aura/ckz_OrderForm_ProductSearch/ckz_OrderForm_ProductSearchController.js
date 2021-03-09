({
    doInit: function(component, event, helper) {
        console.log('ckz_OrderItem - begin init()');

        helper.getFiltersForAllProducts(component);

        // 2019-11-11  msobczak: added to get all products when component is initially rendered.
        helper.getProductDataLive(component, JSON.stringify([]));

        // console.log('ckz_OrderItem - exit init()');

    },
    scriptsLoaded : function(component) {

        var orderType = component.get("v.orderType");

        if(orderType == 'cart' || orderType == 'newcart') {
            component.set("v.addButtonLabel", util.getLabel('addToCart'));
        }
        else if(orderType == 'wish' || orderType == 'newwish') {
             component.set("v.addButtonLabel", util.getLabel('addToWishList'));
         }
    },
    getProducts : function(component, event, helper) {
        var productData = helper.getProductDataMock(component);

        component.set("v.productData", productData);
    },
    handleFilterChange : function(component, event, helper) {

        console.log('ckz_OrderForm_ProductSearch - inside handleFilterChange');

        var filterName = event.getParam("filterName");
        var filterSfid = event.getParam("filterSfid");
        var filterSelections = event.getParam("filterSelections");

        var filterValues = component.get("v.filterValues");

        filterValues[filterSfid] = filterSelections;

        component.set("v.filterValues", filterValues);

        component.set("v.productData", []);

        // Get all filter entries that are not an empty array.
        var validFilterList = [];

        for(var key in filterValues) {

            var filterMap = {};
            filterMap.sfid = key;

            var filterSelections = filterValues[key];

            if(filterSelections.length > 0) {

                var specValues = [];

                for(var i = 0; i < filterSelections.length; i++) {
                    var specValue = {};
                    specValue.value = filterSelections[i];
                    specValues.push(specValue);
                }

                filterMap.specValues = specValues;

                validFilterList.push(filterMap);
            }

        }

        if(validFilterList.length > 0) {
            helper.getProductDataLive(component, JSON.stringify(validFilterList));
        }

    },
    handleProductSelect : function(component, event, helper) {

        console.log('ckz_OrderForm_ProductSearch - inside handleProductSelect');

        var productName = event.getParam("productName");
        var productSfid = event.getParam("productSfid");
        var productSKU = event.getParam("productSKU");
        var productSelectValue = event.getParam("productSelectValue");

        var productSelections = component.get("v.productSelections");

        var product = {};
        product.name = productName;
        product.sfid = productSfid;
        product.sku = productSKU;
        product.selected = productSelectValue;

        productSelections[productSfid] = product;

        component.set("v.productSelections", productSelections);

    },
    handleNavigatePrev: function(component, event, helper) {

        var attrs = util.createAttrsObj(component);

        var event = component.getEvent("renderPanel");

        var orderType = component.get('v.orderType');

        if(orderType == 'cart' || orderType == 'newcart') {
            event.setParam("type", "c:ckz_OrderFormDataEntry");
        }
        else if(orderType == 'wish' || orderType == 'newwish') {
            event.setParam("type", "c:ckz_OrderFormWishListEdit");
        }

        event.setParam("attributes", attrs);

        event.fire();

    },
    addItemsAndReturnToCart: function(component, event, helper) {

        console.log('ckz_OrderForm_AddItem - begin addItemAndReturnToCart()');

        var orderItems = component.get("v.orderItems");

        // 2020-01-10  msobczak: put the current order Items into a Map
        var orderItemsMap = {};

        for(var i = 0; i < orderItems.length; i++) {
            orderItemsMap[orderItems[i].sku] = orderItems[i];
        }

        var productSelections = component.get("v.productSelections");

        for(var key in productSelections) {
            var product = productSelections[key];
            if(product.selected) {

                // 2020-01-10  msobczak: added check to make sure duplicate product is not added.
                if(orderItemsMap[product.sku] === undefined) {
                    var orderItem = helper.createNewOrderItem();
                    orderItem.product_sfid = product.sfid;
                    orderItem.productName = product.name;
                    orderItem.sku = product.sku;

                    orderItems.push(orderItem);
                }
            }
        }

        var attrs = util.createAttrsObj(component);

        var event = component.getEvent("renderPanel");

        var orderType = component.get('v.orderType');

        if(orderType == 'cart' || orderType == 'newcart') {
            event.setParam("type", "c:ckz_OrderFormDataEntry");
        }
        else if(orderType == 'wish' || orderType == 'newwish') {
            event.setParam("type", "c:ckz_OrderFormWishListEdit");
        }

        event.setParam("attributes", attrs);

        event.fire();
    },
    waiting: function(component, event, helper) {
        helper.waiting(component);
    },
    doneWaiting: function(component, event, helper) {
        helper.doneWaiting(component);
    },

});