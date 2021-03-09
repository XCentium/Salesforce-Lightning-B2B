({
    onInit : function(component, event, helper){
        var Users = component.get("v.LoginUserIds");
        if(Users != undefined){
        	helper.getUsers(component, event, helper);    
        }
        var commUsers = component.get("v.LoginUserSubIds");
        if(commUsers != undefined){
        	helper.getSubUsers(component, event, helper);    
        }
        
    },
    gotoURL : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/lightning/n/Get_to_Know_the_IDO"
        });
        urlEvent.fire();
    },
    focusNavigationItem : function(component, event, helper) {
        var navigationItemAPI = component.find("navigationItem");
        navigationItemAPI.focusNavigationItem().then(function(response) {
            console.log(response);
        })
        .catch(function(error) {
            console.log(error);
        });
    } 
})