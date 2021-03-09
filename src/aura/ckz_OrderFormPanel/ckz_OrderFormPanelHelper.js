({
    getInfo: function(component) {

        console.log('inside getInfo');

        var recordId = component.get('v.recordId');

        if(recordId == null || recordId == '') {

            console.log('not opened from a record page');
            
            var panelName = 'ckz_OrderFormStart';

            component.set('v.parameters', {});

            // 2019-09-19  msobczak: added
            var attrs = {};
            attrs.defaultStorefront = component.get("v.defaultStorefront");

            // 2019-09-20  msobczak: added
            attrs.useCardLayout = component.get("v.useCardLayout");

            this.renderPanel(component, {
                type: 'c:' + panelName,
                attributes: attrs
            });

        }
        else {
            this.lookupObjectData(component);
        }


    },
    lookupObjectData: function(component) {

        var action = component.get("c.fetchInfo");

        var recordId = component.get('v.recordId');

        action.setParams({
            "recordId" : recordId
        });

        action.setCallback(this, function (response) {

            var attrs = {};

            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if(returnValue.userId) {
                    attrs.userId = returnValue.userId;
                    console.log('userId = ' + returnValue.userId);
                }

                if(returnValue.contactId) {
                    attrs.contactId = returnValue.contactId;
                    console.log('contactId = ' + returnValue.contactId);
                }

                if(returnValue.locale) {
                    attrs.locale = returnValue.locale;
                    component.set('v.locale', returnValue.locale);
                }

                if(returnValue.accountId) {
                    attrs.accountId = returnValue.accountId;
                    console.log('accountId = ' + returnValue.accountId);
                }

                if(returnValue.accountName) {
                    attrs.accountName = returnValue.accountName;
                    console.log('accountName = ' + returnValue.accountName);
                }

                if(returnValue.accountGroupName) {
                    attrs.accountGroupName = returnValue.accountGroupName;
                    console.log('accountGroupName = ' + returnValue.accountGroupName);
                }

                if(returnValue.currencyCode) {
                    attrs.currencyCode = returnValue.currencyCode;
                    console.log('currencyCode = ' + returnValue.currencyCode);
                }

                if(returnValue.cartId) {
                    attrs.cartId = returnValue.cartId;
                    console.log('cartId = ' + returnValue.cartId);
                }

                if(returnValue.cartEncryptedId) {
                    attrs.cartEncryptedId = returnValue.cartEncryptedId;
                    console.log('cartEncryptedId = ' + returnValue.cartEncryptedId);
                }

                if(returnValue.selectedObjectName) {
                    attrs.selectedObjectName = returnValue.selectedObjectName;
                    console.log('selectedObjectName = ' + returnValue.selectedObjectName);
                }

                if(returnValue.orderType) {
                    attrs.orderType = returnValue.orderType;
                    console.log('orderType = ' + returnValue.orderType);
                }

                if(returnValue.selectedStorefront) {
                    attrs.selectedStorefront = returnValue.selectedStorefront;
                    console.log('selectedStorefront = ' + returnValue.selectedStorefront);
                }

                if(returnValue.quoteId) {
                    attrs.quoteId = returnValue.quoteId;
                    console.log('quoteId = ' + returnValue.quoteId);
                }
                else {
                    attrs.quoteId = null;
                }

                // 2019-09-05  msobczak: added
                attrs.defaultStorefront = component.get("v.defaultStorefront");

                // 2019-09-20  msobczak: added
                attrs.useCardLayout = component.get("v.useCardLayout");

                if(returnValue.cartStatus) {
                    attrs.cartStatus = returnValue.cartStatus;
                    console.log('cartStatus = ' + returnValue.cartStatus);
                }
                else {
                    attrs.cartStatus = null;
                }

                attrs.recordId = component.get('v.recordId');

                var objectApiName = returnValue.objectApiName;

                component.set('v.parameters', attrs);

                var panelName = 'ckz_OrderFormStart';

                if(objectApiName == 'ccrz__E_Cart__c') {
                    // Starting from a CC Cart object

                    console.log('opening order entry component');
                    panelName = 'ckz_OrderFormDataEntry';

                }
                else if(objectApiName == 'SBQQ__Quote__c') {
                    // Startig with a CPQ Quote object
                    console.log('opening quick checkout component');
                    panelName = 'ckz_QuickCheckout';
                }
                else {
                    console.log('opening start component');
                }

                // 2020-04-06 msobczak: added
                var newCartFirstScreenChoice = component.get("v.newCartFirstScreenChoice");

                attrs.newCartFirstScreenChoice = newCartFirstScreenChoice;

                this.renderPanel(component, {
                            type: 'c:' + panelName,
                            attributes: attrs
                        });

            }
            else {
                console.log('Failed with state: ' + state);
            }
        });

        $A.enqueueAction(action);

    },

    VERBOSE: true,

    renderPanel : function(component, params) {
        let self = this;
        component.set('v.showSpinner', true);

        if(self.VERBOSE) console.log('Rendering ' + params.type, JSON.stringify(params.attributes));

        if (params.toast) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(params.toast);
            toastEvent.fire();
        }

        if ( params.type ) {
            try {
                //var attrs = JSON.parse(JSON.stringify(params.attributes));
                $A.createComponent(params.type, params.attributes, function(newPanel) {
                    if (component.isValid()) {
                        component.set('v.body', [ newPanel ]);
                        self.hideSpinner(component)
                    }
                });
            }
            catch(err) {
                console.log('error message: ' + err.message);
            }
        } else {
            self.hideSpinner(component)
        }
    },
    showSpinner: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            try{
                component.set('v.showSpinner', true);
                resolve();
            } catch(err){
                reject(err);
            }

        }))
    },
    hideSpinner: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            try{
                component.set('v.showSpinner', false);
                resolve();
            } catch(err){
                reject(err);
            }

        }))
    }
})