/*
* Created by Jesse Chase
* jchase@salesforce.com
* 09/20/2018.
*/

global class DemoConfigurator{
    /** Adds a permission set to the Admin users **/
    @AuraEnabled
    public static void AddPermissionSetToAdmin(String PermName){
        String UserId = [SELECT ID FROM User WHERE External_ID__c = 'User.001'].Id;
        String PermId = [Select ID From PermissionSet WHere Name = :PermName].Id;
        if(PermId != '' && UserId != ''){
            PermissionSetAssignment psa = new PermissionSetAssignment
                (
                    PermissionSetId = PermId, 
                    AssigneeId = UserId
                );
            insert psa;        
        }
    }
    /** Remove a permission set from the Admin users **/
    @AuraEnabled
    public static void RemovePermissionSetToAdmin(String PermName){
        String UserId = [SELECT ID FROM User WHERE External_ID__c = 'User.001'].Id;
        List<PermissionSetAssignment> permlist = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserId AND PermissionSet.Name = :PermName];
        if(!permlist.isEmpty()){
            delete permlist;
        }
    }
    /** Check if Admin User already has the Perm Set **/
    @AuraEnabled
    public static Boolean CheckPermSet(String PermName){
        String UserId = [SELECT ID FROM User WHERE External_ID__c = 'User.001'].Id;
        List<PermissionSetAssignment> permlist = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserId AND PermissionSet.Name = :PermName];
        if(!permlist.isEmpty()){
            return true;
        }else{
            return false;
        }
    }
    
    
    
    /** Get All Demo Settings from Demo Settings Object **/
    @AuraEnabled
    global static List<IDO_DemoSettings__c> GetSettings() { 
        return [SELECT Id, Name,Description__c,Enablement_Type__c,DeveloperName__c,functionName__c ,Configuration_Name__c,Enablement_Description__c,Enabled__c,AllowEnable__c FROM IDO_DemoSettings__c WHERE AllowEnable__c = true Order By Order__c ASC];
    }
    /** Update Demo Settings to Enabled **/
    @AuraEnabled
    global static List<IDO_DemoSettings__c> UpdateDemoSetting(String WhichSetting) {
        
        IDO_DemoSettings__c[] demosetting = [SELECT Id FROM IDO_DemoSettings__c WHERE DeveloperName__c = :WhichSetting];
        for(IDO_DemoSettings__c ds: demosetting) {
            ds.Enabled__c = true;
        }
        /** Attempt to update the demo setting fields and throw error in debug log if it fails **/
        try{
            update demosetting;
            return [SELECT Id, Name,Description__c,DeveloperName__c,functionName__c ,Configuration_Name__c,Enablement_Description__c,Enabled__c,AllowEnable__c FROM IDO_DemoSettings__c WHERE AllowEnable__c = true Order By Order__c ASC];
        }catch(exception e){
            System.debug('Update Demo Setting Error: ' + e);
            return null;
        }
    }
    
    /** Get All Demo Settings from Demo Settings Object **/
    @AuraEnabled
    global static Boolean ReadObjectDetection() {
        return false;
    }
    
    /** CG Cloud - Fix Old Datasets For Einstein Vision **/
    @AuraEnabled 
    global static void ClearDataSets() {
        AiDataset[] datasets = [SELECT Id, LabelList FROM AiDataset];
        for(AiDataset ds: datasets) {
            ds.LabelList = '{}';
        }
        try{
            update datasets;
        }catch(exception e){
            System.debug('Update Demo Setting Error: ' + e);
        }
    }
    /** CG Cloud - Create New Datasets **/
    @AuraEnabled
    global static void CreateDatasets() {
        /* Create First Dataset */
        AiDataset ds = new AiDataset(
            Name = 'Alpine Cereal Dataset',
            ContentType = 'Object Detection',
            DatasetType ='Training',
            FileUrl = 'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/Einstein/AlpineCereal.zip'
        );
        
        /* Create Second Dataset */
        AiDataset ds2 = new AiDataset(
            Name = 'Alpine Energy Bars Dataset',
            ContentType = 'Object Detection',
            DatasetType ='Training',
            FileUrl = 'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/Einstein/AlpineEnergyBars-Compressed.zip'
        );
        
        /* Create Void Dataset */
        AiDataset ds3 = new AiDataset(
            Name = 'Alpine Energy Voids Dataset',
            ContentType = 'Object Detection',
            DatasetType ='Training',
            FileUrl = 'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/Einstein/voids.zip'
        );
        
        /* Create Out of Stock Dataset */
        AiDataset ds4 = new AiDataset(
            Name = 'Alpine Energy Out-of-Stock Dataset',
            ContentType = 'Object Detection',
            DatasetType ='Training',
            FileUrl = 'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/Einstein/out-of-stock.zip'
        );
        
        try{
            insert ds;
            insert ds2;
            insert ds3;
        }catch(exception e){
            System.debug('Update Demo Setting Error: ' + e);
        }
        
    }
    
    /** Update Iot Settings for Queue ID,PricebookId,and RecordType for Case Creation **/
    @AuraEnabled
    global static void UpdatedIoTSettings() {
        /* Due to Rebuild of IoT Orchestrations, we no longer use this - REMOVE AFTER SUMMER
String QueueID = [SELECT Id FROM Group WHERE Type = 'Queue' AND (Name = 'IoT Queue') LIMIT 1].Id;
String RecordTypeId = [SELECT id FROM Recordtype WHERE Name='IoT Case' LIMIT 1].Id;
String PricebookId = [Select Id FROM Pricebook2 WHERE NAME = 'Alpine Group Pricebook' LIMIT 1].Id;
Asset[] assets = [SELECT Id FROM Asset];
for(Asset a: assets) {
a.DemoSetting_IoT_Queue_Id__c = QueueID;
a.DemoSetting_IoT_RecordType_Id__c = RecordTypeId; 
a.DemoSetting_IoT_PriceBookId__c = PricebookId;
}

try{
update assets;
}catch(exception e){
System.debug('Update Iot Settings Error: ' + e);
}
*/
    }
    /** CG CLOUD SPECIFIC SETUP */
    @AuraEnabled
    global static void RunCGCloudSurveys(){
        /* Survey Invitations */
        String Result;
        String storeId = [Select ID FROM RetailStore WHERE Name LIKE '%Presidio%'].Id;
        
        for (Survey surv : [Select ID,Name FROM Survey WHERE (NOT Name like 'Generic%')]) {
            SurveyInvitation inv = new SurveyInvitation(Name=surv.Name,SurveyId=surv.Id);
            insert inv;
            
            result = inv.id; 
            
            SurveySubject subj = new SurveySubject(Name='RetailStore',ParentID=result,SubjectId=storeId);
            insert subj;
        } 
        
    }
    /** Update Iot Asset Settings Proactive Sales Process Builder **/
    @AuraEnabled
    global static void UpdatedIoTAssetInventorySettings() {
        /* Rebuild the Community URL to Staged CloudCraze Cart */
        String domain = [SELECT Domain FROM Domain].domain;
        String myCommunity = [SELECT Name,UrlPathPrefix FROM Network WHERE Name = 'Alpine Retail Partner Community'].UrlPathPrefix;
        String assetId = [Select Id FROM Asset Where Name = 'Alpine Cooler 1 - NTO Presidio' LIMIT 1].Id;
        String oliviaId = [SELECT Id FROM Contact WHERE Name = 'Olivia Buyer'].Id;
        String cartId = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Contact__c = :oliviaId LIMIT 1].Id;
        String FullCommunity = 'https://' + domain + '/' + myCommunity + '/ccrz__ProductDetails?viewState=DetailView&cartID=' + assetId + '&sku=P4-012&isCSRFlow=true&portalUser=&store=&cclcl=en_US';
        System.debug('Full Commiunity URL: ' + FullCommunity);

        IDO_Cooler_Inventory__c [] inv = [SELECT Id, Community_URL__c  FROM IDO_Cooler_Inventory__c];
        for(IDO_Cooler_Inventory__c i: inv) {
            i.Community_URL__c = FullCommunity;
        }
        
        /** Attempt to update the Cooler Inventory fields and throw error in debug log if it fails **/
        
       
        try{
            update inv;
        }catch(exception e){
            System.debug('Update Cooler Inventory Fields Error: ' + e);
        }
        
    }
    /** Update Olivia Buyer Record Type for CloudCraze Demos **/
    @AuraEnabled
    global static void updateOliviaBuyer() {
        List<Contact> contact = [SELECT Id FROM Contact WHERE FirstName = 'Olivia' AND LastName='Buyer'];
        RecordType rt = [select Id from RecordType where Name = 'B2B Commerce' and SobjectType = 'Contact'];
        for(Contact c: contact) {
            c.RecordTypeId = rt.Id;
        }
        /** Attempt to update the record and throw error in debug log if it fails **/
        try{
            update contact;
        }catch(exception e){
            System.debug('Olivia Buyer Update Error: ' + e);
        }
    }
    /** Called by VF Page to Create Remote Site ThisOrg and MyDomain **/
    public void CreateRemoteSiteVF()
    {
        /** Create MyDomainNew Remote Site Setting **/
        DCMetadataService.MetadataPort service = createService();
        DCMetadataService.RemoteSiteSetting remoteSiteSettings = new DCMetadataService.RemoteSiteSetting();
        remoteSiteSettings.fullName = 'MyDomainNew'; 
        remoteSiteSettings.url = URL.getSalesforceBaseUrl().toExternalForm();
        remoteSiteSettings.isActive = true;
        remoteSiteSettings.disableProtocolSecurity=false;
        service.createMetadata(new List<DCMetadataService.Metadata> { remoteSiteSettings });
    }
    /** Create Service For MetaDataPort Service used for Remote Site Creation **/
    public static DCMetadataService.MetadataPort createService()
    {
        DCMetadataService.MetadataPort service = new DCMetadataService.MetadataPort();
        service.SessionHeader = new DCMetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    /** Get Org Base URL **/
    @AuraEnabled
    public static String getBaseURL(){
        return URL.getSalesforceBaseUrl().toExternalForm(); 
    } 
    /** Create a Store Visit Record for Field Sales Ipad App **/
    @AuraEnabled
    global static void CreateStoreVisitRecord() {
        
    }
    /** Called By VF Page to get WaveDashboard Ids in the Org **/
    @RemoteAction
    global static List<Object> WaveDashboardIds(){
        List<Object> dashboards = new List<Object>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = getBaseURL() + '/services/data/v43.0/wave/dashboards';
        request.setEndpoint(endpoint);
        String sessionId = UserInfo.getSessionId();
        request.setHeader('Authorization', 'OAuth ' + sessionId);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            dashboards = (List<Object>) results.get('dashboards');
            for (Object dashboard: dashboards) {
                System.debug(dashboard);
            }
            return dashboards;
        }else{
            return dashboards; 
        }
    }
    /** Called By VF Page to Update Wave Dashboard URL in Field Sales Admin **/
    @RemoteAction
    global static void UpdateWaveDashboardURL(String NewWaveURL){ 
        
    }
    /** Update Rachel Morris Phone Number for LiveMessage **/
    @AuraEnabled
    global static void UpdateRMorrisPhone(String PhoneNumber,String Persona, String Email) {
        List<Contact> cont = new List<Contact>();
        
        if(Persona == 'Rachel Morris (Retail)'){
            cont = [SELECT Id,Phone FROM Contact WHERE FirstName = 'Rachel' AND (LastName = 'Morris') LIMIT 1];
        }else{
            cont = [SELECT Id,Phone FROM Contact WHERE FirstName = 'Olivia' AND (LastName = 'Buyer') LIMIT 1];
        }
        
        for(Contact c: cont) {
            c.Phone  = PhoneNumber;
            c.Email = email;
            c.MobilePhone = PhoneNumber;
        }
        /** Attempt to update the record and throw error in debug log if it fails **/
        try{
            update cont; 
        }catch(exception e){
            System.debug('Update Contact Phone Error: ' + e);
        }
    }
    /** Update Tyree Zilnicki Email Address for IoT Proactive Sales Orchestration **/
    @AuraEnabled
    global static void UpdateTyreeEmail(String Email) {
        List<Contact> cont = [SELECT Id,Phone FROM Contact WHERE Name = 'Tyree Zilnicki' LIMIT 1];
        for(Contact c: cont) {
            c.Email  = Email;
        }
        /** Attempt to update the record and throw error in debug log if it fails **/
        try{
            update cont; 
        }catch(exception e){
            System.debug('Update Rachel Morris Phone Error: ' + e);
        }
    }
    @AuraEnabled
    public static String getPersonaTitle(String Name) {
        String title = [SELECT title FROM User WHERE NAME = :Name].title;
        return title;
    }
    @AuraEnabled
    public static List <String> getselectOptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            if(fld == 'Persona__c'){
                /*String Name = a.getValue();
String title = [SELECT title FROM User WHERE Name = Name].title;
String NewValue = a.getValue() + ' | ' + title;
allOpts.add(NewValue);*/
                
                allOpts.add(a.getValue()); 
            }else{
                allOpts.add(a.getValue()); 
            }
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }
    /** Send Feedback to Demo Content Owner Via Email **/
    @AuraEnabled 
    public static void emailContentFeedback(String title, String reasonAttr, String unlineDescAttr,String email){
        Id userId = userInfo.getUserId();
        String OwnerEmail = email;
        String ContentTitle = title;
        String UserProfile = [SELECT ID FROM Profile WHERE Name = 'System Administrator'].Id;
        String UserEmail = [SELECT Email FROM User WHERE ProfileId = :UserProfile AND (UserRole.Name = 'CEO') LIMIT 1].Email;
        /* org information */
        String instanceName = [select InstanceName from Organization limit 1].InstanceName;
        Organization org = [SELECT id, Name, PrimaryContact  FROM Organization];
        Id orgId = org.Id;
        String Name = org.Name;
        String PrimContact = org.PrimaryContact;
        
        String EmailBody;
        String likedisliketext;
        EmailBody = '<h2>Content Feedback</h2>' +
            '<strong>Demo Content</strong><br/>' +  ContentTitle + '<br/><br/>' + 
            '<strong>Feedback Reason</strong><br/>' +  reasonAttr + '<br/><br/>' +
            '<strong>Description</strong><br/>' +  unlineDescAttr + '<br/><br/><hr/>' + 
            '<h2>Org Details</h2>' +
            '<strong>Org Details</strong><br/>' +  instanceName + '<br/><br/>' + 
            '<strong>Id: </strong>' +  orgId + ' | ' +
            '<strong>Name: </strong>' +  Name + ' | ' +
            '<strong>User: </strong> ' + PrimContact + ' | ' +  
            '<strong>Email: </strong>' + UserEmail;
        
        String EmailSubj = 'Demo Content Feedback | ' + ContentTitle;
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { OwnerEmail};
            message.optOutPolicy = 'FILTER';
        message.subject = EmailSubj;
        message.htmlBody = EmailBody;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    
    /** Update CC Admin Secure and Unsecure URLs **/
    @AuraEnabled
    global static void ClearMCConnectUpdate() {
        et4ae5.SupportUtilities.resetConfiguration(); 
        
    }
    
    /** Update CC Admin Secure and Unsecure URLs **/
    @AuraEnabled
    global static void UpdateCCStoreFront() {
        Network myCommunity = [SELECT Id FROM Network WHERE Name = 'IDO Alpine Retail Partner'];
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(myCommunity.Id);
        List<String> BaseURL = comm.siteUrl.split('[/]');
        
        ccrz.cc_util_Reflection.updateStoreFrontSettings('AlpinePartner', 'Site_Unsecure_Domain__c', 'http://' + BaseURL[2]); 
        ccrz.cc_util_Reflection.updateStoreFrontSettings('AlpinePartner', 'Site_secure_Domain__c', 'https://' + BaseURL[2]); 
        
        Network myCommunity2 = [SELECT Id FROM Network WHERE Name = 'IDO NTO Retail Franchise'];
        ConnectApi.Community comm2 = ConnectApi.Communities.getCommunity(myCommunity2.Id); 
        List<String> BaseURL2 = comm2.siteUrl.split('[/]');
        
        ccrz.cc_util_Reflection.updateStoreFrontSettings('NTOFranchise', 'Site_Unsecure_Domain__c', 'http://' + BaseURL2[2]); 
        ccrz.cc_util_Reflection.updateStoreFrontSettings('NTOFranchise', 'Site_secure_Domain__c', 'https://' + BaseURL2[2]);  
        
        /*Updates the domain URLs for self registration 
* 
* Would handle what i've already done above using REST
CkzSDOConfigUpdateService.doGet();
*/
        
        /*Updates all of the indexes */
        CkzUpdateCacheService.doUpdate();
    }  
    /*FSL Stuffs
* 
* 
* */
    @AuraEnabled
    public static void RestoreData(Integer year, Integer month, Integer day){
        system.debug('*************** Date to restore to (y,m,d):'+ year+','+month+','+day);
        Integer y = integer.valueof(year);
        Integer m = integer.valueof(month);
        Integer d = integer.valueof(day);
        Date dtToRestore = date.newinstance(y, m, d);
        
        
        Datetime lookupOldDate = [SELECT Id, Start FROM ResourceAbsence WHERE FSLDemoTools_Master_Data__c = TRUE ORDER BY Start ASC LIMIT 1].Start;
        Date oldDate = Date.newinstance(lookupOldDate.year(), lookupOldDate.month(), lookupOldDate.day());
        
        Integer numberDaysBetween = oldDate.daysBetween(dtToRestore);
        system.debug('*************** Days Between:'+ numberDaysBetween);
        
        
        ResourceAbsence demoEmployeeAbsence = [SELECT Id, Start FROM ResourceAbsence WHERE FSLDemoTools_Master_Data__c = TRUE ORDER BY Start ASC LIMIT 1];
        Integer daysDiff = demoEmployeeAbsence.Start.dateGMT().daysBetween(dtToRestore);
        system.debug('*************** RestoreData daysDiff:'+daysDiff);
        
        FSLDemoTools_BatchRestoreData batch = new FSLDemoTools_BatchRestoreData('ResourceAbsence', daysDiff, 'delete');
        Database.executeBatch(batch);
        
        RestoreServiceTerritoryMembers();
        RestoreTerritories();
    }
    private static Void RestoreServiceTerritoryMembers() {
        List<ServiceTerritoryMember> stms = [Select Id, FSLDemoTools_Original_Geolocation__Latitude__s, FSLDemoTools_Original_Geolocation__Longitude__s, Latitude, Longitude From ServiceTerritoryMember where FSLDemoTools_Master_Data__c=true];
        
        for(ServiceTerritoryMember terr : stms) {
            if(terr.FSLDemoTools_Original_Geolocation__Latitude__s != null && terr.FSLDemoTools_Original_Geolocation__Latitude__s != 0) terr.Latitude = terr.FSLDemoTools_Original_Geolocation__Latitude__s;
            if(terr.FSLDemoTools_Original_Geolocation__Longitude__s != null && terr.FSLDemoTools_Original_Geolocation__Longitude__s != 0) terr.Longitude = terr.FSLDemoTools_Original_Geolocation__Longitude__s;
        } 
        update stms;
    }
    
    private static Void RestoreTerritories() {
        List<ServiceTerritory> territories = [Select Id, Name, FSLDemoTools_Original_Name__c, FSLDemoTools_Original_Geolocation__Latitude__s, FSLDemoTools_Original_Geolocation__Longitude__s, Latitude, Longitude,FSLDemoTools_Original_Timezone__c,OperatingHoursId From ServiceTerritory];
        List<Id> lstOpertingHoursIds = new List<Id>();
        Map<Id,String> mapOperatingHoursTimezones = new  Map<Id,String>();
        
        for(ServiceTerritory terr : territories) {
            if(terr.FSLDemoTools_Original_Timezone__c!=null && !mapOperatingHoursTimezones.containsKey(terr.OperatingHoursId)){
                mapOperatingHoursTimezones.put(terr.OperatingHoursId, terr.FSLDemoTools_Original_Timezone__c);
                lstOpertingHoursIds.add(terr.OperatingHoursId);
            }
            
            if(terr.FSLDemoTools_Original_Name__c != null && terr.FSLDemoTools_Original_Name__c != '') terr.Name = terr.FSLDemoTools_Original_Name__c;
            if(terr.FSLDemoTools_Original_Geolocation__Latitude__s != null && terr.FSLDemoTools_Original_Geolocation__Latitude__s != 0) terr.Latitude = terr.FSLDemoTools_Original_Geolocation__Latitude__s;
            if(terr.FSLDemoTools_Original_Geolocation__Longitude__s != null && terr.FSLDemoTools_Original_Geolocation__Longitude__s != 0) terr.Longitude = terr.FSLDemoTools_Original_Geolocation__Longitude__s;
        } 
        update territories;
        
        system.debug('************ mapOperatingHoursTimezones:'+mapOperatingHoursTimezones);
        List<OperatingHours> operatingHours = [Select Id, timezone from operatinghours where Id in : lstOpertingHoursIds];
        for(OperatingHours op : operatingHours) {
            system.debug('************ mapOperatingHoursTimezones.get(op.Id)!=null:'+mapOperatingHoursTimezones.get(op.Id));
            if(mapOperatingHoursTimezones.get(op.Id)!=null)
                op.Timezone = mapOperatingHoursTimezones.get(op.Id);
        }
        
        Update operatingHours;
        
    }  
    @AuraEnabled
    global static String getCalloutResponseContents(String endpoint) {
        String base = 'https://gettingtoknowtheido-v2.herokuapp.com';
        String url = base + endpoint;    
        
        Http h = new Http();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        System.debug('RESPONSE IS: ' + res.getBody());
        return res.getBody();
    }
    
    
    @RemoteAction
    global static Map<String,Object> DataConnectors() {
        string sessionId = UserInfo.getSessionId();
        string base = URL.getSalesforceBaseUrl().toExternalForm();
        String url = base + '/services/data/v47.0/wave/dataConnectors';  
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        String authorizationHeader = 'OAuth ' + sessionId;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        return responseMap;
        
    }
    /** Run all Analytics Dataflows with this handy snippet **/
    @RemoteAction
    global static void RunDataConnector(String ConnectorId) {
        string sessionId = UserInfo.getSessionId();
        string base = URL.getSalesforceBaseUrl().toExternalForm();
        string ingest = '/services/data/v47.0/wave/dataConnectors/' + ConnectorId + '/ingest';
        String url = base + ingest;  
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        
        String authorizationHeader = 'OAuth ' + sessionId;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        
    } 
}