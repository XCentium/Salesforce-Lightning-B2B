({
	addToCart : function(component, event, helper) {
        var productId = event.getSource().get("v.value");
        
        var quantity = component.find('prodQuantity').get("v.value");
        quantity = parseInt(quantity);
        if (!isNaN(quantity) || quantity < 1) {
            var product = {
                productId : productId,
                quantity: quantity
            }
            //console.log('In Child',product);
            $A.get("e.c:ProductCatalogAddToCartEvent").
            setParams({
                product: JSON.stringify(product)
            }).fire();
        } else {
            let toast = $A.get("e.force:showToast");
            toast.setParams({
                "title": "Invalid Quantity",
                "type": "error",
                "message": "The entered order quantity '" + component.find('prodQuantity').get("v.value") + "' is invalid."
            });
            toast.fire();
        }
	},
    doInit : function(component, event, helper) {
        var product = component.get('v.product');
        var cart = component.get('v.cart');
        
        var cart = cart.filter(function(cartItem){
            return cartItem.productId == product.Product2Id;
        });
        if (cart.length > 0) {
            
            var currentQty = cart[0].quantity;
        }
       	component.set('v.currentQty',currentQty);
    },
    clearQty : function(component, event, helper) {
        component.set('v.currentQty','');
    }
})