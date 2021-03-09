({
	prepareAndSendFilter : function(component,event) {
	    var selectedValue=component.get('v.selectedValue');
        var fieldName=component.get('v.fieldName');
        var min = Number(component.get('v.min'));
        var max = Number(component.get('v.max'));
        if (!min || min==0) min=NaN;
        if (!max || max==0) max=NaN;
        var uniqueFilterName=component.get('v.uniqueFilterName');
        var filterGroup={groupName:uniqueFilterName,type:'AND',enabled:!(isNaN(min) && isNaN(max)) ? true : false ,filters:[]};
        var filter1={field:fieldName,operator:'>=',value:min,enabled:!isNaN(min)};
        var filter2={field:fieldName,operator:'<=',value:max,enabled:!isNaN(max)};
        filterGroup.filters.push(filter1);
        filterGroup.filters.push(filter2);
        console.log(JSON.stringify(filterGroup));
        
        var appEvent = $A.get("e.c:CatalogSendFilterEvent");
        appEvent.setParams({ "JSONFilterData" : JSON.stringify(filterGroup),
                             "filterSection" : "rootObjectFilters" });
        appEvent.fire();	
	}
})