({

    
    displayToast : function(component, type, message) {
        
        console.log(message);
        $A.createComponents([
            ["ui:message",{ "title" : "Error",  "severity" : type, }],
            ["ui:outputText",{ "value" : message}]
        ],
                            function(components, status, errorMessage){
                                if (status === "SUCCESS") {
                                    var message = components[0];
                                    var outputText = components[1];
                                    // set the body of the ui:message to be the ui:outputText
                                    message.set("v.body", outputText);
                                    var div1 = component.find("msgDiv");
                                    // Replace div body with the dynamic component
                                    div1.set("v.body", message);
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
    
    loadChart : function(component, event, helper) {
          
        let chartId  = component.get("v.chartId");
        var canvas = document.getElementById(chartId);

        if(canvas == null) {
            console.log("--------- IOT Chart Canvas Missing ----------");
            return;
        }
        
        var ctx =  canvas.getContext('2d');  
        var timeFormat = 'YYYY-MM-DD hh:mm:ss';
        var date = Date.now();
        var labels = [];
        var data2 = [];
        var radius = [];
        
        var config = {
            type: 'bubble',
            data: {      
                datasets: [{
                    label: '',
                    data: data2,
                    backgroundColor: [ 'rgba(15, 8, 200, 0.4)' ],
                    borderColor: [
                        
                    ],
                    borderWidth: 1
                }]
            },
            options:  {
                aspectRatio: 1,
                legend: false,
                tooltips: false,
                
                elements: {
                    point: {
                       
                        hoverBackgroundColor: 'transparent',
                        radius: radius
                    }
                }
            }
        };
        
       var myChart  = new Chart(ctx, config); 
        component.set("v.chart", myChart);
        

    },
   
    loadFieldsAndData : function(component, event, helper) {
        
        let selectedEvent  = component.get("v.eventName");
        
        //to be used in fireApex callback
        let args = arguments;
        
        
        helper.fireApex(arguments,  "c.getFields", {eventName: selectedEvent}, (res) => {
            let eventNameFieldsMap = {};
                        let eventLabelsAndNames = [];
                        let nameLabelMap = {};
                        
                        let parsedResponse = JSON.parse(res);
        //extract field names from array
        let fieldNames = parsedResponse.map(fn => {return Object.keys(fn)[0]});
        
        // use this to create a friendlier shape, then filter out system generated fields
        //while we're in there let's make a map for setting the field label too
        let fieldNamesToLabelsMap = {};
        let selectedFields = fieldNames.map((fn, i) => {
            fieldNamesToLabelsMap[fn] = parsedResponse[i][fn]
            return {fieldName: fn, fieldLabel: parsedResponse[i][fn]}
                                            })
        .filter(fn => {return fn.fieldName.indexOf("__c") > -1})
        .reverse();
        component.set("v.fieldNamesToLabelsMap",fieldNamesToLabelsMap);
        
        //to populate field dropdown
        component.set("v.selectedFields", selectedFields);
        
        //Set the field Label for use in the title header
        helper.setFieldLabel(...args);
        
        
        if(selectedFields.length > 0) {
            
            var defaultField = selectedFields[0].fieldName;
            component.set("v.selectedField", defaultField);
            
            helper.getChartData(component, helper, defaultField);
        }
        
    });  
    
},
 
 getChartData : function(component, helper, fieldName) {
 
    
    var objName = component.get("v.objectName");
    if(objName == null || objName.length == 0) {
        return;
    }
    
    fieldName = fieldName + '__c';
    
    let eventName = component.get("v.eventName");
    
    var action = component.get("c.getEventData");
    action.setParams({
        fieldName: fieldName,
        eventName : eventName,
        objectName : objName,
        recordId : component.get("v.recordId")
    });
    
    action.setCallback(this, function(a) {
        if (a.getState() === "SUCCESS") {
            //  console.log("Loaded Chart Data");
            // console.log("Field Name " + fieldName);
            
            helper.renderData(component, helper, a.getReturnValue());
        } else if (a.getState() === "ERROR") {
            console.error("Loading Chart Data Failed! ");
            //console.log(a.getError());
            $A.log("Errors", a.getError());
            helper.displayToast(component, "error", "Loading Chart Data Failed! " + a.getError());
        }
    });
    
    $A.enqueueAction(action);
}, 
        getSelectedField : function(component, helper) {
            var selectItem = document.getElementById("selectField");
            var fieldName = selectItem.options[selectItem.selectedIndex].value;
            
            var fieldList = component.get("v.objectDefs");
            var defaultField = '';
            
            
            for(var i =0; i<fieldList.length; i++ ) {
                
                if(fieldList[i].Label == fieldName) {
                    defaultField = fieldList[i].DeveloperName;
                }
            }
            
            return defaultField;
            
    },
            
   setFieldLabel : function(component, event, helper) {
                //console.log("Set label fields");
                let fieldNamesToLabelsMap  = component.get("v.fieldNamesToLabelsMap")
                let selectedField  = component.get("v.selectedField")
                if(selectedField){
                    let selectedFieldLabel = fieldNamesToLabelsMap[selectedField]
                    component.set("v.selectedFieldLabel", selectedFieldLabel)
                }
     },
                
    fireApex : function(args, ApexFunctionName, params, option ){
                    // console.log("Fire APEX");
                    let [component, event, helper] = args;
                    
                    let action = component.get(ApexFunctionName);
                    action.setParams(params);
                    
                    action.setCallback(this, function(a) {
                        if(a.getState() === 'ERROR'){
                            console.error("There was an error:");
                            console.error(a.getError());
                        } else if (a.getState() === 'SUCCESS'){
                            // console.log("Fire APEX Success");
                            if(typeof option === "string"){
                                component.set(option, a.getReturnValue());
                            }else{
                                option(a.getReturnValue());
                            }
                            console.log(a.getReturnValue())	;
                        }
                        
                    });
                    //  console.log("Send Acount");
                    $A.enqueueAction(action);
    },
        
   displayToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    }

})