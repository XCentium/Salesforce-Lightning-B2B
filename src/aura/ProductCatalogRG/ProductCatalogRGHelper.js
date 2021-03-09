({
    getSitePrefix : function(component) {
        var paths = window.location.pathname.split('/').filter(Boolean);
        var sitePrefix;
        if (window.location.pathname == "/one/one.app") {
            sitePrefix = '';
        } else {
            sitePrefix = '/' + paths[0];
        }
        component.set("v.sitePrefix", sitePrefix);
        
    },
    getYears : function(component) {
        var today = new Date();
        var currentYear = today.getFullYear();
        var years = [];
        for (var i = 0; i < 6; i++) { 
            years.push(currentYear);
            currentYear++;
        }
        component.set("v.expirationYears",years);
    },
    getUserInfo : function(component) {
        var action = component.get("c.getUserInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set('v.userInfo', response.getReturnValue());
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    getCart : function(component) {
        var action = component.get("c.getCart");
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.cartRecord", response.getReturnValue());
                
                if (response.getReturnValue().CartItem_Count__c > 0) {
                    self.getCartItems(component, response.getReturnValue().Id);
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    getCartItems : function(component, cartId) {
        //console.log('cartId',cartId);
        var action = component.get("c.getCartItems");
        
        action.setParams({ cartId : cartId });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cart = component.get('v.cart');
                
                for (var i = 0; i < response.getReturnValue().length; i++) { 
                    var cartItem = {
                        Id : response.getReturnValue()[i].Id,
                        productId : response.getReturnValue()[i].Product__r.Id,
                        name : response.getReturnValue()[i].Name,
                        price : response.getReturnValue()[i].Unit_Price__c,
                        quantity : response.getReturnValue()[i].Quantity__c ,
                        total : response.getReturnValue()[i].Total_Price__c,
                        image : response.getReturnValue()[i].Product__r.Product_Catalog_Image__c
                    }
                    
                    cart.push(cartItem);
                }
                
                component.set('v.cart', cart);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    updateCartItems : function(component, cartItemId, quantity) {
        var action = component.get("c.updateCartItems");
        
        action.setParams({ 
            cartItemId : cartItemId,
            quantity : quantity
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               // console.log("updated cart item", response.getReturnValue());
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    deleteCartItems : function(component) {
        var action = component.get("c.deleteCartItems");
        
        action.setParams({ 
            cartId : component.get('v.cartRecord').Id
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               // console.log("deleted cart item");
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    getProducts : function(component) {
        var action = component.get("c.getProducts");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.products", response.getReturnValue());
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    getSelectProducts : function(component) {
        var action = component.get("c.getSelectProducts");
        var priceBookNameLocal = component.get('v.pricebook');
        console.log("Pricebook:"+priceBookNameLocal);
        
        action.setParams({ 
            priceBookName : priceBookNameLocal
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.products", response.getReturnValue());
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    closeModal : function(component, event) {
        var modal = component.find('modal');
        $A.util.removeClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
    },
    updateCart : function(component, event, cartItem) {
       // console.log('Create or Update Cart Item',cartItem);
        
        var action = component.get("c.updateCart");
        
        action.setParams({ 
            cartId : component.get('v.cartRecord').Id,
            itemName : cartItem.name, 
            productId : cartItem.productId,
            price : cartItem.price, 
            quantity : cartItem.quantity
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cartItem = response.getReturnValue();
                var cart = component.get('v.cart');
                
                for (var i = 0; i < cart.length; i++) { 
                    if (cart[i].productId == cartItem.Product__c) {
                        cart[i].Id = cartItem.Id
                    }
                }
                component.set('v.cart',cart);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    closeOrder : function(component, cardId, cardNumber, expiration, securityCode, tax, shipping) {
        
        var action = component.get("c.closeOrder");
        
        action.setParams({ 
            cartId : cardId,
            cardNumber : cardNumber, 
            expiration : expiration,
            securityCode : securityCode,
            tax : tax,
            shipping : shipping
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    updateUserInfo : function(component, firstName, lastName, company, street, city, state, zip) {
        //console.log(component, firstName, lastName, company, street, city, state, zip);
        var action = component.get("c.updateUserInfo");
        
        action.setParams({ 
            firstName : firstName,
            lastName : lastName,
            company : company,
            street : street,
            city : city,
            state : state,
            zip : zip
        });
        
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var spinner = component.find("mySpinner");
                $A.util.addClass(spinner, "slds-hide");
                self.showToast(component, event);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    showToast : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Thank You!",
            "type": "success",
            "message": "Your order has successfully been placed."
        });
        toastEvent.fire();
    }
})