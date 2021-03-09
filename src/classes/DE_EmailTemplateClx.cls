public class DE_EmailTemplateClx {
    @auraEnabled
    public static list<emailtemplate> getTemplates(string FolderName){
        list<emailtemplate> templates=[ select body, htmlvalue, templatetype, name,folder.name ,id from emailtemplate where folder.name=:folderName ];
        return templates;
    }
    @auraEnabled
    public static wrapperClass getEmailBody1(string templateId,string contactId,String CaseId){
        wrapperClass returnwrapperClass = new  wrapperClass ();   
       emailtemplate template=[ select body, htmlvalue, templatetype, name,folder.name ,id from emailtemplate where id=:templateId];
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'test@test.com'};
            mail.setToAddresses(toAddresses);
            mail.setwhatid(CaseId);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            mail.setSenderDisplayName('MMPT');
            mail.setTargetObjectId(contactId);
            mail.setTemplateId(templateId);
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            Database.rollback(sp);
            String mailTextBody = mail.getPlainTextBody();
            String mailHtmlBody = mail.getHTMLBody();
            String mailSubject = mail.getSubject();
            system.debug(mailHtmlBody);
            returnwrapperClass.subject=mailSubject;
            returnwrapperClass.htmlBody=mailHtmlBody;
       
        return returnwrapperClass; 
    }
    
    public class wrapperClass{
        
        @AuraEnabled public String Subject{get;set;}
        @AuraEnabled public String htmlBody {get;set;}
       
    }
    
    @auraEnabled
    public static string UpdateText(string emailBody,string templateName,string caseid,string templateId){
        emailtemplate e = [select id,name from emailtemplate where id=:templateId];
        system.debug('emailBody'+emailBody);
        if(emailBody!=''&&caseid!=''){
            
        IDO_Response_Detail__c rd=new IDO_Response_Detail__c ();
        rd.Body__c = emailBody;
        rd.Email_Template_Folder_Name__c = templateName;
        rd.Email_Template_Name__c = e.Name;
            
        rd.Case__c=caseid;
        insert rd;
            system.debug('rd'+rd);
              return rd.id;
        }
        else{
            system.debug('not enough details');
            return null;
        }
      
    }
}