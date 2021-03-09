({
	handleTouchMove : function(component, event, helper) {
		event.stopPropagation();
	},
    doInit : function(cmp,event,helper){
        
    },
    accountIdChanged: function(cmp,event,helper){
       var accountId = cmp.get('v.accountId');
       if (!accountId || accountId =='') cmp.set('v.currentStep',1);
       else cmp.set('v.currentStep',2); 
    },
    newOppClick: function(cmp,event,helper) {
      helper.createRec(cmp,'Opportunity');
      cmp.set('v.currentStep',3);  
    },
    newOrderClick: function(cmp,event,helper) {
      helper.createRec(cmp,'Order');
      cmp.set('v.currentStep',3);  
    }
})