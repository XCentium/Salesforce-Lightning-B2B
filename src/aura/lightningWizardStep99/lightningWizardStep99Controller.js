({
	goToNextPage : function(cmp, event, helper) {
        var nextButtonAction = cmp.get("v.nextButtonAction");
        if (nextButtonAction != null) {
            //nextButtonAction();
			$A.enqueueAction(nextButtonAction);
        }
        helper.fireChangePageEvent('next');
	},
    goToPreviousPage : function(cmp, event, helper) {
        var previousButtonAction = cmp.get("v.previousButtonAction");
        if (previousButtonAction != null) {
            //nextButtonAction();
			$A.enqueueAction(previousButtonAction);
        }
        helper.fireChangePageEvent('previous');
	}
})