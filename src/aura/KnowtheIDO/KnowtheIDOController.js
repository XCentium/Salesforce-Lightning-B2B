({
    init : function(component, event, helper) {
        document.title = "Get to Know your Demo Org";
        var industry = component.get("v.Industry");
        if(industry != ''){
            helper.getSettings(component, event, helper);
        }
    },
})