({
    getData : function(component) {

        this.waiting(component);

        var productId = component.get("v.productId");
        console.log('productId: ' + productId);

        var action = component.get("c.fetchAllProductMedia");

        var productId = component.get('v.productId');

        console.log('productId: ' + productId);

        action.setParams({
            "productId" : productId
        });

        action.setCallback(this, function (response) {

            this.doneWaiting(component);

            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                for(var i = 0; i < returnValue.length; i++) {
                    var rec = returnValue[i];
                    rec.linkUri = '/lightning/r/' + rec.Id + '/view';

                    // This does not work
//                    if(rec.ccrz__URI__c && rec.ccrz__URI__c !== '') {
//                        rec.imagePreview = "<img src='" + rec.ccrz__URI__c + "'>";
//                    }
                }

                console.log('records returned = ' + returnValue.length);

                component.set("v.data", returnValue);

            }
            else {
                var msg = 'Failed with state: ' + state;
                console.log(msg);
                this.showToast(component, msg, 'dismissible', 'error');
            }

            component.set("v.reloadData", false);
        });

        $A.enqueueAction(action);

    },
    deleteRecord: function (component, row) {

        this.waiting(component);

        var recordId = row.Id;

        var action = component.get("c.deleteProductMedia");

        action.setParams({
            "recordId" : recordId
        });

        action.setCallback(this, function (response) {

            this.doneWaiting(component);

            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                component.set("v.reloadData", true);

                this.showToast(component, 'Record deleted', 'dismissible', 'info');

            }
            else {
                var msg = 'Failed with state: ' + state;
                console.log(msg);
                this.showToast(component, msg, 'dismissible', 'error');
            }

            component.set("v.reloadData", false);
        });

        $A.enqueueAction(action);
    },
    showToast : function(component, userMessage, mode, type) {

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: mode,
            message: userMessage,
            type : type
        });
        toastEvent.fire();
    },
    updateRecs: function(component, draftValues) {
        
        var action = component.get("c.updateRecords");

        action.setParams({
            "records" : draftValues
        });

        action.setCallback(this, function (response) {

            this.doneWaiting(component);

            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                component.find("mediaTable").set("v.draftValues", null);

                component.set("v.reloadData", true);

                if(returnValue.isError && returnValue.isError === true) {
                    this.showToast(component, returnValue.errorMsg, 'dismissible', 'error');
                }

                if(returnValue.resultMsg && returnValue.resultMsg != '') {
                    this.showToast(component, returnValue.resultMsg, 'dismissible', 'info');
                }

            }
            else {
                var msg = 'Failed with state: ' + state;
                console.log(msg);
                this.showToast(component, msg, 'dismissible', 'error');
            }

        });

        $A.enqueueAction(action);
    },
    deleteAll: function(component) {

        this.waiting(component);

        var action = component.get("c.deleteAllProductMedia");

        var productId = component.get('v.productId');

        console.log('productId: ' + productId);

        action.setParams({
            "productId" : productId
        });

        action.setCallback(this, function (response) {
            this.doneWaiting(component);

            var state = response.getState();
            if (state === 'SUCCESS') {

                this.getData(component);

                var returnValue = response.getReturnValue();

                if(returnValue.isError && returnValue.isError === true) {
                    this.showToast(component, returnValue.errorMsg, 'dismissible', 'error');
                }

                if(returnValue.resultMsg && returnValue.resultMsg != '') {
                    this.showToast(component, returnValue.resultMsg, 'dismissible', 'info');
                }

            }
            else {
                var msg = 'Failed with state: ' + state;
                console.log(msg);
                this.showToast(component, msg, 'dismissible', 'error');
            }

        });

        $A.enqueueAction(action);
    },
    deleteSelected: function(component) {

        this.waiting(component);

        var action = component.get("c.deleteSelectedProductMedia");

        var productId = component.get('v.productId');

        console.log('productId: ' + productId);

        var selections = component.find("mediaTable").getSelectedRows();
        console.log("selected: " + selections);

        if(selections === undefined || selections.length <= 0) {
            return;
        }

        var ids = [];

        for(var i = 0; i < selections.length; i++) {
            var id = selections[i].Id;
            ids.push(id);
        }

        action.setParams({
            "productId" : productId,
            "ids" : ids
        });

        action.setCallback(this, function (response) {
            this.doneWaiting(component);

            var state = response.getState();
            if (state === 'SUCCESS') {

                this.getData(component);

                var returnValue = response.getReturnValue();

                if(returnValue.isError && returnValue.isError === true) {
                    this.showToast(component, returnValue.errorMsg, 'dismissible', 'error');
                }

                if(returnValue.resultMsg && returnValue.resultMsg != '') {
                    this.showToast(component, returnValue.resultMsg, 'dismissible', 'info');
                }

            }
            else {
                var msg = 'Failed with state: ' + state;
                console.log(msg);
                this.showToast(component, msg, 'dismissible', 'error');
            }

        });

        $A.enqueueAction(action);
    },
    waiting: function(component) {
        component.set("v.showSpinner", true);
    },
    doneWaiting: function(component) {
        component.set("v.showSpinner", false);
    },
});