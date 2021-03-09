/*................................................................*/
/*Written by: Hanul Park..........................................*/
/*Package: Mixpanel...............................................*/
/*Version: 1.0....................................................*/
/*Documentation/Manifest: https://salesforce.quip.com/vWgkAaprUKJX*/
/*................................................................*/

global class MixpanelCtrl {
    global MixpanelCtrl(){}
    global MixpanelCtrl(EMC_Controller emc){}
    global MixpanelCtrl(ApexPages.StandardController ctrl){}
    
    @AuraEnabled@RemoteAction
    global static String getToken(){
        return Mixpanel_Key__c.getOrgDefaults().Token__c;
    }
    
    @AuraEnabled@RemoteAction
    global static Boolean sendSimpleMixpanelEvent(String action){
        Boolean isSuccess;
        
        OrgData orgData = getOrgData();
        Map<String,Object> data = new Map<String,Object>();
        data.put('event', 'SDO Event');
        
        Map<String,Object> payload = new Map<String,Object>();
        payload.put('action', action);
        payload.put('token',  getToken());
        payload.put('org_id', orgData.org_id);
        payload.put('org_type', orgData.org_type);
        payload.put('distinct_id', orgData.distinct_id);
        
        data.put('properties', payload);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        String dataString = JSON.serialize(data);
        String dataEncoded = EncodingUtil.base64Encode(Blob.valueOf(dataString));
        
        System.debug(dataEncoded);
        
        req.setEndpoint('http://api.mixpanel.com/track/?data=' + dataEncoded);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        isSuccess = res.getBody() == '0' ? false : true;
        
        return isSuccess;
    }
    
    @AuraEnabled@RemoteAction
    global static OrgData getOrgData(){
        Id profileId = UserInfo.getProfileId();
        QLabs__mdt org_metadata = [SELECT DeveloperName, Identifier__c FROM QLabs__mdt WHERE DeveloperName = 'Org_Identifier' LIMIT 1];
        Profile userProfile = [Select CreatedBy.Email From Profile Where Id = :profileId Limit 1];
        String org_id = UserInfo.getOrganizationId();
        
        return new OrgData(userProfile.CreatedBy.Email, org_id, org_metadata.Identifier__c);
    }
    
    @AuraEnabled@RemoteAction
    global static Boolean createEvent(String data){
        Boolean isSuccess;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://api.mixpanel.com/track/?data=' + data);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        isSuccess = res.getBody() == '0' ? false : true;
        
        return isSuccess;
    }
    
    @AuraEnabled@RemoteAction
    global static Boolean updateProfile(String data){
        Boolean isSuccess;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://api.mixpanel.com/engage/?data=' + data);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        
        isSuccess = res.getBody() == '0' ? false : true;
        
        return isSuccess;
    }
    
    global class OrgData {
        @AuraEnabled@RemoteAction
        global String distinct_id {get;set;}
        @AuraEnabled@RemoteAction
        global String org_id {get;set;}
        @AuraEnabled@RemoteAction
        global String org_type {get;set;}
        
        global OrgData(){}
        global OrgData(String distinct_id, String org_id, String org_type){
            this.distinct_id = distinct_id;
            this.org_id = org_id;
            this.org_type = org_type;
        }
    }
}