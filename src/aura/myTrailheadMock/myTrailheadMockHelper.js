({
	ToastNotification : function(Title,Message,Type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        	title : Title,
            message: Message,
            duration:' 5000',
            type: Type,
            mode: 'pester'
        });
        toastEvent.fire(); 
    },
})