global class SchedulePerfectDateWiz implements Schedulable
{
    public SchedulePerfectDateWiz()
    {
    }
    
    global void execute(SchedulableContext SC) 
    {
        Opportunity[] Opps = [Select CloseDate, DB_Days__c from Opportunity where DB_Days__c != null and CloseDate != null];
        Date today = Date.today();   
        for( Opportunity o: Opps)
        {
            o.CloseDate = today.addDays(o.DB_Days__c.intValue()); 
        } 
        update Opps;
        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String orgName = UserInfo.getOrganizationName();
            User u = [Select ID, Name, Email From User Where ID =: UserInfo.getUserID() Limit 1];
            String uEmail = u.Email;
            //String emailAddr;
            //String nomineeName;
            String[] toAddresses = new String[] {uEmail}; 
            //String[] ccAddresses = new String[] {adminEmail};
            
            mail.setToAddresses(toAddresses);
            //mail.setCcAddresses(ccAddresses);
            mail.setBccSender(true);
            mail.setUseSignature(false);
            //mail.setReplyTo();
            mail.setSenderDisplayName('Opportunity Dates are Now Perfect');
            mail.setSubject('Opportunity Dates are Now Perfect in ' + orgName);
            mail.setPlainTextBody('The Opportunity Dates are now perfect, thanks for your patience ' + u.Name +'!');
            mail.setHtmlBody('<p>The Opportunity Dates are now perfect, thanks for your patience!</p>');
        //Send!!
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}