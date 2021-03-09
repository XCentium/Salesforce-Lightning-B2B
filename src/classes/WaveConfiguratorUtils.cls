public with sharing class WaveConfiguratorUtils {
	
	private Double apiVersion;

	public WaveConfiguratorUtils() {
		
	}

	public GenericAppConfiguration getAppConfiguration(String configurationFileName){
		StaticResource[] sr = [SELECT Id, Body FROM StaticResource WHERE Name = :configurationFileName LIMIT 1];
		
		if(sr.size() > 0){
			String body = sr.get(0).Body.toString();
			GenericAppConfiguration appConfig = (GenericAppConfiguration)JSON.deserialize(body, GenericAppConfiguration.class);
			apiVersion = appConfig.apiVersion;

			return appConfig;
		} 
		else {
			throw new WaveConfiguratorException('The configuration file ' + configurationFileName + ' does not exist. Please add it as static resource to initialize the installation process.');
		}
	}

	public static List<WaveApplicationRow> getWaveApplications(String csvUrl){
		
		IMockarooHelper helper = MockarooHelperFactory.getIMockarooHelper();
		List<WaveApplicationRow> apps = new List<WaveApplicationRow>();
		List<List<String>> csvAppsData = helper.getData(csvUrl, false);
		
		if(csvAppsData.size() > 0){
			// Will extract headers
			List<String> headers = csvAppsData.remove(0);
			Map<String, Integer> fieldPositions = new Map<String, Integer>();
			
			for(Integer i = 0; i < headers.size(); i++) {
				fieldPositions.put(headers.get(i), i);
			}

			for(List<String> appCsvRow: csvAppsData) {
				WaveApplicationRow appRow = new WaveApplicationRow();
				
				if(fieldPositions.containsKey('Name')){
					appRow.Name = appCsvRow.get(fieldPositions.get('Name'));
				}
				else {
					throw new WaveConfiguratorException('Name column not found in applications csv file.');
				}

				if(fieldPositions.containsKey('Label')){
					appRow.Label = appCsvRow.get(fieldPositions.get('Label'));
				}
				else {
					throw new WaveConfiguratorException('Label column not found in applications csv file.');
				}

				if(fieldPositions.containsKey('Description')){
					appRow.Description = appCsvRow.get(fieldPositions.get('Description'));
				}
				else {
					throw new WaveConfiguratorException('Description column not found in applications csv file.');
				}

				if(fieldPositions.containsKey('MetadataUrl')){
					appRow.MetadataUrl = appCsvRow.get(fieldPositions.get('MetadataUrl'));
				}
				else {
					throw new WaveConfiguratorException('MetadataUrl column not found in applications csv file.');
				}

				apps.add(appRow);
			}
		}

		return apps;
	}

	public static boolean checkStatus(HTTPResponse r){
		String strStatusCode = String.valueOf(r.getStatusCode());
		return !(strStatusCode.startsWith('4') || strStatusCode.startsWith('5'));
	}

	public static HttpResponse httpCallout(String url, String method, Boolean sfdcApi, String parameter){
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		String totalUrl = url;

		if(sfdcApi){
			String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
			totalUrl = salesforceHost + url;			
		}

		if(method.toUpperCase() == 'DELETE'){
			totalUrl += '/' + parameter;
		}

		if(method.toUpperCase() == 'POST' || method.toUpperCase() == 'PUT'){
			req.setBody(parameter);
		}

		req.setMethod(method);
		req.setEndpoint(totalUrl);
		req.setHeader('Content-type', 'application/json');
		req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());

		HttpResponse response = http.send(req);
		return response;
	}

	public static HttpResponse httpCallout(String url, String method, String parameter, String contentType, Map<String, String> httpHeaders){
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		String totalUrl = url;
		
		if(method.toUpperCase() == 'POST' || method.toUpperCase() == 'PUT'){
			req.setBody(parameter);
		}

		req.setMethod(method);
		req.setEndpoint(totalUrl);
		req.setHeader('Content-type', contentType);

		for (String headerKey : httpHeaders.keyset()) {
			req.setHeader(headerKey, httpHeaders.get(headerKey));
		}

		HttpResponse response = http.send(req);
		return response;
	}

	public static HttpResponse httpGetCallout(String url){
		Http http = new Http();
		HttpRequest req = new HttpRequest();

		req.setMethod('GET');
		req.setEndpoint(url);

		HttpResponse response = http.send(req);
		return response;
	}

	public static void sendEmail(String address, String dataflowLabel){
		if(!String.isBlank(address)){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] { address };
			String body = 'Congratulations, your data and Wave dataflow have been loaded into ' + UserInfo.getOrganizationId() + '.'; 
			body += 'Please log-in and Start the ' + dataflowLabel + ' Data Flow from the Wave Dataflow editor.';
			
			mail.setToAddresses(toAddresses);
			mail.setSubject('Wave application installation succeeded');
			mail.setPlainTextBody(body);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}

	public static void sendEmail(String addressTo, String subject, String body){
		if(!String.isBlank(addressTo)){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] { addressTo };
			mail.setToAddresses(toAddresses);
			mail.setSubject(subject);
			mail.setPlainTextBody(body);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}

	public static Boolean isInvalidEmail(String address){
		String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
	    Pattern MyPattern = Pattern.compile(emailRegex);
	    Matcher MyMatcher = MyPattern.matcher(address);

	    return !MyMatcher.matches(); 
	}

	// Retrieves asset JSON through WAVE REST API, only works within the ORG in which this code executes
	// @param waveAssets: Type of asset to retrieve [folders, datasets, lenses, dashboards]
	// @param requestUrl: If not null, uses this URL to request data
	/*public String getWaveAssetsJSON(String waveAssets, String requestUrl){
        HttpRequest req = new HttpRequest();
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String url = salesforceHost + (requestUrl != null ? requestUrl : '/services/data/' + apiVersion + '/wave/' + waveAssets + '?pageSize=200');
        req.setEndpoint(url);
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        req.setMethod('GET');

        Http httpMgr = new Http();
        HTTPResponse res = httpMgr.send(req);

        return res.getBody();
    }*/

    public Blob getUsersPhotosZipBlob(String zipFileUrl){
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(zipFileUrl);
        req.setMethod('GET');

        HTTPResponse res = http.send(req);
        
        if(!WaveConfiguratorUtils.checkStatus(res)){
			throw new WaveConfiguratorException('Error ' + res.getStatusCode() + ' - ' + res.getStatus() + ' in the attempt to get user profile photos.');
		}

        return res.getBodyAsBlob();
	}

	public Blob getUrlContentsAsBlob(String fileUrl){
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(fileUrl);
        req.setMethod('GET');

        HTTPResponse res = http.send(req);
        
        if(!WaveConfiguratorUtils.checkStatus(res)){
			throw new WaveConfiguratorException('Error ' + res.getStatusCode() + ' - ' + res.getStatus() + ' in getUrlContentsAsBlob().');
		}

        return res.getBodyAsBlob();
	}

	public void uploadUsersPhotos(String zipFileUrl){

		Map<String,Blob> photosToQuery = new Map<String,Blob>();
		Map<String,String> imagesType = new Map<String,String>();

		Blob file = this.getUsersPhotosZipBlob(zipFileUrl);
		Zippex zip = new Zippex(file);

		for(String fileName: zip.getFileNames()){
			
			String fileBaseName = fileName;
			
			if(fileName.contains('/')){
				fileBaseName = fileName.substringAfterLast('/');
			}
					
			String nameToSave = fileBaseName.substringBeforeLast('.');

			if(String.isNotBlank(nameToSave)){
				imagesType.put(nameToSave, fileName.substringAfterLast('.'));
				
				photosToQuery.put(nameToSave, zip.getFile(fileName));
			}
		}

		List<String> lstNames = new List<String>();
		lstNames.addAll(photosToQuery.keyset());
		String soqlQuery = 'SELECT Id, External_Id__c FROM User WHERE External_Id__c IN (' + String.join(lstNames, ',') + ')';
		List<sObject> users = Database.query(soqlQuery);

		if(users.size() > 0){
			for(sObject u: users){
				String fileName = (String) u.get('External_Id__c');

				Blob blobFile = photosToQuery.get(fileName);
				String imageName = fileName + imagesType.get(fileName);
				String extension = 'image/' + imagesType.get(fileName);

				ConnectApi.UserProfiles.setPhoto(null, (String) u.get('Id'), new ConnectApi.BinaryInput(blobFile, extension, imageName));
			}
		}
	}

	@future(callout=true)
	public static void getTimeShiftingJson(String url){
		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
        req.setMethod('GET');
		Http http = new Http();
        HTTPResponse res = http.send(req);
	}

	public boolean folderExists(String folderName){
        Folder[] lstFolders = [SELECT Id FROM Folder WHERE DeveloperName = :folderName AND Type = 'Insights'];
        return lstFolders.size() > 0;
    }

	public String getFolderIdByDevName(String folderName){
        List<Folder> lstFolders = [SELECT Id FROM Folder WHERE DeveloperName = :folderName AND Type = 'Insights'];
        return lstFolders.size() > 0 ? lstFolders.get(0).Id : '';
    }

	public Map<String, String> getDatasetIdByDevNameMapping(List<String> lstDatasetNames){
        
		Map<String, String> mapping = new Map<String, String>();

		for (EdgeMart edg : [SELECT Id, DeveloperName FROM EdgeMart WHERE DeveloperName IN :lstDatasetNames]) {
			mapping.put(edg.DeveloperName, edg.Id);
		}

		return mapping;
    }

	public String getAnalyticsAppIdByDevName(String devName){
		InsightsApplication anApp = [SELECT Id FROM InsightsApplication WHERE DeveloperName = :devName];
		return anApp.Id;
	}

	public String getAnalyticsAppIdByFolderId(String folderId){
		InsightsApplication anApp = [SELECT Id FROM InsightsApplication WHERE FolderId = :folderId];
		return anApp.Id;
	}	

	public String insertFolder(String appLabel, String folderName) {
        String jsonToPost = '{"label":"' + appLabel + '","name":"' + folderName + '"}';
        HTTPResponse res = WaveConfiguratorUtils.httpCallout('/services/data/v' + this.apiVersion + '/wave/folders', 'POST', true, jsonToPost);
        
		if(!WaveConfiguratorUtils.checkStatus(res)){
            if(res.getBody().containsIgnoreCase('errorCode')){
                List<RestApiFolderErrorResponse> r = (List<RestApiFolderErrorResponse>)JSON.deserialize(res.getBody(), List<RestApiFolderErrorResponse>.class);
                throw new WaveConfiguratorException('There was an error in the attempt to create the: ' + folderName + ' folder. Cause: ' + r.get(0).message + '.');
            }
            throw new WaveConfiguratorException('There was an error in the attempt to create the: ' + folderName + ' folder.');
        }
        else {
            RestApiResponseBody responseBody = (RestApiResponseBody)JSON.deserialize(res.getBody(), RestApiResponseBody.class);
            return responseBody.id;
        }
    }

	public static void setXmdForDataset(String datasetDevName, String xmdUrl, Double apiVersion){
		Edgemart edgObj = [SELECT Id, CurrentId FROM EdgeMart WHERE DeveloperName = :datasetDevName];
		HttpResponse resGetJsonXmd = WaveConfiguratorUtils.httpGetCallout(xmdUrl);
		String xmdData = resGetJsonXmd.getBody();
		String datasetId = edgObj.Id;
		String currentVersionId = edgObj.CurrentId;
		String urlToAttach = '/services/data/v' + apiVersion+ '/wave/datasets/' + datasetId + '/versions/' + currentVersionId + '/xmds/user';
		HttpResponse resAttachXmd = WaveConfiguratorUtils.httpCallout(urlToAttach, 'PUT', true, xmdData);
		if(!WaveConfiguratorUtils.checkStatus(resAttachXmd) || resAttachXmd.getBody().containsIgnoreCase('errorCode')){
			List<RestApiErrorResponse> r = (List<RestApiErrorResponse>)JSON.deserialize(resAttachXmd.getBody(), List<RestApiErrorResponse>.class);
			throw new WaveConfiguratorException('The xmd file could not be attached to the ' + datasetDevName + ' dataset. Cause: ' + r.get(0).message);
		}
	}

	@future(callout=true)
	public static void setXmdForDatasetFuture(String datasetDevName, String xmdUrl, Double apiVersion){
		WaveConfiguratorUtils.setXmdForDataset(datasetDevName, xmdUrl, apiVersion);
	}

	public static Boolean containsDoubleByteCharacters(String input)
	{
    	Matcher m = Pattern.compile('[\\u0000-\\u007F]*').matcher(input);
    	return !m.matches();
	}

	public static String getDatasetUploadStatus(String datasetDevName){
        try {
            InsightsExternalData iedObj = [SELECT Status FROM InsightsExternalData WHERE EdgemartAlias = :datasetDevName ORDER BY CreatedDate DESC LIMIT 1];
            return iedObj.Status;
        } 
        catch (Exception ex) {
            return '';
        }
    }

	public String insertDashboard(String dashboardJson){
        HTTPResponse res = WaveConfiguratorUtils.httpCallout('/services/data/v' + this.apiVersion + '/wave/dashboards', 'POST', true, dashboardJson);
        if(!WaveConfiguratorUtils.checkStatus(res)){
            if(res.getBody().containsIgnoreCase('errorCode')){
                List<RestApiErrorResponse> r = (List<RestApiErrorResponse>)JSON.deserialize(res.getBody(), List<RestApiErrorResponse>.class);
                throw new WaveConfiguratorException('Dashboard could not be created. Cause: ' + r.get(0).message + '.');
            }
            throw new WaveConfiguratorException('Dashboard could not be created. Check debug logs.');
        }
        else {
            RestApiResponseBody responseBody = (RestApiResponseBody)JSON.deserialize(res.getBody(), RestApiResponseBody.class);
              return responseBody.id;
        }
    }

	public Map<String, String> insertAnalyticsImages(WaveApplicationImage imgObject){
        Blob file = this.getUrlContentsAsBlob(imgObject.zipUrl);
		Zippex zip = new Zippex(file);
		List<ContentVersion> lContentVersions = new List<ContentVersion>();		

		for(String fileName: zip.getFileNames()){
			System.debug(fileName);
			Blob image = zip.getFile(fileName);
			
			if(!fileName.contains('/')){
				ContentVersion cv = new ContentVersion();
				cv.IsAssetEnabled = true;
				cv.Title = fileName;
				cv.PathOnClient = fileName;
				cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.base64Encode(image));
				lContentVersions.add(cv);	
			}
		}
		
		// DML
		insert lContentVersions;
		List<String> lstIdsCv = new List<String>();
		for (ContentVersion c: lContentVersions) {
			lstIdsCv.add(c.Id);
		}

		Map<String, String> mapping = new Map<String, String>();
		List<ContentVersion> lSavedContentVersions = [SELECT PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id IN :lstIdsCv];
		for (ContentVersion newCv : lSavedContentVersions) {
			mapping.put(newCv.PathOnClient, newCv.ContentDocumentId);
		}

		return mapping;
	}
	
	public static String generateApiName(String label){
		String nameToSuggest = label.trim();
		while (nameToSuggest.substring(0 ,1).isNumeric()) {
			nameToSuggest = nameToSuggest.substring(1);
		}
		
		return nameToSuggest.replaceAll('[^a-zA-Z0-9]', '_');
	}
}