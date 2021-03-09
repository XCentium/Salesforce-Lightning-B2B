/**
 * Created by msobczak on 2/14/2019.
 */

global with sharing class ckz_ForgotPasswordController {

    public static boolean sendEmailDebug = true;

    @RemoteAction
    global static ccrz.cc_RemoteActionResult sendMessage(ccrz.cc_RemoteActionContext ctx, String username) {

        String emailBody = '';

        System.debug('ckz_ForgotPasswordController - begin sendMessage()');

        //Id userId = UserInfo.getUserId();
        //User user = [Select Id, Name, Email from User where Id = :userId];
        //System.debug('user: ' + user.Name);

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        try {
            boolean success = Site.forgotPassword(username);

            if (success) {
                String messageText = 'Message sent';
                emailBody += messageText;

                ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.INFO);
                msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                msg.classToAppend = 'messagingSection-Info';
                retMessages.add(msg);
            } else {
                String messageText = 'Error sending message.  Harrumph!';
                emailBody += messageText;

                ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.INFO);
                msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                msg.classToAppend = 'messagingSection-Error';
                retMessages.add(msg);
            }
        }
        catch (Exception ex) {

            System.debug('error message: ' + ex.getMessage());
            System.debug('line number: ' + ex.getLineNumber());

            String messageText = ex.getMessage();
            emailBody += messageText;

            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.ERROR);
            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msg.classToAppend = 'messagingSection-Error';
            retMessages.add(msg);

        }

        result.data = null;
        result.messages.addAll(retMessages);

        return result;
    }

    private static void sendEmailMsg(String emailBody) {

        if(sendEmailDebug == false) {
            return;
        }

        List<Messaging.SingleEmailMessage> mails =
                new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage mail =
                new Messaging.SingleEmailMessage();

        List<String> sendTo = new List<String>();
        sendTo.add('msobczak@salesforce.com');
        mail.setToAddresses(sendTo);

        // Step 3: Set who the email is sent from
        mail.setReplyTo('msobczak@salesforce.com');
        mail.setSenderDisplayName('Michael Sobczak');

        mail.setSubject('Reward Points account update log');

        mail.setHtmlBody(emailBody);

        mails.add(mail);

        Messaging.sendEmail(mails);
    }

}