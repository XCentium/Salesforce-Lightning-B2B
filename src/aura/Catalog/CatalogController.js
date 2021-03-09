({
	doInit : function(component, event, helper) {
		 var actionFetchOrgInfo = component.get("c.fetchOrgInfo");
         actionFetchOrgInfo.setParams({
         });
	        
	     actionFetchOrgInfo.setCallback(this, function(a) {
               var state = a.getState();
               if (state === "SUCCESS") {
                   var result = a.getReturnValue();
                   var namespace = {};
                   result.namespacePrefix = (result.namespace == null) ? "c" : result.namespace;
                   result.namespaceDashedPrefix = (result.namespace == null) ? "" : result.namespace+"__";
                   var statsImgSrc_load = result.statsUrl +'&Action=load&ParentObj='+component.get("v.objectName");
                   component.set('v.orgInfo',result);
                   component.set('v.statsImgSrc_load',statsImgSrc_load);
               }
           });
        $A.enqueueAction(actionFetchOrgInfo); 
	}
})