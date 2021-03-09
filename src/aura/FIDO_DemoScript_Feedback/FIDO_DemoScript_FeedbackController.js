({
    doInit : function (component, event, helper) {
        var unlikeCardCmp = component.find("unlikeCard");
        $A.util.removeClass(unlikeCardCmp, "slds-show");
        $A.util.addClass(unlikeCardCmp, "slds-hide");
    },
    handleClick : function (component, event, helper) {
        helper.saveFeedBackJS(component, event);
    }
})