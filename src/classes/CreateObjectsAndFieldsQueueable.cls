public with sharing class CreateObjectsAndFieldsQueueable implements Queueable, Database.AllowsCallouts{
	
	private SF_MetadataUtils.CustomFieldSpecification fieldToCreate;
	private String sessionId;

	public CreateObjectsAndFieldsQueueable(SF_MetadataUtils.CustomFieldSpecification fieldToCreate, String sessionId) {
		this.fieldToCreate = fieldToCreate;
		this.sessionId = sessionId;
	}

	public void execute(QueueableContext context) {
	
		if(!SF_MetadataUtils.objectExists(fieldToCreate.ObjectName)){
			List<String> objectCreationErrors = SF_MetadataUtils.createObject(fieldToCreate.ObjectName, this.sessionId);
			
			if(objectCreationErrors.size() > 0){
				String errors = '';
			
				for(String err: objectCreationErrors){
					errors += err + '.';
				}

				throw new WaveConfiguratorException('An object could not be created. Cause: ' + errors);

			}
		}

		/*if(SF_MetadataUtils.fieldExists(fieldToCreate.ObjectName, fieldToCreate.Name)){
			
			if(!fieldToCreate.IsRequired){
				List<String> assignmentAccessErrors = SF_MetadataUtils.assignAccessToField(fieldToCreate.ObjectName, fieldToCreate.Name, this.sessionId);
			
				if(assignmentAccessErrors.size() > 0){
					String errors = '';
				
					for(String err: assignmentAccessErrors){
						errors += err + '.';
					}

					throw new WaveConfiguratorException('A field could not be granted. Cause: ' + errors);
				
				}	
			}
			
		}*/
		if(!SF_MetadataUtils.fieldExists(fieldToCreate.ObjectName, fieldToCreate.Name)){
			List<String> fieldCreationErrors = SF_MetadataUtils.createField(fieldToCreate, this.sessionId);
			
			if(fieldCreationErrors.size() > 0){
				String errors = '';
			
				for(String err: fieldCreationErrors){
					errors += err + '.';
				}

				throw new WaveConfiguratorException('A field could not be created. Cause: ' + errors);
			
			}
		}

    }
}