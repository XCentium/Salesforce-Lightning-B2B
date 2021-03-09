public with sharing class WaveDataManagerController {
	
	public String VisualforceContextHost { get;set; }
    public String Host { get;set; }
	public String RemoteSiteName { get { return 'InstanceHost'; } }
	public String MetadataResponse {get;set;}
	public Boolean MetadataConnectionWarning {get;set;}
	public String MetadataApiException {get;set;}
	public String selectedWaveApp { get; set; }
	public String errorMessage { get; set; }
	public String successMessage  { get; set; }
	public String warningMessage  { get; set; }
	public Id batchProcessId { get; set; }
	public Id queueProcessId { get; set; }
	public List<String> processingLog { get; set; }
	public Set<String> processingLogWithoutTime { get; set; }
	public Integer currentNodeIndex { get; set; }
	public Integer currentTimeShiftingNodeIndex { get; set; }
	public String currentObjectProcessing { get; set; }
	public List<WaveApplicationObject> objectsNodes { get; set; }
	public List<WaveApplicationEdgemart> edgemartsNodes { get; set; }
	public boolean disabledButton { get; set; }
	private WaveMetadata metadata;
	private Map<String, String> appDescriptions; // <appName, appDesc>
	private Map<String, Integer> appIndexes; // <appName, appIndex in this.metadata.waveApplications>
	public String emailAddress { get; set; }
	public List<WaveApplicationRow> applicationRows;
	public WaveMetadataApplication selectedAppMetadata { get; set; }
	public GenericAppConfiguration genericAppConfiguration { get; set; }
	public static final String genericAppConfigurationFileName = 'SEADemoDataLoaderConfig';
	public Boolean pageRendered { get; set; }
	public WaveConfiguratorUtils utils;
	public List<WaveTimeShiftingItem> timeShiftingItems { get; set; }
	public Boolean enableTimeShiftingCheck { get; set; }
	public Boolean enableObjectProcessingCheck { get; set; }
	public String selectedInstallationProcess { get; set; }
	public List<List<SF_MetadataUtils.CustomFieldSpecification>> objectsAndFieldsMatrix;
	public Integer currentObjectIndex;
	public Integer currentFieldIndex;
	public Integer currentEdgemartIndex;
	public Boolean processingObjectsAndFieldsMetadata { get; set; }
	public Boolean processingEdgemartsLoad { get; set;}
	public List<List<SF_MetadataUtils.RecordTypeSpecification>> objectsRecordTypesMatrix;
	public Integer currentRecordTypeIndex;
	public Boolean processingRecordTypes { get; set; }
	public List<UserPhotoInfo> userPhotoNodes;
	public Integer currentUserPhotoNodeIndex;
	public Boolean uploadingUserPhotos { get; set; }
	public Boolean advancedOption { get; set; }
	public Integer daysToShift { get; set; }
	public String timeShiftingcalculatedDateLabel { get; set; }
	public Map<String,Map<String,String>> operationsStatusTable { get; set; }
	public String timeShiftingWhereClause { get; set; }
	public Boolean advancedTimeShifting { get; set; }
	public Boolean overrideDefaultSettingTS { get; set; }
	public List<AnalyticsDemoFAQ> analyticsDemoFAQ { get; set; }
	public String baseUrl { get; set; } 
	public Map<String, Boolean> selectedObjectsToTimeShift { get; set; }
	public CustomModalConfirmation modalMessage { get; set; }
	public CustomModalConfirmation modalDetailsMessage { get; set; }
	public Boolean shiftOnlyOfApp { get; set; }
	public String selectedDataflow { get; set; }
	public String selectedDataflowForActionFields { get; set; }
	public String selectedAnalyticsApp { get; set; }
	public Map<String, Map<String, WaveApplicationActionField>> actionInputFields { get; set; }
	public String createCompleteAppId { get; set; }
	public String createCompleteAppLabel { get; set; }
	public String createCompleteAppName { get; set; }
	private Map<String, String> folderIdByDatasetDevName; // <dataset developer name in org, folder id where it is stored>
	private Map<String, String> idsByDatasetDevName; // <dataset developer name in org, dataset id with which it is stored>
	private Map<String, WaveApplicationDataset> datasetsMap; // <dataset name as it comes from JSON, Dataset object as processed>
	private Map<String, WaveApplicationDashboard> dashboardsMap; // <dashboard name as it comes from JSON, Dashboard object as processed>
    private Map<String, String> dashboardImagesMapping;
	private Map<String, String> dashboardsIdsByName;
	private WaveApplicationImage referencedImages;
    public String insightsAppName { get; set; }
    public String insightsAppLabel { get; set; }
    public String insightsAppId { get; set; }
	public String handleCompleteAppFolderId { get; set; }
	public List<WaveApplicationDataset> datasetsNodes { get; set; }
	public Boolean processingLoadDatasets { get; set; }
	public Boolean processingLoadDashboards { get; set; }
	public List<WaveApplicationDashboard> dashboardsNodes { get; set; }
	public Integer currentDatasetIndex { get; set; }
	public Integer currentDashboardIndex { get; set; }
	//public WaveApplicationDataflow dataflowConfig { get; set; }
	
	// Cookie String for the following tools
	public String cookieString { get; set; }
	
	// *** Template Deploy Tool ***
	private Boolean retrievedTemplates;
	private Map<String, RepositoryTemplateResponse> repositoryTemplatesMap;
	private List<String> undraggedTemplates;
	public String[] templatesToDrag { get; set; }
	public String[] templatesToReturn { get; set; }
	public String[] selectedTemplates { get; set; }
	
	public Boolean processingTemplateDeployment { get; set; }
	public String dplErrorMessage { get; set; }
	public String dplWarningMessage { get; set; }
	public String dplSuccessMessage { get; set; }
	public String dplJobId { get; set; }
	public Boolean advancedTemplateDeploy { get; set; }
	public String tplDeployUrl { get; set; }
	public String tplDeployRepoBranch { get; set; }

	// *** Timeshifting Dataflow Tool ***
	private Boolean retrievedTsDatasets;
	public Boolean processingTimeshiftingDataflow { get; set; }
	public String tsdfErrorMessage { get; set; }
	public String tsdfWarningMessage { get; set; }
	public String tsdfSuccessMessage { get; set; }
	public String tsdfJobId { get; set; }
	public Boolean advancedTimeshiftingDataflow { get; set; }
	public String tsdfUrl { get; set; }
	public Map<String, FolderDatasetResponse> mapOfDatasetsByFolder { get; set; }
	public String selectedAppForTimeshiftingDataflow { get; set; }
	public List<DatasetItemResponse> selectedDatasetsForTimeshiftingDataflow { get; set; }
	public Map<String, DatasetItemResponse> mapOfDatasetsForTimeshiftingDataflow { get; set; }
	public String tsdfJSON { get; set; }
	public String tsdfLabel { get; set; }
	public String tsdfName { get; set; }
	public String tsdfCreateOrReplace { get; set; }
	public String selectedDataflowForTimeshiftingDataflow { get; set; }

	// Secuence control
	public String installationStep { get; set; }

	public class UserPhotoInfo {
		public String zipFileUrl;
		public String fileNameToExtract;
		public String fileBaseName;
	}

	public WaveDataManagerController() {
		this.objectsNodes = new List<WaveApplicationObject>();
		this.edgemartsNodes = new List<WaveApplicationEdgemart>();
		this.datasetsNodes = new List<WaveApplicationDataset>();
		this.dashboardsNodes = new List<WaveApplicationDashboard>();
		this.timeShiftingItems = new List<WaveTimeShiftingItem>();
		this.processingLog = new List<String>();
		this.processingLogWithoutTime = new Set<String>();
		this.appDescriptions = new Map<String, String>();
		this.appIndexes = new Map<String, Integer>();
		this.emailAddress = UserInfo.getUserEmail();
		this.utils = new WaveConfiguratorUtils();
		this.objectsAndFieldsMatrix = new List<List<SF_MetadataUtils.CustomFieldSpecification>>();
		this.objectsRecordTypesMatrix = new List<List<SF_MetadataUtils.RecordTypeSpecification>>();
		this.MetadataResponse = '';
		this.installationStep = '';
		this.enableTimeShiftingCheck = false;
		this.enableObjectProcessingCheck = false;
		this.processingObjectsAndFieldsMetadata = false;
		this.selectedInstallationProcess = '';
		this.userPhotoNodes = new List<UserPhotoInfo>();
		this.advancedOption = false;
		this.advancedTimeShifting = false;
		this.daysToShift = 0;
		this.overrideDefaultSettingTS = false;
		this.shiftOnlyOfApp = true;
		this.operationsStatusTable = new Map<String,Map<String,String>>();
		this.analyticsDemoFAQ = new List<AnalyticsDemoFAQ>();
		this.selectedObjectsToTimeShift = new Map<String, Boolean>();
		this.modalMessage = new CustomModalConfirmation();
		this.modalDetailsMessage = new CustomModalConfirmation();
		this.retrievedTemplates = false;
		this.repositoryTemplatesMap = new Map<String, RepositoryTemplateResponse>();
		this.undraggedTemplates = new List<String>();
		this.templatesToDrag = new String[]{};
		this.templatesToReturn = new String[]{};
		this.selectedTemplates = new String[]{};
		this.cookieString = '';
		this.advancedTemplateDeploy = false;
		this.tplDeployRepoBranch = 'master';

		this.retrievedTsDatasets = false;
		this.selectedDatasetsForTimeshiftingDataflow = new List<DatasetItemResponse>();
		this.mapOfDatasetsForTimeshiftingDataflow = new Map<String, DatasetItemResponse>();
	}

	public PageReference pageLoad()
	{
		// Get Host Domain
		String result = null;
		List<String> fragments = URL.getSalesforceBaseUrl().getHost().split('\\.');

        if(fragments.size() == 3) {
        	result = fragments[0]; // Note: Apex URL: NA14.salesforce.com
    	}
    	else if(fragments.size() == 4){
            result = fragments[0] + '.' + fragments[1]; // Note: Apex URL: pmm-test-org.my.salesforce.com
        }
	    else if(fragments.size() == 5) {
        	result = fragments[1]; // Note: Visualforce URL: mydomain.NA14.visual.force.com
    	}
        
		Host = 'https://' + result + '.salesforce.com';
       	VisualforceContextHost = URL.getSalesforceBaseUrl().toExternalForm();
		
		try{

			//Get App Configuration File
			this.genericAppConfiguration = utils.getAppConfiguration(genericAppConfigurationFileName);
			this.pageRendered = true;
			this.baseUrl = this.genericAppConfiguration.baseUrl;
			this.tplDeployUrl = this.genericAppConfiguration.tplDeployBaseUrl;
			this.tsdfUrl = this.genericAppConfiguration.tplDeployBaseUrl;

			if(System.Test.isRunningTest()){
				this.baseUrl = this.genericAppConfiguration.baseDevUrl;
			}

			this.getFaqJson();
			
			// Attempt to connect to the Metadata API
			MetadataConnectionWarning = false;
			if(!System.Test.isRunningTest() && !SF_MetadataUtils.checkMetadataAPIConnection())
			{
				this.warningMessage = 'Current Salesforce Instance URL not found in Remote Sites. See details below:';
				MetadataConnectionWarning = true;
				MetadataApiException = '';
				/*if(RollupService.LastMetadataAPIConnectionException!=null)
					MetadataApiException = RollupService.LastMetadataAPIConnectionException.getMessage();*/
			}

			if(applicationRows == null){
				applicationRows = WaveConfiguratorUtils.getWaveApplications(this.baseUrl + this.genericAppConfiguration.waveApplicationsUrl);
				if(this.applicationRows != null){
					Integer index = 0;
		        	for(WaveApplicationRow genericApp: this.applicationRows) {
						this.appIndexes.put(genericApp.Name, index);
						this.appDescriptions.put(genericApp.Name, genericApp.Description);
						index++;
					}
		        }
			}
		} 
		catch(WaveConfiguratorException ex){
			this.errorMessage = ex.getMessage();			
		}

		return null;
	}

	private void logMessage(String msg){

		if(!this.processingLogWithoutTime.contains(msg)){
			DateTime dtNow = DateTime.now();
			this.processingLog.add(String.format('[{0}] {1}', new String[]{ dtNow.format('yyyyMMdd HH:mm:ss') , msg }));
		}

		this.processingLogWithoutTime.add(msg);
	}

	public void getFaqJson(){
		try{
			if(String.isNotBlank(genericAppConfiguration.faqJsonUrl)){
				Http http = new Http();
				HttpRequest req = new HttpRequest();

				req.setEndpoint(this.baseUrl + genericAppConfiguration.faqJsonUrl);
		        req.setMethod('GET');

		        HTTPResponse res = http.send(req);
		        
		        if(WaveConfiguratorUtils.checkStatus(res)){
		        	this.analyticsDemoFAQ = (List<AnalyticsDemoFAQ>)JSON.deserialize(res.getBody(), List<AnalyticsDemoFAQ>.class);
		        }
		        else { 
		        	throw new WaveConfiguratorException('Error ' + res.getStatusCode() + ' - ' + res.getStatus() + ' in the attempt to get the FAQ file. Please make sure that it is pointing to a proper url');
		        }
			} 
			else {
				throw new WaveConfiguratorException('The FAQ file could not be retrieved. Please make sure that it is specified in the configuration file pointing to a proper url.');
			}    
    	} 
    	catch(Exception ex){
    		this.errorMessage = ex.getMessage();
    	}
	}

	public void handleAdvancedSetting(){
		this.advancedOption = !this.advancedOption;
	}

	public void handleAdvancedTimeShifting(){
		this.advancedTimeShifting = !this.advancedTimeShifting;
	}

	public void getWaveApplications(){
		this.errorMessage = '';
		this.applicationRows = null;
		
		try{
			applicationRows = WaveConfiguratorUtils.getWaveApplications(this.baseUrl + this.genericAppConfiguration.waveApplicationsUrl);			
			if(this.applicationRows != null){
				Integer index = 0;
	        	for(WaveApplicationRow genericApp: this.applicationRows) {
					this.appIndexes.put(genericApp.Name, index);
					this.appDescriptions.put(genericApp.Name, genericApp.Description);
					index++;
				}
	        }
        }
        catch(Exception ex){
        	this.errorMessage = 'The ' + this.baseUrl + this.genericAppConfiguration.waveApplicationsUrl + ' URL doesn\'t point to a valid wave applications list resource. Try changing Base URL and/or Application List URI.';
        }
	}

	public List<SelectOption> getWaveApps() {
        
        List<SelectOption> options = new List<SelectOption>();

        if(this.applicationRows != null){
        	for(WaveApplicationRow genericApp: this.applicationRows) {
				options.add(new SelectOption(genericApp.Name, genericApp.Label));
			}
        }

        return options;
    }

	public List<SelectOption> getAvailableProcesses() {
        
        List<SelectOption> options = new List<SelectOption>();

		/*
		<apex:selectOption itemValue="loadObjects" itemLabel="Load Data into Core"/>
		<apex:selectOption itemValue="createMetadata" itemLabel="Create Objects and Fields"/>
		<apex:selectOption itemValue="timeShifting" itemLabel="Time shifting"/>
		<apex:selectOption itemValue="loadEdgemarts" itemLabel="Load Datasets"/>
		<apex:selectOption itemValue="setActionFields" itemLabel="Set Action Fields"/>
		*/		

		if (this.selectedAppMetadata != null) {
			// Options to work with ORG Objects
			if (this.selectedAppMetadata.objects != null && this.selectedAppMetadata.objects.size() > 0) {
				// UX depends on availability of configuration
				Boolean addLoadObjects = false;
				Boolean addCreateMetadata = false;
				Boolean addTimeshifting = false;

				for (WaveMetadataApplicationObject wmaObj : this.selectedAppMetadata.objects) {
					// If there is some piece of config for metadata
					if (String.isNotBlank(wmaObj.metadataUrl)) {
						addCreateMetadata = true;
					}

					// URL with data to load
					if (String.isNotBlank(wmaObj.url)) {
						addLoadObjects = true;
					}

					// Timeshifting fields
					if (wmaObj.dateFieldsToShift != null && wmaObj.dateFieldsToShift.size() > 0) {
						addTimeshifting = true;
					}
				}

				if (addLoadObjects) {
					options.add(new SelectOption('loadObjects', 'Load Data into Core'));	
				}
				
				if (addCreateMetadata) {
					options.add(new SelectOption('createMetadata', 'Create Objects and Fields'));	
				}
				
				if (addTimeshifting) {
					options.add(new SelectOption('timeShifting', 'Time shifting'));	
				}
			}

			// Options to work with datasets
			if (this.selectedAppMetadata.edgemarts != null && this.selectedAppMetadata.edgemarts.size() > 0) {
				options.add(new SelectOption('loadEdgemarts', 'Load Datasets'));
			}

			if (this.selectedAppMetadata.actionFieldOverrides != null && this.selectedAppMetadata.actionFieldOverrides.size() > 0) {
				options.add(new SelectOption('setActionFields', 'Set Action Fields'));
			}

			if ((this.selectedAppMetadata.datasets != null && this.selectedAppMetadata.datasets.size() > 0) || (this.selectedAppMetadata.dashboards != null && this.selectedAppMetadata.dashboards.size() > 0)) {
				options.add(new SelectOption('createCompleteApp', 'Create App, Datasets and Dashboards'));
			}

			if ((this.selectedAppMetadata.datasets != null && this.selectedAppMetadata.datasets.size() > 0)) {
				options.add(new SelectOption('loadDatasetsToExistingApp', 'Load Datasets into existing app'));
			}

			if (options.size() > 0) {
				options.add(0, new SelectOption('', 'None'));
			}
		}

        return options;
    }

	public List<SelectOption> getOrgDataflows() {
        
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'None')); // Empty item

        List<Dataflow> lstDataflows = [SELECT Id, MasterLabel FROM Dataflow WHERE DataflowType = 'User' AND State = 'Active' ORDER BY MasterLabel];
		for(Dataflow dataflowItem: lstDataflows) {
			options.add(new SelectOption(dataflowItem.Id, dataflowItem.MasterLabel));
		}

        return options;
    }

	public List<SelectOption> getOrgAnalyticsApps() {
        
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'None')); // Empty item

        List<InsightsApplication> lstApps = [SELECT Id, MasterLabel FROM InsightsApplication WHERE DeveloperName NOT IN ('WAVE_PUBLIC_DATAFLOWS', 'SharedApp')];
		for(InsightsApplication apptem: lstApps) {
			options.add(new SelectOption(apptem.Id, apptem.MasterLabel));
		}

        return options;
    }

	public List<SelectOption> getOrgAnalyticsFolders() {
        
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'None')); // Empty item

        List<Folder> lstApps = [SELECT Id, Name FROM Folder WHERE Type = 'Insights' AND Name NOT IN ('WavePublicDataflowsLabel', 'Einstein Bots', 'Einstein Forecasting')];
		for(Folder apptem: lstApps) {
			options.add(new SelectOption(apptem.Id, apptem.Name));
		}

        return options;
    }

    public void saveSetting(){
    	this.overrideDefaultSettingTS = true;
    	this.selectedProcess();
    }

	public void selectedApp(){
		this.selectedInstallationProcess = '';
		if (String.isNotBlank(this.selectedWaveApp)) {
			this.selectAppMetadata();
		}
	}

    public void selectedProcess(){
    	
    	this.resetMessages();

    	try{
			if(this.selectedInstallationProcess == 'timeShifting'){

				if(String.isNotBlank(this.selectedWaveApp)){
					this.getObjectsToTimeShift();
					
					List<String> objNames = new List<String>();

					for(String selectedObjs: this.selectedObjectsToTimeShift.keySet()){
						if(this.selectedObjectsToTimeShift.get(selectedObjs)){
							objNames.add(selectedObjs);
						}
					}

					this.checkForTriggersAndRules(objNames, true);
				}
				this.calculateDaysToShift();
			} 
			else if(this.selectedInstallationProcess == 'loadObjects'){
				
				if(String.isNotBlank(this.selectedWaveApp)){
					this.selectAppMetadata();
					List<String> objNames = new List<String>();

					for(WaveMetadataApplicationObject wmaObj: this.selectedAppMetadata.objects) {
						objNames.add(wmaObj.name);
					}

					this.checkForTriggersAndRules(objNames, false);
				}
			}
			else if(this.selectedInstallationProcess == 'setActionFields'){
				
				this.actionInputFields = new Map<String, Map<String, WaveApplicationActionField>>();

				if(String.isNotBlank(this.selectedWaveApp)){
					this.selectAppMetadata();
					
					if(this.selectedAppMetadata.actionFieldOverrides != null){
						
						for(WaveMetadataApplicationActionField wmaAF: this.selectedAppMetadata.actionFieldOverrides) {
							
							WaveApplicationActionField waAF = new WaveApplicationActionField();
							waAF.datasetName = wmaAF.datasetName;
							waAF.actionFieldName = wmaAF.actionFieldName;
							waAF.actionFieldLabel = wmaAF.actionFieldLabel;
							waAF.computeExpressionName = wmaAF.computeExpressionName;

							// Build action fields inputText list
							Map<String, WaveApplicationActionField> mapWaf;
							
							if (this.actionInputFields.containsKey(waAF.datasetName)) {
								mapWaf = this.actionInputFields.get(waAF.datasetName);
							}
							else {
								mapWaf = new Map<String, WaveApplicationActionField>();
								this.actionInputFields.put(waAF.datasetName, mapWaf);
							}

							mapWaf.put(waAF.actionFieldName, waAF);
						}
					}
				}
			}
		}
		catch(Exception e){
            System.debug(e.getStackTraceString());
			this.errorMessage = e.getMessage();
		}
    }

    public void checkForTriggersAndRules(List<String> objNames, Boolean timeShifting){

    	List<ApexTrigger> triggers = [SELECT Status, TableEnumOrId FROM ApexTrigger WHERE TableEnumOrId IN :objNames];
    	
    	//Set that will contain the objects with triggers/wk/rules if found.
    	Set<String> objectsToWarn = new Set<String>(); 

    	if(triggers.size() > 0){
    		for(ApexTrigger tr: triggers){
    			if(tr.Status.equalsIgnoreCase('Active')){
    				objectsToWarn.add(tr.TableEnumOrId);
    			}
    		}
    	}

    	//Won't be necessary to search for Workflows/Rules in objects that already have triggers.
    	List<String> objWithoutTriggers = new List<String>();

    	for(String obj: objNames){
    		if(!objectsToWarn.contains(obj)){
    			objWithoutTriggers.add(obj);
    		}
    	}

    	List<String> objWithRulesOrWorkflows = SF_MetadataUtils.getObjectsWithRulesAndOrWorkflows(objWithoutTriggers, genericAppConfiguration.apiVersion);
    	this.buildConfirmationModal(objWithRulesOrWorkflows, objectsToWarn, timeShifting);
    }

	public void checkCreateCompleteAppExistence(){
		this.clearModal();
		if (this.utils.folderExists(this.createCompleteAppName)) {
			this.buildConfirmationModalGeneric('Process confirmation', 'The analytics application that you entered already exists. This action will overwrite all its dashboards and datasets. You may loose any customization made on it. Are you sure you want to continue?');
		}
	}

    public void buildConfirmationModal(List<String> objNames, Set<String> objToDisplay, Boolean timeShifting){
    	
    	this.clearModal();

    	//If there are workflows and/or validation rules, we added it to the main list.
    	if(objNames.size() > 0){
    		objToDisplay.addAll(objNames);
    	}

    	//If we have elements in list, we build the string to display in modal.
    	if(objToDisplay.size() > 0){
			String objectsDetected = '';

			Integer i = 0;
			for(String obj: objToDisplay){
				objectsDetected += obj;

				if(i < objToDisplay.size() - 1){
					objectsDetected += ', ';
				}

				i++;
			}
		
			modalMessage.body = 'Triggers, Workflow Rules and/or Validation Rules detected on the following objects: ' + objectsDetected + '. Make sure they are inactive or process may fail.';
		}
		
		//If time shifting, the modal will be displayed anyway.
    	if(timeShifting){
    		modalMessage.header = 'Process Confirmation';
    		modalMessage.body += ' All records will be time-shifted.';
    	}
    	else {
    		//If not time shifting , we make appear confirmation only when there're Triggers/Workflows/Rules
    		if(objToDisplay.size() > 0){
    			modalMessage.header = 'Process Confirmation';	
    		}
    	}
        
        modalMessage.body += ' Are you sure you want to continue?';
    }	

    public void clearModal(){
    	modalMessage.header = '';
    	modalMessage.body = '';
    }

	public void buildConfirmationModalGeneric(String modalHeader, String modalBody){
    	this.clearModal();
		modalMessage.header = modalHeader;
		modalMessage.body = modalBody;
    }

    public void getObjectsToTimeShift(){
    	this.selectAppMetadata();
    	this.selectedObjectsToTimeShift.clear();

    	for(WaveMetadataApplicationObject wmaObj: this.selectedAppMetadata.objects) {
    		if(wmaObj.dateFieldsToShift != null && wmaObj.dateFieldsToShift.size() > 0){
    			this.selectedObjectsToTimeShift.put(wmaObj.Name, true);
    		}
    	}
    }

    public void calculateDaysToShift(){
		
		TimeShiftSettings tsSettings = this.selectedAppMetadata.timeShift;

		if(tsSettings != null && (String.isNotBlank(tsSettings.tObject) 
			&& String.isNotBlank(tsSettings.dateField) 
			&& String.isNotBlank(tsSettings.displayText))){
			
			String dateField = tsSettings.dateField;
			String baselineObjectName = tsSettings.tObject;
			this.timeShiftingcalculatedDateLabel = tsSettings.displayText;
		
			if(!this.overrideDefaultSettingTS){
				this.timeShiftingWhereClause = tsSettings.filter;
			}
			
			String dynamicSoql = 'SELECT ' + dateField + ' FROM ' + baselineObjectName;
			
			if(String.isNotBlank(this.timeShiftingWhereClause)){
				dynamicSoql += ' WHERE ' + this.timeShiftingWhereClause;
			}

			dynamicSoql += ' ORDER BY ' + dateField + ' DESC NULLS LAST';
			dynamicSoql += ' LIMIT 1';

			try{
				List<sObject> sobjList = Database.query(dynamicSoql);
				if(sobjList.size() > 0){				
					sObject s = sobjList.get(0);
					DateTime foundDate = (DateTime)s.get(dateField);
					if(foundDate != null) {
						String formattedDate = foundDate.formatGmt('MM/dd/yyyy');

						Date compareDate = Date.today();

						if(String.isNotBlank(tsSettings.compareDate)){
							compareDate = Date.valueOf(tsSettings.compareDate);	
						}

						Datetime dtCompareDate = (DateTime)compareDate;
						this.timeShiftingcalculatedDateLabel += ': ' + formattedDate + ' compared to ' + dtCompareDate.formatGmt('MM/dd/yyyy');
						this.daysToShift = foundDate.dateGMT().daysBetween(compareDate);
					}
					else {
						this.daysToShift = 0;
					}
				}
				else{
					this.daysToShift = 0;
				}
			}
			catch(Exception e){
				this.errorMessage = 'There was an error trying to calculate the days to shift. Error detail: ' + e.getMessage();
			}
		} else {
			this.daysToShift = 0;
			this.warningMessage = 'Unable to calculate the Number of Days to Shift Records. Please enter it manually.';
		}
	}
		

    public void updateSelectedObjectsToTimeShift(){
    	this.timeShiftingItems.clear();
		this.selectAppMetadata();

		List<String> objToCheck = new List<String>();

		for(WaveMetadataApplicationObject wmaObj: this.selectedAppMetadata.objects) {
			//If object is selected in UI
			if(this.selectedObjectsToTimeShift.containsKey(wmaObj.Name)){
				if(this.selectedObjectsToTimeShift.get(wmaObj.Name)){
					this.addTimeShiftingNode(wmaObj);
					objToCheck.add(wmaObj.Name);
				}
			}
		}

		this.checkForTriggersAndRules(objToCheck, true);
    }

    public String getAppDescription(){
    	
    	String dsc = 'No description available.';

    	if(!String.isBlank(this.selectedWaveApp) && this.appDescriptions.containsKey(this.selectedWaveApp)){
    		dsc =  this.appDescriptions.get(this.selectedWaveApp);
    	}
    	
    	return dsc;
    }

	public void resetMessages(){
		this.errorMessage = '';
		this.successMessage = '';
		this.warningMessage = '';
		this.processingLog.clear();
		this.processingLogWithoutTime.clear();

		this.dplErrorMessage = '';
		this.dplSuccessMessage = '';
		this.dplWarningMessage = '';

		this.tsdfErrorMessage = '';
		this.tsdfSuccessMessage = '';
		this.tsdfWarningMessage = '';

		this.modalDetailsMessage.body = '';
		this.modalDetailsMessage.header = '';
	}

	public List<WaveApplicationObject> getObjectsToProcess(WaveMetadataApplicationObject wmaObj){
		List<WaveApplicationObject> listToProcess = new List<WaveApplicationObject>();
		
        if(String.isNotBlank(wmaObj.url) && String.isNotBlank(wmaObj.metadataUrl)){
            
            WaveApplicationObject rootObj = new WaveApplicationObject();
            rootObj.name = wmaObj.name;
            rootObj.url = this.baseUrl + wmaObj.url;
            rootObj.additionalDataFiles = wmaObj.additionalDataFiles;
            rootObj.stdFieldsForPermissionSet = wmaObj.stdFieldsForPermissionSet;
    
            listToProcess.add(rootObj);
    
            // We process the fields metadata
            IMockarooHelper iMockHelper = MockarooHelperFactory.getIMockarooHelper();
            
            String metadataUrl = this.baseUrl + wmaObj.metadataUrl;
    
            List<List<String>> csvMetadata = iMockHelper.getData(metadataUrl, false);
            if(csvMetadata.size() > 0){
                // Will extract headers
                List<String> headers = csvMetadata.remove(0);
                Map<String, Integer> fieldPositions = new Map<String, Integer>();
                
                for(Integer i = 0; i < headers.size(); i++) {
                    String fieldName = headers.get(i);
                    fieldName = fieldName.replace('"', '');
                    fieldPositions.put(fieldName, i);
                }
    
                // For each row of data in the CSV
                rootObj.fields = new List<WaveApplicationObjectField>();
    
                try{
                    for(List<String> metadataRow: csvMetadata) {
    
                        WaveApplicationObjectField fieldMetadata = new WaveApplicationObjectField();
                        fieldMetadata.Label = metadataRow.get(fieldPositions.get('Label')).trim();
                        fieldMetadata.Name = metadataRow.get(fieldPositions.get('Name')).trim();
                        fieldMetadata.Type = metadataRow.get(fieldPositions.get('Type')).trim();
                        fieldMetadata.PickListValues = metadataRow.get(fieldPositions.get('PickListValues')).trim();
                        fieldMetadata.ReferenceTo = metadataRow.get(fieldPositions.get('ReferenceTo')).trim();
                        fieldMetadata.Length = Integer.valueOf(metadataRow.get(fieldPositions.get('Length')));
                        fieldMetadata.Precision = Integer.valueOf(metadataRow.get(fieldPositions.get('Precision')));
                        fieldMetadata.Scale = Integer.valueOf(metadataRow.get(fieldPositions.get('Scale')));
                        fieldMetadata.IsExternalId = Boolean.valueOf(metadataRow.get(fieldPositions.get('IsExternalId')));
                        fieldMetadata.IsRequired = Boolean.valueOf(metadataRow.get(fieldPositions.get('IsRequired')));
                        fieldMetadata.DefaultValue = metadataRow.get(fieldPositions.get('DefaultValue')).trim();
                        fieldMetadata.Formula = metadataRow.get(fieldPositions.get('Formula')).trim();
    
                        rootObj.fields.add(fieldMetadata);
                    }	
                } 
                catch(Exception ex){				
                    throw new WaveConfiguratorException('There is a configuration error. Missing csv columns at ' + metadataUrl);
                }
                
            }
            else {
                throw new WaveConfiguratorException('There is a configuration error. No metadata csv found at ' + metadataUrl + ' URL.');
            }
    
            // We process the relations
            rootObj.relations = new List<WaveApplicationObjectRelation>();
            if(wmaObj.relations != null){
                for(WaveMetadataApplicationObjectRelation relObj: wmaObj.relations) {
                    WaveApplicationObjectRelation rel = new WaveApplicationObjectRelation();
                    
                    rel.csvColumnName = relObj.csvColumnName;
                    rel.targetSObject = relObj.targetSObject;
                    rel.targetSObjectLookupField = relObj.targetSObjectLookupField;
                    rel.foreignKeyField = relObj.foreignKeyField;
    
                    if (relObj.compositeForeignKey != null) {
                        // We have a composite foreign key
                        rel.compositeForeignKey = new List<WaveApplicationCompositeForeignKeyPart>();
    
                        for (WaveMetadataCompositeForeignKeyPart wmcFKP : relObj.compositeForeignKey) {
                           WaveApplicationCompositeForeignKeyPart wacFKP = new WaveApplicationCompositeForeignKeyPart();
                           wacFKP.csvColumnName = wmcFKP.csvColumnName;
                           wacFKP.targetSObjectLookupField = wmcFKP.targetSObjectLookupField;
                           rel.compositeForeignKey.add(wacFKP);
                        }
                    }
    
                    rootObj.relations.add(rel);
                }
            }
    
            // Replicate for each adittional data CSV file
    
            // We process the children
            if(wmaObj.children != null) {
                // Now the children objects
                for(WaveMetadataApplicationObject chObj: wmaObj.children) {
                    List<WaveApplicationObject> childrenObjs = getObjectsToProcess(chObj);
                    listToProcess.addAll(childrenObjs);
                }
            }
        }

		return listToProcess;
	}

	private void processCurrentObjectLoadNode(){
		
		try{
			WaveApplicationObject currentNode = this.objectsNodes.get(this.currentNodeIndex);
			this.operationsStatusTable.get(currentNode.Name).put('LoadData','In progress');
			this.logMessage('Loading records for ' + currentNode.name + ' object...');
            
            String csvDataWithHeaders;
            HttpResponse res;
            String url;

            // Check whether we are in the initial chunk of CSV data or not
            if(currentNode.currentDataIndex == 0){
                // We start processing the initial chunk of data
                url = currentNode.url;
				res = WaveConfiguratorUtils.httpGetCallout(url);
                csvDataWithHeaders = res.getBody();
            }
            else {
                url = currentNode.url.substringBeforeLast('.csv') + '-' + currentNode.currentDataIndex + '.csv';
                res = WaveConfiguratorUtils.httpGetCallout(url);
                csvDataWithHeaders = res.getBody();
            }

            if(res.getStatusCode() != 200) {
				throw new WaveConfiguratorException('There is a configuration error. No data csv found at ' + url + ' URL.');            	
            }

			// We search for \n
			Integer indexOfLF = csvDataWithHeaders.indexOf('\n');
			if(indexOfLF != -1){
				
				String headersLine = csvDataWithHeaders.substring(0, indexOfLF);
								
				// We search for \r
				if(headersLine.indexOf('\r') != -1){
					headersLine = headersLine.replace('\r', '');
				}

				headersLine = headersLine.replace('"', '');
				List<String> headers = headersLine.split(',');
				
				currentNode.fieldPositions = new Map<Integer, String>();
					
				for(Integer i = 0; i < headers.size(); i++) {
					currentNode.fieldPositions.put(i, headers[i]);
				}

				String csvData = csvDataWithHeaders.substringAfter('\n');
				if(csvData.length() > 0){

					this.currentObjectProcessing = currentNode.name;

					// Start the batch process
					CsvDataImportBatch batchProcess = new CsvDataImportBatch(Schema.getGlobalDescribe().get(currentNode.name), csvData, currentNode.fieldPositions, currentNode.relations, genericAppConfiguration.apiVersion);
					this.batchProcessId = Database.executeBatch(batchProcess, this.genericAppConfiguration.objectLoadingBatchSize);
					this.enableObjectProcessingCheck = true;					
				}
			}	
		} 
		catch(Exception e){
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.enableObjectProcessingCheck = false;
			this.disabledButton = false;
			this.errorMessage = e.getMessage();
		}	
	}


	private void processTimeShiftingObjects(){
		
		if(this.timeShiftingItems.size() > 0){
			WaveTimeShiftingItem currentNode = this.timeShiftingItems.get(this.currentTimeShiftingNodeIndex);
			this.operationsStatusTable.get(currentNode.objectTypeName).put('TimeShifting','In progress');
			this.logMessage('Loading ' + currentNode.fieldsToTimeShift.size() + ' fields for time shifting for ' + currentNode.objectTypeName + ' object...');

			String externalIdPrefix = '';

			if(this.shiftOnlyOfApp){
				externalIdPrefix = currentNode.externalIdObjectPrefix;
			}

			// Start the batch process
			TimeShiftingBatch batchProcess = new TimeShiftingBatch(currentNode.objectTypeName, currentNode.fieldsToTimeShift, this.daysToShift, externalIdPrefix);
			this.batchProcessId = Database.executeBatch(batchProcess, this.genericAppConfiguration.timeShiftingBatchSize);

		} 
		else{
			this.logMessage('There are no fields for time shifting.');
			this.finishTimeShiftingProcess();			
		}

	}

	private void finishTimeShiftingProcess(){
		this.disabledButton = false;
		this.currentTimeShiftingNodeIndex = 0;
		this.timeShiftingItems.clear();
		this.logMessage('Done.');

		if(this.selectedInstallationProcess == 'timeShifting'){
			this.successMessage = 'The Time Shifting process has finished successfully.';
			WaveConfiguratorUtils.sendEmail(this.emailAddress, 'Time Shifting completed successfully', 'The Time Shifting process of your ORG data has finished successfully.');
		}
	}

	public PageReference checkObjectLoadingStatus(){
		
		try{
			if(!String.isBlank(this.batchProcessId)){

				WaveApplicationObject currentNode = this.objectsNodes.get(this.currentNodeIndex);
				List<AsyncApexJob> lstJobs = [SELECT CompletedDate, JobItemsProcessed, NumberOfErrors, Status, ExtendedStatus, TotalJobItems FROM AsyncApexJob WHERE Id = :this.batchProcessId];
				
				if(lstJobs.size() > 0){

					AsyncApexJob asyncJob = lstJobs.get(0);

					if(asyncJob.Status == 'Completed'){
						if(asyncJob.NumberOfErrors > 0) {
							this.errorMessage = 'The process was interrupted due to errors while loading data for the ' + this.objectsNodes.get(this.currentNodeIndex).name + ' object. ';
							if (string.isNotBlank(asyncJob.ExtendedStatus)) {
								this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
							}
							this.currentNodeIndex = 0;
							currentNode.currentDataIndex = 0;
							this.objectsNodes.clear();
							this.disabledButton = false;

							// Rollback
							this.rollbackProcess(this.errorMessage, '');
						}
						else {
							// Completed entire job, inspect if there are more data files 
							// within the current node
							if(currentNode.currentDataIndex < currentNode.additionalDataFiles){
								currentNode.currentDataIndex = currentNode.currentDataIndex + 1;
								this.processCurrentObjectLoadNode();
							}
							else{
								// Entire node finished, reset currentNode.currentDataIndex
								currentNode.currentDataIndex = 0;
								
								// now check whether it was the last one
								if(this.currentNodeIndex == this.objectsNodes.size() - 1){
									this.objectsNodes.clear();
									this.currentTimeShiftingNodeIndex = 0;
									this.enableObjectProcessingCheck = false;

									if(String.isNotBlank(this.selectedAppMetadata.userProfilePicturesUrl)){
										// Build upload photos nodes
										String zipFileUrl = this.baseUrl + this.selectedAppMetadata.userProfilePicturesUrl;
										Blob file = this.utils.getUsersPhotosZipBlob(zipFileUrl);
										Zippex zip = new Zippex(file);
										
										for(String fileName: zip.getFileNames()){
			
											String fileBaseName = fileName;
											
											if(fileName.contains('/')){
												fileBaseName = fileName.substringAfterLast('/');
											}
													
											String nameToSave = fileBaseName.substringBeforeLast('.');

											if(String.isNotBlank(nameToSave)){
												// Add to the node array to be processed
												UserPhotoInfo userPhoto = new UserPhotoInfo();
												userPhoto.fileNameToExtract = fileName;
												userPhoto.fileBaseName = fileBaseName;
												userPhoto.zipFileUrl = zipFileUrl;
												this.userPhotoNodes.add(userPhoto);
											}
										}

										if(this.userPhotoNodes.size() > 0){
											this.logMessage('Loading user profile photos...');
											this.currentUserPhotoNodeIndex = 0;
											this.processCurrentUserPhoto();
											this.uploadingUserPhotos = true;
										}
										else {
											this.finishPrepCoreData();
										}
									}
									else {
										this.finishPrepCoreData();
									}									
								}
								else {
									// There are more nodes to process, increment index and reset
									// currentNode.currentDataIndex
									this.operationsStatusTable.get(currentNode.Name).put('LoadData','Done');
									this.currentNodeIndex = this.currentNodeIndex + 1;
									this.processCurrentObjectLoadNode();
								}
							}
						}		
					}
					else if(asyncJob.Status == 'Aborted'){
						this.errorMessage = 'The process was aborted while loading data for the ' + this.objectsNodes.get(this.currentNodeIndex).name + ' object.';
						this.currentNodeIndex = 0;
						this.disabledButton = false;
						this.objectsNodes.clear();

						// Rollback
						this.rollbackProcess(this.errorMessage, '');
					}
					else if(asyncJob.Status == 'Failed'){
						this.errorMessage = 'The process failed while loading data for the ' + this.objectsNodes.get(this.currentNodeIndex).name + ' object. ';
						if (string.isNotBlank(asyncJob.ExtendedStatus)) {
							this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
						}
						this.currentNodeIndex = 0;
						this.disabledButton = false;
						this.objectsNodes.clear();

						// Rollback
						this.rollbackProcess(this.errorMessage, '');
					}
				}
			}
		}
		catch(Exception e) {
			this.errorMessage = e.getMessage();
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());

			this.objectsNodes.clear();
			this.currentNodeIndex = 0;
			this.disabledButton = false;
			
			// Rollback
			this.rollbackProcess(e.getMessage(), e.getStackTraceString());
		}

		return null;
	}

	public void processCurrentUserPhoto(){
		// Launch current queueable job
		UserPhotoInfo currentNode = this.userPhotoNodes.get(this.currentUserPhotoNodeIndex);		
		UploadUserPhotoQueueable userPhotoUploadQueue = new UploadUserPhotoQueueable(currentNode.zipFileUrl, currentNode.fileNameToExtract, currentNode.fileBaseName);
		this.queueProcessId = System.enqueueJob(userPhotoUploadQueue);
	}

	public PageReference checkUserPhotoUploadStatus(){
		
		try {
			if(!String.isBlank(this.queueProcessId)){
				UserPhotoInfo currentNode = this.userPhotoNodes.get(this.currentUserPhotoNodeIndex);
				List<AsyncApexJob> lstJobs = [SELECT CompletedDate, JobItemsProcessed, NumberOfErrors, Status, ExtendedStatus, TotalJobItems FROM AsyncApexJob WHERE Id = :this.queueProcessId];
				
				if(lstJobs.size() > 0){

					AsyncApexJob asyncJob = lstJobs.get(0);

					if(asyncJob.Status == 'Completed'){
						if(asyncJob.NumberOfErrors > 0) {
							this.errorMessage = 'The process was interrupted due to errors while uploading ' + this.userPhotoNodes.get(this.currentUserPhotoNodeIndex).fileBaseName + ' photo. ';
							if (string.isNotBlank(asyncJob.ExtendedStatus)) {
								this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
							}
							this.currentUserPhotoNodeIndex = 0;
							this.userPhotoNodes.clear();
							this.disabledButton = false;
							this.uploadingUserPhotos = false;
						}
						else {
							// now check whether it was the last one
							if(this.currentUserPhotoNodeIndex == this.userPhotoNodes.size() - 1){
								this.finishPrepCoreData();
							}
							else {
								// There are more nodes to process, increment index and reset
								this.currentUserPhotoNodeIndex = this.currentUserPhotoNodeIndex + 1;
								this.processCurrentUserPhoto();
							}
						}		
					}
					else if(asyncJob.Status == 'Aborted'){
						this.errorMessage = 'The process was aborted while uploading ' + this.userPhotoNodes.get(this.currentUserPhotoNodeIndex).fileBaseName + ' photo.';
						this.currentUserPhotoNodeIndex = 0;
						this.userPhotoNodes.clear();
						this.disabledButton = false;
						this.uploadingUserPhotos = false;
					}
					else if(asyncJob.Status == 'Failed'){
						this.errorMessage = 'The process failed while uploading ' + this.userPhotoNodes.get(this.currentUserPhotoNodeIndex).fileBaseName + ' photo. ';
						if (string.isNotBlank(asyncJob.ExtendedStatus)) {
							this.errorMessage = this.errorMessage + 'Error: ' +  asyncJob.ExtendedStatus;
						}
						this.currentUserPhotoNodeIndex = 0;
						this.userPhotoNodes.clear();
						this.disabledButton = false;
						this.uploadingUserPhotos = false;
					}
				}
			}
		}
		catch(Exception e) {
			this.errorMessage = e.getMessage();
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			
			this.userPhotoNodes.clear();
			this.currentUserPhotoNodeIndex = 0;
			this.disabledButton = false;
			this.uploadingUserPhotos = false;
		}

		return null;
	}

	public void finishPrepCoreData(){
		this.disabledButton = false;
		this.uploadingUserPhotos = false;
		this.currentUserPhotoNodeIndex = 0;
		this.userPhotoNodes.clear();
		this.logMessage('Done.');
		this.successMessage = 'Data loaded successfully.';								
		WaveConfiguratorUtils.sendEmail(this.emailAddress, 'Prep Core Data completed successfully', 'The Prep Core Data has finished successfully.');
	}

	public PageReference checkTimeShiftingStatus(){
		
		try {
			if(!String.isBlank(this.batchProcessId)){
				WaveTimeShiftingItem currentNode = this.timeShiftingItems.get(this.currentTimeShiftingNodeIndex);
				List<AsyncApexJob> lstJobs = [SELECT CompletedDate, JobItemsProcessed, NumberOfErrors, Status, ExtendedStatus, TotalJobItems FROM AsyncApexJob WHERE Id = :this.batchProcessId];
				
				if(lstJobs.size() > 0){

					AsyncApexJob asyncJob = lstJobs.get(0);

					if(asyncJob.Status == 'Completed'){
						if(asyncJob.NumberOfErrors > 0) {
							this.errorMessage = 'The process was interrupted due to errors while time shifting data for the ' + this.timeShiftingItems.get(this.currentTimeShiftingNodeIndex).objectTypeName + ' object. ';
							if (string.isNotBlank(asyncJob.ExtendedStatus)) {
								this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
							}
							this.currentTimeShiftingNodeIndex = 0;
							this.timeShiftingItems.clear();
							this.disabledButton = false;

							// Rollback
							this.rollbackProcess(this.errorMessage, '');
						}
						else {
							// now check whether it was the last one
							if(this.currentTimeShiftingNodeIndex == this.timeShiftingItems.size() - 1){
								this.finishTimeShiftingProcess();
							}
							else {
								// There are more nodes to process, increment index and reset
								this.operationsStatusTable.get(currentNode.objectTypeName).put('TimeShifting','Done');
								this.currentTimeShiftingNodeIndex = this.currentTimeShiftingNodeIndex + 1;
								this.processTimeShiftingObjects();
							}
						}		
					}
					else if(asyncJob.Status == 'Aborted'){
						this.errorMessage = 'The process was aborted while time shifting data for the ' + this.timeShiftingItems.get(this.currentTimeShiftingNodeIndex).objectTypeName + ' object.';
						this.currentTimeShiftingNodeIndex = 0;
						this.timeShiftingItems.clear();
						this.disabledButton = false;

						// Rollback
						this.rollbackProcess(this.errorMessage, '');
					}
					else if(asyncJob.Status == 'Failed'){
						this.errorMessage = 'The process failed while time shifting data for the ' + this.timeShiftingItems.get(this.currentTimeShiftingNodeIndex).objectTypeName + ' object. ';
						if (string.isNotBlank(asyncJob.ExtendedStatus)) {
							this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
						}
						this.currentTimeShiftingNodeIndex = 0;
						this.timeShiftingItems.clear();
						this.disabledButton = false;

						// Rollback
						this.rollbackProcess(this.errorMessage, '');
					}
				}
			}
		}
		catch(Exception e) {
			this.errorMessage = e.getMessage();
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			
			this.timeShiftingItems.clear();
			this.currentTimeShiftingNodeIndex = 0;
			this.disabledButton = false;

			// Rollback
			this.rollbackProcess(e.getMessage(), e.getStackTraceString());
		}

		return null;
	}

	public PageReference displayMetadataResponse()
	{
		// Display the response from the client side Metadata API callout
		if(this.MetadataResponse.length() == 0)
		{
			this.warningMessage = '';
			this.successMessage = 'Remote Site Settings have been created. Now you can continue using Analytics Demo Tool.';
			MetadataConnectionWarning = false;
		}
		else
		{
			this.warningMessage = '';
			this.errorMessage = this.MetadataResponse;
			MetadataConnectionWarning = true;
		}
		return null;
	}

	private void rollbackProcess(String mainMessage, String stackTrace){

		this.disabledButton = false;
		this.enableObjectProcessingCheck = false;
		this.enableTimeShiftingCheck = false;
	}

	public void launchObjectsLoading(){
		if(this.objectsNodes.size() > 0){
			// We start loading data for each object
			this.logMessage('This process can take up to 30 minutes. We will refresh status every 5 seconds.');
			this.currentNodeIndex = 0;
			this.disabledButton = true;

			// This launchs all the process of loading data to salesforce objects
			this.processCurrentObjectLoadNode();
		}
		else {
			this.logMessage('There are no objects to load.');
		}
	}

	private void launchRecordTypeCreation(){
		if(this.objectsRecordTypesMatrix.size() > 0){
			this.currentObjectIndex = 0;
			this.currentRecordTypeIndex = 0;
			this.processCurrentRecordType(true);
			this.processingRecordTypes = true;
		}
	}

	public void loadAllObjects(){
		try {
			if(this.installationStep == 'LoadObjects'){
				this.launchObjectsLoading();				
			}
		}
		catch(Exception e) {
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.errorMessage = e.getMessage();
			this.installationStep = '';

			this.rollbackProcess(e.getMessage(), e.getStackTraceString());
		}
		finally {
			// We reset this, don't want to re-execute this method. If we don't do this, 
			// page will recall this method.
			this.installationStep = '';
		}
	}

	public void executeSelectedProcess(){

		Boolean passedValidation = true;
		this.resetMessages();
		this.getWaveApplications();

		try{
			
			if(String.isBlank(this.selectedWaveApp)){
				throw new WaveConfiguratorException('Please select an App to configure.');
			}

			if(this.selectedInstallationProcess == 'createMetadata'){
				this.disabledButton = true;
				this.selectAppMetadata();

				if(this.selectedAppMetadata.objects != null){
					
					List<WaveApplicationObject> lstObjects = new List<WaveApplicationObject>();
					// Retrieve objects to process

					for(WaveMetadataApplicationObject wmaObj: this.selectedAppMetadata.objects) {
						this.operationsStatusTable.get(wmaObj.Name).put('CreateObjectsAndFields','Pending');
						List<WaveApplicationObject> objs = this.getObjectsToProcess(wmaObj);
						lstObjects.addAll(objs);
						this.addRecordTypeNodes(wmaObj);
					}

					this.objectsNodes = lstObjects;
					createObjectsAndFields(this.objectsNodes);
				}
			}
			else if(this.selectedInstallationProcess == 'timeShifting'){
				this.disabledButton = true;
				this.currentTimeShiftingNodeIndex = 0;
				this.enableTimeShiftingCheck = true;
				this.timeShiftingItems.clear();

				for(WaveMetadataApplicationObject wmaObj: this.selectedAppMetadata.objects) {
					//If object is selected in UI
					if(this.selectedObjectsToTimeShift.containsKey(wmaObj.Name)){
						if(this.selectedObjectsToTimeShift.get(wmaObj.Name)){
							this.addTimeShiftingNode(wmaObj);
						}
					}
				}

				this.processTimeShiftingObjects();
			}
			else if(this.selectedInstallationProcess == 'loadObjects'){
				this.disabledButton = true;
				this.selectAppMetadata();

				if(this.selectedAppMetadata.objects != null){
					this.timeShiftingItems.clear();
				
					for(WaveMetadataApplicationObject wmaObj: this.selectedAppMetadata.objects) {
						this.addTimeShiftingNode(wmaObj);
					}
					
					List<WaveApplicationObject> lstObjects = new List<WaveApplicationObject>();
					// Retrieve objects to process
					for(WaveMetadataApplicationObject wmaObj: this.selectedAppMetadata.objects) {
						this.operationsStatusTable.get(wmaObj.Name).put('LoadData','Pending');
						List<WaveApplicationObject> objs = this.getObjectsToProcess(wmaObj);
						lstObjects.addAll(objs);
						this.addRecordTypeNodes(wmaObj);
					}

					this.objectsNodes = lstObjects;
					//createObjectsAndFields(this.objectsNodes); UNCOMMENT
					this.launchObjectsLoading(); // COMMENT
				}
			} 
			else if(this.selectedInstallationProcess == 'loadEdgemarts'){
				this.disabledButton = true;
				this.selectAppMetadata();
				this.edgemartsNodes.clear();

				if(this.selectedAppMetadata.edgemarts != null){
					
					for(WaveMetadataApplicationEdgemart wmaEdg: this.selectedAppMetadata.edgemarts) {
						
						WaveApplicationEdgemart waEdg = new WaveApplicationEdgemart();
						waEdg.edgemartDeveloperName = wmaEdg.edgemartDeveloperName;
						waEdg.edgemartLabel = wmaEdg.edgemartLabel;
						waEdg.edgemartCsvDataUrl = wmaEdg.edgemartCsvDataUrl;
						waEdg.edgemartJsonSchemaUrl = wmaEdg.edgemartJsonSchemaUrl;
						waEdg.edgemartNodeNameInDataflow = wmaEdg.edgemartNodeNameInDataflow;
						waEdg.edgemartNodeNameToReplaceInDataflow = wmaEdg.edgemartNodeNameToReplaceInDataflow;
						waEdg.objectName = wmaEdg.objectName;
						waEdg.replaceData = wmaEdg.replaceData;

						this.edgemartsNodes.add(waEdg);
					}
					
					loadEdgemarts();
				}
			}
			else if(this.selectedInstallationProcess == 'setActionFields'){
				setActionFields();				
			}
			else if (this.selectedInstallationProcess == 'createCompleteApp') {
				// Process specific pre validation

				this.resetMessages();
				// Start with validations
				if(String.isBlank(this.createCompleteAppName)){
					passedValidation = false;
					this.warningMessage = 'Analytics application name must be specified.';
				}
				
				if(String.isBlank(this.createCompleteAppLabel)){
					passedValidation = false;
					this.warningMessage = 'Analytics application label name must be specified.';
				}				

				if (passedValidation) {
					this.disabledButton = true;
					this.selectAppMetadata();
					this.datasetsNodes.clear();
					this.dashboardsNodes.clear();

					if(this.selectedAppMetadata.datasets != null){
						
						for(WaveMetadataApplicationDataset wmaEdg: this.selectedAppMetadata.datasets) {
							
							WaveApplicationDataset waDataset = new WaveApplicationDataset();
							waDataset.name = wmaEdg.name;
							waDataset.label = wmaEdg.label;
							waDataset.jsonSchemaUrl = wmaEdg.jsonSchemaUrl;
							waDataset.csvDataUrl = wmaEdg.csvDataUrl;
							waDataset.xmdUrl = wmaEdg.xmdUrl;
							waDataset.dataParts = wmaEdg.dataParts;

							this.datasetsNodes.add(waDataset);
						}
					}

					if(this.selectedAppMetadata.dashboards != null){
						
						for(WaveMetadataApplicationDashboard wmaDash: this.selectedAppMetadata.dashboards) {
							
							WaveApplicationDashboard waDashboard = new WaveApplicationDashboard();
							waDashboard.name = wmaDash.name;
							waDashboard.referencedDatasets = wmaDash.referencedDatasets;
							waDashboard.referencedDashboards = wmaDash.referencedDashboards;
							waDashboard.referencedImages = wmaDash.referencedImages;
							waDashboard.jsonUrl = wmaDash.jsonUrl;

							this.dashboardsNodes.add(waDashboard);
						}
					}

					/*if(this.selectedAppMetadata.dataflow != null){
						this.dataflowConfig = new WaveApplicationDataflow();
						this.dataflowConfig.referencedDatasets = this.selectedAppMetadata.dataflow.referencedDatasets;
						this.dataflowConfig.jsonUrl = this.selectedAppMetadata.dataflow.jsonUrl;
					}*/

					handleCompleteApp(true);
				}
			}
			else if(this.selectedInstallationProcess == 'loadDatasetsToExistingApp'){
				this.resetMessages();
				
				// Start with validations
				if(String.isBlank(this.handleCompleteAppFolderId)){
					passedValidation = false;
					this.warningMessage = 'An Analytics Application name must be selected.';
				}

				if (passedValidation) {
					this.disabledButton = true;
					this.selectAppMetadata();
					this.datasetsNodes.clear();
					this.dashboardsNodes.clear();

					if(this.selectedAppMetadata.datasets != null){
						
						for(WaveMetadataApplicationDataset wmaEdg: this.selectedAppMetadata.datasets) {
							
							WaveApplicationDataset waDataset = new WaveApplicationDataset();
							waDataset.name = wmaEdg.name;
							waDataset.label = wmaEdg.label;
							waDataset.jsonSchemaUrl = wmaEdg.jsonSchemaUrl;
							waDataset.csvDataUrl = wmaEdg.csvDataUrl;
							waDataset.xmdUrl = wmaEdg.xmdUrl;
							waDataset.dataParts = wmaEdg.dataParts;

							this.datasetsNodes.add(waDataset);
						}
					}

					handleCompleteApp(false);
				}
			}
		}
		catch(Exception e) {
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.errorMessage = e.getMessage();
			this.disabledButton = false;
			this.installationStep = '';
			this.rollbackProcess(e.getMessage(), e.getStackTraceString());
		}
	}

	public void setActionFields(){
		if(String.isBlank(this.selectedDataflowForActionFields)){
			throw new WaveConfiguratorException('You are required to select dataflow for this operation.');
		}

		List<WaveApplicationActionField> fieldsToSet = new List<WaveApplicationActionField>();
		
		for (String dsName: this.actionInputFields.keySet()) {
			for (WaveApplicationActionField v: this.actionInputFields.get(dsName).values()) {
				if (!String.isBlank(v.actionFieldValue)) {
					fieldsToSet.add(v); // Value was set by the user
					this.logMessage('Setting ' + v.actionFieldValue + ' value for ' + v.actionFieldLabel + ' field in ' + v.datasetName + ' dataset.');
				}
			}
		}

		AnalyticsDemoDataflowHelper dataflowHelper = new AnalyticsDemoDataflowHelper('v' + this.genericAppConfiguration.apiVersion);
		dataflowHelper.setComputeExpressionsForActionFields(this.selectedDataflowForActionFields, fieldsToSet);
		this.successMessage = 'The Set Action Fields process has finished successfully.';
	}

	public void loadEdgemarts(){
		// Check if there are edgemarts to load
		if(this.edgemartsNodes.size() > 0){

			this.currentEdgemartIndex = 0;
			this.processCurrentEdgemartLoad();
			this.processingEdgemartsLoad = true;
			
		}
		else {
			// We DON'T have metadata to process
			this.logMessage('No edgemarts to load.');
			this.disabledButton = false;
			this.processingEdgemartsLoad = false;
		}
	}

	public void processCurrentEdgemartLoad(){
		WaveApplicationEdgemart edg = this.edgemartsNodes.get(this.currentEdgemartIndex);
		LoadEdgemartQueueable edgCreationQueue = new LoadEdgemartQueueable(edg, this.selectedAnalyticsApp, UserInfo.getSessionId());
		this.queueProcessId = System.enqueueJob(edgCreationQueue);
		this.logMessage('Loading ' + edg.edgemartLabel + ' dataset.');
	}

	public PageReference checkEdgemartLoadStatus(){
		try {
			if(!String.isBlank(this.queueProcessId) && this.processingEdgemartsLoad){
				List<AsyncApexJob> lstJobs = [SELECT CompletedDate, JobItemsProcessed, NumberOfErrors, Status, ExtendedStatus, TotalJobItems FROM AsyncApexJob WHERE Id = :this.queueProcessId];
				WaveApplicationEdgemart currentEdg = this.edgemartsNodes.get(this.currentEdgemartIndex);

				if(lstJobs.size() > 0){
					AsyncApexJob asyncJob = lstJobs.get(0);

					if(asyncJob.Status == 'Completed'){
						if(asyncJob.NumberOfErrors > 0) {
							this.errorMessage = 'Error while loading edgemart for the ' + currentEdg.objectName + ' object.';
							if (string.isNotBlank(asyncJob.ExtendedStatus)) {
								this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
							}
							this.currentEdgemartIndex = 0;
							this.processingEdgemartsLoad = false;
							this.disabledButton = false;
						}
						else {
							if(this.currentEdgemartIndex == this.edgemartsNodes.size() - 1){
								
								AnalyticsDemoDataflowHelper dataflowHelper = new AnalyticsDemoDataflowHelper('v' + this.genericAppConfiguration.apiVersion);
								
								// Dataflow will be edited?
								if (String.isNotBlank(this.selectedDataflow)) {									
									dataflowHelper.replaceSfdcDigestByEdgemarts(this.selectedDataflow, this.edgemartsNodes);
								}

								// App will be edited?
								if (String.isNotBlank(this.selectedAnalyticsApp)) {
									dataflowHelper.remapNamesInAssets(this.selectedAnalyticsApp);
								}

								// We are finished loading edgemarts
								this.finishEdgemartLoadProcess();
							}
							else {
								this.currentEdgemartIndex = this.currentEdgemartIndex + 1;
								this.processCurrentEdgemartLoad();
							}
						}		
					}
					else if(asyncJob.Status == 'Aborted'){
						this.errorMessage = 'The process was aborted while loading edgemart for the ' + currentEdg.objectName + ' object.';
						this.currentEdgemartIndex = 0;
						this.processingEdgemartsLoad = false;
						this.disabledButton = false;
					}
					else if(asyncJob.Status == 'Failed'){
						this.errorMessage = 'The process failed while loading edgemart for the ' + currentEdg.objectName + ' object.';
						if (string.isNotBlank(asyncJob.ExtendedStatus)) {
							this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
						}
						this.currentEdgemartIndex = 0;
						this.processingEdgemartsLoad = false;
						this.disabledButton = false;
					}
				}
			}
		}
		catch(Exception e) {
			this.errorMessage = e.getMessage();
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.currentEdgemartIndex = 0;
			this.processingEdgemartsLoad = false;
			this.disabledButton = false;
		}

		return null;
	}

	private void finishEdgemartLoadProcess(){
		this.disabledButton = false;
		this.currentEdgemartIndex = 0;
		this.edgemartsNodes.clear();
		this.logMessage('Done.');
		this.processingEdgemartsLoad = false;

		if(this.selectedInstallationProcess == 'loadEdgemarts'){
			this.successMessage = 'The Load Datasets process has finished successfully.';
			WaveConfiguratorUtils.sendEmail(this.emailAddress, 'Load Datasets completed successfully', 'The Load Datasets process of your ORG data has finished successfully.');
		}
	}	

	public void addRecordTypeNodes(WaveMetadataApplicationObject wmaObj){
		
		if(wmaObj.recordTypes != null && wmaObj.recordTypes.size() > 0){
			
			List<SF_MetadataUtils.RecordTypeSpecification> recordTypesToCreate = new List<SF_MetadataUtils.RecordTypeSpecification>();
			
			for(WaveRecordTypeItem rt: wmaObj.recordTypes){
				SF_MetadataUtils.RecordTypeSpecification rtSpec = new SF_MetadataUtils.RecordTypeSpecification();
				rtSpec.ObjectName = wmaObj.name;
				rtSpec.Name = rt.Label;
				rtSpec.DeveloperName = rt.developerName;
				rtSpec.BusinessProcessName = rt.businessProcessName;

				recordTypesToCreate.add(rtSpec);
			}

			if(recordTypesToCreate.size() > 0){
				this.objectsRecordTypesMatrix.add(recordTypesToCreate);
			}
		}
		
	}

	public void addTimeShiftingNode(WaveMetadataApplicationObject wmaObj){
		if(wmaObj.dateFieldsToShift != null && wmaObj.dateFieldsToShift.size() > 0){
			WaveTimeShiftingItem timeShiftingItem = new WaveTimeShiftingItem();
			timeShiftingItem.appType = this.selectedAppMetadata.appType;
			timeShiftingItem.objectTypeName = wmaObj.Name;
			timeShiftingItem.fieldsToTimeShift = wmaObj.dateFieldsToShift;
			timeShiftingItem.externalIdObjectPrefix = wmaObj.externalIdPrefix;

			this.selectedObjectsToTimeShift.put(wmaObj.Name, true);
			this.timeShiftingItems.add(timeShiftingItem);
		}
	}

	public void selectAppMetadata(){
		Integer appIndex = this.appIndexes.get(this.selectedWaveApp);
		WaveApplicationRow appRow = this.applicationRows.get(appIndex);
		
		// Retrieve and parse metadata
		HttpRequest req = new HttpRequest();
		req.setEndpoint(appRow.MetadataUrl);
        req.setMethod('GET');
		Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() != 200){
        	throw new WaveConfiguratorException('There is a configuration error. No app configuration was found at the ' + appRow.MetadataUrl + ' URL.');
        }
		
		String jsonMetadata = res.getBody();
		this.selectedAppMetadata = (WaveMetadataApplication)JSON.deserialize(jsonMetadata, WaveMetadataApplication.class);
		
		if (this.selectedAppMetadata != null && this.selectedAppMetadata.objects != null) {
			for(WaveMetadataApplicationObject wmaObj: this.selectedAppMetadata.objects) {
				Map<String,String> operationMap = new Map<String,String>();
				operationMap.put('CreateObjectsAndFields','N/A');
				operationMap.put('LoadData','N/A');
				operationMap.put('TimeShifting','N/A');
				operationMap.put('LoadEdgemarts','N/A');
				operationMap.put('SetActionFields', 'N/A');
				this.operationsStatusTable.put(wmaObj.Name, operationMap);
			}
		}
	}

	public void createObjectsAndFields(List<WaveApplicationObject> lstObjects){
		
		// Check if there are objects data to load
		if(lstObjects.size() > 0){

			// Objects and fields Setup

			for(WaveApplicationObject waObj: lstObjects) {
				List<SF_MetadataUtils.CustomFieldSpecification> fieldsToCreate = new List<SF_MetadataUtils.CustomFieldSpecification>();

				// Check fields existence using waObj.fields property
				for(WaveApplicationObjectField field: waObj.fields) {			
					
					if(field.Name.endsWithIgnoreCase('__c'))
					{
						SF_MetadataUtils.CustomFieldSpecification fieldSpec = new SF_MetadataUtils.CustomFieldSpecification();
						fieldSpec.ObjectName = waObj.name;
						fieldSpec.Name = field.Name;
				    	fieldSpec.Label = field.Label;
				    	fieldSpec.Type = field.Type;
				    	fieldSpec.PickListValues = field.PickListValues;
						fieldSpec.ReferenceTo = field.ReferenceTo;
						fieldSpec.Length = field.Length;
						fieldSpec.Precision = field.Precision;
						fieldSpec.Scale = field.Scale;
						fieldSpec.IsExternalId = field.IsExternalId;
						fieldSpec.IsRequired = field.IsRequired;
						fieldSpec.DefaultValue = field.DefaultValue;
						fieldSpec.Formula = field.Formula;

						fieldsToCreate.add(fieldSpec);
					}
				}			

				if(fieldsToCreate.size() > 0){
					this.objectsAndFieldsMatrix.add(fieldsToCreate);
				}
			}

			if(this.objectsAndFieldsMatrix.size() > 0){
				// We have metadata to process
				this.currentObjectIndex = 0;
				this.currentFieldIndex = 0;
				this.processCurrentObjectAndFieldsMetadata(true);
				this.processingObjectsAndFieldsMetadata = true;
			}
			else {
				// We DON'T have metadata to process
				this.logMessage('No need to create new objects and fields.');
				
				for(WaveMetadataApplicationObject wmaObj: this.selectedAppMetadata.objects) {
					this.operationsStatusTable.get(wmaObj.Name).put('CreateObjectsAndFields','Done');
				}
				
				if(this.objectsRecordTypesMatrix.size() > 0){
					this.launchRecordTypeCreation();
				}
				else {
					
					if(this.selectedInstallationProcess == 'loadObjects'){
						// We chain this with object data loading
						this.launchObjectsLoading();
					}
					else if(this.selectedInstallationProcess == 'createMetadata'){
						this.disabledButton = false;
					}
				}
			}
		}
		else {
			this.currentObjectIndex = 0;
			this.currentFieldIndex = 0;
			this.processingObjectsAndFieldsMetadata = false;
			this.disabledButton = false;
			this.logMessage('There are no objects and fields to create.');
		}
	}

	private void processCurrentRecordType(Boolean startingWithObject){
		SF_MetadataUtils.RecordTypeSpecification initialRecordType = this.objectsRecordTypesMatrix.get(this.currentObjectIndex).get(this.currentRecordTypeIndex);
		
		if(startingWithObject){
			this.logMessage('Processing ' + initialRecordType.ObjectName + ' record type...');
		}

		CreateRecordTypesQueueable recordTypeCreationQueue = new CreateRecordTypesQueueable(initialRecordType, UserInfo.getSessionId());
		this.queueProcessId = System.enqueueJob(recordTypeCreationQueue);		
	}

	public PageReference checkRecordTypeCreationStatus(){
		
		try {
			if(!String.isBlank(this.queueProcessId) && this.processingRecordTypes){
				List<AsyncApexJob> lstJobs = [SELECT CompletedDate, JobItemsProcessed, NumberOfErrors, Status, ExtendedStatus, TotalJobItems FROM AsyncApexJob WHERE Id = :this.queueProcessId];
				SF_MetadataUtils.RecordTypeSpecification currentRecordType = this.objectsRecordTypesMatrix.get(this.currentObjectIndex).get(this.currentRecordTypeIndex);

				if(lstJobs.size() > 0){
					AsyncApexJob asyncJob = lstJobs.get(0);

					if(asyncJob.Status == 'Completed'){
						if(asyncJob.NumberOfErrors > 0) {
							this.errorMessage = 'Error while processing ' + currentRecordType.Name + ' record type for the ' + currentRecordType.ObjectName + ' object. ';
							if (string.isNotBlank(asyncJob.ExtendedStatus)) {
								this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
							}
							this.currentObjectIndex = 0;
							this.currentRecordTypeIndex = 0;
							this.processingRecordTypes = false;
							this.disabledButton = false;
						}
						else {
							// now check whether it was the last one
							List<SF_MetadataUtils.RecordTypeSpecification> currentRecordTypeList = this.objectsRecordTypesMatrix.get(this.currentObjectIndex);

							if(this.currentObjectIndex == this.objectsRecordTypesMatrix.size() - 1){
								
								if(this.currentRecordTypeIndex == currentRecordTypeList.size() - 1){
									this.currentObjectIndex = 0;
									this.currentRecordTypeIndex = 0;
									this.objectsRecordTypesMatrix.clear();
									this.processingRecordTypes = false;
									this.disabledButton = false;
									this.logMessage('All needed metadata was created successfully.');

									if(this.selectedInstallationProcess == 'loadObjects'){
										this.launchObjectsLoading();
									}
								}
								else{
									this.currentRecordTypeIndex = this.currentRecordTypeIndex + 1;
									this.processCurrentRecordType(false);
								}
							}
							else {
								if(this.currentRecordTypeIndex == currentRecordTypeList.size() - 1){
									this.currentObjectIndex = this.currentObjectIndex + 1;
									this.currentRecordTypeIndex = 0;
									this.processCurrentRecordType(true);
								}
								else{
									this.currentRecordTypeIndex = this.currentRecordTypeIndex + 1;
									this.processCurrentRecordType(false);
								}
							}
						}		
					}
					else if(asyncJob.Status == 'Aborted'){
						this.errorMessage = 'The process was aborted while processing ' + currentRecordType.Name + ' record type for the ' + currentRecordType.ObjectName + ' object.';
						this.currentObjectIndex = 0;
						this.currentRecordTypeIndex = 0;
						this.processingRecordTypes = false;
						this.disabledButton = false;
					}
					else if(asyncJob.Status == 'Failed'){
						this.errorMessage = 'The process failed while processing ' + currentRecordType.Name + ' record type for the ' + currentRecordType.ObjectName + ' object. ';
						if (string.isNotBlank(asyncJob.ExtendedStatus)) {
							this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
						}
						this.currentObjectIndex = 0;
						this.currentRecordTypeIndex = 0;
						this.processingRecordTypes = false;
						this.disabledButton = false;
					}
				}
			}
		}
		catch(Exception e) {
			this.errorMessage = e.getMessage();
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.currentObjectIndex = 0;
			this.currentRecordTypeIndex = 0;
			this.processingRecordTypes = false;
			this.disabledButton = false;
			this.objectsRecordTypesMatrix.clear();
		}

		return null;
	}

	private void processCurrentObjectAndFieldsMetadata(Boolean startingWithObject){

		SF_MetadataUtils.CustomFieldSpecification initialField = this.objectsAndFieldsMatrix.get(this.currentObjectIndex).get(this.currentFieldIndex);
		
		if(startingWithObject){
			this.operationsStatusTable.get(initialField.ObjectName).put('CreateObjectsAndFields','In progress');
			this.logMessage('Processing ' + initialField.ObjectName + ' object metadata...');
			
			if(!SF_MetadataUtils.objectExists(initialField.ObjectName)){
				this.logMessage(initialField.ObjectName + ' doesn\'t exists. Attempting to create it...');										
			}
		}

		CreateObjectsAndFieldsQueueable metadataCreationQueue = new CreateObjectsAndFieldsQueueable(initialField, UserInfo.getSessionId());
		this.queueProcessId = System.enqueueJob(metadataCreationQueue);
	}

	public PageReference checkMetadataCreationStatus(){
		
		try {
			if(!String.isBlank(this.queueProcessId) && this.processingObjectsAndFieldsMetadata){
				List<AsyncApexJob> lstJobs = [SELECT CompletedDate, JobItemsProcessed, NumberOfErrors, Status, ExtendedStatus, TotalJobItems FROM AsyncApexJob WHERE Id = :this.queueProcessId];
				SF_MetadataUtils.CustomFieldSpecification currentField = this.objectsAndFieldsMatrix.get(this.currentObjectIndex).get(this.currentFieldIndex);

				if(lstJobs.size() > 0){
					AsyncApexJob asyncJob = lstJobs.get(0);

					if(asyncJob.Status == 'Completed'){
						if(asyncJob.NumberOfErrors > 0) {
							this.errorMessage = 'Error while processing metadata for the ' + currentField.ObjectName + ' object. Field: ' + currentField.Name + '. ';
							if (string.isNotBlank(asyncJob.ExtendedStatus)) {
								this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
							}
							this.currentObjectIndex = 0;
							this.currentFieldIndex = 0;
							this.processingObjectsAndFieldsMetadata = false;
							this.disabledButton = false;
						}
						else {
							// now check whether it was the last one
							List<SF_MetadataUtils.CustomFieldSpecification> currentFieldList = this.objectsAndFieldsMatrix.get(this.currentObjectIndex);

							if(this.currentObjectIndex == this.objectsAndFieldsMatrix.size() - 1){
								
								if(this.currentFieldIndex == currentFieldList.size() - 1){
									this.currentObjectIndex = 0;
									this.currentFieldIndex = 0;
									this.objectsAndFieldsMatrix.clear();
									this.processingObjectsAndFieldsMetadata = false;
									this.createPermissionSet();

									if(this.selectedInstallationProcess == 'loadObjects'){
										if(this.objectsRecordTypesMatrix.size() > 0){
											this.launchRecordTypeCreation();
										} 
										else{
											this.launchObjectsLoading();
										}
									}
									else if(this.selectedInstallationProcess == 'createMetadata'){
										this.successMessage = 'Done';
										this.logMessage('All needed metadata was created successfully.');
										this.disabledButton = false;
									}

								}
								else{
									this.currentFieldIndex = this.currentFieldIndex + 1;
									this.processCurrentObjectAndFieldsMetadata(false);
								}
							}
							else {
								if(this.currentFieldIndex == currentFieldList.size() - 1){
									this.currentObjectIndex = this.currentObjectIndex + 1;
									this.currentFieldIndex = 0;

									if(this.operationsStatusTable.containsKey(currentField.ObjectName)){
										this.operationsStatusTable.get(currentField.ObjectName).put('CreateObjectsAndFields','Done');
									}
								
									this.processCurrentObjectAndFieldsMetadata(true);
								}
								else{
									this.currentFieldIndex = this.currentFieldIndex + 1;
									this.processCurrentObjectAndFieldsMetadata(false);
								}
							}
						}		
					}
					else if(asyncJob.Status == 'Aborted'){
						this.errorMessage = 'The process was aborted while processing metadata for the ' + currentField.ObjectName + ' object. Field: ' + currentField.Name + '.';
						this.currentObjectIndex = 0;
						this.currentFieldIndex = 0;
						this.processingObjectsAndFieldsMetadata = false;
						this.disabledButton = false;
					}
					else if(asyncJob.Status == 'Failed'){
						this.errorMessage = 'The process failed while processing metadata for the ' + currentField.ObjectName + ' object. Field: ' + currentField.Name + '. ';
						if (string.isNotBlank(asyncJob.ExtendedStatus)) {
							this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
						}
						this.currentObjectIndex = 0;
						this.currentFieldIndex = 0;
						this.processingObjectsAndFieldsMetadata = false;
						this.disabledButton = false;
					}
				}
			}
		}
		catch(Exception e) {
			this.errorMessage = e.getMessage();
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.currentObjectIndex = 0;
			this.currentFieldIndex = 0;
			this.processingObjectsAndFieldsMetadata = false;
			this.disabledButton = false;
			this.objectsAndFieldsMatrix.clear();
		}

		return null;
	}

	private void createPermissionSet(){
		List<PermissionSet> pr = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'Analytics_Demo_Integration'];
		
		Id pSetId;
		
		if(pr.size() == 0){
			PermissionSet newPr = new PermissionSet();
		    newPr.Label = 'Analytics Demo Integration';
			newPr.Name = 'Analytics_Demo_Integration';

			insert newPr;
			pSetId = newPr.Id;
		} 
		else {
			pSetId = pr.get(0).Id;
		}


		Set<FieldPermissions> fieldPermissions = new Set<FieldPermissions>();
		
		List<String> fieldsToPermissionSet = new List<String>();

		for(WaveApplicationObject obj: this.objectsNodes){
			//Add to list the objects that were put in JSON
			if(obj.stdFieldsForPermissionSet != null){
				for(String field: obj.stdFieldsForPermissionSet){
					fieldsToPermissionSet.add(obj.Name + '.' + field);
				}
			}

			//Add to list the custom objects in org.
			List<String> customFields = this.getCustomFieldsForPermissionSet(obj.Name);
			fieldsToPermissionSet.addAll(customFields);
		}


		for(String field: fieldsToPermissionSet){
			
			FieldPermissions fp = new FieldPermissions();
			fp.Field = field;
			fp.ParentId = pSetId;
			fp.PermissionsRead = true;
			fp.SobjectType = field.substringBefore('.');

			fieldPermissions.add(fp);
		}
		
		List<FieldPermissions> alreadyThere = [SELECT Field, PermissionsRead FROM FieldPermissions WHERE ParentId = :pSetId];
		Map<String, Boolean> mapFieldPermissions = new Map<String, Boolean>();
		
		for(FieldPermissions existentField: alreadyThere){
		    mapFieldPermissions.put(existentField.Field, existentField.PermissionsRead);
		}

		List<FieldPermissions> fpToUpsert = new List<FieldPermissions>();

		for(FieldPermissions fp: fieldPermissions){
			//If permission field not exists for that parent
		    if(!mapFieldPermissions.containsKey(fp.Field)){
		        fpToUpsert.add(fp);
		    }
		    //If permissionRead is false
		    else if(!mapFieldPermissions.get(fp.Field)){
		    	fpToUpsert.add(fp);
		    }
		}

		if(fpToUpsert.size() > 0){
			upsert fpToUpsert;
		}
		
		List<User> analyticsCloudUsers = [SELECT Id FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name = 'Analytics Cloud Integration User')];
		List<PermissionSetAssignment> pSetAlreadyThere = [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :analyticsCloudUsers AND PermissionSetId = :pSetId];

		if(pSetAlreadyThere.size() == 0){

			if(analyticsCloudUsers.size() > 0){
				List<PermissionSetAssignment> pAssignments = new List<PermissionSetAssignment>();

				for(User u: analyticsCloudUsers){
					PermissionSetAssignment pAssignment = new PermissionSetAssignment();
					pAssignment.AssigneeId = u.Id;
					pAssignment.PermissionSetId = pSetId;

					pAssignments.add(pAssignment);
				}
			
				insert pAssignments;
			}
		}
	}

	private List<String> getCustomFieldsForPermissionSet(String obj){
		
		if(Schema.getGlobalDescribe().containsKey(obj)){		
			Map<String, Schema.SObjectField> objectMap = Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap();

			List<String> fields = new List<String>();

			for(String f: objectMap.keySet()){
				Schema.DescribeFieldResult fieldDetails = objectMap.get(f).getDescribe();

				if(fieldDetails.isPermissionable() && f.endsWithIgnoreCase('__c')){
					fields.add(obj + '.' + String.valueOf(objectMap.get(f)));
				}
			}

			return fields;
		} 
		else {
			throw new WaveConfiguratorException(obj + ' object not supported.');
		}
	}

	private void getDatasetMappingToFolderId(){
		this.folderIdByDatasetDevName = new Map<String, String>();
		for (EdgeMart edg: [SELECT DeveloperName, FolderId FROM EdgeMart WHERE IsDeleted = false]) {
			this.folderIdByDatasetDevName.put(edg.DeveloperName, edg.FolderId);
		}
	}

	public void handleCompleteApp(Boolean createApp){
		// Check if there are datasets to load
		if (this.datasetsNodes.size() == 0 && this.dashboardsNodes.size() == 0) {
			// We DON'T have datasets or dashboards to process
			this.warningMessage = 'There are no datasets or dashboards to load to application.';
			this.disabledButton = false;
			this.processingLoadDatasets = false;
			this.processingLoadDashboards = false;
		}
		else {
			if (createApp) {
				// 1st, create app
				if(!this.utils.folderExists(this.createCompleteAppName)){
					this.handleCompleteAppFolderId = this.utils.insertFolder(this.createCompleteAppLabel, this.createCompleteAppName);
				}
				else {
					this.handleCompleteAppFolderId = this.utils.getFolderIdByDevName(this.createCompleteAppName);
				}

				// At this point we should have an InsightsApplication object created in the org with FolderId = this.handleCompleteAppFolderId
				this.insightsAppId = this.utils.getAnalyticsAppIdByDevName(this.createCompleteAppName);
			}
			else {
				this.insightsAppId = this.utils.getAnalyticsAppIdByFolderId(this.handleCompleteAppFolderId);
			}

			this.getDatasetMappingToFolderId();
			
			// Need to define dataset developer names
			for (WaveApplicationDataset ds : this.datasetsNodes) {
				// As default, we try to use it as it comes from config
				ds.nameToSave = ds.name;
				
				if (this.folderIdByDatasetDevName.containsKey(ds.name) && !this.folderIdByDatasetDevName.get(ds.name).equalsIgnoreCase(this.handleCompleteAppFolderId)) {
					// The dataset already exists in the org but it is contained in another app, need to generate new name
					Integer iSuffix = 0;
                    String edgNameCandidate = ds.Name;
					while(this.folderIdByDatasetDevName.containsKey(edgNameCandidate)){
						iSuffix++;
						edgNameCandidate = ds.Name + iSuffix;
					}
					
					ds.nameToSave = edgNameCandidate;
				}
			}			

			if(this.datasetsNodes.size() > 0){
				this.currentDatasetIndex = 0;
				this.processingLoadDatasets = true;
				this.processingLoadDashboards = false;
				this.processCurrentDatasetLoad();				
			}
			else if(this.dashboardsNodes.size() > 0){
				this.currentDashboardIndex = 0;
				this.processingLoadDatasets = false;
				this.processingLoadDashboards = true;
				this.processCurrentDashboardLoad();				
			}
		}
	}

	public void processCurrentDatasetLoad(){
		WaveApplicationDataset edg = this.datasetsNodes.get(this.currentDatasetIndex);
		LoadDatasetBatch dsBatch = new LoadDatasetBatch(edg, this.insightsAppId);
		this.batchProcessId = Database.executeBatch(dsBatch, 1);
		this.logMessage('Loading ' + edg.label + ' dataset.');
	}

	public void suggestAnalyticsAppName(){
		if (String.isBlank(this.createCompleteAppName) && String.isNotBlank(this.createCompleteAppLabel)) {			
			this.createCompleteAppName = WaveConfiguratorUtils.generateApiName(this.createCompleteAppLabel);
			this.checkCreateCompleteAppExistence();
		}
	}

	public PageReference checkDatasetLoadStatus(){
		try {
			if(!String.isBlank(this.batchProcessId) && this.processingLoadDatasets){
				List<AsyncApexJob> lstJobs = [SELECT CompletedDate, JobItemsProcessed, NumberOfErrors, Status, ExtendedStatus, TotalJobItems FROM AsyncApexJob WHERE Id = :this.batchProcessId];
				WaveApplicationDataset currentEdg = this.datasetsNodes.get(this.currentDatasetIndex);

				if(lstJobs.size() > 0){
					AsyncApexJob asyncJob = lstJobs.get(0);

					if(asyncJob.Status == 'Completed'){
						if(asyncJob.NumberOfErrors > 0) {
							this.errorMessage = 'Error while loading dataset: ' + currentEdg.label;
							if (string.isNotBlank(asyncJob.ExtendedStatus)) {
								this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
							}
							this.currentDatasetIndex = 0;
							this.processingLoadDatasets = false;
							this.disabledButton = false;
							this.createCompleteAppName = '';
							this.handleCompleteAppFolderId = '';
							this.insightsAppId = '';
						}
						else {
							String datasetLoadStatus = WaveConfiguratorUtils.getDatasetUploadStatus(currentEdg.nameToSave);
							if (datasetLoadStatus.equalsIgnoreCase('Completed') || datasetLoadStatus.equalsIgnoreCase('CompletedWithWarnings')) {
								if (datasetLoadStatus.equalsIgnoreCase('CompletedWithWarnings')) {
									this.logMessage('Load completed with warnings. Please go to Analytics Studio / Data Manager for details.');
								}
								// Dataset upload completed
								//Load XMD ?
								// XMD
								if (String.isNotBlank(currentEdg.xmdUrl)) {
									WaveConfiguratorUtils.setXmdForDataset(currentEdg.nameToSave, currentEdg.xmdUrl, this.genericAppConfiguration.apiVersion);
								}
								
								//Now we have to finish or move to next dataset upload
								if(this.currentDatasetIndex == this.datasetsNodes.size() - 1){
									
									// We are finished loading app datasets
									this.processingLoadDatasets = false;

									// DATAFLOW?
									/*
									if (this.dataflowConfig != null) {
										// Download dataflow JSON template
										HttpResponse resDfJson = WaveConfiguratorUtils.httpGetCallout(this.dataflowConfig.jsonUrl);
										String dataflowJsonToSend = resDfJson.getBody();
										//dataflowJsonToSend = dataflowJsonToSend.replace('{#FolderId}', this.folderId);
										//dataflowJsonToSend = dataflowJsonToSend.replace('{#DashboardName}', this.dashboardToLoad.nameToSave);
										
										if (this.dataflowConfig.referencedDatasets != null) {
											for (String datasetName : this.dataflowConfig.referencedDatasets) {
												if (this.datasetsMap.containsKey(datasetName)) {
													WaveApplicationDataset ds = this.datasetsMap.get(datasetName);
													dataflowJsonToSend = dataflowJsonToSend.replace('{#' + datasetName + '}', ds.nameToSave);
												}
											}   
										}
									}*/

									if (this.selectedInstallationProcess.equals('createCompleteApp')) {
										// Creating complete app, now launch dashboards load
										this.currentDashboardIndex = 0;
										this.processingLoadDatasets = false;
										this.processingLoadDashboards = true;
										this.processCurrentDashboardLoad();	
									}
									else if(this.selectedInstallationProcess.equals('loadDatasetsToExistingApp')){
										// Only loading datasets into existing app, finish
										this.finishHandleCompleteAppProcess();
									}
								}
								else {
									// Not finished yet, move to next dataset upload
									this.currentDatasetIndex = this.currentDatasetIndex + 1;
									this.processCurrentDatasetLoad();
								}
							}
							else if (datasetLoadStatus.equalsIgnoreCase('Failed')) {
								this.errorMessage = 'The dataset: ' + currentEdg.label + ' failed to load. Please go to Analytics Studio / Data Manager for details.';
								this.currentDatasetIndex = 0;
								this.processingLoadDatasets = false;
								this.disabledButton = false;
								this.createCompleteAppName = '';
								this.handleCompleteAppFolderId = '';
								this.insightsAppId = '';
							}
						}
					}
					else if(asyncJob.Status == 'Aborted'){
						this.errorMessage = 'The process was aborted while loading dataset: ' + currentEdg.label;
						this.currentDatasetIndex = 0;
						this.processingLoadDatasets = false;
						this.disabledButton = false;
						this.createCompleteAppName = '';
						this.handleCompleteAppFolderId = '';
						this.insightsAppId = '';
					}
					else if(asyncJob.Status == 'Failed'){
						this.errorMessage = 'The process failed while loading dataset: ' + currentEdg.label;
						if (string.isNotBlank(asyncJob.ExtendedStatus)) {
							this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
						}
						this.currentDatasetIndex = 0;
						this.processingLoadDatasets = false;
						this.disabledButton = false;
						this.createCompleteAppName = '';
						this.handleCompleteAppFolderId = '';
						this.insightsAppId = '';
					}
				}
			}
		}
		catch(Exception e) {
			this.errorMessage = e.getMessage();
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.currentDatasetIndex = 0;
			this.processingLoadDatasets = false;
			this.processingLoadDashboards = false;
			this.disabledButton = false;
			this.createCompleteAppName = '';
			this.handleCompleteAppFolderId = '';
			this.insightsAppId = '';
		}

		return null;
	}

	public void processCurrentDashboardLoad(){
		if(this.dashboardsNodes != null && this.dashboardsNodes.size() > 0){
			if (this.currentDashboardIndex == 0) {
				// Get Dataset Name, Id mapping
				List<String> lstDatasetDevNames = new List<String>();
				for (WaveApplicationDataset ds : this.datasetsNodes) {
					lstDatasetDevNames.add(ds.nameToSave);
				}
				this.idsByDatasetDevName = this.utils.getDatasetIdByDevNameMapping(lstDatasetDevNames);
				this.datasetsMap = new Map<String, WaveApplicationDataset>();
				for (WaveApplicationDataset ds : this.datasetsNodes) {
					ds.Id = this.idsByDatasetDevName.get(ds.nameToSave);
					this.datasetsMap.put(ds.name, ds);
				}
				
				// Load all dashboards so we can get the api names
				List<StaticResource> srList = [SELECT Body FROM StaticResource WHERE Name = 'BlankDashboardTemplate'];
				if(srList.size() == 0){
					throw new WaveConfiguratorException('BlankDashboardTemplate Static Resource not found.');
				}
				// We create the dummy dashboards and the Map for storing resulting IDs
				this.dashboardsIdsByName = new Map<String, String>();
				String dummyDashboardJson = srList.get(0).Body.toString();
				dummyDashboardJson = dummyDashboardJson.replace('{#FolderId}', this.handleCompleteAppFolderId);

				// Find if there exists dashboard
				Map<String, String> dashboardFoldersByName = new Map<String, String>();			
				for (Lens l: [SELECT DeveloperName, FolderId FROM Lens WHERE Type = 'dashboard' AND IsDeleted = false]) {
					dashboardFoldersByName.put(l.DeveloperName, l.FolderId);
				}

				Set<String> dashboardNames = dashboardFoldersByName.keySet();
				this.dashboardsMap = new Map<String, WaveApplicationDashboard>();

				for (WaveApplicationDashboard dash : this.dashboardsNodes) {
					
					dash.nameToSave = dash.name;

					if (!dashboardFoldersByName.containsKey(dash.name) || (dashboardFoldersByName.containsKey(dash.name) && !dashboardFoldersByName.get(dash.name).equals(this.handleCompleteAppFolderId))) {
						
						// Have to create new dashboard
						
						if (dashboardFoldersByName.containsKey(dash.name) && !dashboardFoldersByName.get(dash.name).equals(this.handleCompleteAppFolderId)) {
							// Dashboard already exists in the org but contained in another app. Need to find new name for it
							String dashNameCandidate = dash.name;
							Integer iSuffix = 0;                
							while(dashboardNames.contains(dashNameCandidate)){
								iSuffix++;
								dashNameCandidate = dash.name + iSuffix;
							}

							dash.nameToSave = dashNameCandidate;
						}

						String currDashJson = dummyDashboardJson.replace('{#DashboardName}', dash.nameToSave);
						this.utils.insertDashboard(currDashJson);
					}

					this.dashboardsMap.put(dash.name, dash);
				}

				// If there are images to load for dashboards
				this.dashboardImagesMapping = new Map<String, String>();
				if(this.selectedAppMetadata.referencedImages != null){
					this.referencedImages = new WaveApplicationImage();
					this.referencedImages.type = this.selectedAppMetadata.referencedImages.type;
					this.referencedImages.names = this.selectedAppMetadata.referencedImages.names;
					this.referencedImages.zipUrl = this.selectedAppMetadata.referencedImages.zipUrl;
					
					this.dashboardImagesMapping = this.utils.insertAnalyticsImages(this.referencedImages);
				}
			}

			WaveApplicationDashboard d = this.dashboardsNodes.get(this.currentDashboardIndex);
			LoadDashboardQueueable dashQueueable = new LoadDashboardQueueable(d, this.datasetsMap, this.dashboardsMap, this.referencedImages, this.dashboardImagesMapping, this.handleCompleteAppFolderId, genericAppConfiguration.apiVersion, UserInfo.getSessionId());
			this.queueProcessId = System.enqueueJob(dashQueueable);
			this.logMessage('Loading ' + d.name + ' dashboard.');
		}
	}

	public PageReference checkDashboardLoadStatus(){
		try {
			if(!String.isBlank(this.queueProcessId) && this.processingLoadDashboards){
				List<AsyncApexJob> lstJobs = [SELECT CompletedDate, JobItemsProcessed, NumberOfErrors, Status, ExtendedStatus, TotalJobItems FROM AsyncApexJob WHERE Id = :this.queueProcessId];
				WaveApplicationDashboard currentDashboard = this.dashboardsNodes.get(this.currentDashboardIndex);

				if(lstJobs.size() > 0){
					AsyncApexJob asyncJob = lstJobs.get(0);

					if(asyncJob.Status == 'Completed'){
						if(asyncJob.NumberOfErrors > 0) {
							this.errorMessage = 'Error while loading ' + currentDashboard.name + ' dashboard.';
							if (string.isNotBlank(asyncJob.ExtendedStatus)) {
								this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
							}
							this.currentDashboardIndex = 0;
							this.processingLoadDashboards = false;
							this.disabledButton = false;
							this.createCompleteAppName = '';
							this.handleCompleteAppFolderId = '';
							this.insightsAppId = '';
						}
						else {
							if(this.currentDashboardIndex == this.dashboardsNodes.size() - 1){
								
								// We are finished loading dashboards, finish process
								this.finishHandleCompleteAppProcess();
							}
							else {
								this.currentDashboardIndex = this.currentDashboardIndex + 1;
								this.processCurrentDashboardLoad();
							}
						}
					}
					else if(asyncJob.Status == 'Aborted'){
						this.errorMessage = 'The process was aborted while loading ' + currentDashboard.name + ' dashboard.';
						this.currentDashboardIndex = 0;
						this.processingLoadDashboards = false;
						this.disabledButton = false;
						this.createCompleteAppName = '';
						this.handleCompleteAppFolderId = '';
						this.insightsAppId = '';
					}
					else if(asyncJob.Status == 'Failed'){
						this.errorMessage = 'The process failed while loading ' + currentDashboard.name + ' dasboard.';
						if (string.isNotBlank(asyncJob.ExtendedStatus)) {
							this.errorMessage = this.errorMessage + 'Detail: ' +  asyncJob.ExtendedStatus;
						}
						this.currentDashboardIndex = 0;
						this.processingLoadDashboards = false;
						this.disabledButton = false;
						this.createCompleteAppName = '';
						this.handleCompleteAppFolderId = '';
						this.insightsAppId = '';
					}
				}
			}
		}
		catch(Exception e) {
			this.errorMessage = e.getMessage();
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.currentDashboardIndex = 0;
			this.processingLoadDashboards = false;
			this.disabledButton = false;
			this.createCompleteAppName = '';
			this.handleCompleteAppFolderId = '';
			this.insightsAppId = '';
		}

		return null;
	}

	private void finishHandleCompleteAppProcess(){
		
		this.disabledButton = false;
		this.currentDatasetIndex = 0;
		this.currentDashboardIndex = 0;
		this.datasetsNodes.clear();
		this.dashboardsNodes.clear();
		this.logMessage('Done.');
		this.processingLoadDatasets = false;
		this.processingLoadDashboards = false;
		this.createCompleteAppName = '';
		this.handleCompleteAppFolderId = '';
		this.insightsAppId = '';

		if(this.selectedInstallationProcess == 'createCompleteApp'){
			this.successMessage = 'The Create App, Datasets and Dashboards process has finished successfully.';
			WaveConfiguratorUtils.sendEmail(this.emailAddress, 'Create App, Datasets and Dashboards completed successfully', 'The Create App, Datasets and Dashboards process of your ORG data has finished successfully.');
		}
		else if(this.selectedInstallationProcess == 'loadDatasetsToExistingApp'){
			this.successMessage = 'The Load Datasets Into Existing App process has finished successfully.';
			WaveConfiguratorUtils.sendEmail(this.emailAddress, 'Load Datasets Into Existing App completed successfully', 'The Load Datasets Into Existing App process of your ORG data has finished successfully.');
		}
	}

	// **************************** TEMPLATE DEPLOYMENT TOOL ******************************

	class RepositoryTemplateResponse {
		RepositoryTemplate template;
	}

	class RepositoryTemplate {
		String api_version { get; set; }
		Boolean deployable { get; set; }
		String api_name { get; set; }
		String label { get; set; }
		String template_key { get; set; }
	}

	class TemplateList {
		List<String> templates {get; set;}
	}

	class TemplateDeploymentResponse {
		String name { get; set; }
		String run_at { get; set; }
		String done_at { get; set; }
		List<TemplateDeploymentResponseResult> result { get; set; }
	}

	class TemplateDeploymentResponseResult {
		String status { get; set; }
		TemplateDeploymentResponseResultValue value { get; set; }
	}

	class TemplateDeploymentResponseResultValue {
		String completedDate { get; set; }
		Boolean done { get; set; }
		String id { get; set; }
		Integer numberComponentErrors { get; set; }
		Integer numberComponentsDeployed { get; set; }
		Integer numberComponentsTotal { get; set; }
		String status { get; set; }
		Boolean success { get; set; }
		//TemplateDeploymentResponseResultDetail details { get;set; }
		//Map<String, Object> details { get;set; }
	}

	class TemplateDeploymentResponseResultDetail {
		// List<TemplateDeploymentResponseResultComponent> componentFailures { get;set; } this will be used at the end
		List<Object> componentFailures { get;set; }
		List<TemplateDeploymentResponseResultComponent> componentSuccesses { get;set; }
	}

	class TemplateDeploymentResponseResultComponent {
		String componentType { get; set; }
		String problem { get; set; }
		String fullName { get; set; }
		String fileName { get; set; }
	}

	private void setTemplateServiceCookie(){
		if(String.isNotBlank(this.tplDeployUrl)){
			String serverUrl = URL.getOrgDomainUrl().toExternalForm();
			String sessionId = UserInfo.getSessionId();

			String requestBody = '{"source": "session", "credentials": {"session_id": "' + sessionId + '",	"server_url" : "' + serverUrl + '"}}';
			
			HttpRequest deployReq = new HttpRequest();
			deployReq.setEndpoint(this.tplDeployUrl + '/api/auth');
			deployReq.setMethod('POST');
			deployReq.setHeader('Content-Type', 'application/json');
			deployReq.setBody(requestBody);

			Http http = new Http();
			HTTPResponse res = http.send(deployReq);

			String responseHeaderSetCookie = res.getHeader('Set-Cookie');
			String[] sParts = responseHeaderSetCookie.split(';');
			this.cookieString = sParts[0];
		}
	}

	public List<SelectOption> getAvailableTemplates() {
		
		String msgBody = '';
		List<SelectOption> options = new List<SelectOption>();

		try {
			if (!this.retrievedTemplates) {
				Map<String, String> headersMap = new Map<String, String>();
				if (String.isBlank(this.cookieString)) {
					this.setTemplateServiceCookie();
				}

				headersMap.put('Cookie', this.cookieString);
				HTTPResponse res = WaveConfiguratorUtils.httpCallout(
					this.tplDeployUrl + '/api/repository/template/' + this.tplDeployRepoBranch,
					'GET',
					'',
					'application/json',
					headersMap
				);
			
				msgBody = res.getBody();
				System.debug(msgBody);

				List<RepositoryTemplateResponse> repositoryTemplates = (List<RepositoryTemplateResponse>)JSON.deserialize(msgBody, List<RepositoryTemplateResponse>.class);
				
				this.repositoryTemplatesMap.clear();
				this.undraggedTemplates.clear();

				for (RepositoryTemplateResponse repoTpl : repositoryTemplates) {
					this.repositoryTemplatesMap.put(repoTpl.template.api_name, repoTpl);
					this.undraggedTemplates.add(repoTpl.template.api_name);
				}
				
				this.retrievedTemplates = true;
			} 
			
			for (String t : this.undraggedTemplates) {
				RepositoryTemplateResponse repoTplHashed = this.repositoryTemplatesMap.get(t);
				options.add(new SelectOption(repoTplHashed.template.api_name, repoTplHashed.template.label, !repoTplHashed.template.deployable));
			}
		} 
		catch (Exception ex) {
			System.debug(ex.getMessage());
			this.dplErrorMessage = 'Could not retrieve templates: \n' + ex.getMessage();
			this.modalDetailsMessage.body = msgBody;
			this.modalDetailsMessage.header = 'Template retrievement failed: More information';
		}

		return options;
	}

	public void executeDeployTemplate(){

		Boolean passedValidation = true;
		this.processingTemplateDeployment = false;
		this.resetMessages();

		try{
			
			if(this.selectedTemplates.size() == 0){
                this.dplErrorMessage = 'Please select an App Template to deploy.';
                this.disabledButton = false;
            }
            else {
                TemplateList temp = new TemplateList();
				temp.templates = new List<String>(); 
				
				for (String selTplApiName : this.selectedTemplates) {
					RepositoryTemplateResponse repoTplHashed = this.repositoryTemplatesMap.get(selTplApiName);
					temp.templates.add(repoTplHashed.template.template_key);
				}

				String jsonBody = JSON.serialize(temp);
				
				Map<String, String> headersMap = new Map<String, String>();
				if (String.isBlank(this.cookieString)) {
					this.setTemplateServiceCookie();
				}
				headersMap.put('Cookie', this.cookieString);

				System.debug('Executing Template Deployment...');
				System.debug(jsonBody);
                
                HTTPResponse res = WaveConfiguratorUtils.httpCallout(
                    this.tplDeployUrl + '/api/repository/template/' + this.tplDeployRepoBranch + '/deploy',
                    'POST',
                    jsonBody,
                    'application/json',
                    headersMap
				);

				System.debug(res.getBody());

				ApiJobStartResponse dplResult = (ApiJobStartResponse)JSON.deserialize(res.getBody(), ApiJobStartResponse.class);

				if (dplResult != null && String.isNotBlank(dplResult.job_id)) {
					
					this.processingTemplateDeployment = true;
					this.dplJobId = dplResult.job_id;
					this.disabledButton = true;
				}
				else {
					this.dplErrorMessage = 'The template deployment process could not start.';
					this.disabledButton = false;
				}
            }
		}
		catch(Exception e) {
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.dplErrorMessage = e.getMessage();
			this.disabledButton = false;
		}
	}

	public void checkTemplateDeploymentStatus(){
		
		if (String.isNotBlank(this.dplJobId)) {
			Map<String, String> headersMap = new Map<String, String>();
			if (String.isBlank(this.cookieString)) {
				this.setTemplateServiceCookie();
			}
			headersMap.put('Cookie', this.cookieString);
			HTTPResponse res = WaveConfiguratorUtils.httpCallout(
				this.tplDeployUrl + '/api/jobs/' + this.dplJobId,
				'GET',
				'',
				'application/json',
				headersMap
			);

			String responseBody = res.getBody();
			System.debug(responseBody);

			TemplateDeploymentResponse jobResult = (TemplateDeploymentResponse)JSON.deserialize(responseBody, TemplateDeploymentResponse.class);
			
			if (jobResult != null) {
				if (String.isNotBlank(jobResult.done_at)) {
					
					List<String> lstFailedTemplates = new List<String>();
					Integer resultIndex = 0;
					Map<String, Object> respUntyped = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
					List<Object> lstResults = (List<Object>)respUntyped.get('result');

					for (TemplateDeploymentResponseResult result : jobResult.result) {
						if (!result.value.success) {
							// This particular deployment failed
							if (result.value.numberComponentErrors > 0) {
							
								// We have component errors
								Map<String, Object> resultItemDetails = (Map<String, Object>)((Map<String, Object>)((Map<String, Object>)lstResults.get(resultIndex)).get('value')).get('details');
								if (result.value.numberComponentErrors == 1) {
									// Get Object
									Map<String, Object> failuresObj = (Map<String, Object>)resultItemDetails.get('componentFailures');									
									TemplateDeploymentResponseResultComponent compFailed = (TemplateDeploymentResponseResultComponent) JSON.deserialize(JSON.serialize(failuresObj), TemplateDeploymentResponseResultComponent.class);
									
									if (compFailed.componentType.equalsIgnoreCase('WaveTemplateBundle')) {
										// It's a template
										String compName = compFailed.fullName;
										if (this.repositoryTemplatesMap.containsKey(compName)) {
											// We get the template label
											String tplLabel = this.repositoryTemplatesMap.get(compName).template.label;
											lstFailedTemplates.add(tplLabel);
										}
									}
								} 
								else {
									// Get Array
									List<Object> lstFailures = (List<Object>)resultItemDetails.get('componentFailures');
									lstFailedTemplates.add('Deployment item Nr.: ' + (resultIndex + 1));
								}
							}
						}
						resultIndex++;
					}

					if (lstFailedTemplates.size() == 0) {
						this.dplSuccessMessage = 'Template deployment completed successfully.';
						this.sendTemplateDeploymentSuccessEmail();
					}
					else {										
						this.dplErrorMessage = 'One or more templates failed to deploy.\n';
						this.dplErrorMessage = this.dplErrorMessage + String.join(lstFailedTemplates, '\n');
						this.modalDetailsMessage.body = res.getBody();
						this.modalDetailsMessage.header = 'Template deployment failed: More information';
					}
					
					this.disabledButton = false;
					this.processingTemplateDeployment = false;
				}
			}
			else {
				this.dplErrorMessage = 'Template deployment failed. Lost connection with the job process at server side.';
				this.disabledButton = false;
				this.processingTemplateDeployment = false;
			}
		}
	}

	public void dragSelectedTemplates(){
		if (this.templatesToDrag.size() > 0) {
			this.selectedTemplates.addAll(this.templatesToDrag);
			for (String tpl: this.templatesToDrag) {
				Integer i = this.undraggedTemplates.indexOf(tpl);
				if (i != -1) {
					this.undraggedTemplates.remove(i);
				}
			}
		}
	}

	public void returnSelectedTemplates(){
		if (this.templatesToReturn.size() > 0) {
			this.undraggedTemplates.addAll(this.templatesToReturn);
			for (String tpl: this.templatesToReturn) {
				Integer i = this.selectedTemplates.indexOf(tpl);
				if (i != -1) {
					this.selectedTemplates.remove(i);
				}
			}
		}
	}

	public List<SelectOption> getDraggedTemplates() {
        
        List<SelectOption> options = new List<SelectOption>();
		
		for (String t : this.selectedTemplates) {
			RepositoryTemplateResponse repoTplHashed = this.repositoryTemplatesMap.get(t);
			options.add(new SelectOption(repoTplHashed.template.api_name, repoTplHashed.template.label));
		}
		
		return options;
	}

	private void sendTemplateDeploymentSuccessEmail(){
		String username = UserInfo.getUserName();
		String orgId = UserInfo.getOrganizationId();
		WaveConfiguratorUtils.sendEmail(this.emailAddress, 'Template deployment completed successfully', 'The Template Deployment process has finished successfully. \n\nUsername: ' + username + '\nOrganization ID: ' + orgId + '\n\nThe following templates were deployed:\n\n' + String.join(this.selectedTemplates, '\n'));
	}

	public void handleAdvancedTemplateDeploy(){
		this.advancedTemplateDeploy = !this.advancedTemplateDeploy;
	}

	public void tplDeployUrlChanged(){
		try{
			this.resetMessages();
			if (String.isNotBlank(this.tplDeployUrl)) {
				this.setTemplateServiceCookie();
			}
			else {
				this.dplWarningMessage = 'Base Endpoint URL for deployment services must not be blank.';
			}
		}
		catch(Exception e) {
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			this.dplErrorMessage = e.getMessage();
		}
	}

	public void tplDeployRepoBranchChanged(){
		this.resetMessages();
		this.retrievedTemplates = false;
	}

	public List<SelectOption> getBranches() {
        
        List<SelectOption> options = new List<SelectOption>();
		
		options.add(new SelectOption('master', 'Master'));
		options.add(new SelectOption('beta', 'Beta'));
		
		return options;
	}

	// **************************** TIMESHIFTING DATAFLOW TOOL ******************************

	public class TimeShiftingDataflowParameters {
		String id { get; set; } // Id of the dataflow for an overwrite operation
		String name { get; set; } // API name for dataflow in create operation
		String label { get; set; } // Label for dataflow in create operation
		String operation { get; set; } // create | overwrite
	}

	public class TimeShiftingDataflowDataset {
		String id { get; set; } // Dataset ID
	}

	public class TimeShiftingDataflowRequest {
		TimeShiftingDataflowParameters dataflow_parameters { get;set; }
		List<TimeShiftingDataflowDataset> dataset_array { get;set; }
	}

	public class ApiJobResponseResult {
		Boolean success { get; set; }
		String dataflow_id { get; set; } // Dataflow ID
		String dataflow_version_id { get; set; } // Dataflow Version ID
		List<ApiJobResultDataset> branches { get; set; } // Datasets that succeeded and were added to dataflow
		List<ApiJobResultDataset> errors { get; set; } // Datasets that weren't added to dataflow
		String message { get; set; } // Error message when success = false
	}

	public class ApiJobStartResponse {
		String job_id { get; set; }
		String run_at { get; set; }
	}

	public class ApiJobResultDataset {
		String dataset_id { get; set; }
		String error { get; set; }
	}

	public class ApiJobResponse {
		String name { get; set; } // Name of the job
		String org { get; set; } // ORG Instance URL
		String run_at { get; set; } // Job Started Timestamp, for example: 2020-08-10T18:34:50.312Z
		String done_at { get; set; } // Job Finished Timestamp, for example: 2020-08-10T18:34:55.023Z
		Boolean success { get; set; }
		ApiJobResponseResult result { get; set; }
	}

	public class FolderDatasetResponse {
		String id { get; set; }
		String label { get; set; }
		List<DatasetItemResponse> datasets { get; set; }
	}

	public class DatasetItemResponse {
		public String id { get; set; }
		public String label { get; set; }
		public String name { get; set; }
		public Boolean selected { get; set; }
	}

	public List<SelectOption> getAppsForTimeshiftingDataflow(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', ''));
		
		if (this.retrievedTsDatasets) {
			
			for (String appId : this.mapOfDatasetsByFolder.keySet()) {
				if(String.isNotBlank(this.mapOfDatasetsByFolder.get(appId).label)){
					options.add(new SelectOption(appId, this.mapOfDatasetsByFolder.get(appId).label));
				}
			}
		}

		return options;
	}	

	public void loadTimeshiftingDataflowTab(){
		if (!this.retrievedTsDatasets) {					
			
			Map<String, String> headersMap = new Map<String, String>();
			if (String.isBlank(this.cookieString)) {
				this.setTemplateServiceCookie();
			}
			headersMap.put('Cookie', this.cookieString);
			HTTPResponse res = WaveConfiguratorUtils.httpCallout(
				this.tsdfUrl + '/api/org/refresh',
				'GET',
				'',
				'application/json',
				headersMap
			);

			this.mapOfDatasetsByFolder = new Map<String, FolderDatasetResponse>();
			
			List<EdgeMart> lstDatasets = [
				SELECT DeveloperName, FolderId, Id, MasterLabel, Folder.Name 
				FROM EdgeMart
				ORDER BY Folder.Name, MasterLabel
			];

			for (EdgeMart e : lstDatasets) {

				if (!this.mapOfDatasetsByFolder.containsKey(e.FolderId)) {
					FolderDatasetResponse fdr = new FolderDatasetResponse();
					fdr.id = e.FolderId;
					fdr.label = e.Folder.Name;
					fdr.datasets = new List<DatasetItemResponse>();
					this.mapOfDatasetsByFolder.put(e.FolderId, fdr);
				}
				
				DatasetItemResponse d = new DatasetItemResponse();
				d.id = e.Id;
				d.label = e.MasterLabel;
				d.name = e.DeveloperName;
				d.selected = true;

				FolderDatasetResponse fdrAux = this.mapOfDatasetsByFolder.get(e.FolderId);
				fdrAux.datasets.add(d);

				this.mapOfDatasetsForTimeshiftingDataflow.put(e.Id, d);
			}

			this.retrievedTsDatasets = true;
		}
	}

	public void appsForTimeshiftingDataflowChanged(){
		if (String.isNotBlank(this.selectedAppForTimeshiftingDataflow)) {
			this.selectedDatasetsForTimeshiftingDataflow = new List<DatasetItemResponse>();
			List<DatasetItemResponse> dsList = this.mapOfDatasetsByFolder.get(this.selectedAppForTimeshiftingDataflow).datasets;
			if (dsList != null && dsList.size() > 0) {
				this.selectedDatasetsForTimeshiftingDataflow.addAll(dsList);	
			}
		}
		else {
			this.selectedDatasetsForTimeshiftingDataflow.clear();
		}
	}

	public void executeTsDataflowGeneration(){
		
		if (this.tsdfCreateOrReplace == 'create') {
			// Create
			this.createNewTsDataflow();
		}
		else if(this.tsdfCreateOrReplace == 'replace'){
			// Replace
			this.replaceTsDataflow();
		}
		else {
			this.tsdfWarningMessage = 'Please select between Create a new Dataflow or Overwrite an existing Dataflow options.';
		}
	}

	private void createNewTsDataflow(){
		List<String> validations = new List<String>();
		this.processingTimeshiftingDataflow = false;
		this.resetMessages();

		if (String.isBlank(this.tsdfName)) {
			validations.add('Please enter the dataflow name.');
		}

		if (AnalyticsDemoDataflowHelper.dataflowExistsByApiName(this.tsdfName)) {
			validations.add('Please select another dataflow name. The one that you entered is already in use.');
		}

		if (this.selectedDatasetsForTimeshiftingDataflow.size() == 0) {
			validations.add('Please select any dataset to include in the dataflow.');
		}

		if(validations.size() > 0){
			this.tsdfWarningMessage = String.join(validations, '\n');
		}
		else {
			try {

				TimeShiftingDataflowParameters tsdfParams = new TimeShiftingDataflowParameters();
				tsdfParams.name = this.tsdfName;
				tsdfParams.label = String.isNotBlank(this.tsdfLabel) ? this.tsdfLabel : this.tsdfName;
				tsdfParams.operation = 'create';

				List<TimeShiftingDataflowDataset> datasetsJsonToSend = new List<TimeShiftingDataflowDataset>();
				
				
				for (DatasetItemResponse variable : this.selectedDatasetsForTimeshiftingDataflow) {
					if (variable.selected) {
						TimeShiftingDataflowDataset tsdd = new TimeShiftingDataflowDataset();
						tsdd.id = variable.id;
						datasetsJsonToSend.add(tsdd);
					}
				}

				TimeShiftingDataflowRequest tsdfRequest = new TimeShiftingDataflowRequest();
				tsdfRequest.dataflow_parameters = tsdfParams;
				tsdfRequest.dataset_array = datasetsJsonToSend;

				String jsonBody = JSON.serialize(tsdfRequest, true);
				//System.debug(jsonBody);
		
				Map<String, String> headersMap = new Map<String, String>();
				if (String.isBlank(this.cookieString)) {
					this.setTemplateServiceCookie();
				}
				headersMap.put('Cookie', this.cookieString);
				
				HTTPResponse res = WaveConfiguratorUtils.httpCallout(
					this.tsdfUrl + '/api/org/dataflow',
					'POST',
					jsonBody,
					'application/json',
					headersMap
				);
		
				ApiJobStartResponse jobInfo = (ApiJobStartResponse) JSON.deserialize(res.getBody(), ApiJobStartResponse.class);	
				if (jobInfo != null) {
					if (String.isNotBlank(jobInfo.job_id)) {
						this.processingTimeshiftingDataflow = true;
						this.tsdfJobId = jobInfo.job_id;
						this.disabledButton = true;
					}
				}
			}
			catch (Exception ex) {
				System.debug(ex.getMessage());
				System.debug(ex.getStackTraceString());
				this.tsdfErrorMessage = ex.getMessage();
				this.disabledButton = false;
			}
		}
	}

	private void replaceTsDataflow(){

		this.processingTimeshiftingDataflow = false;
		this.resetMessages();
		
		List<String> validations = new List<String>();

		if (String.isBlank(this.selectedDataflowForTimeshiftingDataflow)) {
			validations.add('Please select the dataflow to overwrite.');
		}

		if (this.selectedDatasetsForTimeshiftingDataflow.size() == 0) {
			validations.add('Please select any dataset to include in the dataflow.');
		}

		if(validations.size() > 0){
			this.tsdfWarningMessage = String.join(validations, '\n');
		}
		else {
			try {
				TimeShiftingDataflowParameters tsdfParams = new TimeShiftingDataflowParameters();
				tsdfParams.id = this.selectedDataflowForTimeshiftingDataflow;
				tsdfParams.operation = 'overwrite';

				List<TimeShiftingDataflowDataset> datasetsJsonToSend = new List<TimeShiftingDataflowDataset>();
								
				for (DatasetItemResponse variable : this.selectedDatasetsForTimeshiftingDataflow) {
					if (variable.selected) {
						TimeShiftingDataflowDataset tsdd = new TimeShiftingDataflowDataset();
						tsdd.id = variable.id;
						datasetsJsonToSend.add(tsdd);
					}
				}

				TimeShiftingDataflowRequest tsdfRequest = new TimeShiftingDataflowRequest();
				tsdfRequest.dataflow_parameters = tsdfParams;
				tsdfRequest.dataset_array = datasetsJsonToSend;

				String jsonBody = JSON.serialize(tsdfRequest, true);
				System.debug('Overwritting TimeShifting Dataflow...');
				System.debug(jsonBody);

				Map<String, String> headersMap = new Map<String, String>();
				if (String.isBlank(this.cookieString)) {
					this.setTemplateServiceCookie();
				}
				headersMap.put('Cookie', this.cookieString);
				
				HTTPResponse res = WaveConfiguratorUtils.httpCallout(
					this.tsdfUrl + '/api/org/dataflow',
					'POST',
					jsonBody,
					'application/json',
					headersMap
				);

				System.debug(res.getBody());

				ApiJobStartResponse jobInfo = (ApiJobStartResponse) JSON.deserialize(res.getBody(), ApiJobStartResponse.class);	
				if (jobInfo != null) {
					if (String.isNotBlank(jobInfo.job_id)) {
						this.processingTimeshiftingDataflow = true;
						this.tsdfJobId = jobInfo.job_id;
						this.disabledButton = true;
					}
				}
			} 
			catch (Exception ex) {
				System.debug(ex.getMessage());
				System.debug(ex.getStackTraceString());
				this.tsdfErrorMessage = ex.getMessage();
				this.disabledButton = false;
			}
		}		
	}

	public List<SelectOption> getTsdfCreateOrReplaceOptions() {
        
        List<SelectOption> options = new List<SelectOption>();
		
		options.add(new SelectOption('create', 'Create a new Dataflow'));
		options.add(new SelectOption('replace', 'Overwrite an existing Dataflow'));
		
		return options;
	}

	public List<SelectOption> getDataflowsForTimeshiftingDataflow(){
		List<SelectOption> options = this.getOrgDataflows();
		options.remove(0);
		return options;
	}

	public void suggestTsDataflowName(){
		if (String.isBlank(this.tsdfName) && String.isNotBlank(this.tsdfLabel)) {			
			this.tsdfName = WaveConfiguratorUtils.generateApiName(this.tsdfLabel);
		}
	}

	public void checkTimeshiftingDataflowStatus(){
		try {
			if (String.isNotBlank(this.tsdfJobId)) {
				Map<String, String> headersMap = new Map<String, String>();
				if (String.isBlank(this.cookieString)) {
					this.setTemplateServiceCookie();
				}
				headersMap.put('Cookie', this.cookieString);
				HTTPResponse res = WaveConfiguratorUtils.httpCallout(
					this.tplDeployUrl + '/api/jobs/' + this.tsdfJobId,
					'GET',
					'',
					'application/json',
					headersMap
				);

				System.debug(res.getBody());

				ApiJobResponse jobResult = (ApiJobResponse)JSON.deserialize(res.getBody(), ApiJobResponse.class);

				if (jobResult != null) {

					if (String.isNotBlank(jobResult.done_at)) {
						// Job finished
						this.processingTimeshiftingDataflow = false;
						this.disabledButton = false;

						if (jobResult.result.success) {
							// Search for errors 
							if (jobResult.result.errors != null && jobResult.result.errors.size() > 0) {
								this.tsdfWarningMessage = res.getBody();
								List<String> lstFailedDatasets = new List<String>();
								for (ApiJobResultDataset dsError : jobResult.result.errors) {
									String datasetLabel = this.mapOfDatasetsForTimeshiftingDataflow.get(dsError.dataset_id).label;
									lstFailedDatasets.add(datasetLabel + ' was not included: ' + dsError.error);
								}
								
								String errorMsg = String.join(lstFailedDatasets, '\n');
								this.tsdfWarningMessage = 'The Timeshifting Dataflow generation completed successfully. However, some datasets could not be included: \n' + errorMsg;
							}
							else {
								this.tsdfSuccessMessage = 'The Timeshifting Dataflow generation completed successfully.';
							}
							
							if (String.isNotBlank(this.emailAddress)) {
								this.sendTimeshiftingDataflowSuccessEmail(jobResult.result.dataflow_id);	
							}
						}
						else {
							this.tsdfErrorMessage = 'The Timeshifting Dataflow generation failed: ' + jobResult.result.message;
						}
					}
				}
				else {
					// Job disconnected
					this.processingTimeshiftingDataflow = false;
					this.disabledButton = false;
					this.tsdfErrorMessage = 'The Timeshifting Dataflow generation failed. Lost connection with the job process at server side.';
				}
			}
		}
		catch (Exception ex) {
			System.debug(ex.getMessage());
			System.debug(ex.getStackTraceString());
			this.tsdfErrorMessage += ex.getMessage();
			this.disabledButton = false;
		}
	}

	public void sendTimeshiftingDataflowSuccessEmail(String dataflowId){
		String username = UserInfo.getUserName();
		String orgId = UserInfo.getOrganizationId();
		Dataflow dfInfo = AnalyticsDemoDataflowHelper.dataflowById(dataflowId);

		if (dfInfo != null) {
			WaveConfiguratorUtils.sendEmail(
				this.emailAddress, 
				'Timeshifting Dataflow generation successfully', 
				'The Timeshifting Dataflow generation process has finished successfully. \n\nUsername: ' + username + '\nOrganization ID: ' + orgId + '\n\nDataflow Label: ' + dfInfo.MasterLabel + '\nDataflow Id: ' + dfInfo.Id);	
		}
	}

	// TO-DoS:
	// 1) 
	// 2) 
	// 3) 
	// 4) 
}