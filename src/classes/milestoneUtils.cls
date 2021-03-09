public class milestoneUtils {
    
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime complDate) {
        
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                                           from CaseMilestone cm
                                           where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName and completionDate = null limit 1];
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            update cmsToUpdate;
        } // end if
    }
    
    public static void completeSingleMilestone(Id cId, String milestoneName, DateTime complDate) {
        
        CaseMilestone cm = [select Id, completionDate
                                           from CaseMilestone
                                           where caseId = :cId and MilestoneType.Name=:milestoneName and completionDate = null limit 1];
        if (cm != null){
            cm.completionDate = complDate;
            update cm;
        } // end if
    }
    
    // test methods
    static testMethod void testCompleteMilestoneCase(){
        
        Contact oContact = [select id from Contact limit 1];
        String contactId;
        if (oContact != null)
            contactId = oContact.Id;
        
        Entitlement entl = [select id from Entitlement limit 1];
        String entlId;
        if (entl != null)
            entlId = entl.Id;
        
        List<Case> cases = new List<Case>{};
        if (entlId != null){
            Case c = new Case(Subject = 'Test Case with Entitlement ', EntitlementId = entlId, ContactId = contactId);
            cases.add(c);
        }
        
        // Insert the Account records that cause the trigger to execute.
        if (cases.isEmpty()==false){
            insert cases;
            List<Id> caseIds = new List<Id>();
            for (Case cL : cases){
                caseIds.add(cL.Id);
            }
            milestoneUtils.completeMilestone(caseIds, 'First Response', System.now());
        }
    }
    
    static testMethod void testCompleteMilestoneViaCase(){
        
        // Perform data preparation
        Entitlement entl = [select id from Entitlement limit 1];
        String entlId;
        if (entl != null)
            entlId = entl.Id;
        List<Case> cases = new List<Case>{};
        for(Integer i = 0; i < 1; i++){
            Case c = new Case(Subject = 'Test Case ' + i);
            cases.add(c);
            if (entlId != null){
                c = new Case(Subject = 'Test Case with Entitlement ' + i, EntitlementId = entlId);
                cases.add(c);
            }
        }
        
        // Insert the Account records that cause the trigger to execute.
        insert cases;

        List<CaseComment> ccs = new List<CaseComment>{};
        for(Case c : cases){
            CaseComment cc = new CaseComment(CommentBody='TestPublic', IsPublished=true, ParentId=c.Id);
            ccs.add(cc);
            cc = new CaseComment(CommentBody='TestPrivate', IsPublished=false, ParentId=c.Id);
            ccs.add(cc);
        }
        if (ccs.isEmpty()==false)
            insert ccs;
        
        // Now create emailmessage objects for them.
        
        List<EmailMessage> emails = new List<EmailMessage>();
        for(Case c : cases){
            emails.add(new EmailMessage(parentId = c.id));
        }
        if(emails.isEmpty()==false)
            database.insert(emails);
        
        for(Case c : cases){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddr = new String[] {'mramsey@salesforce.com'};
            mail.setToAddresses(toAddr);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(c.ContactId);
            mail.setWhatId(c.Id);
            mail.setHtmlBody('TestHTMLBody');
            mail.setPlainTextBody('TestTextBody');
            // mail.setTemplateID('emailtemplateId');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        for(Case c : cases){
            c.Status = 'Closed';
        }
        update cases;
        
        // Query the database for the newly inserted records.
        List<Case> insertedCases = [SELECT Subject,
                                           Description,
                                          (SELECT IsPublished, CommentBody From CaseComments),
                                          (SELECT TextBody, Subject, Incoming From EmailMessages)
                                           FROM Case
                                           WHERE Id IN :cases];
    }
}