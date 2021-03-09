({
    doInit: function(component, event, helper){
        var width = component.get("v.width");
        
        if (width == 'XLARGE' || width == 'LARGE') {
            component.set("v.size", 4);
        }else if(width == 'MEDIUM') {
            component.set("v.size", 4);
        }else if(width == 'SMALL') {
            component.set("v.size", 12);
        };
        console.log('width is: ' + width);
    },
    acceptAll : function(component, event, helper) {
        var compEvent = $A.get("e.c:acceptAllEvent");
        compEvent.setParams({
            "message": "accept"
        });

        compEvent.fire();        
        console.log("Accept All Fired");


		
	},
    rejectAll : function(component, event, helper) {
        var compEvent = $A.get("e.c:rejectAllEvent");
        compEvent.setParams({
            "message": "reject"
        });

        compEvent.fire();        
        console.log("Reject All Fired");


		
	},
    collapse : function(component) {
        var collapsed = component.get("v.collapsed");			
        if ( collapsed == true){
            component.set("v.collapsed", false);            
        }else{
            component.set("v.collapsed", true);
        };
    }
})