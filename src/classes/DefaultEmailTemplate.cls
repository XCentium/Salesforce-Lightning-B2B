global class DefaultEmailTemplate implements Support.EmailTemplateSelector {
    // Empty constructor 
    global DefaultEmailTemplate() {    }

    // The main interface method 
    global ID getDefaultEmailTemplateId(ID caseId) {

        // Select the case we're interested in.  You may want to query various fields on the case for more sophisticated logic in choosing a template.
        Case c = [SELECT Subject, Description FROM Case WHERE Id=:caseId];
        
        // Select the email template you'd like to appear as the default
        EmailTemplate et;
        et=[SELECT id FROM EmailTemplate WHERE DeveloperName = 'Default_Email_Template'];
            
        // Return the ID of the template selected
        return et.id;
    }

}