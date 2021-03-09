({
    
        
    loadChart : function(component, event, helper) {
  
       let selectedFieldValue  = component.get("v.selectedFieldValue");
   
     //   let selectedFieldLabel  = component.get("v.selectedFieldLabel");
        
        
        let chart  = component.get("v.chart");
        
        if(chart == null) {
            helper.buildChart(component, event, helper);
            return;
        }
    
        chart.load({  columns: [['data', selectedFieldValue]]}); 
       
    },
    
    receivePayload : function(component, event, helper) {
      
        
		//payload comes from supercomponent listener
        let payload  = component.get("v.payload");
      
        let selectedField  = component.get("v.selectedField");
        // console.log(selectedField);
        let payloadAtField = payload[selectedField];
       // console.log( payload[selectedField]);
        let selectedFieldValue = +(payload[selectedField]).toFixed(2);
     //  console.log( selectedFieldValue);
        if(selectedFieldValue != undefined){
            component.set("v.selectedFieldValue", selectedFieldValue);
        }
   
       
    },
    
    scriptsLoaded : function(component, event, helper) {
       helper.buildChart(component, event, helper);
    },

    updateSelectedFields : function(component, event, helper) {
		let eventName = event.getSource().get("v.value");
        let  eventNameFieldsMap = component.get("v.eventNameFieldsMap");
        let selectedFields = eventNameFieldsMap[eventName];
        component.set("v.selectedFields", selectedFields);
        
    },
        
    setFieldLabel : function(component, event, helper) {		
        let selectedField  = component.get("v.selectedField");
        helper.setFieldLabel(...arguments);
    },
        
    toggleOptions : function(component, event, helper) {		
		helper.toggleClass(arguments,  "options-container", "hidden");
        
        let optionsLabel  = component.get("v.optionsLabel");
        
        optionsLabel = optionsLabel === "Show Options" ? "Hide Options" : "Show Options";
        
        component.set("v.optionsLabel", optionsLabel);
        
    },        
            
})