({
    createUsers : function(component, loginUsers) {
        for(var i=0; i < loginUsers.length; i++){
            $A.createComponent(
                "c:LogMeInUser", 
                { "UserInfo": loginUsers[i] }, 
                function(LoginUser, status, errorMessage){
                    if(status === "SUCCESS"){
                        var LoginUsers = component.get("v.LoginUsers");
                        LoginUsers.push(LoginUser);
                        component.set("v.LoginUsers", LoginUsers);
                    } else if (status === "INCOMPLETE") {
                        console.log("LogMeInHelper:createUsers", "Incomplete - No response from server or client is offline.")
                    } else if (status === "ERROR") {
                        console.log("LogMeInHelper:createUsers", "Error: " + errorMessage);
                    }
                }
            );
        }
    },
    createSubUsers : function(component, loginUsers) {
        for(var i=0; i < loginUsers.length; i++){
            console.log('User Information: ' +  JSON.stringify(loginUsers[i]));
            $A.createComponent(
                "c:LogMeInUser", 
                { "UserInfo": loginUsers[i] }, 
                function(LoginUser, status, errorMessage){
                    if(status === "SUCCESS"){
                        var LoginUsers = component.get("v.LoginSubUsers");
                        LoginUsers.push(LoginUser);
                        component.set("v.LoginSubUsers", LoginUsers);
                    } else if (status === "INCOMPLETE") {
                        console.log("LogMeInHelper:createUsers", "Incomplete - No response from server or client is offline.")
                    } else if (status === "ERROR") {
                        console.log("LogMeInHelper:createUsers", "Error: " + errorMessage);
                    }
                }
            );
        }
    },
    getUsers : function(component, event, helper) {
        let action = component.get('c.getLogins');
        
        let externalIds = component.get('v.LoginUserIds');

        if(externalIds != undefined){
            externalIds = externalIds.split(',');
            for(let i = 0; i < externalIds.length; i++){
                externalIds[i] = externalIds[i].trim();
            }
            externalIds = JSON.stringify(externalIds);
        }
        console.log('LogMeInController:onInit:externalIds', externalIds);
        
        action.setParams({
            sExternalIds: externalIds != undefined ? externalIds : '[]'
        });
        
        action.setCallback(this, function(res){
            let state = res.getState();
            let retVal = res.getReturnValue();
            
            if(state === 'SUCCESS'){
                console.log('LogMeInController:onInit:success', retVal);
                helper.createUsers(component, retVal);
            }
            else {
                console.log('LogMeIn:onInit:error', res.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    getSubUsers : function(component, event, helper) {
        let action = component.get('c.getLogins');
        let externalIds = component.get('v.LoginUserSubIds');
        console.log('COMMUNITY External IDs: ' +  externalIds);
        if(externalIds != undefined){
            externalIds = externalIds.split(',');
            for(let i = 0; i < externalIds.length; i++){
                externalIds[i] = externalIds[i].trim();
            }
            externalIds = JSON.stringify(externalIds);
        }
        console.log('LogMeInController:onInit:externalIds', externalIds);
        
        action.setParams({
            sExternalIds: externalIds != undefined ? externalIds : '[]'
        });
        
        action.setCallback(this, function(res){
            let state = res.getState();
            let retVal = res.getReturnValue();
            console.log("Users: " + retVal);
            if(state === 'SUCCESS'){
                console.log('LogMeInController:onInit:success', retVal);
                helper.createSubUsers(component, retVal);
            }
            else {
                console.log('LogMeIn:onInit:error', res.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
})