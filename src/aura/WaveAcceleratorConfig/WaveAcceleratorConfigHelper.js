({
    loadExistingChoices : function (cmp, helper) {
        helper.callServer(
            cmp,
            "c.getExistingSettings",
            function (settings) {
                var countryName = settings.Country__c;
                var industryId = settings.Industry__c;
                if (countryName != null && industryId != null) {
                    var country = helper.findCountry(countryName, cmp);
                    var industry = helper.findIndustry(industryId, country);
                    console.log(countryName, industryId);
                    cmp.set("v.selectedCountry", country);
                    cmp.set("v.selectedIndustry", industry);
                    cmp.set("v.accountStructureId", industry.datasets["accountStructure"]);
                    cmp.set("v.productStructureId", industry.datasets["productStructure"]);
                    helper.setSettingsFromIndustry(industry, cmp);
                    helper.flipToNextPage();
                    helper.flipToNextPage();
                }
            },
            {}
        );
    },
    flipToNextPage : function() {
        var appEvent = $A.get("e.c:lightningWizardStepChange99");
        appEvent.setParams({ "type" : "next" });
        appEvent.fire();
    },
    findCountry : function (countryName, cmp) {
		var countries = cmp.get("v.countries");
        var industries = cmp.get("v.industries");
        
        for (var i = 0; i < countries.length; i++) {
            if (countries[i].name == countryName) {
                countries[i].industries.forEach(function(industry) {
                    var metadata = industries[industry.id];
                    industry.name = metadata.name;
                    industry.image = metadata.image;
                });
                return countries[i];
            }
        }
        
        return null;
	},
    findIndustry : function (industryId, country) {
        for (var i = 0; i < country.industries.length; i++) {
            var industry = country.industries[i];
            if (industry.id === industryId) {
                return industry;
            }
        }
        return null;
    },
    setSettingsFromIndustry : function (selectedIndustry, cmp) {
        var defaultSettings = cmp.get("v.defaultSettings");
		var settings = JSON.parse(JSON.stringify(defaultSettings));
        if (selectedIndustry.datasets["accountStructure"] != null) {
            settings["accountStructure"].data = selectedIndustry.datasets["accountStructure"];
        }
        if (selectedIndustry.datasets["productStructure"] != null) {
            settings["productStructure"].data = selectedIndustry.datasets["productStructure"];
        }
        if (selectedIndustry.datasets["accountMonthlyTarget"] != null) {
            settings["accountMonthlyTarget"].data = selectedIndustry.datasets["accountMonthlyTarget"];
        }
        if (selectedIndustry.datasets["productSales"] != null) {
            settings["productSales"].data = selectedIndustry.datasets["productSales"];
        }
        if (selectedIndustry.XMDOverrides["Sales_Data"] != null) {
            settings["Sales_Data"].xmd = selectedIndustry.XMDOverrides["Sales_Data"];
        }
        if (selectedIndustry.XMDOverrides["Activity_Data"] != null) {
            settings["Activity_Data"].xmd = selectedIndustry.XMDOverrides["Activity_Data"];
        }
        if (selectedIndustry.XMDOverrides["Sales_Targets"] != null) {
            settings["Sales_Targets"].xmd = selectedIndustry.XMDOverrides["Sales_Targets"];
        }
        cmp.set("v.settings", settings);
        return settings;
    },
    callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    hideSpinner : function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    showSpinner : function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    showToast : function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    uploadAccountStructure : function (cmp, fileContent) {
        var settings = cmp.get("v.settings");
        this.callServer(
            cmp,
            "c.uploadAccountStructureInWave",
            function (response) {
                console.log(response);
                this.hideSpinner(cmp);
                if (response == 'success') {
                    this.showToast('Success', 'Your customised Account Structure has been submitted for upload', 'success');
                } else {
                    this.showToast('Oops', response, 'error');
                }
            },
            { 
                fileContent: fileContent, 
                xmdFile : settings["accountStructure"].xmd
            }
        );
    },
    uploadProductStructure : function (cmp, fileContent) {
        var settings = cmp.get("v.settings");
        this.callServer(
            cmp,
            "c.uploadProductStructureInWave",
            function (response) {
                console.log(response);
                this.hideSpinner(cmp);
                if (response == 'success') {
                    this.showToast('Success', 'Your customised Product Structure has been submitted for upload', 'success');
                } else {
                    this.showToast('Oops', response, 'error');
                }
            },
            { 
                fileContent: fileContent, 
                xmdFile : settings["productStructure"].xmd 
            }
        );
    },
    handleFileChange : function (cmp, fileListVar, base64Var, filenameVar) {        
        var fileList = cmp.get(fileListVar);
        if (fileList.length > 0) {
            var file = fileList[0];
            var filename = file.name;
            cmp.set(filenameVar, filename);
            
            var reader = new FileReader();
            reader.onload = function (e) {
                var fileContent = e.target.result;
                var base64 = fileContent;
                cmp.set(base64Var, base64);
            }
            
            reader.readAsDataURL(file);
        }
    }
})