({
    retreivePartnerAccount : function(cmp) {
        var action = cmp.get("c.getPartnerAccount");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var account = response.getReturnValue();
                if (account !== null) {
                    cmp.set("v.account", account);
                } else {
                    this.initialisePreviewChart(cmp);
                }
            }
            else if (state === "INCOMPLETE") {
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
    retrievePartnerAccountActivityMap : function (cmp) {
        var account = cmp.get("v.account");
        var action = cmp.get("c.getAccountPointsByType");
        action.setParams({ 'accountId' : account.Id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var activityTypeMap = response.getReturnValue();
                if (activityTypeMap !== null) {
                    cmp.set("v.activityTypeMap", activityTypeMap);
                    this.assignStatusToRequirements(cmp);
                }
            }
            else if (state === "INCOMPLETE") {
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
    initialiseProgressChart : function (cmp, account) {
        var nextLevelMinimumPoints = account.Points_to_Next_Level__c + account.Total_Partner_Points__c;
        var percentage = account.Total_Partner_Points__c / nextLevelMinimumPoints;
        var colour =  cmp.get("v.chartColour");// '#0097E1';
        
        $('#circle').circleProgress({
            value: percentage,
            size: 150,
            thickness: 10,
            fill: { color: colour },
            startAngle: Math.PI * 1.5
        }).on('circle-animation-progress', function(event, progress) {
            $(this).find('strong').html('<p class="slds-text-heading--large chart-number">' + account.Points_to_Next_Level__c + '</p>' +
                                        '<p class="slds-text-heading--label">to ' + account.Current_Partner_Level__r.Next_Level__r.Name + '</p>');
        });
    },
    retrieveLevelRequirements : function (cmp, levelId) {
        var action = cmp.get("c.getLevelRequirements");
        action.setParams({ 'levelId' : levelId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var requirements = response.getReturnValue();
                cmp.set("v.requirements", requirements);
                
                this.retrievePartnerAccountActivityMap(cmp);
            }
            else if (state === "INCOMPLETE") {
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
    assignStatusToRequirements : function(cmp) {
        var requirements = cmp.get("v.requirements");
        var map = cmp.get("v.activityTypeMap");
        requirements.forEach(function(requirement) {
            var points = map[requirement.Partner_Activity_Type__c];
            if (points == null) {
                points = 0;
            }
            requirement.CurrentPoints = points;
            requirement.Fulfilled = false;
            if (points >= requirement.Minimum_Point_Requirement__c) {
                requirement.Fulfilled = true;
            }
        });
        cmp.set("v.requirements", requirements);
    },
    initialisePreviewChart : function (cmp) {
        //initialise chart for preview
        var colour =  cmp.get("v.chartColour");// '#0097E1';

        $('#circle').circleProgress({
            value: 0.8,
            size: 150,
            thickness: 10,
            fill: { color: colour },
            startAngle: Math.PI * 1.5
        }).on('circle-animation-progress', function(event, progress) {
            $(this).find('strong').html('<p class="slds-text-heading--large chart-number">' + 20 + '</p>' +
                '<p class="slds-text-heading--label">to Level</p>');
        });
    }
})