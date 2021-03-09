({
	prepareAndSendFilter : function(component,event) {
	    var selectedValue=component.get('v.selectedValue');
        var boolResult=(selectedValue=='isTrue');
        var fieldName=component.get('v.fieldName');
        var uniqueFilterName=component.get('v.uniqueFilterName');
        var filterGroup={groupName:uniqueFilterName,type:'OR',enabled:(selectedValue!='NoFilter') ? true : false ,filters:[]};
        var filter1={field:fieldName,operator:'=',value:boolResult,enabled:true};
        filterGroup.filters.push(filter1); 
        console.log(JSON.stringify(filterGroup));
        
        var appEvent = $A.get("e.c:CatalogSendFilterEvent");
        appEvent.setParams({ "JSONFilterData" : JSON.stringify(filterGroup),
                             "filterSection" : "rootObjectFilters" });
        appEvent.fire();	
	}
})