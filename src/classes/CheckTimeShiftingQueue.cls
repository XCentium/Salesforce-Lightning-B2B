public class CheckTimeShiftingQueue implements Queueable, Database.AllowsCallouts {
	
	private Boolean initialStep;
	private List<WaveTimeShiftingItem> timeShiftingItems;
	private Integer daysToShift;
	private String url;
    
	public CheckTimeShiftingQueue(Boolean initialStep, String url){
		this.initialStep = initialStep;
		this.timeShiftingItems = new List<WaveTimeShiftingItem>();
		this.url = url;
    }

	public void execute(QueueableContext context) {
        
		if(this.initialStep){
			this.selectMetadataAndBuildNodes();
			this.calculateDaysToShift();
			this.processTimeShiftingObjects(0);
		}
		else {

	        List<ScheduledTSDetails__c> tsDetails = [
		        SELECT DetailJson__c, DaysToShift__c, Started_Date__c, End_Date__c, JobStatus__c, CurrentNodeIndex__c, CurrentBatchProcessId__c, QueueProcessId__c, Errors__c 
		        FROM ScheduledTSDetails__c ORDER BY Started_Date__c DESC LIMIT 1
	        ];
	        
	        System.debug(tsDetails.size());

			if(tsDetails.size() > 0){
				List<WaveTimeShiftingItem> timeShiftingItems = (List<WaveTimeShiftingItem>)JSON.deserialize(tsDetails.get(0).DetailJson__c, List<WaveTimeShiftingItem>.class);
				ScheduledTSDetails__c currentNode = tsDetails.get(0);
				Integer nodeIndex = (Integer)currentNode.CurrentNodeIndex__c;

				System.debug('TS Items: ' + timeShiftingItems);
				System.debug('Node index: ' + nodeIndex);

				if(!String.isBlank(currentNode.CurrentBatchProcessId__c)){
					List<AsyncApexJob> batchJob = [SELECT CompletedDate, JobItemsProcessed, NumberOfErrors, Status, TotalJobItems FROM AsyncApexJob WHERE Id = :currentNode.CurrentBatchProcessId__c];
					AsyncApexJob asyncBatchJob = batchJob.get(0);

					if(asyncBatchJob.Status == 'Completed'){
						if(asyncBatchJob.NumberOfErrors > 0) {
							System.debug('Completed with errors');
							currentNode.JobStatus__c = 'Completed with errors';
							currentNode.Errors__c = 'The process was interrupted due to errors while time shifting data for the ' + timeShiftingItems.get(nodeIndex).objectTypeName + ' object.';
							currentNode.CurrentNodeIndex__c = 0;
							currentNode.End_Date__c = Datetime.now();
						}
						else {
							// now check whether it was the last one
							if(currentNode.CurrentNodeIndex__c == timeShiftingItems.size() - 1){
								System.debug('No more nodes to process');
								currentNode.JobStatus__c = 'Completed';
								currentNode.Errors__c = '';
								currentNode.CurrentNodeIndex__c = 0;
								currentNode.End_Date__c = Datetime.now();
							}
							else {
								// There are more nodes to process, increment index and reset
								System.debug('More nodes to process');
								currentNode.CurrentNodeIndex__c = currentNode.CurrentNodeIndex__c + 1;
								WaveTimeShiftingItem tsItem = timeShiftingItems.get((Integer)currentNode.CurrentNodeIndex__c);
								
                                TimeShiftingBatch batchProcess = new TimeShiftingBatch(tsItem.objectTypeName, tsItem.fieldsToTimeShift, (Integer)currentNode.DaysToShift__c, tsItem.externalIdObjectPrefix);
								currentNode.CurrentBatchProcessId__c = Database.executeBatch(batchProcess, 800);
                                
								update currentNode;

								CheckTimeShiftingQueue tsQueue = new CheckTimeShiftingQueue(false, this.url);
								currentNode.QueueProcessId__c = System.enqueueJob(tsQueue);
							}
						}		
					}
					else if(asyncBatchJob.Status == 'Aborted'){
						System.debug('Aborted');
						currentNode.JobStatus__c = 'Aborted';
						currentNode.Errors__c = 'The process was aborted while time shifting data for the ' + timeShiftingItems.get(nodeIndex).objectTypeName + ' object.';
						currentNode.CurrentNodeIndex__c = 0;
						currentNode.End_Date__c = Datetime.now();
					}
					else if(asyncBatchJob.Status == 'Failed'){
						System.debug('Failed');
						currentNode.JobStatus__c = 'Failed';
						currentNode.Errors__c = 'The process failed while time shifting data for the ' + timeShiftingItems.get(nodeIndex).objectTypeName + ' object.';
						currentNode.CurrentNodeIndex__c = 0;
						currentNode.End_Date__c = Datetime.now();
					}
					else {
						CheckTimeShiftingQueue tsQueue = new CheckTimeShiftingQueue(false, this.url);
						currentNode.QueueProcessId__c = System.enqueueJob(tsQueue);
					}

					update currentNode;
				}
			}
		}
	}

	private void calculateDaysToShift(){
		String soqlQuery = 'SELECT CloseDate FROM Opportunity WHERE External_Id__c LIKE \'W_Opportunity%\' AND StageName = \'Closed Won\'';
		
		soqlQuery += ' ORDER BY CloseDate DESC NULLS LAST';
		soqlQuery += ' LIMIT 1';

		List<sObject> sobjList = Database.query(soqlQuery);
		ScheduledTSDetails__c tsDetails = new ScheduledTSDetails__c();

		if(sobjList.size() > 0){				
			sObject s = sobjList.get(0);
			DateTime foundDate = (DateTime)s.get('CloseDate');
			
			this.daysToShift = foundDate.dateGMT().daysBetween(Date.today());
		}
		else{
			this.daysToShift = 0;
		}
	}

	private void selectMetadataAndBuildNodes(){
		HttpRequest req = new HttpRequest();
		req.setEndpoint(this.url);
        req.setMethod('GET');
		Http http = new Http();
        HTTPResponse res = http.send(req);

        String jsonMetadata = res.getBody();
		WaveMetadataApplication selectedAppMetadata = (WaveMetadataApplication)JSON.deserialize(jsonMetadata, WaveMetadataApplication.class);
	
		for(WaveMetadataApplicationObject wmaObj: selectedAppMetadata.objects) {
			if(wmaObj.dateFieldsToShift != null && wmaObj.dateFieldsToShift.size() > 0){
				WaveTimeShiftingItem timeShiftingItem = new WaveTimeShiftingItem();
				timeShiftingItem.appType = selectedAppMetadata.appType;
				timeShiftingItem.objectTypeName = wmaObj.Name;
				timeShiftingItem.fieldsToTimeShift = wmaObj.dateFieldsToShift;
                timeShiftingItem.externalIdObjectPrefix = wmaObj.externalIdPrefix;
                
				this.timeShiftingItems.add(timeShiftingItem);
			}
		}
	}

	private void processTimeShiftingObjects(Integer currentNodeIndex){
		if(this.timeShiftingItems.size() > 0){
			ScheduledTSDetails__c tsDetails = new ScheduledTSDetails__c();
			WaveTimeShiftingItem currentNode = this.timeShiftingItems.get(currentNodeIndex);

			// Start the batch and queue process
			TimeShiftingBatch batchProcess = new TimeShiftingBatch(currentNode.objectTypeName, currentNode.fieldsToTimeShift, this.daysToShift, currentNode.externalIdObjectPrefix);
			CheckTimeShiftingQueue tsQueue = new CheckTimeShiftingQueue(false, this.url);

			String tsDetailsJson = JSON.serialize(this.timeShiftingItems);

			tsDetails.DetailJson__c = tsDetailsJson;
			tsDetails.DaysToShift__c = this.daysToShift;
			tsDetails.Started_Date__c = Datetime.now();
			tsDetails.JobStatus__c = 'In Progress';
			tsDetails.Errors__c = '';
			tsDetails.CurrentNodeIndex__c = 0;
			tsDetails.CurrentBatchProcessId__c = Database.executeBatch(batchProcess, 800);
			tsDetails.QueueProcessId__c = System.enqueueJob(tsQueue);
			insert tsDetails;
		}
	}
}