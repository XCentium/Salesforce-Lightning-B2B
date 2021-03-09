/*
 	* Created by Jesse Chase
 		* jchase@salesforce.com
 			* 11/17/2018.
*/
public class FIDO {
    
    /** Get Org Identifier **/
	@AuraEnabled
    public static String getOrgIdentifier() {
        return [SELECT Identifier__c FROM QLabs__mdt].Identifier__c;
    }
    /** Get All Pricebooks Entries by Industry **/
	@AuraEnabled
    public static List<PricebookEntry> GetPricebookEntryByIndustry(String PId) {
        return [SELECT Id,Product2.Name,Product2.Image_URL__c, UnitPrice, Product2.ProductCode ,Product2.Description FROM PricebookEntry WHERE Pricebook2.Id = :PId Order By Product2.Name];
    }    
    /** Get Demo Personas User ID **/
	@AuraEnabled
    public static String GetPersonaId(String Name) {
        return [SELECT Id FROM User WHERE Name = :Name Limit 1].Id;
    }
    /** Get Demo Personas Contact ID **/
	@AuraEnabled
    public static String GetContactId(String Name) {
        return [SELECT Id FROM Contact WHERE Name = :Name Limit 1].Id;
    }
    /** Get Demo Personas Contact ID **/
	@AuraEnabled
    public static String lookupAccount(String Name) {
        return [SELECT Id FROM Account WHERE Name = :Name Limit 1].Id;
    }
    /** Get Demo Case Info **/
	@AuraEnabled
    public static String lookupCase(String Name) {
        return [SELECT Id FROM Case WHERE Subject = :Name Limit 1].Id;
    }
    /** Get Demo Lead Info **/
	@AuraEnabled
    public static String lookupLead(String Name) {
        return [SELECT Id FROM Lead WHERE Name = :Name Limit 1].Id;
    }
    /** Get Demo Opportunity Info **/
	@AuraEnabled
    public static String lookupOpportunity(String Name) {
        return [SELECT Id FROM Opportunity WHERE Name = :Name Limit 1].Id;
    }
    /** Get All Pricebooks by Industry **/
	@AuraEnabled
    public static List<PriceBook2> GetPricebookByIndustry(String Industry,String Brand) {
        return [Select ID, Name FROM PriceBook2 WHERE Name LIKE :Brand];
    } 
     
    /** Get Org Id **/
	@AuraEnabled
    public static String GetOrgId() {
        return UserInfo.getOrganizationId(); 
    } 
    @AuraEnabled
    public static String getCalloutResponseContents(String endpoint) {
    	String base = 'https://gettingtoknowtheido-v4.herokuapp.com';
        String url = base + endpoint;    

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        /* Auth */
		req.setHeader('key', '5723fa9eaa8af90dc5e97dd6ec54960b');
    	req.setMethod('GET');
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res.getBody();
      }
    /*** Mix Panel ***/
    public class OrgData {
        public String distinct_id {get;set;}
        public String org_id {get;set;}
        public String org_type {get;set;}
        
        public OrgData(){}
        public OrgData(String distinct_id, String org_id, String org_type){
            this.distinct_id = distinct_id;
            this.org_id = org_id;
            this.org_type = org_type;
        }
    }
    /** Get Admin User Email **/
	@AuraEnabled
    public static String GetAdminUserEmail() {
        return [Select Email FROM User WHERE External_ID__c = 'User.001'].Email;
    }
    /** Get Admin User Name **/
	@AuraEnabled
    public static String GetAdminUserName() {
        return [Select Name FROM User WHERE External_ID__c = 'User.001'].Name;
    }
    public static String getToken(){
        return null;
        /*return Mixpanel__c.getOrgDefaults().Token__c; */
    }
    public static OrgData getOrgData(){
        String org_id = UserInfo.getOrganizationId();
        QLabs__mdt org_metadata = [SELECT DeveloperName, Identifier__c FROM QLabs__mdt WHERE DeveloperName = 'Org_Identifier' LIMIT 1];
        Organization org = [Select CreatedBy.Email From Organization Where Id = :org_id];
        
        return new OrgData(org.CreatedBy.Email, org_id, org_metadata.Identifier__c);
    }
    @AuraEnabled
    public static void sendFIDOMixpanelEvent(String GTKIDOPage, String GTKIDORecord){
        Boolean isSuccess = false;
        OrgData orgData = getOrgData();
        
        Map<String,Object> data = new Map<String,Object>();
        data.put('event', 'RCG IDO Event');
        
        Map<String,Object> payload = new Map<String,Object>();
        payload.put('action', GTKIDOPage);
        payload.put('action', GTKIDOPage);
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