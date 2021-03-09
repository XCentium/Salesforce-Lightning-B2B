({
    
   onReceiveNotification : function(component, platformEvent) {
        
        var helper = this;
        
      //  console.log("Chart received IOT Data");
       // console.log(platformEvent.data);
 		/*var selectItem = document.getElementById("selectField");
        var fieldName = selectItem.options[selectItem.selectedIndex].value;
 		
        var fieldList =  component.get('v.objectDefs');
       // console.log(fieldList);
        var devName = '';
        for(var i=0; i<fieldList.length; i++) {
            if(fieldList[i].Label == fieldName) {
                devName = fieldList[i].DeveloperName; 
            }
        }
        */
       var deviceIdField = component.get("v.deviceId");
        var recordId = component.get("v.recordId");
       //console.log("deviceIdField " + deviceIdField);
       if(deviceIdField != null && deviceIdField.length > 0) {
           var itemId = platformEvent.data.payload[deviceIdField];
           console.log("Filtering data if event id does not match current record:" + itemId + " recordId " + recordId);
           if(itemId != recordId) {
               return;
           }
       }
       
       var devName = helper.getSelectedField(component, helper);
        devName = devName + "__c";
      
        var newNotification = {
            x : platformEvent.data.payload.CreatedDate,
            y : platformEvent.data.payload[devName]
        };
        
     
        if(window.myChart == null) {return};
        var chart = window.myChart;
        
    //  chart.data.labels.push(platformEvent.data.payload.CreatedDate);
       console.log("*******************")          
       console.log(newNotification)
       console.log("*******************")
        chart.data.datasets[0].data.push(newNotification);
        chart.update();
       
        
    },
    
    displayToast : function(component, type, message) {
        
      // console.log(message);
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
       let title = component.get('v.title');
       // console.log("Load chart " + title);
        
          if(component.get("v.jsLoaded") == false) {
            console.error("JS Not loaded - " + title);
            return;
        }
        
         let chartId  = component.get("v.chartId");
       // var canvas = document.getElementById("myChart");
        var canvas = document.getElementById(chartId);
        
        if(canvas == null) {
            console.error("IOT Chart Canvas Missing ");
            return;
        }
        
      
      
     // var chart = window.myChart;
     // let chart = document.getElementById(chartId); 
       
        let selectedFields = component.get("v.selectedFields");
        let selectedField = component.get("v.selectedField");
    
		for(var i=0; i<selectedFields.length; i++) {
                        if(selectedFields[i].fieldName == selectedField) {
                            component.set("v.selectedEventLabel", selectedFields[i].fieldLabel);
                 }
              }
           
        if(selectedField == null) {
            selectedField = 0;
        }
        
        let dataTitle = component.get("v.selectedEventLabel");
        var ctx =  canvas.getContext('2d');  
        var timeFormat = 'YYYY-MM-DD hh:mm:ss';
         let color = component.get("v.color");
	    var date = Date.now();
 		var labels = [];
        var data2 = [];

       let eventDataList = component.get("v.eventDataList");
        
       
        for(var i=0; i<eventDataList.length; i++) {
            
            let payload =eventDataList[i];
            let payloadAtField = payload[selectedField];
            let newNotification = {
                x : payload.CreatedDate,
                y : payloadAtField
        	}; 
            data2.push(newNotification);
        }
       //   
        var config = {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: dataTitle,
                    data: data2,   
                    type: 'line',
                    fill: true,
                backgroundColor: [color],
                    borderWidth: 2
                }]
            },
            options: {
                elements: {
					line: {
						tension: 0.001
					}
                },
                scales: {
                    xAxes: [{
                        type: 'time',
                        distribution: 'series',
                        ticks: {
                            source: 'labels'
                        }
                    }],
                    yAxes: [{
                        scaleLabel: {
                            display: true,
                            labelString: 'Value'
                        }
                    }]
                }
            }
        };
        
        
   
       // chart = new Chart(ctx, config); 
       
        var myChart  = new Chart(ctx, config); 
        component.set("v.chart", myChart);
        
       // window.myChart = new Chart(ctx, config);  
        
        //  config.update();
        
      },
     loadFieldsAndData : function(component, event, helper) {
       /* 
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
            */
         
     },
     loadFieldsAndData2 : function(component, event, helper) {
        
         var action2 = component.get("c.getEventFields");
		action2.setParams({
        	eventName : component.get("v.eventName")
    	});

    	action2.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
               // console.log("Loaded Event Object Fields");
              // console.log(a.getReturnValue());
                var fieldsNames = a.getReturnValue();
                component.set("v.objectDefs", fieldsNames);

			                
               var labelList = [];
                for(var i =0; i<fieldsNames.length; i++ ) {
                    labelList[i] = fieldsNames[i].Label;
                }
                 component.set("v.objectFields", labelList);
                if(fieldsNames.length > 0) {
                    var defaultField = fieldsNames[0].DeveloperName;
                 //   console.log("Default Field " + defaultField);
                    helper.getChartData(component, helper, defaultField);
                }
              
            } else if (a.getState() === "ERROR") {
                 console.log("Loading Event Object Fields Failed! ");
               //  console.log(a.getError());
                $A.log("Errors", a.getError());
                 helper.displayToast(component, "error", "Loading Event Object Fields Failed! " + a.getError());
            }
   		});

    	$A.enqueueAction(action2);
         
     },
    getChartData : function(component, helper, fieldName) {
        
       // console.log("Getting chart data for " + fieldName);
       // component.set("v.chartField", fieldName);  
        
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
                console.log("Loading Chart Data Failed! ");
                //console.log(a.getError());
                $A.log("Errors", a.getError());
                  helper.displayToast(component, "error", "Loading Chart Data Failed! " + a.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    renderData : function(component, helper, queryResult) {
        
      //  console.log("----------Rendering Data ------------");
     
       /*    var selectItem = document.getElementById("selectField");
          var fieldName = selectItem.options[selectItem.selectedIndex].value;
        
        fieldName = fieldName + "__c"; */
        
        var fieldName = helper.getSelectedField(component, helper);
         fieldName = fieldName + "__c";
       /* 
        console.log("-----Got Data -----");
        console.log(queryResult);
        console.log("For Field Name - " + fieldName);
          */
        
        if(window.myChart == null) {return};
         
      //  console.log(window.myChart);        
        var chart = window.myChart;

        for(var i=0; i<queryResult.length; i++) {
             if(queryResult[i][fieldName] != null) {
                var newNotification = {
                    x : queryResult[i].CreatedDate,
                    y :queryResult[i][fieldName]
                };
                 
              //  chart.data.labels.push(queryResult[i].CreatedDate);
           
        		chart.data.datasets[0].data.push(newNotification);
            }
        }
           chart.update();
        
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
                console.log("There was an error:");
                console.log(a.getError());
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
    }
    
})