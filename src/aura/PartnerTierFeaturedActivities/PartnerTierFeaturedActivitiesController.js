/**
 * Created by cxu on 27/06/2017.
 */
({
    doInit : function (cmp) {
        var action = cmp.get("c.getFeaturedActivityTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var activityTypes = response.getReturnValue();
                if (activityTypes != null) {
                    cmp.set("v.activityTypes", activityTypes);
                }
            }
            else if (state === "INCOMPLETE") {
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
    }
})