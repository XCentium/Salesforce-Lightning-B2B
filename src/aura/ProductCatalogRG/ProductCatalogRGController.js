({
    doInit : function(component, event, helper) {
        helper.getSitePrefix(component);
        helper.getYears(component);
        helper.getUserInfo(component);
        helper.getCart(component);
        //helper.getProducts(component);
        helper.getSelectProducts(component);
    },
    addedToCart : function(component, event, helper) {
        var productAdded = event.getParam("product");
        productAdded = JSON.parse(productAdded);
       // console.log('productAdded',productAdded);
        var products = component.get('v.products');
       // console.log('products',products)
        var product;
        
        for (var i = 0; i < products.length; i++) { 
            
            if (products[i].Product2Id == productAdded.productId) {
                
                product = products[i];
            }
        }
        
        //console.log('product', product);
        var cart = component.get('v.cart');
        var existingItemIndex;
        var result = cart.filter(function (item, index) {
            existingItemIndex = index;
            
            return item.productId === product.Product2Id;
        })
        
        var cartItem;
        if ( result.length > 0 ) {
            cartItem = result[0];
            cartItem.quantity = productAdded.quantity;
            cartItem.total = cartItem.price * cartItem.quantity;
            cart = cart.filter(function( item ) {
                return item.Id !== cartItem.Id;
            });
            
        } else {
            cartItem = {
                productId : product.Product2.Id,
                name : product.Product2.Name,
                price : product.UnitPrice,
                quantity : productAdded.quantity,
                total : productAdded.quantity * product.UnitPrice,
                image : product.Product2.Product_Catalog_Image__c
            }
        }
        
        cart.push(cartItem);
        component.set('v.cart', cart);
        
    },
    sumCart : function(component, event, helper) {
       // console.log('sumCart');
        var cart = component.get('v.cart');
        var totalPrice = 0;
        var totalQuantity = 0;
        for (var i = 0; i < cart.length; i++) { 
            totalPrice += cart[i].total;
            totalQuantity += cart[i].quantity;
            //Create or Update Cart Item except for items saved on cart from previous session
            
            if (cart[i].Id == null) {
                helper.updateCart(component, event, cart[i]);
                
                
            } else {
                helper.updateCartItems(component, cart[i].Id, cart[i].quantity);
            }
        }
        component.set('v.cartTotalPrice', totalPrice);
        component.set('v.cartTotalQuantity', totalQuantity);
        
        var tax = component.get('v.tax');
        var taxPercentage = parseFloat(component.get("v.taxPercentage"));
 
        tax = totalPrice * (taxPercentage/100);
        component.set('v.tax', tax);
        
        var orderTotal = component.get('v.orderTotal');
        orderTotal = totalPrice + tax + parseFloat(component.get('v.shipping'));
        component.set('v.orderTotal', orderTotal);
    },
    showCart : function(component, event, helper) {
        var modal = component.find('modal');
        $A.util.addClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.addClass(backdrop, 'slds-backdrop--open');
    },
    closeCart : function(component, event, helper) {
        helper.closeModal(component, event);
        
    },
    removeItem : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var removeItem = selectedItem.dataset.id;
        var cart = component.get('v.cart');
        cart.splice(removeItem, 1);
        component.set('v.cart', cart);
    },
    changeQuantity : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var changeItem = parseInt(selectedItem.dataset.id);
        var newQuantity = parseInt(selectedItem.value);
        var cart = component.get('v.cart');
        var cartItem = cart[changeItem];
        cartItem.quantity = newQuantity;
        cartItem.total = cartItem.price * newQuantity;
        component.set('v.cart', cart);
    },
    clearCart : function(component, event, helper) {
        var cart = component.get('v.cart');
        cart = [];
        component.set('v.cart', cart);
        
        helper.deleteCartItems(component);
    },
    checkout : function(component, event, helper) {
        helper.closeModal(component, event);
        var catalog = component.find('catalog');
        $A.util.addClass(catalog, 'hidden');
        var checkout = component.find('checkout');
        $A.util.removeClass(checkout, 'hidden');
    },
    placeOrder : function(component, event, helper) {
        var cardValidity = component.find("cardnumber").get("v.validity");
        var codeValidity = component.find("securityCode").get("v.validity");
        if (cardValidity.valid && codeValidity.valid) {
            var spinner = component.find("mySpinner");
            $A.util.removeClass(spinner, "slds-hide");
            var checkout = component.find('checkout');
            $A.util.addClass(checkout, 'hidden');
            var confirmation = component.find('confirmation');
            $A.util.removeClass(confirmation, 'hidden');
            var cardNumber = component.find('cardnumber').get("v.value");
            var hiddenCardNumber = '**** **** **** ' + cardNumber.slice(-4);
            var formValues = {
                cardnumber : hiddenCardNumber,
                expiration : component.find('expMonth').get("v.value") + "/" + component.find('expYear').get("v.value"),
                securityCode : component.find('securityCode').get("v.value"),
                firstName : component.find('firstName').get("v.value"),
                lastName : component.find('lastName').get("v.value"),
                company : component.find('company').get("v.value"),
                street : component.find('street').get("v.value"),
                city : component.find('city').get("v.value"),
                state : component.find('state').get("v.value"),
                zip : component.find('zip').get("v.value")
            }
            component.set('v.formValues', formValues);
            helper.closeOrder(component, component.get('v.cartRecord').Id, cardNumber, formValues.expiration, formValues.securityCode, component.get('v.tax'), component.get('v.shipping'));
            helper.updateUserInfo(component,component.find('firstName').get("v.value"), 
                                  component.find('lastName').get("v.value"), 
                                  component.find('company').get("v.value"),
                                  component.find('street').get("v.value"),
                                  component.find('city').get("v.value"),
                                  component.find('state').get("v.value"),
                                  component.find('zip').get("v.value"));
        } else {
            if (!cardValidity.valid) {
                component.find("cardnumber").showHelpMessageIfInvalid();
            }
            if (!codeValidity.valid) {
                component.find("securityCode").showHelpMessageIfInvalid();
            }
        }
    }
})