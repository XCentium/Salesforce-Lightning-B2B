({
    onInit: function (component, event, helper) {
        helper.toggleLoading(component, true)
        .then(function () {
            let promises = [
                helper.getScoreIntelligence(component),
                helper.getRecordData(component)
            ];
            return Promise.all(promises);
        })
        .then(function () {
            return helper.getLeadIQConfiguration(component);
        })
        .then(function (res) {
            return helper.getModelFactors(component, res.ModelVersion);
        })
        .then(function () {
            return helper.getLeadInsights(component);
        })
        .then(function (res) {
            return helper.createModelFactorInsights(component);
        })
        .then(function () {
            return helper.toggleLoading(component, false);
        })
        .catch(function (err) {
            console.log("ERROR:Init", err);
        });
        
    },
    addInsight: function (component, event, helper) {
        let baseId = component.get("v.recordId");
        let scoreIntelligence = component.get("v.scoreIntelligence");
        let leadIQConfig = component.get("v.leadIQConfig");
        let modelFactorInsights = component.get("v.modelFactorInsights");
        
        let uuid = helper.generateUUID();
        
        let insight = {
            sobjectType: "LeadInsight",
            FeatureType: "EngagementScoring",
            IntensityLevel: null,
            Intensity: 0.5,
            ParentId: baseId,
            ModelFactor: uuid,
            Value: 15
        };
        
        let modelFactor = {
            sobjectType: "ModelFactor",
            Factor1: "EmailClickCount",
            Factor2: "7Days",
            Value: "top",
            FeatureType: "EngagementScoring",
            ExternalId: uuid,
            Version: 1
        };
        
        let modelFactorInsight = {
            modelFactor: modelFactor,
            insight: insight
        };
        
        modelFactorInsights.push(modelFactorInsight);
        
        component.set("v.scoreIntelligence", scoreIntelligence);
        component.set("v.modelFactorInsights", modelFactorInsights);
    },
    deleteIndex: function (component, event, helper) {
        let index = event.getParam("index");
        let leadInsight = event.getParam("payload");
        
        let modelFactorInsights = component.get("v.modelFactorInsights");
        let modelFactorInsight = modelFactorInsights[index];
        
        let deletedModelFactors = component.get("v.deletedModelFactors");
        let deletedInsights = component.get("v.deletedInsights");
        
        if (modelFactorInsight.insight.hasOwnProperty("Id"))
            deletedInsights.push(modelFactorInsight.insight);
        if (modelFactorInsight.modelFactor.hasOwnProperty("Id"))
            deletedModelFactors.push(modelFactorInsight.modelFactor);
        modelFactorInsights.splice(index, 1);
        
        component.set("v.deletedModelFactors", deletedModelFactors);
        component.set("v.deletedInsights", deletedInsights);
        component.set("v.modelFactorInsights", modelFactorInsights);
    },
    save: function (component, event, helper) {
        component.set('v.saving', true);
        let scoreIntelligence = component.get("v.scoreIntelligence");
        let baseRecord = component.get("v.record");
        scoreIntelligence["LastModifiedTimeOnRecord"] = baseRecord.LastModifiedDate;
        
        let recordId = component.get("v.recordId");
        let sessionId = component.get("v.sessionId");
        
        let close = $A.get('e.force:closeQuickAction');
        let refresh = $A.get('e.force:refreshView');
        
        helper.sendRequest(component,'c.handleSaveRecords',{
            endpoint: '/services/data/v48.0/sobjects/EngagementScore',
            method: 'POST',
            data: JSON.stringify(scoreIntelligence)
        })
        .then(function () {
            return helper.deleteLeadInsights(component);
        })
        .then(function () {
            return helper.setModelFactorsAndLeads(component);
        })
        .then(function () {
            let records = [];
            let leadInsights = component.get("v.insights");
            let modelFactors = component.get("v.modelFactors");
            
            records = leadInsights;
            records = records.concat(modelFactors);
            
            let promises = [];
            
            records.map(function (record) {
                let sobjectType = record["sobjectType"];
                
                if (sobjectType) {
                    delete record["sobjectType"];
                } else if (record.hasOwnProperty("Id")) {
                    sobjectType = record["Id"].startsWith("0O3")
                    ? "ModelFactor"
                    : "LeadInsight";
                    delete record["Id"];
                }
                
                if (sobjectType == "LeadInsight") {
                    record["LastModifiedTimeOnRecord"] = baseRecord.LastModifiedDate;
                }
                
                console.log("record", sobjectType);
                
                promises.push(
                    helper.sendRequest(component, "c.handleSaveRecords", {
                        //auth: sessionId,
                        endpoint: "/services/data/v47.0/sobjects/" + sobjectType,
                        method: "POST",
                        data: JSON.stringify(record)
                    })
                );
            });
            
            return Promise.all(promises);
        })
        .then(function () {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type":"success",
                "message": "The score has been updated successfully."
            });
            toastEvent.fire();
        })
        .finally(function(){
            refresh.fire();
            close.fire();
        })
        .catch($A.getCallback(function (err) {
            console.log("ERROR:save", err);
            component.set('v.saving', false);
        }));
    },
    cancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
});