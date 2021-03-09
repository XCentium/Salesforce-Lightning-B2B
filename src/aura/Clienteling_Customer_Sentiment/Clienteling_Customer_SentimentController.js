({
	init : function(component, event, helper) {
        console.log('Contact ID: ' + component.get("v.ContactID"));
        var action = component.get("c.getContactOrders");
        action.setParams({
            ContactId : component.get("v.ContactID"),
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Orders",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        var OverallSentimentAction = component.get("c.SentimentScore");
        OverallSentimentAction.setParams({
            ContactId : component.get("v.ContactID"),
        });
		OverallSentimentAction.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Score",response.getReturnValue());
            }
        });
        $A.enqueueAction(OverallSentimentAction);
        
        /* Get Order Sentiment Score */
        var OrderSentimentAction = component.get("c.OrderSentimentScore");
        OrderSentimentAction.setParams({
            ContactId : component.get("v.ContactID"),
        });
		OrderSentimentAction.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.OrderScore",response.getReturnValue());
            }
        });
        $A.enqueueAction(OrderSentimentAction);
        
        /* Get Case Sentiment Score */
        var CaseSentimentAction = component.get("c.CaseSentimentScore");
        CaseSentimentAction.setParams({
            ContactId : component.get("v.ContactID"),
        });
		CaseSentimentAction.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.CaseScore",response.getReturnValue());
            }
        });
        $A.enqueueAction(CaseSentimentAction);
        
        /* Get All Cases by Contact */
        var CaseSentimentAction = component.get("c.getContactCases");
        CaseSentimentAction.setParams({
            ContactId : component.get("v.ContactID"),
        });
		CaseSentimentAction.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Cases",response.getReturnValue());
            }
        });
        $A.enqueueAction(CaseSentimentAction);
        
	},
})