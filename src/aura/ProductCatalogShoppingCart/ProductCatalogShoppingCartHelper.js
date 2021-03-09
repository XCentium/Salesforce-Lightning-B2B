({
	updateTotal : function(cmp) {
        var items = cmp.get("v.itemsInCart");
        var total = 0;
        items.forEach(function(item){
            total += item.product.Default_Price__c * item.quantity;            
        });
        cmp.set("v.total", total);
	},
    addNewItem : function (cmp, newItem) {
        var items = cmp.get("v.itemsInCart");
        var itemExist = false;
        for (var i = 0; i < items.length; ++i) {
            if (items[i].product.Id === newItem.product.Id) {
                itemExist = true;
                items[i].quantity += newItem.quantity;
            }
        }
        if (!itemExist) {
            items.push(newItem);
        }
        cmp.set("v.itemsInCart", items);
    },
    removeItem : function (component, productId) {
        var items = component.get("v.itemsInCart");
        var index;
        for (var i = 0; i < items.length; ++i) {
            if (items[i].product.Id === productId) {
                index = i;
            }
        }
        items.splice(index,1);
        component.set("v.itemsInCart",items);
    },
    removeAllItems : function (component) {
        var array = [];
        component.set("v.itemsInCart", array);
    }
})