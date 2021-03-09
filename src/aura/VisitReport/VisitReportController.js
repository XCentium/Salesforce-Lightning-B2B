({
    init: function (component, event, helper) {
        console.log("form factor- "+ component.get("v.reportTab") +" -- "+ component.get("v.recordId"));
        var formFactor = component.get("v.reportTab");
        var storeId = component.get("v.recordId");
        
        var now = new Date();
        var today = $A.localizationService.formatDate(now, "yyyy-MM-dd");
        var beforeDays = now.setDate(now.getDate() - 30);
        var startDay = $A.localizationService.formatDate(beforeDays,"yyyy-MM-dd");
        console.log('init Dates-- ' + today + ' --- ' + startDay);
        
        var tabcmp = component.find("report-tab");
        
        if(formFactor === true){
            console.log("in Tab");
            $A.util.removeClass(tabcmp, 'report-Tab-Fields');
            var action = component.get('c.loadRetailGroups');
            $A.enqueueAction(action);            
        } else {
            console.log("in Record");
            component.set('v.endVisit', today);
            component.set('v.startVisit', startDay);
            $A.util.addClass(tabcmp, 'report-Tab-Fields');
            var action = component.get('c.getAssessmentTasks');
            $A.enqueueAction(action); 
        }
    },
    
    /* onRender: function (component, event, helper){
        console.log("inside onRender");
        var formFactor = component.get("v.reportTab");
        var tabcmp = component.find("report-tab");
        if(formFactor === false){           
            console.log("in Record");
            $A.util.addClass(tabcmp, 'report-Tab-Fields');
            //var action = component.get('c.getAssessmentTasks');
            
            //$A.enqueueAction(action);              
        }
    },*/
    
    loadRetailGroups: function (component, event, helper) {
        var rec = component.find("myRetailGroup").get("v.value")
        var action = component.get("c.getRetailGroups");
        console.log("form factor- "+ component.get("v.reportTab") +" -- "+ component.get("v.recordId"));
        console.log("selected RG- "+rec);
        console.log("selected RG2- "+ component.get("v.selectedRetailGroup"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("after response- " + state);
            if (state === "SUCCESS") {
                console.log("after success- " + response.getReturnValue());
                component.set("v.retailGroupOptions", response.getReturnValue());                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }            
        });
        $A.enqueueAction(action);  
    },
    
    loadRetailStores : function (component, event, helper) {        
        var rec = component.find("myRetailGroup").get("v.value");
        console.log("rec in RS-- " + rec);
        console.log("selected RG after RS load- "+ component.get("v.selectedRetailGroup"));
        if(rec === ""){
            component.find("myRetailStore").set("v.disabled",true);
            component.find("myRetailStore").set("v.messageWhenValueMissing","");            
            component.set("v.retailStoreOptions", "");
            
        } else {
            component.find("myRetailStore").set("v.disabled",false);            
            var action = component.get("c.getRetailStores");
            action.setParams({rsgId : rec});
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("after response in loadRS - " + state);
                if (state === "SUCCESS") {
                    console.log("after success- " + response.getReturnValue());
                    component.set("v.retailStoreOptions", response.getReturnValue());
                    
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }           
            }); }
        $A.enqueueAction(action);  
        
    },
    
    checkEnd : function (component, event, helper) {
        component.find("visitEnd").setCustomValidity(""); 
        var startDate = component.find("visitStart").get("v.value");
        var endDate = component.find("visitEnd").get("v.value");
        var days = (new Date(endDate)- new Date(startDate))/8.64e7;
        console.log('in date math checkEnd: ' + days);
        if(days > 30){
            component.find("visitEnd").setCustomValidity("Please select dates within 30 Days");
            component.find("visitEnd").reportValidity();            
        } else if(days < 1){
            component.find("visitEnd").setCustomValidity("Please select atlest 1 Day");
            component.find("visitEnd").reportValidity();
        } else {
            console.log('in all good checkEnd: ' + days);
            component.find("visitEnd").reportValidity();
            component.find("visitEnd").checkValidity(); 
            component.find("visitEnd").setCustomValidity("");
            component.find("visitEnd").reportValidity();            
        }
    },
    
    checkStart : function (component, event, helper) {
        component.find("visitStart").setCustomValidity(""); 
        var startDate = component.find("visitStart").get("v.value");
        var endDate = component.find("visitEnd").get("v.value");
        
        console.log('in date math checkStart: ' + startDate);
        
        if(startDate !== null){
            component.find("visitStart").reportValidity();
            component.find("visitStart").checkValidity(); 
            component.find("visitStart").setCustomValidity("");
            component.find("visitStart").reportValidity();
        } else {
            component.find("visitStart").reportValidity();
            component.find("visitEnd").reportValidity();
        }
        var days;
        if(endDate !== null){              
            days = (new Date(endDate)- new Date(startDate))/8.64e7;
            console.log('in if math checkStart : ' + days);
            if(days > 30){
                component.find("visitEnd").reportValidity();
                component.find("visitEnd").checkValidity(); 
                component.find("visitEnd").setCustomValidity("Please select dates within 30 Days");
                component.find("visitEnd").reportValidity();
            } else if(days < 1){
                component.find("visitEnd").reportValidity();
                component.find("visitEnd").checkValidity(); 
                component.find("visitEnd").setCustomValidity("Please select atlest 1 Day");
                component.find("visitEnd").reportValidity();
            } else {                
                console.log('all good: ' + days);
                component.find("visitStart").reportValidity();
                component.find("visitStart").checkValidity(); 
                component.find("visitStart").setCustomValidity("");                
                
                component.find("visitEnd").reportValidity();
                component.find("visitEnd").checkValidity(); 
                component.find("visitEnd").setCustomValidity("");
                component.find("visitEnd").reportValidity();
            }
        } else {
            component.find("visitStart").reportValidity();
            component.find("visitEnd").reportValidity();
        }
        
        
    },   
    resetForm : function(component,event,helper){
        var isReportTab = component.get("v.reportTab");
        var cmpRResult = component.find("reportResult");
        if(isReportTab === false){
            component.set('v.endVisit', null);
            component.set('v.startVisit', null);
            component.find("visitStart").setCustomValidity("");
            component.find("visitEnd").setCustomValidity("");
            component.set("v.atListCount","0");
            $A.util.addClass(cmpRResult, 'reportHide'); 
        }
        $A.get('e.force:refreshView').fire();
        
    },    
    getAssessmentTasks : function (component, event, helper) {         
        component.find("visitStart").checkValidity();
        component.find("visitEnd").checkValidity();
        console.log('checks-- '+component.find("visitStart").checkValidity()); 
        
        var isReportTab = component.get("v.reportTab");
        var storeId = component.get("v.recordId");
        var rsg;
        var rs;
        var startDate = component.find("visitStart").get("v.value");
        var endDate = component.find("visitEnd").get("v.value");
        var allOK;        
        
        if(isReportTab === true){
            if(component.find("myRetailGroup").checkValidity() 
               && component.find("visitStart").checkValidity() && 
               component.find("visitEnd").checkValidity()) {
                console.log('myRetailGroup good');
                rsg = component.find("myRetailGroup").get("v.value");
                rs = component.find("myRetailStore").get("v.value");
                allOK = true;
            } else {
                allOK = false;
                component.find("myRetailGroup").showHelpMessageIfInvalid();
            }                
        } else {
            console.log('in Record getTasks- ' + startDate +' - '+ endDate);
            if(startDate !== null && endDate !== null){
                if(component.find("visitStart").checkValidity() !== false &&
                   component.find("visitEnd").checkValidity() !== false){
                    allOK = true;
                    rsg = null;
                    rs = storeId; 
                }
                
            } else {
                console.log('in Record errors- ' + component.find("visitStart").checkValidity());
                allOK = false;
                component.find("visitStart").showHelpMessageIfInvalid(); 
                component.find("visitEnd").showHelpMessageIfInvalid(); 
            } 
            
        }
        
        
        
        if(allOK === true){
            console.log('ALL OK, ready to get Tasks');
            
            var action = component.get("c.getTaskData");        
            action.setParams({rGroupId : rsg,
                              rStoreId : rs,
                              startDate : startDate,
                              endDate : endDate,
                              reportTab : isReportTab}); 
            var cmpRResult = component.find("reportResult");
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {                    
                    console.log("getAssessmentTasks success- " + response.getReturnValue());
                    var resWrap = response.getReturnValue();
                    if(resWrap === null){
                        console.log('****-');
                        component.set("v.atListCount","0");
                        $A.util.addClass(cmpRResult, 'reportHide'); 
                    } else {
                        component.set("v.atListCount",resWrap.atCount);
                        component.set("v.wrapATList",response.getReturnValue()); 
                        $A.util.removeClass(cmpRResult, 'reportHide'); 
                    }
                    
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }            
            });
        } else {
            console.log('in else rsg');            
            
        } 
        $A.enqueueAction(action);  
    },
    
    handleNav : function(cmp, event, helper) {
        var navService = cmp.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {        
                actionName: 'View'       
            }
        }
        navService.navigate(pageReference);
    }
})