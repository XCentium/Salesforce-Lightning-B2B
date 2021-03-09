({
	doChange : function(component, event, helper) {
        var minVal=component.get('v.valSliderMin');
        var maxVal=component.get('v.valSliderMax');
        var filterGroup={groupName:'priceFilter',type:'AND',enabled:component.get('v.enablePriceFilter'),filters:[]};
        var filter1={field:'UnitPrice',operator:'>=',value:minVal,enabled:component.get('v.enablePriceFilter')};
        var filter2={field:'UnitPrice',operator:'<=',value:maxVal,enabled:component.get('v.enablePriceFilter')};
        filterGroup.filters.push(filter1);
        filterGroup.filters.push(filter2);
        //console.log(JSON.stringify(filterGroup));
        
        var appEvent = $A.get("e.c:CatalogSendFilterEvent");
        appEvent.setParams({ "JSONFilterData" : JSON.stringify(filterGroup),
                             "filterSection" : "pbeFilters" });
        appEvent.fire();
        
	},
    
    toggleChange : function(component, event, helper) {
      	if (typeof(event.currentTarget.type) !== 'undefined'){
            component.set("v.enablePriceFilter",event.currentTarget.checked);
            component.calculateAndSendFilters();

        }
	},
    
    doInit : function(cmp, event, helper) {
        console.log('c.getPriceBounds');
        var action = cmp.get("c.getPriceBounds");
        action.setParams({pricebookId:cmp.get('v.pricebookId'),
                          activeOnly:cmp.get('v.activeProductsOnly')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log(result);
                cmp.set('v.minPrice',result.minAsInt);
                cmp.set('v.maxPrice',result.maxAsInt);
                cmp.set('v.valSliderMin',result.minAsInt);
                cmp.set('v.valSliderMax',result.maxAsInt);
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
        
    }
    
})