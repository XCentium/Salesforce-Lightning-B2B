({
    
    doInit : function(component, event, helper) {
        helper.addAppIcon(component);
        var screenNumber = component.get("v.currentScreen");

        helper.parseAttribute(component, 'screen'+screenNumber)
    },
    handleClick : function(component, event, helper) {
        var screenNumber = component.get("v.currentScreen");
        screen="screen"+screenNumber;
        helper.parseAttribute(component,screen);
        
        //elem.style.cssText = "color: blue; border: 1px solid black"
        
        
        
        
    }
})