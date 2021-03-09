({
    createloginButtons : function(component) {
        let LoginInfo = component.get('v.UserInfo');
        //If user is not a customer or partner user add internal login
        if(!LoginInfo.loginUser.hasOwnProperty('ContactId')){
            $A.createComponent(
                "c:LogMeInButton",
                {
                    "loginUserId": LoginInfo.loginUser.Id,
                    "orgId": LoginInfo.orgId,
                    "networkLabel": "Internal",
                    "networkId": null,
                    "isInternal": !LoginInfo.loginUser.hasOwnProperty('ContactId')
                },
                function(LoginButton, status, errorMessage){
                    if(status === "SUCCESS"){
                        var LoginButtons = component.get("v.LoginButtons");
                        LoginButtons.push(LoginButton);
                        component.set("v.LoginButtons", LoginButtons);
                    } else if (status === "INCOMPLETE") {
                        console.log("LogMeInHelper:createLoginButtons", "Incomplete - No response from server or client is offline.")
                        // Show offline error
                    } else if (status === "ERROR") {
                        console.log("LogMeInHelper:createLoginButtons", "Error: " + errorMessage);
                        // Show error message
                    }
                }
            );
        }
		if(LoginInfo.loginUser.hasOwnProperty('ContactId')){
            for(var i=0; i < LoginInfo.networks.length; i++){
                $A.createComponent(
                    "c:LogMeInButton", 
                    {
                        "loginUserId": LoginInfo.loginUser.Id,
                        "orgId": LoginInfo.orgId,
                        "networkLabel": LoginInfo.networks[i].Network.Name,
                        "networkId": LoginInfo.networks[i].NetworkId,
                        "isInternal": !LoginInfo.loginUser.hasOwnProperty('ContactId')
                    }, 
                    function(LoginButton, status, errorMessage){
                        if(status === "SUCCESS"){
                            var LoginButtons = component.get("v.LoginButtons");
                            LoginButtons.push(LoginButton);
                            component.set("v.LoginButtons", LoginButtons);
                        } else if (status === "INCOMPLETE") {
                            console.log("LogMeInHelper:createLoginButtons", "Incomplete - No response from server or client is offline.")
                            // Show offline error
                        } else if (status === "ERROR") {
                            console.log("LogMeInHelper:createLoginButtons", "Error: " + errorMessage);
                            // Show error message
                        }
                    } 
                );
            }
        }
    }
})