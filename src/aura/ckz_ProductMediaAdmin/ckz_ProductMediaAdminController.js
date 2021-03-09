({
    doInit: function(component, event, helper) {

        console.log('ckz_ProductMediaAdmin - begin init()');

        helper.getData(component);

    },
	handleMediaTypeChange : function(component, event, helper) {
		console.log('inside handleMediaTypeChange');
        
        var selection = component.find("selectMediaType").get("v.value");
        
        console.log('selection is: ' + selection);
        
        component.set("v.mediaType", selection);
        
	},
	handleSave : function(component, event, helper) {
	    var isValid = helper.validateInput(component);

	    if(isValid) {
            helper.createMedia(component);
        }
    },
    handleDeleteAll: function(component, event, helper) {
		console.log('inside handleDeleteAll');

		helper.waiting(component);
        
        var action = component.get("c.deleteAllProductMedia");

        var recordId = component.get('v.recordId');
        
        console.log('recordId: ' + recordId);

        action.setParams({
            "productId" : recordId
        });

        action.setCallback(this, function (response) {

            helper.doneWaiting(component);

            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                
                if(returnValue.isError && returnValue.isError === true) {
                    helper.showToast(component, returnValue.errorMsg, 'dismissible', 'error');
                }

                if(returnValue.resultMsg && returnValue.resultMsg != '') {
                    helper.showToast(component, returnValue.resultMsg, 'dismissible', 'info');
                }

            }
            else {
                var msg = 'Failed with state: ' + state;
                console.log(msg);
                helper.showToast(component, msg, 'dismissible', 'error');
            }
        });

        $A.enqueueAction(action);
        
	},
	handleRecordSaveEvent : function(component, event, helper) {
        component.set("v.reloadData", true);
    },
    waiting: function(component, event, helper) {
        helper.waiting(component);
    },
    doneWaiting: function(component, event, helper) {
        helper.doneWaiting(component);
    },
})