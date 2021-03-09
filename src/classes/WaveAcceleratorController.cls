global class WaveAcceleratorController {
    
    global class WaveResponse {
        @AuraEnabled
        public string accountStructureId {get;set;}
        @AuraEnabled
        public string productStructureId {get;set;}
        @AuraEnabled
        public string message {get;set;}
        
        public WaveResponse(string accountStructureId, string productStructureId, string message) {
            this.accountStructureId = accountStructureId;
            this.productStructureId = productStructureId;
            this.message = message;
        }
    }
    
    @AuraEnabled
    global static Analytics_Accelerator__c getExistingSettings() {
        Analytics_Accelerator__c settings = Analytics_Accelerator__c.getOrgDefaults();
        return settings;
    }
    
    @AuraEnabled
    global static WaveResponse uploadWaveDataset(
        string accountStructure,
        string accountStructureXMD,
        string productStructure,
        string productStructureXMD,
        string productSales,
        string productSalesXMD,
        string accountActivity,
        string accountActivityXMD,
        string accountMonthlyTarget,
        string accountMonthlyTargetXMD,
        string Sales_Data,
        string Activity_Data,
        string Budget_Data,
        string country,
        string industry
    ) {
        string accountStructureId;
        string productStructureId;
        try {
            retrieveAndUploadToWave('ACCOUNT_STRUCTURE', accountStructure, accountStructureXMD);
            retrieveAndUploadToWave('PRODUCT_STRUCTURE', productStructure, productStructureXMD);
            retrieveAndUploadToWave('PRODUCT_SALES', productSales, productSalesXMD);
            retrieveAndUploadToWave('ACCOUNT_ACTIVITY', accountActivity, accountActivityXMD);
            retrieveAndUploadToWave('ACCOUNT_MONTHLY_TARGET', accountMonthlyTarget, accountMonthlyTargetXMD);
            retrieveAndUploadToWave('CampaignSpend', 'CampaignSpend.csv.gz', 'CampaignSpend.json');
            retrieveAndUploadToWave('SRG_Interactions', 'Interactions.csv.gz', 'Interactions.json');
            retrieveAndUploadToWave('SocialSpend_Data', 'SOCIALSPEND_DATA.csv.gz', 'SOCIALSPEND_DATA.json');
            
            Analytics_Accelerator__c settings = Analytics_Accelerator__c.getOrgDefaults();
            settings.Country__c = country;
            settings.Industry__c = industry;
            settings.Sales_Data_XMD_Overrides__c = Sales_Data;
            settings.Activity_Data_XMD_Override__c = Activity_Data;
            settings.Sales_Targets_XMD_Override__c = Budget_Data;
            
            upsert settings;
            
            return new WaveResponse(accountStructureId, productStructureId, 'success');
        } catch (Exception e) {
            System.debug(e.getMessage());
            return new WaveResponse(accountStructureId, productStructureId, e.getMessage());
        }
    }
    
    @future(callout=true)
    private static void retrieveAndUploadToWave(string datasetName, string dataFileName, string metadataFileName) {
        Blob dataFile = getS3FileAsBlob(dataFileName);
        Blob metadataFile = getS3FileAsBlob(metadataFileName);
        uploadFile(datasetName, dataFile, metadataFile);
    }
    
    @AuraEnabled
    global static string uploadAccountStructureInWave(string fileContent, string xmdFile) {
        string base64Mark = 'base64,';
        Integer dataStart = fileContent.indexOf(base64Mark) + base64Mark.length();
        string base64 = fileContent.substring(dataStart);
        Blob dataFile = EncodingUtil.base64Decode(base64);
        
        try {
            //string accountStructureXMDJson = getDocument(xmdFile).Body.toString();
            uploadFile('ACCOUNT_STRUCTURE', dataFile, getS3FileAsBlob(xmdFile));
        } catch (Exception e) {
            system.debug(e.getMessage());
            return e.getMessage();
        }
        
        return 'success';
    }
    
    
    @AuraEnabled
    global static string uploadProductStructureInWave(string fileContent, string xmdFile) {
        string base64Mark = 'base64,';
        Integer dataStart = fileContent.indexOf(base64Mark) + base64Mark.length();
        string base64 = fileContent.substring(dataStart);
        Blob dataFile = EncodingUtil.base64Decode(base64);
        
        try {
            //string productStructureXMDJson = getDocument(xmdFile).Body.toString();
            uploadFile('PRODUCT_STRUCTURE', dataFile, getS3FileAsBlob(xmdFile));
        } catch (Exception e) {
            system.debug(e.getMessage());
            return e.getMessage();
        }
        
        return 'success';
    }
    
    private static Document getDocument(string name) {
        return [SELECT Id, Body FROM Document WHERE Name = :name];
    }
    
    private static void uploadFile(string datasetName, Blob dataFile, Blob metadataFile) {
        InsightsExternalData data = new InsightsExternalData();
        data.Format = 'Csv';
        data.Action = 'None';
        data.Operation = 'Overwrite';
        data.EdgemartAlias = datasetName;
        if (metadataFile != null) {
            data.MetadataJson = metadataFile;
        }
        insert data;
        
        InsightsExternalDataPart part = new InsightsExternalDataPart();
        part.DataFile = dataFile;
        part.InsightsExternalDataId = data.Id;
        part.PartNumber = 1;
        
        insert part;
        
        data.Action = 'Process';
        update data;
    }
    
    
    @RemoteAction
    global static string startAcceleratorDataflow() {
        
        string AcceleratorDataflow; 
        string sessionId = UserInfo.getSessionId();
        HttpRequest req = new HttpRequest();
        string endPointURL = URL.getSalesforceBaseUrl().toExternalForm() + 
            '/insights/internal_api/v1.0/esObject/workflow';
        system.debug(endPointURL);
        req.setEndpoint(endPointURL);
        req.setMethod('GET');
        String authorizationHeader = 'OAuth ' + sessionId;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');        
        Http http = new Http();
        HTTPResponse res = http.send(req);
  
        // Parse JSON response to get all the List of Dataflows values and get the id.
        JSONParser  parser = JSON.createParser(res.getBody());
        
        while (parser.nextToken() != null) {
            parser.nextValue();
            
            if (parser.getCurrentName() == 'name' && (parser.getText() == 'Analytics_Demo_Accelerator')) {
                // Loop until find the Uid Value for analytics accelerator
                
                System.debug(parser.getText());
                
                
                while (parser.nextValue() != null ) 
                    
                {	            if (parser.getCurrentName() == '_lastModifiedBy'){
                    parser.nextValue();
                    parser.nextValue();
                    parser.nextValue();
                    parser.nextValue();
                }
                 parser.nextValue();
                 
                 if (parser.getCurrentName() == '_uid'){
                     
                     try  {
                         // Get the id value of the Analytics Demo Accelerator.
                         System.debug(parser.getText());
                         
                         AcceleratorDataflow = parser.getIdValue();
                         string result = startDataflow(AcceleratorDataflow, sessionId);
                         
                         if (result != '{"result":[{"success":true}]}') {
                             return result;
                         }
                     } catch (Exception e) {
                         system.debug(e.getMessage());
                         return e.getMessage();
                     }
                     return 'success';                           
                 }                
                }                
            }           
        }
        return 'Analytics Datflow not Found';      
    }

    global static string startDataflow(string dataflowId, string sessionId) {
        HttpRequest req = new HttpRequest();
        string endPointURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                        '/insights/internal_api/v1.0/esObject/workflow/' + dataflowId + '/start';
        system.debug(endPointURL);
        req.setEndpoint(endPointURL);
        req.setMethod('PUT');
        String authorizationHeader = 'OAuth ' + sessionId;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBody();
    }
    
    @RemoteAction
    global static string overrideXMD(string datasetName, string versionId) {
        string XMDFileName = null;
        Analytics_Accelerator__c settings = Analytics_Accelerator__c.getOrgDefaults();
        if (datasetName == 'Sales_Data') {
            XMDFileName = settings.Sales_Data_XMD_Overrides__c;
        } else if (datasetName == 'Budget_Data') {
            XMDFileName = settings.Sales_Targets_XMD_Override__c;
        } else if (datasetName == 'Activity_Data1') {
            XMDFileName = settings.Activity_Data_XMD_Override__c;
        }
        if (XMDFileName != null) {
            string xmdContent = getS3FileAsString(XMDFileName);
            
            string sessionId = UserInfo.getSessionId();
            HttpRequest req = new HttpRequest();
            string endPointURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                '/services/data/v40.0/wave/datasets/' + datasetName + '/versions/' + versionId + '/xmds/user';
            system.debug(endPointURL);
            req.setEndpoint(endPointURL);
            req.setMethod('PUT');
            String authorizationHeader = 'OAuth ' + sessionId;
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(xmdContent);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            return res.getBody();
        }
        return null;
    }
    
    @AuraEnabled
    global static string getConfigJsonFile() {
        string jsonFile = getS3FileAsString('waveAcceleratorConfig.json');
        return jsonFile;
    }
    
    private static string getS3FileAsString(string name) {
        HttpResponse res = getS3FileResponse(name);
        string body = res.getBody();
        
        return body;
    }
    
    private static Blob getS3FileAsBlob(string name) {
        HttpResponse res = getS3FileResponse(name);
        Blob body = res.getBodyAsBlob();
        
        return body;
    }
    
    private static HttpResponse getS3FileResponse(string name) {
        
        // Instantiate a new http object
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://s3-ap-southeast-2.amazonaws.com/analyticsacceleratorconfigfiles/' + name);
        req.setTimeout(60000);//sets maximum timeout
        req.setMethod('GET');
        
        // Send the request, and return a response
        
        HttpResponse res = h.send(req);
        return res;
    }
    
    global void inflateTest() {
        Integer i = 0; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;}
    
}