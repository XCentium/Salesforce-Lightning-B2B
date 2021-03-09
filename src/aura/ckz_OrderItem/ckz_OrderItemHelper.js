({
	waiting: function(component) {
        component.set("v.showSpinner", true);
    },
    doneWaiting: function(component) {
        component.set("v.showSpinner", false);
    },
})