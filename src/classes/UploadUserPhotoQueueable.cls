public class UploadUserPhotoQueueable implements Queueable, Database.AllowsCallouts {
	
	private String zipFileUrl;
	private String fileNameToExtract;
	private String fileBaseName;

	public UploadUserPhotoQueueable(String zipFileUrl, String fileNameToExtract, String fileBaseName){
		this.zipFileUrl = zipFileUrl;
		this.fileNameToExtract = fileNameToExtract;
		this.fileBaseName = fileBaseName;
	}

	public void execute(QueueableContext context) {
        
        Blob file = new WaveConfiguratorUtils().getUsersPhotosZipBlob(zipFileUrl);
		Zippex zipHandler = new Zippex(file);
        String nameToSave = String.escapeSingleQuotes(this.fileBaseName.substringBeforeLast('.'));

		if(String.isNotBlank(nameToSave)){

			String soqlQuery = 'SELECT Id FROM User WHERE External_Id__c = \'' + nameToSave + '\'';
			List<sObject> users = Database.query(soqlQuery);

			if(users.size() > 0){
				sObject usr = users.get(0);
				Blob blobFile = zipHandler.getFile(this.fileNameToExtract);
				String mimeType = 'image/' + this.fileBaseName.substringAfterLast('.');

				ConnectApi.UserProfiles.setPhoto(null, (String) usr.get('Id'), new ConnectApi.BinaryInput(blobFile, mimeType, this.fileBaseName));
			}
		}
	}
}