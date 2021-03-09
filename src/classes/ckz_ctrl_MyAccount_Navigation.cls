/**
 * Created by brandon.rogers on 1/25/19.
 */

global with sharing class ckz_ctrl_MyAccount_Navigation {

    global String userInfoJSON { get; set; }
    global String contactInfoJSON { get; set; }

    global ckz_ctrl_MyAccount_Navigation() {
        getUserInfo();
        getContactInfo();
    }

    global void getUserInfo() {
        ccrz.ccLog.log('ckz_ctrl_MyAccount_Navigation:getUserInfo');

        User u = ccrz.cc_CallContext.currUser;
        ccrz.ccLog.log('ckz_ctrl_MyAccount_Navigation:getUserInfo:User: ' + u);

        List<User> userInfo = [
                SELECT  Id,
                        FullPhotoUrl
                FROM    User
                WHERE   Id = :u.Id
        ];

        userInfoJSON = JSON.serialize(userInfo);
        ccrz.ccLog.log('ckz_ctrl_MyAccount_Navigation:getUserInfo:userInfoJSON: ' + userInfoJSON);
    }


    global void getContactInfo() {
        ccrz.ccLog.log('ckz_ctrl_MyAccount_Navigation:getContactInfo');

        Contact c = ccrz.cc_CallContext.currContact;
        ccrz.ccLog.log('ckz_ctrl_MyAccount_Navigation:getContactInfo:Contact: ' + c);

        List<Contact> contactInfo = [
                SELECT Id,
                        Name,
                        MailingAddress,
//                        OtherAddress,
                        Phone,
                        Title
                FROM Contact
                WHERE Id = :c.Id
        ];

        contactInfoJSON = JSON.serialize(contactInfo);

        ccrz.ccLog.log('ckz_ctrl_MyAccount_Navigation:getContactInfo:contactInfoJSON: ' + contactInfoJSON);
    }
}