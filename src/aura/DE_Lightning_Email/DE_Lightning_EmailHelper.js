({
	UpdateEvent : function(component, evt, helper) {
			console.log("test111");
            component.set('v.saveDraft',false);
            var action = component.get("c.getEmailBody1");
            action.setParams({
                "templateId" : templateid,
                "contactId":contactid,
                "CaseId":caseid
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var res=response.getReturnValue();
                    console.log('Second Response: ',JSON.Stringify(response.getReturnValue().htmlBody));
                    component.set("v.TemplateBody",res.htmlBody);
                    component.set("v.mailDetails",res);
                    console.log(component.get("v.mailDetails").Subject);
                }else{
                    console.log("error")
                }
                
            });
            $A.enqueueAction(action);
	}
})