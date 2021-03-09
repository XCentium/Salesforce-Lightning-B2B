global class MixpanelInvocable {

    global class OrgData {
        global String distinct_id {get;set;}
        global String org_id {get;set;}
        global String org_type {get;set;}
        
        global OrgData(){}
        global OrgData(String distinct_id, String org_id, String org_type){
            this.distinct_id = distinct_id;
            this.org_id = org_id;
            this.org_type = org_type;
        }
    }
    
    global static String getToken(){
        return Mixpanel__c.getOrgDefaults().Token__c;
    }
    
    global static OrgData getOrgData(){
        String org_id = UserInfo.getOrganizationId();
        QLabs__mdt org_metadata = [SELECT DeveloperName, Identifier__c FROM QLabs__mdt WHERE DeveloperName = 'Org_Identifier' LIMIT 1];
        Organization org = [Select CreatedBy.Email From Organization Where Id = :org_id];
        
        return new OrgData(org.CreatedBy.Email, org_id, org_metadata.Identifier__c);
    }
    
    
    @InvocableMethod(label='Mixpanel - Bot Tracker' description='Send action to save to Mixpanel')
    global static void sendSimpleMixpanelEvent(List<String> action){
        sendAsync(action);
    }
    
    @future(callout=true)
    global static void sendAsync(List<String> action){
        Boolean isSuccess = false;
        OrgData orgData = getOrgData();
        
        Map<String,Object> data = new Map<String,Object>();
        data.put('event', 'SDO Event');
        
        Map<String,Object> payload = new Map<String,Object>();
        payload.put('action', action[0]);
        payload.put('token', getToken());
        payload.put('org_id', orgData.org_id);
        payload.put('org_type', orgData.org_type);
        payload.put('distinct_id', orgData.distinct_id);
        
        System.debug(payload);
        data.put('properties', payload);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        String dataString = JSON.serialize(data);
        String dataEncoded = EncodingUtil.base64Encode(Blob.valueOf(dataString));

        req.setEndpoint('http://api.mixpanel.com/track/?data=' + dataEncoded);
        req.setMethod('GET');
        
        HttpResponse res = http.send(req);
        
        System.debug(res);
    }
}