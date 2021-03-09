public with sharing class ManagedContentController {
    
    // get Topic
    @AuraEnabled
   public static String getTopic(String TopicId) {
       System.debug('TopicId: '+TopicId);
       System.debug('SOQL: ');
       Topic Top = [SELECT Description,Id,ManagedTopicType,Name,NetworkId FROM Topic WHERE NetworkId = :Network.getNetworkID() AND Id=: TopicId];
       System.debug('TOPIC: '+Top.Name);
       Return Top.Name;
   }
 
    // get CMS Content
    @AuraEnabled
   public static List<ConnectApi.ManagedContentVersion> getMContent(String contentType, String managedContentIds_str, String topicNames_str, String language) {
       System.debug('INPUT contentType  : '+contentType);
       System.debug('INPUT managedContentIds_str  : '+managedContentIds_str);
       System.debug('INPUT topicNames_str  : '+topicNames_str);
       System.debug('INPUT language  : '+language);
       List<String> contentIds = new List<String>();
       List<String> topicNames = new List<String>();
       try{
           if(managedContentIds_str != null && !String.isEmpty(managedContentIds_str)){
               contentIds = managedContentIds_str.split(',',-1);
           }
          
           for(Integer i=0;i<contentIds.size();i++){
               contentIds.set(i,contentIds.get(i).trim());
           }
           
           if(topicNames_str != null && !String.isEmpty(topicNames_str)){
               topicNames = topicNames_str.split(',',-1); 
           }
           
           for(Integer i=0;i<topicNames.size();i++){
               topicNames.set(i,topicNames.get(i).trim());
           }

           String communityId = Network.getNetworkId();
//           communityId = '0DB2o000000U1AnGAK';
           
           
           language = 'en_US';
           ConnectApi.ManagedContentVersionCollection contentCollection = null;
           System.debug('API CALL: Channel - '+communityId+' - ContentIds - '+contentIds+'-  topicNames - '+topicNames+' - contentType -'+contentType);
           contentCollection = ConnectApi.ManagedContent.getManagedContentByTopicsAndIds(communityId, contentIds, topicNames, 0, 25, language, contentType);
           System.debug('Content  : '+contentCollection);
           System.debug('Content items : '+contentCollection.items);
           return contentCollection.items;
       }
       catch(ConnectApi.ConnectApiException e){
           System.debug('Error Message : '+e);
           ApexPages.addMessages(e);
           List<ConnectApi.ManagedContentVersion> mcvList = new List<ConnectApi.ManagedContentVersion>();
           return mcvList;
       }
   }
    
    
    // send email
    @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody){
    
     List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
  
     // Step 1: Create a new Email
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    // Step 2: Set list of people who should get the email
       List<String> sendTo = new List<String>();
       sendTo.add(mMail);
       mail.setToAddresses(sendTo);
    
    // Step 3: Set who the email is sent from
       mail.setReplyTo('noreply@gmail.com'); // change it with your mail address.
       mail.setSenderDisplayName('salesforce User'); 
    
    // Step 4. Set email contents - you can use variables!
      mail.setSubject(mSubject);
      mail.setHtmlBody(mbody);
    
    // Step 5. Add your email to the master list
      mails.add(mail);
    
  // Step 6: Send all emails in the master list
     Messaging.sendEmail(mails);
   }   
    
    
    
    
    
    
    
}