({
	init : function(component, event, helper) {
        let accountId = component.get('v.recordId')
        
        helper.getAccount(component,accountId)
        .then(function(){
            return helper.getAddresses(component,accountId)
        })
	}
})