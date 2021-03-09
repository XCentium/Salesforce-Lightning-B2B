({
    doInit : function(component, event, helper) {
        // parse body
        var steps = [];
        var subtags = [];
        var body = component.get("v.body");
        for(var i = 0; i < body.length; i++) {
            var thisTag = body[i];
            if (thisTag.isInstanceOf('c:lightningWizardStep99')) {
                var step = {};
                step.component = thisTag;
                if (steps.length == 0) {
                    step.status = 'current';
                    step.className = 'slds-is-current';
                    thisTag.set("v.current", true);
                    thisTag.set("v.hasPrevious", false);
                } else {
                    step.status = 'incomplete';
                    step.className = 'slds-is-incomplete';
                }
                step.body = thisTag.get("v.body");
                step.name = thisTag.get("v.name");
                steps.push(step);
                subtags.push(thisTag);
            }
        }
        steps[steps.length - 1].component.set("v.hasNext", false);
        component.set("v.totalSteps", steps.length);
        component.set("v.steps", steps);
        
        for(var i = 0; i < subtags.length; i++) {
            var thisTag = subtags[i];
            thisTag.set("v.totalSteps", steps.length);
            thisTag.set("v.currentIndex", i);
        }
    },
    handleStepChange : function(cmp, event, helper) {
        var type = event.getParam("type");
        var currentStep = cmp.get("v.currentStep");
        var totalSteps = cmp.get("v.totalSteps");
        if (type == 'next' && currentStep < totalSteps - 1) {
            cmp.set("v.currentStep", currentStep + 1);
        }
        if (type == 'previous' && currentStep > 0) {
            cmp.set("v.currentStep", currentStep - 1);
        }        
    },
    stepChange : function(cmp, event, helper) {
        var steps = cmp.get("v.steps");
        var currentStep = event.getParam("value");
        
        for(var i = 0; i < steps.length; i++) {
            if (i < currentStep) {
                steps[i].status = 'completed';
                steps[i].className = 'slds-is-complete';
                steps[i].component.set("v.current", false);
            } else if (i == currentStep) {
                steps[i].status = 'current';
                steps[i].className = 'slds-is-current';
                steps[i].component.set("v.current", true);
            } else {
                steps[i].status = 'incomplete';
                steps[i].className = 'slds-is-incomplete';
                steps[i].component.set("v.current", false);
            }
        }
        cmp.set("v.steps", steps);
    }
})