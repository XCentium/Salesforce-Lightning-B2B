({
    onInit : function(component, event, helper) {
        if(!component.get("v.isDoneRendering")){
            helper.setCanvas(component);
            component.set("v.isDoneRendering", true);
        }
    },
    onScoreSet : function(component, event, helper){
        if(component.get("v.isDoneRendering") && !component.get("v.canvasLoaded")){
            helper.setCanvas(component);
        }
    }
})