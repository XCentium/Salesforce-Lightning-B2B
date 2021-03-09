({
    setTabLabels : function(component, event, helper, vc) {
        var workspaceAPI = component.find("workspace");
        var custName = component.find("v.custName");
        console.log('Setting tab label with name ' + vc.Contact_Name__c);
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                //icon: "standard:call",
                label: vc.Contact_Name__c
            });
           
        })        
    },
   
    openSubTabs : function(component, event, helper, vc) {
        var workspaceAPI = component.find("workspace");
        console.log('Opening Subtabs with IDs ' + vc.ContactId + vc.CaseId);
        if (vc.ContactId != null){
            console.log('Opening Contact with ID ' + vc.ContactId);
            workspaceAPI.openSubtab({
                url: '/lightning/r/Contact/' + vc.ContactId + '/view',
                focus: false
            })
            .catch(function(error) {
                console.log(error);
            });  
        }
        if (vc.CaseId != null){
            console.log('Opening Case with Id ' + vc.CaseId);
            workspaceAPI.openSubtab({
                url: '/lightning/r/Case/' + vc.CaseId + '/view',
                focus: false
            })
            .catch(function(error) {
                console.log(error);
            });  
        }
    }
})