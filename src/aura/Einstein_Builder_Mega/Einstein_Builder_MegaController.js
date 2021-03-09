({
	
 
 	doInit : function(component, event, helper) {
        // Get a reference to the function defined in the Apex controller
		var getFieldLabels = component.get("c.getFieldLabels");
        getFieldLabels.setParams({
            "objName": component.get("v.obj")
        });
        
        if (component.get("v.showHeader")==false) {
            component.set("v.headerStyle","display:none;");
        }
        
        var fieldLabels = '';
        
        // Get a reference to the function defined in the Apex controller
        var getObjectData = component.get("c.getObjectData");
        
        getObjectData.setParams({
            "objid": component.get("v.recordId"),
            "objName": component.get("v.obj"),
            "predictionField": component.get("v.field"),
            "factorFields": component.get("v.factors"),
            "factorFieldsField": component.get("v.factorsField")
        });
        
        // Register the callback function
        getObjectData.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            if (resp==null) {
                component.set("v.predictionName","Bad Query - Check Fields");
                return;
            }
            var data = JSON.parse(resp);
            
            var formattedScore = "N/A";
            var score = "N/A";
            if (data.hasOwnProperty(component.get("v.field"))) {
            	score = data[component.get("v.field")];
                formattedScore = component.get("v.showAsPercentage")?score+"%":score;
        	}
                                  
            component.set("v.score", formattedScore);
            if (score<=component.get("v.redZoneThreshold")) {
                component.set("v.circlecolor","goodnum");
            } else {
                component.set("v.circlecolor","badnum");
            }
            
            component.set("v.factor_conf1", "/resource/bubble_3_positive");
            component.set("v.factor_conf2", "/resource/bubble_2_positive");
            component.set("v.factor_conf3", "/resource/bubble_1_negative");
            component.set("v.factor_conf4", "/resource/bubble_2_negative");
            component.set("v.factor_conf5", "/resource/bubble_3_negative");
            
            
            var factorFields = component.get("v.factors");
            var factorFieldsField = component.get("v.factorsField");
            if (factorFieldsField!=null && factorFieldsField!="" && data.hasOwnProperty(factorFieldsField)) {
                factorFields = data[factorFieldsField];
            }
            
            var factors = '';
            
            if (factorFields!=null && factorFields!='' && component.get("v.showFactors")) {
            	//component.set("v.model_factors_shown",component.get("v.showFactors")?"display:block;":"display:none;");
            	component.set("v.model_factors_shown","display:block;");
            	component.set("v.factors_label_shown","display:inline;");
                factors = factorFields.split(",");
            } else {
                component.set("v.model_factors_shown","min-height:5px;padding-bottom:5px;");
            }
                       
            if (factors.length>0) {
            	var cnt;
                
                for (cnt=0;cnt<factors.length;cnt++) {
                    var factor = factors[cnt];
                    var fieldLabel = fieldLabels[factor];
                    var fieldName = fieldLabel + " is";
                    
                    var factorValue = data.hasOwnProperty(factor)?data[factor]:"<Blank>";
                    
                    component.set("v.factor_name"+(cnt+1), fieldName);
                	component.set("v.factor_value"+(cnt+1), factorValue);
                    component.set("v.factor_shown"+(cnt+1), "display:inline;");
                }
            }
        });
        
        
        getFieldLabels.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            fieldLabels = JSON.parse(resp);
        	
            // Invoke the service
            $A.enqueueAction(getObjectData);
        });
                                   
        $A.enqueueAction(getFieldLabels);
    },
       
    scriptLoaded : function (component, event, helper){
        
    }
})