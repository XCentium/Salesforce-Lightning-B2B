public class SSEQuickEmailContLead {
    public String emailBody {get; set;}
    public String to {get; set;}
    public String cc {get; set;}
    public String bcc {get; set;}
    public String subject {get; set;}
    public String selectedTemplateId {get; set;}

    Boolean contentSet = false;

    public String emailContent {
        get {
            System.debug('GET');
            if(!contentSet) {
                if(selectedTemplateId == '-- None --' || selectedTemplateId == '' || selectedTemplateId == null) {
                    System.debug('SELECTED TEMPLATE -- None --');
                    emailContent=emailContent;
                } else {
                    List<EmailTemplate> tempList = [select HtmlValue from EmailTemplate where Id =: selectedTemplateId limit 1];
                    if(!tempList.isEmpty()) {
                        emailContent = tempList[0].HtmlValue;
                    }
                }
            }
            return emailContent;   
        }
        set{
            System.debug('SET');
            emailContent = value;
        }    
    }
    public SSEQuickEmailContLead(ApexPages.StandardController controller) {
        emailContent ='';
        selectedTemplateId = '';
        to='';

        Account acc;
        List <Contact> cList;
        Lead l = [select email from Lead where id =: controller.getId()];
        to = l.email;
    }
    
    public List<SelectOption> getTemplateOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-- None --','-- None --'));

        for (EmailTemplate t : [
            select Id,Name 
            from EmailTemplate
        ]) {
            options.add(new SelectOption(t.Id,t.Name));
        }
        return options;
    }
    public void sendEmail() {
        
        if(to != '' || cc != '' || bcc != '') {

            contentSet = true;

            System.debug('TO = '+to);
            System.debug('CC = '+cc);
            System.debug('BCC = '+bcc);
            System.debug('SUBJECT = '+subject);
            System.debug('EMAIL BODY = '+emailContent);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            if(to != '') {
                String[] toAddresses = new String[] {to};
                email.setToAddresses(toAddresses);
            }
            if(cc != '') {
                String[] ccAddresses = new String[] {cc};
                email.setCcAddresses(ccAddresses);  
            }
            if(bcc != '') {
               String[] bccAddresses = new String[] {bcc}; 
               email.setBccAddresses(bccAddresses); 
            }
            email.setSubject(subject);
            email.setHtmlBody(emailContent);
            // Sends the email
            if(!Test.isRunningTest()) {
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            emailContent='';
            subject='';
            selectedTemplateId='';
            contentSet=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Message Sent'));
       }else {
            System.debug('No Valid email address');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Valid Email Supplied'));
       }
    }
}