({
	onSelectChange : function(component, event, helper) {
        var selected = component.find("payment").get("v.value");
        component.set("v.PaymentType",selected);
        console.log("selected: " + component.get("v.PaymentType"));
    },
    handleNavigate: function(cmp, event) {
       var navigate = cmp.get("v.navigateFlow");
       navigate(event.getParam("action"));
    }
})