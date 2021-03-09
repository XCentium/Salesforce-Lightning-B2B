({
    doInit: function(component, event, helper) {

        console.log('ckz_QT_DeepClone - begin init()');

        var recordId = component.get("v.recordId");
        console.log('recordId: ' + recordId);

        helper.initialLoad(component);

    },
    handleCloneMe: function(component, event, helper) {

        console.log('ckz_QT_DeepClone - begin handleCloneMe()');

        try {
            var validForm = [].concat(component.find('inputForm')).reduce(function (validSoFar, inputCmp) {
                // Displays error messages for invalid fields
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            // If we pass error checking, do some real work
            if(validForm){
                helper.doClone(component);
            }
        }
        catch (err) {
            console.log(err.message);
        }

        
    }
})