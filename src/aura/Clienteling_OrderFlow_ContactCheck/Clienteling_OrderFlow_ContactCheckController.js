({
	handleNavigate: function(cmp, event) {
       var navigate = cmp.get("v.navigateFlow");
       navigate(event.getParam("action"));
    }
})