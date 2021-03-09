({
    isConsoleNavigation : function (component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            component.set('v.isConsoleApplication', response);
            console.log(response);
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    automaticFold : function (component, event, helper, parentRecordId) {
        /*Automatic fold left part is parent tab is LiveChatTranscript */
        if (parentRecordId.substr(0, 3) == '570') {
            component.set('v.isLeftOpen', false);
            component.set('v.messagingSubTab', true);
        }
        /*Automatic fold left part is parent tab is MessagingSession */
        if (parentRecordId.substr(0, 3) == '0Mw') {
            component.set('v.isLeftOpen', false);
            component.set('v.messagingSubTab', true);
        }
    },
    
    isSubtab : function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(response) {
            //window.alert('getEnclosingTabId = ' + response);
            workspaceAPI.getTabInfo({tabId: response}).then(function(response) {
                var subtTabId = response.tabId;
                var parentTabId = response.parentTabId;
                //window.alert('subtTabId = ' + subtTabId + ', parentTabId = ' + parentTabId);
                workspaceAPI.isSubtab({
                    tabId: subtTabId
                }).then(function(response) {
                    component.set('v.isSubTab', response);
                    if (component.get('v.automaticFold')) {
                        workspaceAPI.getTabInfo({tabId: parentTabId}).then(function(response) {
                            helper.automaticFold(component, event, helper, response.recordId);
                        });
                    }
                    $A.get('e.force:refreshView').fire(); 
                });
            }); 
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    addListeners : function (component){
        var cmpLeft = component.find("Left");
        var cmpRight = component.find("Right");
        
        window.addEventListener("keydown", function(event) {
            if (event.shiftKey && event.key == 'ArrowLeft') {
                var newState = !component.get('v.isLeftOpen');
                component.set('v.isLeftOpen', newState);
            }
            if (event.shiftKey && event.key == 'ArrowRight') {
                var newState = !component.get('v.isRightOpen');
                component.set('v.isRightOpen', newState);
            }
        }, true);
    }
})