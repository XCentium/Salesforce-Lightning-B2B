public with sharing class LoadDatasetQueueable implements Queueable, Database.AllowsCallouts{
    
    private Double apiVersion;
    private String sessionId;
    private String insightsAppName;
    private WaveApplicationDataset datasetToLoad;

    public LoadDatasetQueueable(WaveApplicationDataset dataset, String insightsAppId, Double apiVersion, String sessionId) {
        this.datasetToLoad = dataset;
		this.sessionId = sessionId;
        this.apiVersion = apiVersion;
        this.insightsAppName = 'SharedApp';

        if (String.isNotBlank(insightsAppId)) {
            List<InsightsApplication> insAppLst = [SELECT FolderId FROM InsightsApplication WHERE Id = :insightsAppId];
            if (insAppLst.size() > 0) {
                this.insightsAppName = insAppLst.get(0).FolderId;
            }
        }
    }

    public void execute(QueueableContext context) {
        // Process the load of the edgemart
        // This code is intented to work only for those csv files < 10MB
        
        // Retrieve the Data first
        List<InsightsExternalDataPart> lstDataParts = new List<InsightsExternalDataPart>();        

        // Data is chunked or only one file?
        if (this.datasetToLoad.dataParts != null && this.datasetToLoad.dataParts > 0) {
            for (Integer i = 1; i <= this.datasetToLoad.dataParts; i++){
                String dataUrl = this.datasetToLoad.csvDataUrl + this.datasetToLoad.name + '-dataPart-' + i + '.csv';
                HttpResponse resData = WaveConfiguratorUtils.httpGetCallout(dataUrl);
                String csvData = resData.getBody();
                //System.debug(csvData.substringBefore('\n'));
                InsightsExternalDataPart dataPart = new InsightsExternalDataPart();
                dataPart.PartNumber = i;
                Blob csvBlob = Blob.valueof(csvData);
                dataPart.dataFile = csvBlob;
                dataPart.DataLength = csvBlob.size();
                lstDataParts.add(dataPart);
            }
        }
        else {
            HttpResponse resData = WaveConfiguratorUtils.httpGetCallout(this.datasetToLoad.csvDataUrl);
            String csvData = resData.getBody();
            InsightsExternalDataPart dataPart = new InsightsExternalDataPart();
            dataPart.PartNumber = 1;
            Blob csvBlob = Blob.valueof(csvData);
            dataPart.dataFile = csvBlob;
            dataPart.DataLength = csvBlob.size();
            lstDataParts.add(dataPart);
        }

        HttpResponse res = WaveConfiguratorUtils.httpGetCallout(this.datasetToLoad.jsonSchemaUrl);
        String schemaData = res.getBody();

        InsightsExternalData iedObj = new InsightsExternalData();
        iedObj.EdgemartAlias = this.datasetToLoad.name;
        iedObj.EdgemartContainer = this.insightsAppName;
        iedObj.MetadataJson = EncodingUtil.base64Decode(EncodingUtil.base64Encode(Blob.valueOf(schemaData)));
        iedObj.Format = 'Csv';
        iedObj.Operation = 'Overwrite';
        iedObj.EdgemartLabel = this.datasetToLoad.label;
        iedObj.Action = 'None';

        insert iedObj;

        for (InsightsExternalDataPart dataPart : lstDataParts) {
            dataPart.InsightsExternalDataId = iedObj.Id;
        }
                
        insert lstDataParts;

        // Final Step: Manage the Upload
        iedObj.Action = 'Process';
        update iedObj;
    }    
}