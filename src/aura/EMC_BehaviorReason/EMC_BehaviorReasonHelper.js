({
    VERBOSE: true,
    modelFactorValues:[
        { value: "top", label: "Top" },
        { value: "bottom", label: "Bottom" }
    ],
    factor1Options: [
        { value: "AttendedWebinarCount", label:"Attended webinar count"},
        { value: "BouncedEmailCount", label:"Bounced email count"},
        { value: "ClickThirdPartyCount", label:"Third-party tracker click-through count"},
        { value: "ClickThirdPartyPageViewCount", label: "Third-party tracker page view count" },
        { value: "EmailClickCount", label: "Email click-through count" },
        { value: "EmailClickRate", label:"Email click rate"},
        { value: "EmailIndirectBounceCount", label: "Indirect email bounce count" },
        { value: "EmailIndirectOptInCount", label: "Indirect email optIn count" },
        { value: "EmailIndirectUnsubscribeOpenCount", label: "Indirect unsubscribe count" },
        { value: "EmailOpenCount", label: "Email open count" },
        { value: "EmailOpenRate", label: "Email open rate" },
        { value: "EmailPreferencePageCount", label: "Email preference center visit count" },
        { value: "EmailResubscribedCount", label: "Resubscribed count" },
        { value: "EmailSentCount", label: "Sent email count" },
        { value: "EmailSpamComplaintCount", label: "Spam complaint count" },
        { value: "EmailTrackerClickCount", label: "Email tracker click-through count" },
        { value: "EmailUnsubscribePageCount", label: "The unsubscribe page count" },
        { value: "EventCheckedInCount", label: "Event check-in count" },
        { value: "EventRegisteredCount", label: "Event registration count" },
        { value: "FileViewCount", label: "File view count" },
        { value: "FormErrorCount", label: "Form handler error count" },
        { value: "FormHandlerErrorCount", label: "Form handler error count" },
        { value: "FormHandlerSuccessCount", label: "Form handler success count" },
        { value: "FormSuccessCount", label: "Form submission count" },
        { value: "FormTrackerClickCount", label: "Form tracker click-through count" },
        { value: "FormViewCount", label: "Form view count" },
        { value: "IndirectOptInCount", label: "Indirect optIn count" },
        { value: "LandingPageErrorCount", label: "LandingPageErrorCount" },
        { value: "LandingPageSuccessCount", label: "Landing page submission count" },
        { value: "LandingPageTrackerClickCount", label: "Landing page tracker click-through count" },
        { value: "LandingPageViewCount", label: "Landing page view count" },
        { value: "MA_AttendedWebinar", label: "Marketing - Attended Webinar", isMarketing: true },
        { value: "MA_EmailTrackerClick", label: "Marketing - Email Tracker Click", isMarketing: true },
        { value: "MA_EmailOpen", label: "Marketing - Email Open", isMarketing: true },
        { value: "MA_FormTrackerClick", label: "Marketing - Form Tracker Click", isMarketing: true },
        { value: "MA_LandingPageTrackerClick", label: "Marketing - Landing Page Tracker Click", isMarketing: true },
        { value: "MA_PaidSearchAdClick", label: "Marketing - Paid Search Ad Click", isMarketing: true },
        { value: "MA_CustomURLClick", label: "Marketing - Custom URL Click", isMarketing: true },
        { value: "MA_EventCheckedIn", label: "Marketing - Event Checked In", isMarketing: true },
        { value: "MA_EventRegistered", label: "Marketing - Event Registered", isMarketing: true },
        { value: "MA_EmailIndirectUnsubscribeOpen", label: "Marketing - Unsubscribed From Email", isMarketing: true },
        { value: "MA_RegisteredforWebinar", label: "Marketing - Registered for Webinar", isMarketing: true },
        { value: "MA_SocialPostClick", label: "Marketing - Clicked Social Post", isMarketing: true },
        { value: "MA_EmailSpamComplaint", label: "Marketing - Email Spam Complaint", isMarketing: true },
        { value: "MA_FormSuccess", label: "Marketing - Form Submitted", isMarketing: true },
        { value: "MA_FormHandlerSuccess", label: "Marketing - Form Handler Submitted", isMarketing: true },
        { value: "MA_LandingPageSuccess", label: "Marketing - Landing Page Form Submitted", isMarketing: true },
        { value: "MA_VideoConversion", label: "Marketing - Converted From Video", isMarketing: true },
        { value: "MA_VideoView", label: "Marketing - Started Video", isMarketing: true },
        { value: "MA_VideoWatched", label: "Marketing - Watched Video", isMarketing: true },
        { value: "MA_FileView", label: "Marketing - Viewed File", isMarketing: true },
        { value: "MA_FormView", label: "Marketing - Viewed Form", isMarketing: true },
        { value: "MA_LandingPageView", label: "Marketing - Viewed Landing Page", isMarketing: true },
        { value: "MA_PageView", label: "Marketing - Viewed Page", isMarketing: true },
        { value: "MA_Visit", label: "Marketing - Visited Website", isMarketing: true },
        { value: "MA_ClickThirdParty", label: "Marketing - Clicked Third Party Page", isMarketing: true }
    ],
    factor2Options:[
        { value: "1Day", label: "day" },
        { value: "7Days", label: "past 7 days" },
        { value: "3Months", label: "past 3 months" }
    ],
    initMarketing: function(component,event,modelFactor){
        let self = this;
        let selectedModelFactor = self.factor1Options.find(function(factorOption){
            return factorOption.value === modelFactor
        })
        if(selectedModelFactor && selectedModelFactor.isMarketing){
            component.set('v.isMarketing', true);
        } else {
            component.set('v.isMarketing', false);
        }
    },
    setMarketing: function(component,event,modelFactor){
        let self = this;
        let selectedModelFactor = self.factor1Options.find(function(factorOption){
            return factorOption.value === modelFactor
        })
        let insight = component.get('v.insight')
        console.log('modelFactor',modelFactor)
        console.log('selectedModelFactor',selectedModelFactor)
        
        if(selectedModelFactor && selectedModelFactor.isMarketing){
            insight['IntensityLevel'] = null;
            console.log('insight',insight);
            component.set('v.insight', insight);
            component.set('v.isMarketing', true);
        } else {
            component.set('v.isMarketing', false);
        }
    }
})