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
    HandleEventFiring : function(component, event, helper,whichone) { 
        if(whichone == 'Required_Setup_Settings'){
            component.set("v.SpinnerOnOff",true);
            helper.RequiredSetup(component, event, helper);	
        }else if(whichone == 'CG_Cloud_-_Generate_Datasets'){
            component.set("v.SpinnerOnOff",true);
            helper.CGCloudDatasets(component, event, helper);
        }else if( whichone == 'Contact_Phone_/_Email_Settings'){
            helper.OpenDialog(component, event, helper);
        }else if(whichone == 'Update_IoT_Contact_Information'){
            component.set("v.SpinnerOnOff",true);
            helper.OpenIoTDialog(component, event, helper);
            component.set("v.SpinnerOnOff",false);
        }else if(whichone == 'Field_Service_Lightning_Data'){
            component.set("v.SpinnerOnOff",true);
            helper.OpenFSLDialog(component, event, helper);
        }else{
            helper.ToastNotification('No Method Found', 'Have you setup your methods?', 'error');
        }
    },
    /** 1. Run Required Setup **/
    RequiredSetup  : function(component, event, helper,whichone) { 
        console.log("test");
        helper.UpdateWaveURL(component, event, helper);
        helper.StartDataFlow(component, event, helper);
        helper.CreateRSIframe(component, event, helper);
        helper.UpdateCloudCrazeSettings(component, event, helper);
    },
	/** 2. Update and Create Einstein Vision Datasets **/
    CGCloudDatasets  : function(component, event, helper,whichone) { 
       /* Update Existing First */
       var action = component.get("c.ClearDataSets");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                 /* Then Create New Datasets */
                var action = component.get("c.CreateDatasets");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        helper.ToastNotification('Success!', 'Successfully Updated/Created the required Datasets.', 'success');
                        component.set("v.SpinnerOnOff",false);
                        helper.UpdateEnabledField(component, event, helper, component.get("v.whichone"));
                    }else{
                        helper.ToastNotification('Failed', 'Please Report this to your IDO Owner.', 'error');
                        component.set("v.SpinnerOnOff",false);
                    }
                });
                $A.enqueueAction(action);
            }
        });
		$A.enqueueAction(action);
    },
    /** Update Demo Setting to enabled **/
    UpdateEnabledField  : function(component, event, helper,whichone) { 
       var action = component.get("c.UpdateDemoSetting");
        action.setParams({
            WhichSetting: whichone,
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.DemoSettings",response.getReturnValue());
            }
        });
		$A.enqueueAction(action);
    },
    UpdateRachelMorrisPhone : function(component, event, helper) {
        var phone = component.get("v.mobilephone");
        var persona = component.get("v.Persona");
        var email = component.get("v.LVEmail");
		var action = component.get("c.UpdateRMorrisPhone");
        
        action.setParams({
            PhoneNumber: phone,
            Persona: persona,
            Email: email
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.SpinnerOnOff",false);
            	helper.ToastNotification('Success', 'Successfully Updated Records', 'success');
            	helper.UpdateEnabledField(component, event, helper, component.get("v.whichone"));
            }else{
                component.set("v.SpinnerOnOff",false);
                helper.ToastNotification('Persona Phone Update Failed', 'Failed to update the Phone Number', 'error');
            }
        });
		$A.enqueueAction(action);
    },
    CreateStoreVisit : function(component, event, helper) {
		var action = component.get("c.CreateStoreVisitRecord");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                helper.UpdateEnabledField(component, event, helper, component.get("v.whichone"));
            	component.set("v.SpinnerOnOff",false);
                helper.ToastNotification('Success', 'Ran Required Setup Successfully', 'success');
            }else{
                component.set("v.SpinnerOnOff",false);
                helper.ToastNotification('Store Visit Record Creation Failed', 'Failed to create a store visit record', 'error');
            }
        });
		$A.enqueueAction(action);
    },
    StartDataFlow : function(component, event, helper){ 
        window.setTimeout(
            $A.getCallback(function() {
                var iframe = document.createElement('iframe');
                var base = component.get("v.BaseURL");
                iframe.src = base + '/apex/DemoSetupWaveAcc';
                document.getElementById('iframe_dataflow').appendChild(iframe);
        	}), 500
        );
    },
    UpdateWaveURL : function(component, event, helper){
        window.setTimeout(
            $A.getCallback(function() {
                var iframe = document.createElement('iframe');
                var base = component.get("v.BaseURL");
                iframe.src = base + '/apex/DemoSetupUpdateWaveURL';
        	}), 500
        );
    },
    UpdateCloudCrazeSettings : function(component, event, helper) {
        console.log("i am called");
        var action = component.get("c.UpdateCCStoreFront");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.SpinnerOnOff",false);
                helper.UpdateEnabledField(component, event, helper, component.get("v.whichone"));
            }else{
                helper.ToastNotification('CloudCraze Settings update Failed', 'Failed to update settings', 'error');
                component.set("v.SpinnerOnOff",false);
            }
        });
		$A.enqueueAction(action);
    },
    UpdateOliviaBuyerRecordType : function(component, event, helper) {
		var action = component.get("c.updateOliviaBuyer");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            }else{
                helper.ToastNotification('Olivia Buyer Update Failed', 'Failed to update settings', 'error');
            }
        });
		$A.enqueueAction(action);
    },
    UpdateIoTOrchestration : function(component, event, helper) {
		var action = component.get("c.UpdatedIoTSettings");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            }else{
                helper.ToastNotification('IoT Settings update Failed', 'Failed to update settings', 'error');
            }
        });
		$A.enqueueAction(action);
    },
    UpdateIoTCoolerURL : function(component, event, helper) {
		var action = component.get("c.UpdatedIoTAssetInventorySettings");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.ToastMessage",'Updated IoT Cooler Community URL.')
            }else{
                helper.ToastNotification('IoT Alpine Cooler URL update Failed', 'Failed to update settings', 'error');
            }
        });
		$A.enqueueAction(action);
    },
    CreateRSIframe : function(component, event, helper){ 
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.ToastMessage",'Created Remote Site Settings.')
                var iframe = document.createElement('iframe');
                var base = component.get("v.BaseURL");
                iframe.src = base + '/apex/DemoSetup';
                document.getElementById('iframe_parent').appendChild(iframe);
        	}), 500
        );
    },
    OpenDialog: function(component, event, helper) {
        var cmpTarget = component.find('InputPhoneNumber');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    OpenFSLDialog: function(component, event, helper) {
        var cmpTarget = component.find('FSLModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    
    OpenIoTDialog: function(component, event, helper) {
        var cmpTarget = component.find('IoTModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },  
    OpenStoreVisitDialog: function(component, event, helper) {
        var cmpTarget = component.find('VisitModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },  
})