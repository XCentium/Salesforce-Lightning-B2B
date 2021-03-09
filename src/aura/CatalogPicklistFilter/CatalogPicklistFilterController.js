({
    
    doInit: function (cmp, event) {
		var gid = cmp.getGlobalId();
        cmp.set("v.uniqueFilterName", "picklist"+gid.replace(":", "").replace(";", ""));
        
        var action = cmp.get("c.getPicklistOptions");
        action.setParams({ objName : cmp.get('v.objectName'),
                          fieldName : cmp.get('v.fieldName')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                cmp.set('v.options',response.getReturnValue());
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
    
    handleChange: function (component, event) {
        //alert(event.getParam('value'));
        console.log(event.getParam('value'));
        var userChoices = event.getParam('value');
        var uniqueFilterName=component.get('v.uniqueFilterName');
        var filterGroup={groupName:uniqueFilterName,type:'OR',enabled:(userChoices.length > 0) ? true : false,filters:[]};
        for (var i = 0; i < userChoices.length; i++) {
			var filter={field:component.get('v.fieldName'),operator:'=',value:'\''+userChoices[i]+'\'',enabled:true};
            filterGroup.filters.push(filter);
		}
        
        var appEvent = $A.get("e.c:CatalogSendFilterEvent");
        appEvent.setParams({ "JSONFilterData" : JSON.stringify(filterGroup),
                             "filterSection" : "rootObjectFilters"});
        appEvent.fire();
        
    }
})