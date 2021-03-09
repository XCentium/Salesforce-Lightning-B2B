({
    doInit : function(component, event, helper) {	
        
        var TemplateName = component.get("v.TemplateName");
        
        var callout = component.get("c.getTemplates");
        callout.setParams({
            FolderName: TemplateName
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            console.log("Test " + state );
            if(state === 'SUCCESS'){
                var res=response.getReturnValue();
                component.set("v.templates",res);
            }
        });
		$A.enqueueAction(callout); 
    },
    createFD:function(component, event, helper) {
        var TemplateName=component.get("v.TemplateName");
        var caseid=component.get("v.caseid");
        console.log('TemplateName',TemplateName);
        console.log('caseid',caseid);
        var html=component.get("v.TemplateBody");
        var toaddress=component.get("v.toAddress");
        var templateId=component.get("v.templateId");
        var mailDetails=component.get("v.mailDetails");
        var sub=mailDetails.Subject;
        console.log('sub',sub)
        var action=component.get("c.UpdateText");
        action.setParams({"emailBody" : html,"templateName":TemplateName,"caseid":caseid,"templateId":templateId});
        action.setCallback(this, function(response) {
            console.log('came createdRD');
            var res=response.getReturnValue();
            console.log('res',response.getReturnValue());
            component.set("v.responseDetail",res);
            if(res!=null){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Your draft has been saved attached to the case",
                    "type":"success"
                });
                toastEvent.fire();
                component.set("v.toggleDisable",false);
            }
        });
        $A.enqueueAction(action);
        
        
    },
    onChange: function (component, evt, helper) {
        
        var templateid = component.find('select').get('v.value');
        var caseid=component.get("v.caseid");
        var contactid = component.get("v.contactid");
        
        component.set("v.templateId",templateid);
        
        if(component.get("v.templateId") !=''){
            component.set('v.saveDraft',false);
        var action = component.get("c.getEmailBody1");
        action.setParams({
            templateId : templateid,
            contactId:contactid,
            CaseId:caseid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var response = response.getReturnValue();
                component.set("v.TemplateBody",response.htmlBody);
                component.set("v.mailDetails",response);                
               
            }else{
                console.log("error");
            }
            
        });
        $A.enqueueAction(action);
        }
        else{
            component.set('v.saveDraft',true);
            component.set("v.TemplateBody","Please select a letter template");
        }
    },
    displayFC: function (component, evt, helper) {
        
        console.log(component.get("v.myCheckbox")); 
    },
    handleSubmit: function (component, evt, helper) {
        
    },
    handleSuccess:function (component, evt, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Coupon updated",
            "type":"success"
        });
        toastEvent.fire();
    }
})