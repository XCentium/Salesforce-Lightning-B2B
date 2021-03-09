({
	getAppointments : function(component, event, helper) {
		var action = component.get("c.getUserAppointments");
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.allAppointments",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    OpenDialog: function(component, event, helper) {
        var cmpTarget = component.find('NewAppointmentModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    OpenAppointmentDialog: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        console.log(whichOne);
        component.set('v.SelectedAppointmentId',whichOne);
        
        var cmpTarget = component.find('ViewAppointmentModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog: function(component, event, helper) {
        var cmpTarget = component.find('NewAppointmentModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget = component.find('ViewAppointmentModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
    },
    onChange : function(component, event, helper){
        console.log('fired');
        var selected = evt.getSource().get("v.value");
        console.log('changed value: ' + selected);
    },
    handleSuccess : function(component, event, helper) {        
        var action = component.get("c.getUserAppointments");
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.allAppointments",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
       var cmpTarget = component.find('NewAppointmentModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget = component.find('ViewAppointmentModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
    },
    handleSubmit : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(JSON.stringify(payload));
    },
    AppointmentCheckIn : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        var action = component.get("c.CheckInAppointment");
            action.setParams({
                AppointmentId : whichOne
            });
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.allAppointments",response.getReturnValue());
                }else{
                    console.log("ERROR");
                }
            });
            $A.enqueueAction(action);

        let cont = component.get('c.getAppointmentContacted');
        cont.setParams({
        	AppointmentContact : whichOne
        });
        cont.setCallback(this,function(res){
            component.set('v.SelectedContact',res.getReturnValue());
			component.set("v.PageName","Customers");
        });
        $A.enqueueAction(cont);  
    },
    AppointmentCheckOut : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        var action = component.get("c.CheckOutAppointment");
            action.setParams({
                AppointmentId : whichOne
            });
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.allAppointments",response.getReturnValue());
                    component.set('v.SelectedContact','');
                }else{
                    console.log("ERROR");
                }
            });
            $A.enqueueAction(action);
    }
})