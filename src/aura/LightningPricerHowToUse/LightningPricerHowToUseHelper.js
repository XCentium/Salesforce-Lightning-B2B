({
	    getOrgInfo : function(component) {
    	 var actionFetchOrgInfo = component.get("c.fetchOrgInfo");
         actionFetchOrgInfo.setParams({
            parentObjName : null,
            parentRecId: null
         });
	        
	     actionFetchOrgInfo.setCallback(this, function(a) {
               var state = a.getState();
               if (state === "SUCCESS") {
                   var result = a.getReturnValue();
                   var namespace = {};
                   result.namespacePrefix = (result.namespace == null) ? "c" : result.namespace;
                   result.namespaceDashedPrefix = (result.namespace == null) ? "" : result.namespace+"__";
                   var statsImgSrc_load = result.statsUrl +'&Action=helpPage';
                   component.set('v.orgInfo',result);
                   component.set('v.statsImgSrc_load',statsImgSrc_load);
                   //console.log('orgInfo');
                   //console.log(result);
				    var cmpCode = "<aura:component implements=\"flexipage:availableForAllPageTypes\">\n";
                    cmpCode += "  <aura:registerEvent name=\"appEvent\" type=\""+result.namespacePrefix+":PricerAddProductEvent\"/>\n\n";
                    cmpCode += "  <h1>Add product to pricer</h1>\n";
                    cmpCode += "  <lightning:button label=\"Click here\" onclick=\"{!c.fireApplicationEvent}\" />\n";
                    cmpCode += "\n</aura:component>";
                    component.set("v.CmpSampleCode",cmpCode);
                        
                    var ctrlCode="({ \n  fireApplicationEvent : function(cmp, event) {\n";
                    ctrlCode+="    var appEvent = $A.get(\"e."+result.namespacePrefix+":PricerAddProductEvent\");\n"
                    ctrlCode+="    appEvent.setParams({\n";
                    ctrlCode+="      \"productId\" : \"01t5Y00000DRFbDQAH\"});\n";
                    ctrlCode+="    appEvent.fire();\n";
                    ctrlCode+="  }\n})";    
                    component.set("v.CtrlSampleCode",ctrlCode); 

               }
           });
        $A.enqueueAction(actionFetchOrgInfo);  
    }

})