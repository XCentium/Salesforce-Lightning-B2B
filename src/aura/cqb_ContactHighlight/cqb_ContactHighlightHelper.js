({
    viewRecord : function(recordId) {
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": recordId,
        });
        sObjectEvent.fire();
    },
    
    splitString : function(list){
        let arr = list.split(' ');
        let length = arr.length;
        if (length > 8) {
            return arr.slice(0, 8);
        }
        return arr;
    },
    
    checkResetBackground : function(component, backgroundURL, userVal){
        console.log(backgroundURL);
        console.log(userVal);
        if(!backgroundURL){
            console.log('it is undefined');
            component.set('v.backgroundImageURL', userVal);
        }
    }
})