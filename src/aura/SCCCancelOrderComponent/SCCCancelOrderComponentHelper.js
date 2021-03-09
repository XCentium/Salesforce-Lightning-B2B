// noinspection BadExpressionStatementJS
({
  	showPopupHelper: function(component, componentId, className){
        let modal = component.find(componentId);
        $A.util.removeClass(modal, className + 'hide');
        $A.util.addClass(modal, className + 'open');
    },
    hidePopupHelper: function(component, componentId, className){
        let modal = component.find(componentId);
        $A.util.addClass(modal, className+'hide');
        $A.util.removeClass(modal, className+'open');
        component.set("v.body", "");
    },
    toastToDisplay : function(type, message){
        let toast = $A.get("e.force:showToast");
        if (!$A.util.isUndefinedOrNull(toast)) {
            toast
            .setParams({"type":type,
                        "message":message})
            .fire();
        } else {
            alert(message);
        }
    }
});