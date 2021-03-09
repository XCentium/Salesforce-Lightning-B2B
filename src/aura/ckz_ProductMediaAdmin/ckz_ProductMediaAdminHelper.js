({
    getData : function(component) {

        var recordId = component.get("v.recordId");
        console.log('recordId: ' + recordId);

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
    validateInput : function(component) {
        var isValid = true;

        var uri = component.get("v.uri");
        var mediaType = component.get("v.mediaType");

        if(uri == null || uri == '') {
            this.showToast(component, "Please enter the URI", 'dismissible', 'error');
            isValid = false;
        }

        if(mediaType == null || mediaType == '') {
            this.showToast(component, "Please select a Media Type", 'dismissible', 'error');
            isValid = false;
        }

        return isValid;
    },
    createMedia : function(component) {
        console.log('inside createMediaRecords');

        this.waiting(component);

        var action = component.get("c.createProductMedia");

        var productId = component.get('v.recordId');
        var uri = component.get('v.uri');
        var mediaType = component.get('v.mediaType');

        console.log('productId: ' + productId);

        action.setParams({
            "productId" : productId
            ,"uri" : uri
            ,"mediaType" : mediaType

        });

        action.setCallback(this, function (response) {

            this.doneWaiting(component);

            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if(returnValue.isError && returnValue.isError === true) {
                    this.showToast(component, returnValue.errorMsg, 'dismissible', 'error');
                }

                if(returnValue.resultMsg && returnValue.resultMsg != '') {
                    this.showToast(component, returnValue.resultMsg, 'dismissible', 'info');
                }

                component.set("v.reloadData", true);

                component.set("v.mediaType", null);
                component.set("v.URI", '');

                var productField = component.find('mediaURI');
                productField.set("v.value", null);

                window.setTimeout(
                    $A.getCallback(function () {
                        var mediaTypeField = component.find('selectMediaType');
                        mediaTypeField.set("v.value", "");

                    })
                );

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
})