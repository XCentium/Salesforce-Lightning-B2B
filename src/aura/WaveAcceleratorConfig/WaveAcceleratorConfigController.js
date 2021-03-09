({
    doInit : function(cmp, event, helper) {
        helper.callServer(
            cmp,
            "c.getConfigJsonFile",
            function (jsonContent) {
                //console.log(jsonContent);
                var data = JSON.parse(jsonContent);
                cmp.set("v.regions", data.regions);
                cmp.set("v.countries", data.countries);
                cmp.set("v.industries", data.industries);
                cmp.set("v.defaultSettings", data.default);
                helper.loadExistingChoices(cmp, helper);
                helper.hideSpinner(cmp);
            },
            {}
        );
        
    },
    uploadNewDatasets : function (cmp, event, helper) {    
        var accountStructureNewFile = cmp.get("v.accountStructureNewFile");
        var productStructureNewFile = cmp.get("v.productStructureNewFile");
        if (accountStructureNewFile != null && accountStructureNewFile.length > 0) {
            helper.showSpinner(cmp);
            helper.uploadAccountStructure(cmp, accountStructureNewFile);
        } 
        
        if (productStructureNewFile != null && productStructureNewFile.length > 0) {
            helper.showSpinner(cmp);
            helper.uploadProductStructure(cmp, productStructureNewFile);
        }
        
    },
    setAvailableIndustries : function(cmp, event, helper) {
        var selectedCountryName = $('input[type=radio][name=country]:checked').val();
        //console.log(selectedCountryName);
        
        var selectedCountry = helper.findCountry(selectedCountryName, cmp);
        cmp.set("v.selectedCountry", selectedCountry);
        //console.log(selectedCountry);
    },
    setSelectedIndustry : function(cmp, event, helper) {
        var selectedIndustryId = $('input[type=radio][name=industry]:checked').val();
        console.log(selectedIndustryId);
        var settings = cmp.get("v.defaultSettings");
        if (selectedIndustryId != null) {
            var selectedCountry = cmp.get("v.selectedCountry");
            var selectedIndustry = helper.findIndustry(selectedIndustryId, selectedCountry);
            
            cmp.set("v.selectedIndustry", selectedIndustry);
            settings = helper.setSettingsFromIndustry(selectedIndustry, cmp);
            // console.log(settings);        
            helper.showSpinner(cmp);
            
            helper.callServer(
                cmp,
                "c.uploadWaveDataset",
                function (response) {
                    console.log(response);
                    helper.hideSpinner(cmp);
                    if (response.message == 'success') {
                        cmp.set("v.accountStructureId", settings["accountStructure"].data);
                        cmp.set("v.productStructureId", settings["productStructure"].data);
                        helper.showToast('Success', 'Your datasets have been submitted for upload', 'success');
                    } else {
                        helper.showToast('Oops', response.message, 'error');
                    }
                },
                { 
                    accountStructure : settings["accountStructure"].data,
                    accountStructureXMD : settings["accountStructure"].xmd,
                    productStructure : settings["productStructure"].data,
                    productStructureXMD : settings["productStructure"].xmd,
                    productSales : settings["productSales"].data,
                    productSalesXMD : settings["productSales"].xmd,
                    accountActivity : settings["accountActivity"].data,
                    accountActivityXMD : settings["accountActivity"].xmd,
                    accountMonthlyTarget : settings["accountMonthlyTarget"].data,
                    accountMonthlyTargetXMD : settings["accountMonthlyTarget"].xmd,
                    Sales_Data : settings["Sales_Data"].xmd,
                    Activity_Data : settings["Activity_Data"].xmd,
                    Budget_Data : settings["Sales_Targets"].xmd,
                    country : selectedCountry.name,
                    industry: selectedIndustryId
                }
            ); 
            
        }
    },
    updateAccountStructure : function (cmp, event, helper) {
        helper.handleFileChange(
            cmp, 
            "v.accountStructureFileList",
            "v.accountStructureNewFile",
            "v.accountStructureNewFileName"
        );
    },
    updateProductStructure : function (cmp, event, helper) {
        helper.handleFileChange(
            cmp, 
            "v.productStructureFileList",
            "v.productStructureNewFile",
            "v.productStructureNewFileName"
        );
    },
    startDataflow : function (cmp, event, helper) {     
        helper.showSpinner(cmp);
        
        helper.callServer(
            cmp,
            "c.startAcceleratorDataflow",
            function (response) {
                console.log(response);
                helper.hideSpinner(cmp);
                if (response == 'success') {
                    helper.showToast('Success', 'Your dataflow is getting started!', 'success');
                } else {
                    var error = JSON.parse(response);
                    helper.showToast('Oops', error.errorCode + ': ' + error.message, 'error');
                }
            },
            {}
        );
    }
})