({
    init : function(component, event, helper) {
        var action = component.get("c.GetSettings");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.DemoSettings",response.getReturnValue());
            }
        });
		$A.enqueueAction(action);
        
        var Start = component.get('c.BaseURL');
        $A.enqueueAction(Start);
	}, 
    onSingleSelectChange: function(component, event, helper) {
         var selectCmp = component.find("InputSelectSingle");
         var resultCmp = component.find("singleResult");
         component.set("v.Persona", selectCmp.get("v.value"));
         console.log("Persona is: " + component.get("v.Persona"));
	 },
    BaseURL : function(component, event, helper) {
        var action = component.get("c.getBaseURL");
		action.setCallback(this, function(response) {
			var SessionId= response.getReturnValue();
        	component.set("v.BaseURL", SessionId);
            var sid = component.get("v.BaseURL");
        });
		$A.enqueueAction(action);
    }, 
    checkValidity : function(component, event, helper) {
        var validity = event.getSource().get("v.validity");
    },
    toggleChange : function(component, event, helper) {
        var changedOne;
        if(event.currentTarget.id == null){
            changedOne = event.getSource().get("v.name");
        }else{
            changedOne = event.currentTarget.id;
        }
               
        component.set("v.whichone",changedOne);
        /* Now that we know which was changed, call the helper function to handle the setup steps */
        helper.HandleEventFiring(component, event, helper, changedOne);
    },
    CloseDialog: function(component, event, helper) {
        var whichone = component.get("v.whichone");
        var phonenum = component.get("v.mobilephone");
        /** If Phone Number has been input by user */
        if(phonenum != ''){
            helper.UpdateRachelMorrisPhone(component, event, helper);
            var cmpTarget = component.find('InputPhoneNumber');
            $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
            var cmpTarget2 = component.find('overlay');
            $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
            $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
        }else{
            component.set("v.SpinnerOnOff",false);
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Please Input a Phone Number',
                    message: 'Please input your mobile phone number to proceed.',
                    duration:' 5000',
                    type: 'error',
                    mode: 'pester'
                });
            toastEvent.fire();
        }
    },
    CloseFSLDialog  : function(component, event, helper) {
        component.set("v.SpinnerOnOff",true);
        var whichone = component.get("v.whichone");
        var phonenum = component.get("v.FSLDate");
        var dt = new Date(phonenum);
        
        var month = parseInt(dt.getMonth() + 1);
        var day = parseInt(dt.getDate() + 1);
        var year = parseInt(dt.getFullYear ());
        
        /*console.log("Month: " + month + " | Day: " + day + " | Year: " + year); */
        if(month != '' && day != '' && year != ''){
            var action = component.get("c.RestoreData");
            action.setParams({
                year: year,
                month: month,
                day: day
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
            		component.set("v.SpinnerOnOff",false);
                    helper.ToastNotification('Updated FSL Demo Dates', 'Successfully updated FSL dates to your chosen date. Please allow 10 minutes for data to populate.', 'success');
                    helper.UpdateEnabledField(component, event, helper, component.get("v.whichone"));
                    
                } else if (response.getState() === "ERROR") {
                    component.set("v.SpinnerOnOff",false);
                    helper.ToastNotification('Error Updating FSL Dates', 'Could not update FSL dates successfully.', 'error');
                }
            });
        
            $A.enqueueAction(action);
       	    var cmpTarget = component.find('FSLModal');
            $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
                    
            var cmpTarget2 = component.find('overlay');
            $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
            $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');     
        }
    },
    CloseIoTDialog: function(component, event, helper) {
        component.set("v.SpinnerOnOff",true);
        var whichone = component.get("v.whichone");
        var iotEmail = component.get("v.iotEmail");
        console.log("Email: " + iotEmail);
        /** If Phone Number has been input by user */
        if(iotEmail != ''){
            var action = component.get("c.UpdateTyreeEmail");
            action.setParams({
                Email: iotEmail,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.SpinnerOnOff",false);
                    helper.ToastNotification('Updated IoT Cooler Community URL', 'The Community URL For Staged B2B Cart has been updated..', 'success');
                    helper.UpdateIoTCoolerURL(component, event, helper);
                    helper.UpdateEnabledField(component, event, helper, component.get("v.whichone"));
                }else{
                    component.set("v.SpinnerOnOff",false);
                    helper.ToastNotification('IoT Alpine Cooler URL update Failed', 'Failed to update settings', 'error');
                }
            });
            $A.enqueueAction(action);
            
            var cmpTarget = component.find('IoTModal');
            $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
            var cmpTarget2 = component.find('overlay');
            $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
            $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
        }else{
            component.set("v.SpinnerOnOff",false);
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Please Input a valid Email Address',
                    message: 'Please input your work email address to proceed.',
                    duration:' 5000',
                    type: 'error',
                    mode: 'pester'
                });
            toastEvent.fire();
        }
    },
    CloseStoreVisitDialog: function(component, event, helper) {
    	var cmpTarget = component.find('VisitModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
})