({
	getSchedule : function(component, event, helper) {
		var action = component.get("c.getUserShifts");
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.allShifts",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    Checkin : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        var status = component.get('v.checkinStatus');
        
        if (status == 'Check In'){
            console.log("::Check in fired::");
            var action = component.get("c.CheckIntoShift");
            action.setParams({
                ShiftId : whichOne
            });
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.allShifts",response.getReturnValue());
                    console.log("Successfully updated Check in");
                }else{
                    console.log("ERROR");
                }
            });
            $A.enqueueAction(action);
            
            component.set('v.checkinStatus','Check Out');
            component.set('v.checkinButtonClass','slds-button_success');
            status = 'Check Out';
            var d = new Date();
        	component.set('v.CheckinTime', 'Checked in at: ' + d.getHours() + ':' + d.getMinutes());
        }else{
            console.log("::Check out fired::");
            console.log("ID:" + whichOne);
            var action = component.get("c.CheckOutShift");
            action.setParams({
                ShiftId : whichOne
            });
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.allShifts",response.getReturnValue());
                    console.log("Successfully updated Check out");
                }else{
                    console.log("ERROR");
                }
            });
            $A.enqueueAction(action);
            component.set('v.checkinStatus','Check In');
            component.set('v.checkinButtonClass','slds-button_brand');
            status = 'Check In';
            var d = new Date();
        	component.set('v.CheckoutTime', 'Checked out at: ' + d.getHours() + ':' + d.getMinutes());
        }
    }
})