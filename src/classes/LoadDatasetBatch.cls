global class LoadDatasetBatch implements Database.Batchable<Integer>, Database.Stateful, Database.AllowsCallouts {

    private String insightsAppId;
    private String edgemartContainer;
    private WaveApplicationDataset datasetToLoad;
    private String insightsExternalDataId;

    global LoadDatasetBatch(WaveApplicationDataset dataset, String insightsAppId){
        this.datasetToLoad = dataset;
        this.insightsAppId = insightsAppId;
    }

    global Iterable<Integer> start(Database.BatchableContext BC) {
		
        List<Integer> lstIndexes = new List<Integer>();
        if (this.datasetToLoad.dataParts != null) {
            for (Integer i = 1; i <= this.datasetToLoad.dataParts; i++) {
                lstIndexes.add(i);
            }
        }
        else {
            lstIndexes.add(1);
        }

        this.edgemartContainer = 'SharedApp';

        if (String.isNotBlank(insightsAppId)) {
            List<InsightsApplication> insAppLst = [SELECT FolderId FROM InsightsApplication WHERE Id = :insightsAppId];
            if (insAppLst.size() > 0) {
                this.edgemartContainer = insAppLst.get(0).FolderId;
            }
        }

        HttpResponse res = WaveConfiguratorUtils.httpGetCallout(this.datasetToLoad.jsonSchemaUrl);
        String schemaData = res.getBody();

        InsightsExternalData iedObj = new InsightsExternalData();
        iedObj.EdgemartAlias = this.datasetToLoad.nameToSave;
        iedObj.EdgemartContainer = this.edgemartContainer;
        iedObj.MetadataJson = EncodingUtil.base64Decode(EncodingUtil.base64Encode(Blob.valueOf(schemaData)));
        iedObj.Format = 'Csv';
        iedObj.Operation = 'Overwrite';
        iedObj.EdgemartLabel = this.datasetToLoad.label;
        iedObj.Action = 'None';

        insert iedObj;
        this.insightsExternalDataId = iedObj.Id;

		return lstIndexes;
	}

    global void execute(Database.BatchableContext BC, List<Integer> scope) {
        if (scope.size() > 0 && String.isNotBlank(this.insightsExternalDataId)) {
            // Data is chunked or only one file?
            Integer dataIndex = 1;
            String dataUrl = this.datasetToLoad.csvDataUrl;

            if (this.datasetToLoad.dataParts != null && this.datasetToLoad.dataParts > 0) {
                
                dataIndex = scope.get(0);
                dataUrl = this.datasetToLoad.csvDataUrl + this.datasetToLoad.name + '-dataPart-' + dataIndex + '.csv';                            
            }

            HttpResponse resData = WaveConfiguratorUtils.httpGetCallout(dataUrl);
            String csvData = resData.getBody();
            InsightsExternalDataPart dataPart = new InsightsExternalDataPart();
            dataPart.PartNumber = dataIndex;
            Blob csvBlob = Blob.valueof(csvData);
            dataPart.dataFile = csvBlob;
            dataPart.DataLength = csvBlob.size();
            dataPart.InsightsExternalDataId = this.insightsExternalDataId;
            
            insert dataPart;
        }
    }

    global void finish(Database.BatchableContext BC) {		
		if (String.isNotBlank(this.insightsExternalDataId)) {
            InsightsExternalData iedObj = [SELECT Id, Action FROM InsightsExternalData WHERE Id = :this.insightsExternalDataId];
            iedObj.Action = 'Process';
            update iedObj;   
        }
	}
}