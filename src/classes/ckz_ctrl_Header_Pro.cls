/**
 * Created by brandon.rogers on 2019-10-29.
 */

global with sharing class ckz_ctrl_Header_Pro {
    global String userInfoJSON { get; set; }
    global String communityURL { get; set; }

    global ckz_ctrl_Header_Pro() {
        getUserInfo();
        getCommunityURL();
    }
    
    global void getCommunityURL(){
        ccrz.ccLog.log('ckz_ctrl_Header_Pro:getCommunityURL');
        
        //Get current community ID
        String ntwrkId = Network.getNetworkId();
        
        Network currentCommunity= [SELECT Name, UrlPathPrefix FROM Network where id=:ntwrkId];
        communityURL = currentCommunity.UrlPathPrefix;
		ccrz.ccLog.log('ckz_ctrl_Header_Pro:getCommunityURL:communityURL: ' + communityURL);
    }

    global void getUserInfo() {
        ccrz.ccLog.log('ckz_ctrl_Header_Pro:getUserInfo');

        User u = ccrz.cc_CallContext.currUser;
        ccrz.ccLog.log('ckz_ctrl_Header_Pro:getUserInfo:User: ' + u);

        List<User> userInfo = [
                SELECT Id,
                        FullPhotoUrl
                FROM User
                WHERE Id = :u.Id
        ];

        userInfoJSON = JSON.serialize(userInfo);
        ccrz.ccLog.log('ckz_ctrl_Header_Pro:getUserInfo:userInfoJSON: ' + userInfoJSON);
    }
}