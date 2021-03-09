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
    }
})