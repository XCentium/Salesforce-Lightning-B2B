public class ScheduledLicenseExpirationWarning implements Schedulable{
    
	public void execute(SchedulableContext sc) {
        try {
            Organization org = [SELECT Id,Name,CreatedBy.Email,CreatedBy.UserName FROM Organization Limit 1];
            OrgWideEmailAddress orgWideAddress = [Select Id from OrgWideEmailAddress Limit 1];
            
            Date earlyWarningDate = Date.today().addDays(5);
            Date finalWarningDate = Date.today().addDays(1);
            
            List<PackageLicense> expiringLicenses = [SELECT ExpirationDate,NamespacePrefix 
                                                     FROM PackageLicense 
                                                     WHERE (DAY_ONLY(ExpirationDate) >= :earlyWarningDate AND DAY_ONLY(ExpirationDate) <= :earlyWarningDate)
                                                     OR (DAY_ONLY(ExpirationDate) >= :finalWarningDate AND DAY_ONLY(ExpirationDate) <= :finalWarningDate)];

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            toAddresses.add(org.CreatedBy.Email);
            
            email.setSubject('SDO Package Licenses Expiring');
            email.setOrgWideEmailAddressId(orgWideAddress.Id);
            email.setReplyTo('do-not-reply@sdo.demo');
            email.setSaveAsActivity(false);
            email.setTreatTargetObjectAsRecipient(false);
            email.setToAddresses(toAddresses);
            
            if(expiringLicenses.size() > 0){
                String emailBody = '';
                emailBody += '<body>';
                emailBody += '<div>The following licenses for your demo org ' + org.Id + ' with the username ' + org.CreatedBy.UserName + ' will expire on ' + expiringLicenses[0].ExpirationDate.month() + '/' + expiringLicenses[0].ExpirationDate.day() + '/' + expiringLicenses[0].ExpirationDate.year() + '.</div>';
                emailBody += '<div>Expiring Package Namespaces:</div>';
                emailBody += '<div>';
                
                for(PackageLicense expiringLicense: expiringLicenses){
                    emailBody += '<div>'+expiringLicense.NamespacePrefix+'</div>';
                }
                
                emailBody += '</div>';
                emailBody += '</body>';
                email.setHtmlBody(emailBody);
                
                emails.add(email);
            }
            
            if(emails.size() > 0){
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
            }
            
        } catch (Exception e){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'hanul.park@salesforce.com'});
            mail.setReplyTo('do-not-reply@messaging.salesforce');
            mail.setSenderDisplayName('Expiration Email Scheduler');
            mail.setSubject('Error: Expiration Email Scheduler');
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
	}
}