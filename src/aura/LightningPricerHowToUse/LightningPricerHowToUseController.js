({
	doRender : function(component, event, helper) {
/*        var frame = component.find('UserGuideVideo');
        debugger;
        if (frame!=null)
        frame.getElement().setAttribute("allowfullscreen", "allowfullscreen");
*/  
	},
    
    doInit : function(component, event, helper) {
      helper.getOrgInfo(component);  
                
	}  
})