/*
Call these methods in the component controller by passing in the keyword 'arguments'
as the first parameter. This passes [controller, event, helper] to the helper method

example: helper.goToUrl(arguments, "https://google.com")


Signatures:

goToUrl(Keyword arguments, String url)
goToSObject(Keyword arguments, String objectId, Boolean isRedirect [optional, default false])
toggleClass(Keyword arguments, String auraId, String ClassName)
addClass(Keyword arguments, String auraId, String ClassName)
removeClass(Keyword arguments, String auraId, String ClassName)
createComponent(Keyword arguments, String componentName w/ namespace, Object attributes, String location [optional, default "v.body"])
appendComponent(Keyword arguments, String componentName w/ namespace, Object attributes, String location [optional, default "v.body"])

fireApex(Keyword arguments, String ApexFunctionName w/ namespace, Object params, Function callback [receives return value] or String attributeName [sets this attr to return value])
helper.fireApex(arguments,"c.getAccounts", {}, "v.accountProducts")

fireEvent(Keyword arguments, String eventName, Object params[optional, sets event payload])
addEventHandler(Keyword arguments, String eventName, String actionName)

*/

({
    setFieldLabel : function(component, event, helper) {
        let fieldNamesToLabelsMap  = component.get("v.fieldNamesToLabelsMap")
        let selectedField  = component.get("v.selectedField")
        if(selectedField){
			let selectedFieldLabel = fieldNamesToLabelsMap[selectedField]
            component.set("v.selectedFieldLabel", selectedFieldLabel)
        }
    },
    
    buildChart : function(component, event, helper) {
        let max  = component.get("v.max") || "100";

        //normalize inputs or use default
       let colorBreaks  = component.get("v.colorBreaks") ?
            component.get("v.colorBreaks")
        .split(" ").join("").split(",") :
        ["30", "50", "70", "90"];

        //normalize inputs or use default
        let customColors  = component.get("v.customColors") ?
            component.get("v.customColors")
        .split(" ").join("").split(",") :
        ["#60B044", "#F6C600", "#F97600", "#FF0000"];

		//reverse the colors or not based on user input in builder
        let defaultColorOrder  = component.get("v.defaultColorOrder");
        customColors = defaultColorOrder === "Yes" ? customColors.reverse() : customColors;
        
        let selectedFieldLabel  = component.get("v.selectedFieldLabel");
       
        let data  = component.get("v.selectedFieldValue");
        data = data || 0   ;         
      
        
        let chartId  = component.get("v.chartId");
 
        try { 
       var chart = c3.generate({
            bindto: document.getElementById(chartId),
            transition: {
                duration: 0.5
            },
            data: {
                
                columns: [
                    ['data', data]
                ],
                type: 'gauge',
                onclick: function (d, i) {  },
                onmouseover: function (d, i) { },
                onmouseout: function (d, i) { }
            },
            gauge: {
                max: max, // 100 is default
                label: {
                    format: function(value, ratio) {
                        return value;
                    }
                },
                
                /* **** further options for the guage ****
                     units: ' %',
                    show: false // to turn off the min/max labels.
                min: 0, // 0 is default, //can handle negative min e.g. vacuum / voltage / current flow / rate of change
                
                
                width: 39 // for adjusting arc thickness
                */
               },
                color: {
                    pattern: customColors, // the three color levels for the percentage values.
                    threshold: {
                        //unit: 'value', // percentage is default
                        max: max, // 100 is default
                        values: colorBreaks
                    }
                },
                size: {
                    height: 200
                }
            });
      
            component.set("v.chart", chart);
        }  catch(err) {
            console.error("Chart rendering error " & err.message);
            
        }
           
            
          //  helper.addClass(arguments,  "spinner",  "hidden"); 
        },
    
    goToUrl : function(args, url) {
        let [component, event, helper] = args
        var urlEvent = $A.get("e.force:navigateToURL");
        if(urlEvent){
            urlEvent.setParams({
                "url": url
            });
            urlEvent.fire();
        }else{
            window.location.href = url  
        }
        
    },
    
    goToSObject : function(args, objectId, isredirect) {
        //redirect is optional
        let [component, event, helper] = args
        isredirect = isredirect || false
        var navEvt = $A.get("e.force:navigateToSObject");
        if(navEvt){
            navEvt.setParams({
                "recordId": objectId,
                "isredirect": isredirect
            });
            navEvt.fire();
        }else{
            window.location.href = "/" + objectId
        }
    },
    
    toggleClass : function(args, auraId, className){
        let [component, event, helper] = args
        let el = component.find(auraId)
        if(el.length){
            el.forEach(e => $A.util.toggleClass(e, className))
        }else{
            $A.util.toggleClass(el, className)            
        }
    },
    
    addClass : function(args, auraId, className){
        let [component, event, helper] = args;
        let el = component.find(auraId);
        if(el.length){
            el.forEach(e => $A.util.addClass(e, className));
        }else{
            $A.util.addClass(el, className);            
        }

    },
    
    removeClass : function(args, auraId, className){
        let [component, event, helper] = args
        let el = component.find(auraId)
        if(el.length){
            el.forEach(e => $A.util.removeClass(e, className))
        }else{
            $A.util.removeClass(el, className)            
        }
    },
    
    createComponent : function(args, compName, attributes, location, append){
        
        let [component, event, helper] = args
        location = location || "v.body"
        $A.createComponent(
            compName,
            attributes,
            function(newCmp, status, errorMessage){
                
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    if(append){
                        var body = component.get(location);
                        body.push(newCmp);
                        component.set(location, body);
                    }else{
                        component.set(location, newCmp);  
                    }
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
        );
    },
    
    appendComponent : function(args, compName, attributes, location){
        let [component, event, helper] = args
        helper.createComponent(args, compName, attributes, location, true)
    },
    
    fireApex : function(args, ApexFunctionName, params, option ){
        let [component, event, helper] = args
        let action = component.get(ApexFunctionName);
        action.setParams(params)
        action.setCallback(this, function(a) {
            if(a.getState() === 'ERROR'){
                console.error("There was an error:")
                console.error(a.getError())
            } else if (a.getState() === 'SUCCESS'){
                if(typeof option === "string"){
                    component.set(option, a.getReturnValue())
                }else{
                    option(a.getReturnValue())
                }
               // console.log(a.getReturnValue())	
            }
            
        })
        $A.enqueueAction(action);
    },
    
    fireEvent : function(args, eventName, params){
        let [component, event, helper] = args
        var compEvent = component.getEvent(eventName);
        compEvent.setParams(params);
        compEvent.fire();
    },
    
    addEventHandler : function(args, eventName, actionName) {
        let [component, event, helper] = args
        component.addHandler(eventName, component, actionName);
    }
    
    
})