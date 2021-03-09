({
	doInit: function (cmp, event) {

        var action = cmp.get("c.getFieldsDesc");
        action.setParams({ objName : cmp.get('v.objectName'),
                          fields : cmp.get('v.fields')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var result=response.getReturnValue();
                console.log('CustomFilterQueryResult:');
                console.log(result);
                /*
                var fieldsDesc = result.fields.map(function (curr, index) {
                    var isSupported=false;
                    if (curr.fieldType=='picklist') isSupported=true;
            		return Object.assign({}, curr,{ isSupported: isSupported });
        		});
                console.log(fieldsDesc);
                */
                cmp.set('v.fieldsDesc',result.fields);
                //cmp.set('v.options',response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    cmp.set('v.errorMsg',"Error message: " + errors[0].message);
        			$A.util.removeClass(cmp.find('errorDiv'), 'slds-hide');    
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
})