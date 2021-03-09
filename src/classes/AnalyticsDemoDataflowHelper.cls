public with sharing class AnalyticsDemoDataflowHelper {
    
    private String apiVersion;

    public AnalyticsDemoDataflowHelper(String apiVersion){
        this.apiVersion = String.isBlank(apiVersion) ? 'v43.0' : apiVersion;
    }

    public void replaceSfdcDigestByEdgemarts(String dataflowID, List<WaveApplicationEdgemart> edgemartsConfigurations){
        
        Map<String, Object> dataflowDefinitionObject = AnalyticsDemoDataflowHelper.dataflowContentsAsJSON(dataflowID);
        
        // Determine which should process generic and which direct replacement
        List<WaveApplicationEdgemart> genericReplacements = new List<WaveApplicationEdgemart>();
        List<WaveApplicationEdgemart> directReplacements = new List<WaveApplicationEdgemart>();
        
        for (WaveApplicationEdgemart wae : edgemartsConfigurations) {
            if (String.isBlank(wae.edgemartNodeNameToReplaceInDataflow)) {
                genericReplacements.add(wae);
            }
            else {
                directReplacements.add(wae);
            }
        }

        if (genericReplacements.size() > 0) {
            ReplaceSfdcDigestByEdgemarts genericStrategyObj = new ReplaceSfdcDigestByEdgemartsGeneric();
            dataflowDefinitionObject = genericStrategyObj.doReplacement(dataflowDefinitionObject, genericReplacements);
        }

        if (directReplacements.size() > 0) {
            ReplaceSfdcDigestByEdgemarts directStrategyObj = new ReplaceSfdcDigestByEdgemartsDirect();
            dataflowDefinitionObject = directStrategyObj.doReplacement(dataflowDefinitionObject, directReplacements);
        }

        String newDataflowDefinition = JSON.serialize(dataflowDefinitionObject);

        // We need to make sure that the dataflow won't contain double underscores excepting __c ones
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_Year\\b', '#cY#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_Month\\b', '#cM#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_Day\\b', '#cD#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_Week\\b', '#cW#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_Quarter\\b', '#cQ#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_Hour\\b', '#cH#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_Minute\\b', '#cm#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_Second\\b', '#cS#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_day_epoch\\b', '#cDE#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c_sec_epoch\\b', '#cSE#');
        newDataflowDefinition = newDataflowDefinition.replaceAll('__c\\b', '#c#');
        
        newDataflowDefinition = newDataflowDefinition.replaceAll('__', '_');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#c#', '__c');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cY#', '__c_Year');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cM#', '__c_Month');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cD#', '__c_Day');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cW#', '__c_Week');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cQ#', '__c_Quarter');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cH#', '__c_Hour');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cm#', '__c_Minute');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cS#', '__c_Second');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cDE#', '__c_day_epoch');
        newDataflowDefinition = newDataflowDefinition.replaceAll('#cSE#', '__c_sec_epoch');        

        DataflowVersion newDataflowVersion = new DataflowVersion();
        newDataflowVersion.DataflowId = dataflowID;
        newDataflowVersion.DataflowDefinition = newDataflowDefinition;
        RestApiResponseBody versionResult = insertDataflowVersion(JSON.serialize(newDataflowVersion));
        
        if(versionResult.success){
            Dataflow df = [SELECT Id, CurrentId FROM Dataflow WHERE Id = :dataflowID];
            df.CurrentId = versionResult.id;
            this.updateDataflow(dataflowID, df);
        }        
    }

    public void remapNamesInAssets(String insightsApplicationId){
        // Get all dashboards and lenses from Lens object using InsightsApplicationId
        List<Lens> appAssets = [SELECT Id, DeveloperName, Body FROM Lens WHERE InsightsApplicationId = :insightsApplicationId AND Type IN ('lens', 'dashboard')];
        
        // For each dataflow, lens, dashboard, execute the code below over the json body instead of the static resource body
        for (Lens appAssetItem : appAssets) {
            String bdy = appAssetItem.Body.toString();
            bdy = bdy.replaceAll('__c_Year\\b', '#cY#');
            bdy = bdy.replaceAll('__c_Month\\b', '#cM#');
            bdy = bdy.replaceAll('__c_Day\\b', '#cD#');
            bdy = bdy.replaceAll('__c_Week\\b', '#cW#');
            bdy = bdy.replaceAll('__c_Quarter\\b', '#cQ#');
            bdy = bdy.replaceAll('__c_Hour\\b', '#cH#');
            bdy = bdy.replaceAll('__c_Minute\\b', '#cm#');
            bdy = bdy.replaceAll('__c_Second\\b', '#cS#');
            bdy = bdy.replaceAll('__c_day_epoch\\b', '#cDE#');
            bdy = bdy.replaceAll('__c_sec_epoch\\b', '#cSE#');
            bdy = bdy.replaceAll('__c\\b', '#c#');
            
            bdy = bdy.replaceAll('__', '_');
            bdy = bdy.replaceAll('#c#', '__c');
            bdy = bdy.replaceAll('#cY#', '__c_Year');
            bdy = bdy.replaceAll('#cM#', '__c_Month');
            bdy = bdy.replaceAll('#cD#', '__c_Day');
            bdy = bdy.replaceAll('#cW#', '__c_Week');
            bdy = bdy.replaceAll('#cQ#', '__c_Quarter');
            bdy = bdy.replaceAll('#cH#', '__c_Hour');
            bdy = bdy.replaceAll('#cm#', '__c_Minute');
            bdy = bdy.replaceAll('#cS#', '__c_Second');
            bdy = bdy.replaceAll('#cDE#', '__c_day_epoch');
            bdy = bdy.replaceAll('#cSE#', '__c_sec_epoch');
            this.updateLensAssetJsonBody(appAssetItem.Id, bdy);
        }
    }

    public void setComputeExpressionsForActionFields(String dataflowID, List<WaveApplicationActionField> actionFields){
        
        Map<String, Object> dataflowDefinitionObject = AnalyticsDemoDataflowHelper.dataflowContentsAsJSON(dataflowID);
        Map<String, String> registerNodeNamesByDataset = new Map<String, String>();

        for (String transfName : dataflowDefinitionObject.keySet()) {
            Map<String, Object> currTransf = (Map<String, Object>) dataflowDefinitionObject.get(transfName);
            if(currTransf.containsKey('action')) {
                String action = (String)currTransf.get('action');
                if (action.equals('sfdcRegister')) {
                    Map<String, Object> currTransfParams = (Map<String, Object>)currTransf.get('parameters');
                    String alias = (String)currTransfParams.get('alias');
                    registerNodeNamesByDataset.put(alias, transfName);                    
                }
            }
        }

        for (WaveApplicationActionField actField: actionFields) {
            if (dataflowDefinitionObject.containsKey(actField.computeExpressionName)) {
                Map<String, Object> node = (Map<String, Object>)dataflowDefinitionObject.get(actField.computeExpressionName);
                if (node != null) {
                    Map<String, Object> nodeParams = (Map<String, Object>)node.get('parameters');
                    List<Object> computedFields = (List<Object>)nodeParams.get('computedFields');
                    Map<String, Object> theField = (Map<String, Object>)computedFields.get(0);
                    theField.put('saqlExpression', '"' + actField.actionFieldValue + '"');
                    theField.put('name', actField.actionFieldName);
                    theField.put('label', actField.actionFieldLabel);
                }
            }
            else {
                // Add computeExpression
                // First find node that registers dataset
                String datasetName = actField.datasetName;
                String registerNodeName = registerNodeNamesByDataset.get(datasetName);
                Map<String, Object> registerNode = (Map<String, Object>) dataflowDefinitionObject.get(registerNodeName);
                Map<String, Object> registerNodeParams = (Map<String, Object>)registerNode.get('parameters');
                String source = (String)registerNodeParams.get('source');
                String ceJson = '{"action": "computeExpression","parameters": { "source": "' + source + '", "mergeWithSource": true, "computedFields": [{"name": "' + actField.actionFieldName + '", "type": "Text", "label": "' + actField.actionFieldLabel + '", "saqlExpression": "\\"' + actField.actionFieldValue + '\\""}]}}';
                Object o = JSON.deserializeUntyped(ceJson);
                dataflowDefinitionObject.put(actField.computeExpressionName, o);
                registerNodeParams.put('source', actField.computeExpressionName);
            }
        }

        String newDataflowDefinition = JSON.serialize(dataflowDefinitionObject);

        DataflowVersion newDataflowVersion = new DataflowVersion();
        newDataflowVersion.DataflowId = dataflowID;
        newDataflowVersion.DataflowDefinition = newDataflowDefinition;
        RestApiResponseBody versionResult = insertDataflowVersion(JSON.serialize(newDataflowVersion));
        
        if(versionResult.success){
            Dataflow df = [SELECT Id, CurrentId FROM Dataflow WHERE Id = :dataflowID];
            df.CurrentId = versionResult.id;
            this.updateDataflow(dataflowID, df);
        }
    }

    public static Map<String, Object> dataflowContentsAsJSON (String dfId) {
        return (Map<String, Object>)JSON.deserializeUntyped(
           [SELECT DataflowDefinition FROM DataflowVersion WHERE DataflowId = : dfId ORDER BY CreatedDate DESC LIMIT 1].DataflowDefinition
       );
    }

    // This method invokes the SFDC REST API for updating a Dataflow object
    public void updateDataflow(Id dataflowId, Dataflow dataflowObj) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String url = salesforceHost + '/services/data/' + this.apiVersion + '/sobjects/Dataflow/' + dataflowId + '?_HttpMethod=PATCH';
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        Dataflow dfClone = dataflowObj.clone(false);
        String jsonToPost = JSON.serialize(dfClone);
        req.setBody(jsonToPost);
        HTTPResponse res = http.send(req);
    }

    // This method invokes the SFDC REST API for creating a DataflowVersion object
    public RestApiResponseBody insertDataflowVersion(String jsonToPost) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String url =  salesforceHost + '/services/data/' + this.apiVersion + '/sobjects/DataflowVersion';
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        req.setBody(jsonToPost);
        HTTPResponse res = http.send(req);
        String resBody = res.getBody();
        //System.debug(resBody);
        return (RestApiResponseBody)JSON.deserialize(resBody, RestApiResponseBody.class);
    }

    public void updateLensAssetJsonBody(Id assetId, String assetJsonBody) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String url = salesforceHost + '/services/data/' + this.apiVersion + '/sobjects/Lens/' + assetId + '?_HttpMethod=PATCH';
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        String jsonToPost = '{"attributes": {"type": "Lens"},"Body": "' + EncodingUtil.base64Encode(Blob.valueOf(assetJsonBody)) + '"}';
        req.setBody(jsonToPost);
        HTTPResponse res = http.send(req);
    }

    public static Boolean dataflowExistsByApiName(String dataflowName){
        List<Dataflow> dfL = [SELECT Id FROM Dataflow WHERE DeveloperName = :dataflowName];
        return dfL.size() > 0;
    }

    public static Dataflow dataflowById(String dataflowId){
        List<Dataflow> dfL = [SELECT Id, MasterLabel, DeveloperName, State, DataflowType, CreatedDate, LastModifiedDate FROM Dataflow WHERE Id = :dataflowId];
        if (dfL.size() > 0) {
            return dfL.get(0);
        }
        
        return null;
    }
}