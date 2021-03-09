({
	updateProgress: function (cmp)
    {
        var action = cmp.get("c.updateProgress");
        action.setParams({ "currentProgress" : cmp.get("v.strProgress"), "speed" : cmp.get("v.numSpeed") });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) 
        {
            //alert('returned: ' + response.getReturnValue());
            var state = response.getState();
            if (state === "SUCCESS") {
                var theProgress = response.getReturnValue();
                cmp.set('v.strProgress', theProgress);
                if (theProgress >= 100)
                {
                    //Advance to next flow screen
                    var navigate = cmp.get("v.navigateFlow");
                    navigate("NEXT");
                }
                else
                {
                    this.updateProgress(cmp);
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})