global class ckzPOCSelfRegisterController {
    public ckzPOCSelfRegisterController() {

    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult registerNewUser(ccrz.cc_RemoteActionContext ctx, String jsonFormData) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.ccLog.log(System.LoggingLevel.INFO,'M:E','registerNewUser');
        ccrz.ccLog.log(System.LoggingLevel.INFO,'D:jsonFormData',jsonFormData);
        ccrz.cc_RemoteActionResult result = new ccrz.cc_RemoteActionResult();
        result.success = false;
        result.inputContext = ctx;

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        try {
            Map<String,Object> formData = (Map<String,Object>)JSON.deserializeUntyped(jsonFormData);

            ccrz.ccLog.log(System.LoggingLevel.INFO,'ckzPOCSelfRegisterController', 'formData: ' + formData);

            //Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Contact').getRecordTypeId();

            //ccrz.ccLog.log(System.LoggingLevel.INFO,'ckzPOCSelfRegisterController', 'recordTypeId: ' + recordTypeId);

            String fName = (String)formData.get('firstName');
            String lName = (String)formData.get('lastName');

            // ntobusiness
            //String domain = getCommunityDomain('ntobusiness');
            String domain = 'nto.b2b';

            String emailAddress = (String)formData.get('username');
            String userNamePart = getUserFromEmailAddress(emailAddress);

            String alias = (fName.substring(0,1) + lName.substring(0,4)).toLowerCase();

            ccrz.ccLog.log(System.LoggingLevel.INFO,'ckzPOCSelfRegisterController', 'userNamePart: ' + userNamePart);

            String newUserName = userNamePart + '@' + domain;

            ccrz.ccLog.log(System.LoggingLevel.INFO,'ckzPOCSelfRegisterController', 'newUserName: ' + newUserName);

            // See if the user is already registered

            List<User> userList = [Select Id, Name from User where UserName = :newUserName];

            if(userList.isEmpty() == false) {

                String messageText = 'user is already registered: ' + newUserName;

                ccrz.ccLog.log(System.LoggingLevel.INFO,'ckzPOCSelfRegisterController', messageText);

                ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.ERROR);
                msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                msg.classToAppend = 'messagingSection-Error';
                retMessages.add(msg);

                result.messages.addAll(retMessages);
                return result;
            }

            // Create a new Contact
            Contact contactObj = new Contact (
                FirstName = fName
                ,LastName = lName
                ,Email = (String)formData.get('username')
                ,AccountId = '0011N00001tlaVt'  // Summit Sports
            );

            insert contactObj;

            // Create the new user
            User newUserObj = new User (
                FirstName = (String)formData.get('firstName')
                ,LastName = (String)formData.get('lastName')
                ,Email = (String)formData.get('username')
                ,ProfileId = '00e1N000001WzeN' //B2B Commerce Customer Community User
                //,License = 'Customer Community'
                ,Username = newUserName
                ,Alias = alias
                ,CommunityNickname = newUserName
                ,LocaleSidKey = 'en_US'
                ,TimeZoneSidKey = 'America/New_York'
                ,LanguageLocaleKey = 'en_US'
                ,EmailEncodingKey = 'UTF-8'
                ,ContactId = contactObj.Id
            );

            insert newUserObj;
            
            ccrz.ccLog.log(System.LoggingLevel.INFO,'ckzPOCSelfRegisterController', 'newUserObj id: ' + newUserObj.Id);

            String messageText = 'User successfully registered!';

            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.INFO);
            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msg.classToAppend = 'messagingSection-Info';
            retMessages.add(msg);

            result.messages.addAll(retMessages);
            result.success = true;

        } catch(exception e) {
            ccrz.ccLog.log(System.LoggingLevel.ERROR,'ERR',e);

            String messageText = 'Error: ' + e.getMessage();

            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.ERROR);
            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msg.classToAppend = 'messagingSection-Error';
            retMessages.add(msg);


        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO,'M:X','registerNewUser');
            ccrz.ccLog.close(result);
        }

        return result;
    }

    private static String getUserFromEmailAddress(String emailAddress) {

        String [] emailParts = emailAddress.split('@');

        return emailParts[0];

    }

    private static String getCommunityDomain(String storefront) {

        String domain = null;

        System.debug('Get all of the Communities defined in the Org.');
        ccrz.ccLog.log(System.LoggingLevel.INFO,'ckzPOCSelfRegisterController', 'Get all of the Communities defined in the Org.');

        ConnectApi.CommunityPage communityPage = ConnectApi.Communities.getCommunities();

        List<ConnectApi.Community> communities = communityPage.communities;

        for(ConnectApi.Community community : communities) {

            System.debug(community.name + ' / ' + community.status + ' / ' + community.siteUrl);
            ccrz.ccLog.log(System.LoggingLevel.INFO,'ckzPOCSelfRegisterController', community.name + ' / ' + community.status + ' / ' + community.siteUrl);

            String siteUrl = community.siteUrl;

            Integer pos = siteUrl.lastIndexOf('/');

            String newDomain = siteUrl.substring(0, pos);  
            System.debug('newDomain: ' + newDomain);

            String newUnsecureDomain = newDomain.replaceFirst('https:', 'http:');  System.debug('newUnsecureDomain: ' + newUnsecureDomain);

            String communityStorefrontName = siteUrl.substring(pos + 1);

            ccrz.ccLog.log(System.LoggingLevel.INFO,'ckzPOCSelfRegisterController', 'communityStorefrontName: ' + communityStorefrontName);
            
        }

        return domain;

    }
}