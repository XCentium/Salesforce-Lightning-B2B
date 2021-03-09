({
    doInit : function(cmp,event, helper){
     	var gid = cmp.getGlobalId();
        cmp.set("v.uniqueFilterName", "text"+gid.replace(":", "").replace(";", ""));  
    },
    
	doChange : function(component, event, helper) {
        var searchText=component.get('v.searchText');
        var fieldName=component.get('v.fields');
        var uniqueFilterName=component.get('v.uniqueFilterName');
        var filterGroup={groupName:uniqueFilterName,type:'OR',enabled:(searchText.length >= 2) ? true : false ,filters:[]};
        var fields=fieldName.split(',');
        for (var i = 0; i < fields.length; i++) { 
          var filter={field:fields[i],operator:'like',value:'\'%'+searchText+'%\'',enabled:true};  
          filterGroup.filters.push(filter);
        }
        console.log(JSON.stringify(filterGroup));
        
        var appEvent = $A.get("e.c:CatalogSendFilterEvent");
        appEvent.setParams({ "JSONFilterData" : JSON.stringify(filterGroup),
                             "filterSection" : "rootObjectFilters" });
        appEvent.fire();
        
	}
})