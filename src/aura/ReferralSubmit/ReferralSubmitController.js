({
	saveIt : function(component) {
        let ref = component.get("v.refer");

        //the real action we want to take
        if (ref.First_Name__c){

            console.log("component id is " + component.get("v.recordId"));
            //set the job
            ref.Job__c = component.get("v.recordId");

            console.log(ref);
            //ok, now save it
            let action = component.get("c.saveRef");
            action.setParams({
                "serializedRef" : JSON.stringify(ref)
            })

            action.setCallback(this, function (a){
                let state = a.getState();
                if (state === "SUCCESS") {
                    console.log("all good");
                    console.log(a.getReturnValue());
                    //$A.get('e.force:refreshView').fire();
                    //$A.get("e.force:closeQuickAction").fire();
                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId" : a.getReturnValue().Id
                    });
                    navEvt.fire();

                } else if (state === "ERROR") {
                    console.log("error:");
                    console.log(a.getError());
                    /*let appEvent = $A.get("e.c:handleCallbackError");
                    appEvent.setParams({
                        "errors" : a.getError()
                    });
                    appEvent.fire();*/
                }
            });

            $A.enqueueAction(action);
        } else {
          //there's no data yet...let's populate it.
          ref.First_Name__c = 'Bo';
          ref.Last_Name__c = 'Mangels';
          ref.Phone__c = '415 555 5555';
          ref.Email__c = 'bo.mangels@gmail.com';
          component.set("v.refer", ref);
        }
	}
})