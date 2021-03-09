({
   onInit : function(component, event, helper) {
         component.set("v.showConfig", false);
   },
    onInitChart : function(component, event, helper) {
        
        //   console.log("Loading onInitChart  ...");
        
        var eventName =   component.get("v.eventName");
        if(eventName == null) {return;}
        if(!eventName.includes("__e")) {
            //  console.log("event name (" + eventName + ") does not include __e");
            helper.displayToast(component, "error", "event name (" + eventName + ")  should be the API name (including '__e')");
            return;
        }
        
        let xField = component.get("v.xField");
        let yField = component.get("v.yField");
        let rField = component.get("v.rField");
         let title = component.get("v.title");
        
         if(yField == null) {
             helper.displayToast(component, "warning", title + " Vertical Axis Field not set properly. Check chart configuration.");
            return;
        }
         
        if(xField == null) {
               helper.displayToast(component, "warning", title + " Horizontal Axis Field not set properly. Check chart configuration.");
            return;
        }
        
        if(rField == null) {
            helper.displayToast(component, "warning", title + " Bubble Size Field not set properly. Check chart configuration.");
            return;
        }

        
        helper.loadChart(component, event, helper);
        
       // helper.loadFieldsAndData(component, event, helper);
        
    },
    receivePayload : function(component, event, helper) {
              
            let title = component.get('v.title');
      //  console.log("Received payload " + title);
        
        
           let chartId  = component.get("v.chartId");
        let chart2 = component.get("v.chart");   
      
         if(chart2 == null) {
            console.error("update date error: chart not rendered " + title);
           helper.loadChart(component, event, helper);
            return;
        }
        
		//payload comes from supercomponent listener
        let payload  = component.get("v.payload");
      
        let selectedField  = component.get("v.selectedField");
        let xField = component.get("v.xField");
        let yField = component.get("v.yField");
        let rField = component.get("v.rField");
        
        
        // console.log(selectedField);
       
        let payloadAtY = payload[yField];
        let payloadAtX = payload[xField];
        let payloadAtR = payload[rField];
        
        
        if(payloadAtY == null) {
             helper.displayToast(component, "warning", title + " Vertical Axis Field not set properly. Check chart configuration.");
            return;
        }
         
        if(payloadAtX == null) {
               helper.displayToast(component, "warning", title + " Horizontal Axis Field not set properly. Check chart configuration.");
            return;
        }
        
        if(payloadAtR == null) {
            helper.displayToast(component, "warning", title + " Bubble Size Field not set properly. Check chart configuration.");
            return;
        }
                
         var newNotification = {
            x : payloadAtX,
            y : payloadAtY,
             r: payloadAtR
        };
       
        var color = component.get("v.color");
             
       chart2.data.datasets[0].backgroundColor.push(color);
 		
        chart2.data.datasets[0].data.push(newNotification);
        chart2.update();
      
    },
  setFieldLabel : function(component, event, helper) {	
    
        let selectedField  = component.get("v.selectedField");
        helper.setFieldLabel(...arguments);
     	helper.loadChart(component, event, helper);
      
      let eventDataList = component.get("v.eventDataList");
      var chart = window.myChart;
       for(var i=0; i<eventDataList.length; i++) {
             if(eventDataList[i][selectedField] != null) {
                var newNotification = {
                    x : eventDataList[i].CreatedDate,
                    y :eventDataList[i][selectedField]
                };
                 

           
        		chart.data.datasets[0].data.push(newNotification);
            }
        }
           chart.update();
    },
    loadChart : function(component, event, helper) {	
       //   console.log("Load Chart");
        let selectedFieldValue  = component.get("v.selectedFieldValue");
	 	helper.loadChart(component, event, helper);
   
    } 
    
})