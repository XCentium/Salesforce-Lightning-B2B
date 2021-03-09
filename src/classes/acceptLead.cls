public class acceptLead {

    public PageReference doMagic() {
        String prefix = System.currentPagereference().getParameters().get('sPrefix'); 
        try {
            String leadID = System.currentPagereference().getParameters().get('leadID'); 
            Lead theLead = [Select id, Name, OwnerID from Lead where id =: leadID Limit 1];
            theLead.OwnerId = UserInfo.getUserID();
            update theLead; 
        } catch(Exception e) {
            /*
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'ssinghvi@salesforce.com'}; 
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('support@acme.com');
            mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('Exception');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });          
            */      
        }        
        return new PageReference( prefix + '/apex/Community_Partner_Home');
    }

}