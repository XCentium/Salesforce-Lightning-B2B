public with sharing class CreateRecordTypesQueueable implements Queueable, Database.AllowsCallouts{
	private SF_MetadataUtils.RecordTypeSpecification rtToCreate;
	private String sessionId;

	public CreateRecordTypesQueueable(SF_MetadataUtils.RecordTypeSpecification rtToCreate, String sessionId) {
		this.rtToCreate = rtToCreate;
		this.sessionId = sessionId;
	}

	public void execute(QueueableContext context) {
	
		List<String> fieldCreationErrors = SF_MetadataUtils.createRecordType(rtToCreate, this.sessionId);

		if(fieldCreationErrors.size() > 0){
			
			String errors = '';
			
			for(String err: fieldCreationErrors){
				errors += err + '.';
			}

			System.debug('Field Creation errors: ' + errors);
			throw new WaveConfiguratorException('Record types could not be created. Cause: ' + errors);
		}
		
    }
}