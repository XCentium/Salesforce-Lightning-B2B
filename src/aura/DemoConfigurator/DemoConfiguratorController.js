({
    init: function(component, event, helper){
        /*
    	var callout = component.get("c.ReadObjectDetection");
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.ObjDetEnabled",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout); */
	},
    GoToHome : function(component, event, helper) {
        var cmpTarget = component.find('finishedPage');
        $A.util.removeClass(cmpTarget, 'show');
        $A.util.addClass(cmpTarget, 'hide');
        
        var cmpTarget2 = component.find('chooseyouroptions');
        $A.util.removeClass(cmpTarget2, 'hide');
        $A.util.addClass(cmpTarget2, 'show'); 
    },
  	GoToFinish : function(component, event, helper) {
        var cmpTarget2 = component.find('chooseyouroptions');
        $A.util.removeClass(cmpTarget2, 'show');
        $A.util.addClass(cmpTarget2, 'hide'); 
        
        var cmpTarget3 = component.find('finishedPage');
        $A.util.removeClass(cmpTarget3, 'hide');
        $A.util.addClass(cmpTarget3, 'show'); 
    },
    GoToQHome : function(component, event, helper) {
        window.open('/lightning/n/qbranch__Q_Home_Lightning','_top')
    },
    GoToDemoContent : function(component, event, helper) {
        window.open('/lightning/n/Getting_to_know_the_IDO','_top')
    },
    SpinnerCheck : function(component, event, helper) {
        var spinnerSetting = component.get("v.SpinnerOnOff");
        console.log('Spinner setting: ' + spinnerSetting);
        if(spinnerSetting == true){
            helper.showSpinner(component);
        }else{
			helper.hideSpinner(component);
        }
    },
    ObjSet : function(component, event, helper) {
        component.set("v.ObjDetEnabled",true)
    }
})