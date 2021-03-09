@isTest
private class WaveDataManager_test {

	private static MultiStaticResourceCalloutMock createStaticResources(){
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String appsMetadataUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/WaveApplications.csv';
		String simpleAppJsonUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/Simple.json';
		String accountsMetadataUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/Account_metadata.csv';
		String accountsDataUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/Account.csv';
		String accountSchemaUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/Account.schema.json';
		String oppMetadataUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/Opportunity_metadata.csv';
		String oppDataUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/Opportunity.csv';
		String userDataurl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/User.csv';
		String userMetadataUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/simple/User_metadata.csv';
		String waveForSalesJsonUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo/sales/WaveForSales.json';
		String analyticsFaqDemoUrl = 'https://s3-us-west-2.amazonaws.com/ac-sdo-repo-dev/AnalyticsDemoFAQ.json';

		multimock.setStaticResource(appsMetadataUrl, 'WaveAppsMetadataCSV');
		multimock.setStaticResource(accountsMetadataUrl, 'AccountMetadataCSV');
		multimock.setStaticResource(accountsDataUrl, 'AccountsDataCSV');
		multimock.setStaticResource(accountSchemaUrl, 'AccountSchemaJson');
		multimock.setStaticResource(oppMetadataUrl, 'OpportunityMetadataCSV');
		multimock.setStaticResource(oppDataUrl, 'OpportunitiesDataCSV');
		multimock.setStaticResource(waveForSalesJsonUrl, 'WaveForSalesJson');
		multimock.setStaticResource(simpleAppJsonUrl, 'SimpleAppJson');
		multimock.setStaticResource(userDataurl, 'UsersDataCSV');
		multimock.setStaticResource(userMetadataUrl, 'UserMetadataCSV');
		multimock.setStaticResource(analyticsFaqDemoUrl, 'AnalyticsFAQDemo');
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'text/plain');

		return multimock; 
	}
	@isTest static void basicControllerTest() {

		SmartLookup sm = new SmartLookup(0, 'User');

		WaveDataManagerController cnt = new WaveDataManagerController(); // Constructor
		cnt.resetMessages();

		System.assertEquals(0, cnt.processingLog.size());
	}

	@isTest static void metadataUtilsTest() {

		System.assertEquals(false, SF_MetadataUtils.objectExists('FakeTestObj'));
		System.assertEquals(false, SF_MetadataUtils.fieldExists('FakeTestObj', ''));
		System.assertEquals(true, SF_MetadataUtils.fieldExists('Account', 'Id'));

		MetadataServiceWebServiceMockImpl workflowMock = new MetadataServiceWebServiceMockImpl();
		workflowMock.filePropertiesFullNames.put('Case', new List<String>{'MockValidationRule'});
		Test.setMock(WebServiceMock.class, workflowMock);
		List<String> objectsNames = new List<String>();
		objectsNames.add('Case');
		List<String> errs = SF_MetadataUtils.getObjectsWithRulesAndOrWorkflows(objectsNames, 43);

		// Null Web Service mock implementation
        Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createObject('TestObj__c', 'fake-session-id');

		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createObject('TestObj__c');

		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.assignAccessToField('Task', 'Id');

		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.assignAccessToField('Account', 'Id', 'fake-session-id');

		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		SF_MetadataUtils.RecordTypeSpecification recTypeSpec = new SF_MetadataUtils.RecordTypeSpecification();
		recTypeSpec.ObjectName = 'Opportunity';
		recTypeSpec.DeveloperName = 'Test_Oppty_Rec_Type';
		recTypeSpec.Name = 'Test_Oppty_Rec_Type';
		recTypeSpec.BusinessProcessName = '';
		recTypeSpec.Description = '';
		errs = SF_MetadataUtils.createRecordType(recTypeSpec, 'fake-session-id');

		SF_MetadataUtils.CustomFieldSpecification fieldSpec = new SF_MetadataUtils.CustomFieldSpecification();
		fieldSpec.ObjectName = 'TestObj__c';
		fieldSpec.Name = 'TestField__c';
    	fieldSpec.Label = 'Test field';
    	fieldSpec.Type = 'Text';
		fieldSpec.ReferenceTo = '';
		fieldSpec.Length = 50;
		fieldSpec.Precision = 0;
		fieldSpec.Scale = 0;
		fieldSpec.IsExternalId = false;
		fieldSpec.IsRequired = false;

		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createField(fieldSpec);

		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		fieldSpec.ObjectName = 'Task';
		errs = SF_MetadataUtils.createField(fieldSpec, 'fake-session-id');
		
		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		fieldSpec.Name = 'CreatedDate';
		errs = SF_MetadataUtils.createField(fieldSpec);

		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		SF_MetadataUtils.checkMetadataAPIConnection();

		fieldSpec = new SF_MetadataUtils.CustomFieldSpecification();
		fieldSpec.ObjectName = 'TestObj__c';
		fieldSpec.Name = 'TestField2__c';
    	fieldSpec.Label = 'Test field 2';
    	fieldSpec.Type = 'Lookup';
		fieldSpec.ReferenceTo = 'User';
		fieldSpec.Length = 0;
		fieldSpec.Precision = 0;
		fieldSpec.Scale = 0;
		fieldSpec.IsExternalId = false;
		fieldSpec.IsRequired = false;		

		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createField(fieldSpec);

		// Now test field creation for Checkbox, Number, TextArea, LongTextArea, Picklist, Formula
		// Checkbox
		fieldSpec = new SF_MetadataUtils.CustomFieldSpecification();
		fieldSpec.ObjectName = 'TestObj__c';
		fieldSpec.Name = 'CheckboxTestField__c';
    	fieldSpec.Label = 'Checkbox Test field';
    	fieldSpec.Type = 'Checkbox';
		fieldSpec.DefaultValue = '';
		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createField(fieldSpec);

		// Number
		fieldSpec = new SF_MetadataUtils.CustomFieldSpecification();
		fieldSpec.ObjectName = 'TestObj__c';
		fieldSpec.Name = 'NumberTestField__c';
    	fieldSpec.Label = 'Number Test field';
    	fieldSpec.Type = 'Number';
		fieldSpec.Precision = 10;
		fieldSpec.Scale = 0;
		fieldSpec.DefaultValue = '11';
		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createField(fieldSpec);

		// TextArea
		fieldSpec = new SF_MetadataUtils.CustomFieldSpecification();
		fieldSpec.ObjectName = 'TestObj__c';
		fieldSpec.Name = 'TextAreaTestField__c';
    	fieldSpec.Label = 'TextArea Test field';
    	fieldSpec.Type = 'TextArea';
		fieldSpec.Length = 255;
		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createField(fieldSpec);

		// LongTextArea
		fieldSpec = new SF_MetadataUtils.CustomFieldSpecification();
		fieldSpec.ObjectName = 'TestObj__c';
		fieldSpec.Name = 'LongTextAreaTestField__c';
    	fieldSpec.Label = 'LongTextArea Test field';
    	fieldSpec.Type = 'LongTextArea';
		fieldSpec.Length = 1000;
		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createField(fieldSpec);

		// Picklist
		fieldSpec = new SF_MetadataUtils.CustomFieldSpecification();
		fieldSpec.ObjectName = 'TestObj__c';
		fieldSpec.Name = 'PicklistTestField__c';
    	fieldSpec.Label = 'Picklist Test field';
    	fieldSpec.Type = 'Picklist';
		fieldSpec.PickListValues = 'A,B,C';
		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createField(fieldSpec);

		// Formula
		fieldSpec = new SF_MetadataUtils.CustomFieldSpecification();
		fieldSpec.ObjectName = 'TestObj__c';
		fieldSpec.Name = 'FormulaTestField__c';
    	fieldSpec.Label = 'Formula Test field';
    	fieldSpec.Type = 'Text';
		fieldSpec.Formula = 'Name  & \' for testing\'';
		Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
		errs = SF_MetadataUtils.createField(fieldSpec);
	}

    @isTest static void prepCoreTest(){
		MultiStaticResourceCalloutMock multimock = createStaticResources(); 

		WaveDataManagerController cnt = new WaveDataManagerController();

		Test.setMock(HttpCalloutMock.class, multimock);
		cnt.pageLoad();

		cnt.selectedWaveApp = 'Simple';
		cnt.selectedInstallationProcess = 'loadObjects';
		
		cnt.executeSelectedProcess();

		Test.startTest();
		cnt.loadAllObjects();
		Test.stopTest();

		cnt.checkObjectLoadingStatus();
		List<SelectOption> options = cnt.getWaveApps();
		cnt.getAppDescription();

		System.assert(options.size() > 0);
	}
	
	@isTest static void checktimeShiftingStatusTest(){
        
        MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
        
        MetadataServiceWebServiceMockImpl mock = new MetadataServiceWebServiceMockImpl();
		Test.setMock(WebServiceMock.class, mock);
        
		WaveDataManagerController cnt = new WaveDataManagerController();
		cnt.pageLoad();

		cnt.selectedWaveApp = 'Simple';

		cnt.selectedInstallationProcess = 'timeShifting';
		cnt.updateSelectedObjectsToTimeShift();
        
		Test.startTest();
        cnt.selectAppMetadata();
		cnt.executeSelectedProcess();
		Test.stopTest();

		cnt.checkTimeShiftingStatus();
	}
	
	@isTest static void timeShiftingTestServices(){
		List<String> dateFieldNames = new List<String>();
		dateFieldNames.add('CreatedDate__c');
		
		Case cs = new Case();
		SObject caseToTest = cs.getSObjectType().newSObject();
		caseToTest.put('Subject', 'TestCase');
		caseToTest.put('Status', 'Closed');
		caseToTest.put('Priority', 'Medium');
		caseToTest.put('Origin', 'Email');
		caseToTest.put('CreatedDate__c', DateTime.now().addDays(-5));
		
		//Case cas = new Case(Subject='TestCase', Status ='Closed', Priority = 'Medium', Origin = 'Email', CreatedDate__c = DateTime.now().addDays(-5));
        insert caseToTest;

		Test.startTest();
		TimeShiftingBatch batchProcess = new TimeShiftingBatch('Case', dateFieldNames, 0, '');
		ID batchId = Database.executeBatch(batchProcess);
		Test.stopTest();
	}

	@isTest static void timeShiftingTestSales(){
		List<String> dateFieldNames = new List<String>();
		dateFieldNames.add('DateTimeCreated__c'); //Type DateTime
		dateFieldNames.add('CloseDate'); //Type Date
		
		Account acc = new Account(Name = 'TestAccount', Description = 'Test Account Desc');
		insert acc;
		
		Opportunity opp = new Opportunity(); 
		SObject opptyToTest = opp.getSObjectType().newSObject();
		opptyToTest.put('AccountId', acc.Id);
		opptyToTest.put('Name', 'TestOpportunity');
		opptyToTest.put('StageName', 'Closed Won');
		opptyToTest.put('DateTimeCreated__c', DateTime.now().addDays(-5));
		opptyToTest.put('CloseDate', Date.today().addDays(-1));
		/*opp.AccountId = acc.Id;
		opp.Name = 'TestOpportunity';
		opp.StageName = 'Closed Won';
		opp.CloseDate = Date.today();
		opp.CreatedDate__c = Date.today().addDays(-5);*/
		insert opptyToTest;

		Test.startTest();
		TimeShiftingBatch batchProcess = new TimeShiftingBatch('Opportunity', dateFieldNames, 0, '');
		ID batchId = Database.executeBatch(batchProcess);
		Test.stopTest();
	}

	@isTest static void getWaveAppsAndDescriptionTest(){
		WaveDataManagerController cnt = new WaveDataManagerController();
		List<SelectOption> options = cnt.getWaveApps();

		System.assertEquals(0, options.size());

		cnt.selectedWaveApp = 'Wave for Sales';
		String appDsc = cnt.getAppDescription();
	}


 	@isTest static void displayMetadataResponseTest(){
 		WaveDataManagerController cnt = new WaveDataManagerController();

 		cnt.displayMetadataResponse();
		System.assertEquals(false, cnt.MetadataConnectionWarning);

		cnt.MetadataResponse = 'TEST';
		cnt.displayMetadataResponse();
		System.assertEquals(true, cnt.MetadataConnectionWarning);
 	}
    
	@isTest static void sendEmailTest(){
		String address = 'test@test.com';		
		String label = 'Test label'; 
		WaveConfiguratorUtils.sendEmail(address, label);		
	}

	@isTest static void executeSelectedProcessTest(){
        MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
        
        MetadataServiceWebServiceMockImpl mock = new MetadataServiceWebServiceMockImpl();
		Test.setMock(WebServiceMock.class, mock);
        
		WaveDataManagerController cnt = new WaveDataManagerController();
        
		cnt.pageLoad();
		cnt.selectedWaveApp = 'Simple';
        
		cnt.selectedInstallationProcess = 'createMetadata';
		cnt.executeSelectedProcess();
		
		cnt.selectedInstallationProcess = 'timeShifting';
		cnt.executeSelectedProcess();
        
        cnt.selectedInstallationProcess = 'setActionFields';
		cnt.executeSelectedProcess();
        
        cnt.selectedInstallationProcess = 'loadEdgemarts';
		cnt.executeSelectedProcess();
        
        cnt.selectedInstallationProcess = 'setActionFields';
        cnt.selectedDataflowForActionFields = 'selectedDataflowForActionFields';
		cnt.executeSelectedProcess();
        
        //negative
        cnt.selectedInstallationProcess = 'createCompleteApp';
		cnt.executeSelectedProcess();
        
        //positive
		cnt.createCompleteAppName = 'createCompleteAppName';
        cnt.createCompleteAppLabel = 'createCompleteAppLabel';
        cnt.selectedInstallationProcess = 'createCompleteApp';
		cnt.executeSelectedProcess();
        
	}

	@isTest static void loadObjectsThroughChoosingProcess(){
		WaveDataManagerController cnt = new WaveDataManagerController();
		MultiStaticResourceCalloutMock multimock = createStaticResources(); 

		Test.setMock(HttpCalloutMock.class, multimock);
		cnt.pageLoad();

		cnt.selectedWaveApp = 'Simple';
		cnt.selectedInstallationProcess = 'loadObjects';
		cnt.executeSelectedProcess();
	}

	@isTest static void handlerSectionMethodsTest(){
		WaveDataManagerController cnt = new WaveDataManagerController();
		cnt.advancedTimeShifting = false;
		cnt.advancedOption = false;

		cnt.handleAdvancedSetting();
		cnt.handleAdvancedTimeShifting();
	}

	@isTest static void calculateDaysToShift(){
		Account acc = new Account(Name = 'TestAccount', Description = 'Test Account Desc');
		insert acc;

		Opportunity opp = new Opportunity();
		SObject opptyToTest = opp.getSObjectType().newSObject();

		opptyToTest.put('AccountId', acc.Id);
		opptyToTest.put('External_Id__c', 'W_Opportunity.Test');
		opptyToTest.put('Name', 'TestOpportunity');
		opptyToTest.put('StageName', 'Closed Won');
		opptyToTest.put('CloseDate', Date.today());
		insert opptyToTest;

		MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
		WaveDataManagerController cnt = new WaveDataManagerController();
        
        Test.startTest();
        cnt.pageLoad();
		cnt.selectedWaveApp = 'Simple';
        cnt.selectAppMetadata();
		cnt.selectedInstallationProcess = 'timeShifting';
		cnt.overrideDefaultSettingTS = false;
		cnt.calculateDaysToShift();
        Test.stopTest();
	}

	@isTest static void loadEdgemartsTest(){
		MultiStaticResourceCalloutMock multimock = createStaticResources(); 

		WaveDataManagerController cnt = new WaveDataManagerController();

		Test.setMock(HttpCalloutMock.class, multimock);
		cnt.pageLoad();

		cnt.selectedWaveApp = 'Simple';
		cnt.selectedInstallationProcess = 'loadEdgemarts';
		
		Test.startTest();
		cnt.executeSelectedProcess();
		Test.stopTest();

		cnt.checkEdgemartLoadStatus();
	}

	@isTest static void availableProcessesTest(){
		MultiStaticResourceCalloutMock multimock = createStaticResources(); 

		WaveDataManagerController cnt = new WaveDataManagerController();

		Test.setMock(HttpCalloutMock.class, multimock);
		cnt.pageLoad();

		cnt.selectedWaveApp = 'Simple';
		cnt.selectAppMetadata();
		
		Test.startTest();
		List<SelectOption> availableProcesses = cnt.getAvailableProcesses();
		Test.stopTest();

		System.assert(availableProcesses.size() > 0);
	}
    
    @isTest static void getOrgDataflowsTest(){
        WaveDataManagerController cnt = new WaveDataManagerController();
        List<SelectOption> options = new List<SelectOption>();
        
        Test.startTest();
        options = cnt.getOrgDataflows();
        Test.stopTest();
        
        System.assert(!options.isEmpty());
    }
    
    @isTest static void getOrgAnalyticsAppsTest(){
        WaveDataManagerController cnt = new WaveDataManagerController();
        List<SelectOption> options = new List<SelectOption>();
        
        Test.startTest();
        options = cnt.getOrgAnalyticsApps();
        Test.stopTest();
        
        System.assert(!options.isEmpty());
    }
    
    @isTest static void selectedProcessTestTimeShifting(){
        MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
        
        MetadataServiceWebServiceMockImpl mock = new MetadataServiceWebServiceMockImpl();
		Test.setMock(WebServiceMock.class, mock);
        
        WaveDataManagerController cnt = new WaveDataManagerController();
        cnt.pageLoad();
        
        //first path
        cnt.selectedWaveApp = 'Simple';
        cnt.selectedInstallationProcess = 'timeShifting';
        
        Test.startTest();
        cnt.selectedProcess();
        Test.stopTest();
		
        
    }
    
    @isTest static void selectedProcessTestLoadObjects(){
        MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
        
        MetadataServiceWebServiceMockImpl mock = new MetadataServiceWebServiceMockImpl();
		Test.setMock(WebServiceMock.class, mock);
        
        WaveDataManagerController cnt = new WaveDataManagerController();
        cnt.pageLoad();
        
        //second path
        cnt.selectedWaveApp = 'Simple';
        cnt.selectedInstallationProcess = 'loadObjects';
        
        Test.startTest();
        cnt.selectedProcess();
        Test.stopTest();
        
    }
    
    @isTest static void selectedProcessTest(){
        MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
        
        MetadataServiceWebServiceMockImpl mock = new MetadataServiceWebServiceMockImpl();
		Test.setMock(WebServiceMock.class, mock);
        
        WaveDataManagerController cnt = new WaveDataManagerController();
        cnt.pageLoad();
        
        //third path
        cnt.selectedWaveApp = 'Simple';
        cnt.selectedInstallationProcess = 'setActionFields';
        
        Test.startTest();
        cnt.selectedProcess();
		//this.selectedAppMetadata.actionFieldOverrides is null
		cnt.checkMetadataCreationStatus();
        Test.stopTest();
        
    }
    
    @isTest static void saveSettingTest(){
        WaveDataManagerController cnt = new WaveDataManagerController();
        
        Test.startTest();
        cnt.saveSetting();
        Test.stopTest();
    }
    
    @isTest static void selectedAppTest(){
        MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
        
        MetadataServiceWebServiceMockImpl mock = new MetadataServiceWebServiceMockImpl();
		Test.setMock(WebServiceMock.class, mock);
        
        WaveDataManagerController cnt = new WaveDataManagerController();
        cnt.selectedWaveApp = 'Simple';
        
        cnt.pageLoad();
        
        Test.startTest();
        cnt.selectedApp();
        Test.stopTest();
    }
    
    @isTest static void checkCreateCompleteAppExistenceTest(){
        WaveDataManagerController cnt = new WaveDataManagerController();
        
        Test.startTest();
        cnt.checkCreateCompleteAppExistence();
        Test.stopTest();
    }
    
    @isTest static void buildConfirmationModalGenericTest(){
        WaveDataManagerController cnt = new WaveDataManagerController();
        String modalHeader = 'Test modalheader';
        String modalBody = 'Test modalBody';
        
        Test.startTest();
        cnt.buildConfirmationModalGeneric(modalHeader, modalBody);
        Test.stopTest();
    }
    
    @isTest static void updateSelectedObjectsToTimeShiftTest(){
		MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
        
        MetadataServiceWebServiceMockImpl mock = new MetadataServiceWebServiceMockImpl();
		Test.setMock(WebServiceMock.class, mock);
        
        WaveDataManagerController cnt = new WaveDataManagerController();
        cnt.selectedWaveApp = 'Simple';
        cnt.pageLoad();

        Test.startTest();
        cnt.updateSelectedObjectsToTimeShift();
        Test.stopTest();
        
    }
    
    @isTest static void finishPrepCoreDataTest(){
        WaveDataManagerController cnt = new WaveDataManagerController();
        
        Test.startTest();
        cnt.finishPrepCoreData();
        Test.stopTest();
    }
    
    @isTest static void createPermissionSetTest(){
        MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
        
        MetadataServiceWebServiceMockImpl mock = new MetadataServiceWebServiceMockImpl();
		Test.setMock(WebServiceMock.class, mock);
        
        WaveDataManagerController cnt = new WaveDataManagerController();
        
        Test.startTest();
        cnt.checkMetadataCreationStatus();
        Test.stopTest();
    }
    
    @isTest static void checkTimeShiftingStatusTestError(){
		MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		WaveDataManagerController cnt = new WaveDataManagerController();

		Test.setMock(HttpCalloutMock.class, multimock);
		cnt.pageLoad();

		cnt.selectedWaveApp = 'Simple';
		cnt.selectedInstallationProcess = 'loadObjects';
		
		cnt.executeSelectedProcess();
		cnt.loadAllObjects();
        
		Test.startTest();
		cnt.checkTimeShiftingStatus();
		Test.stopTest();
	}
    
    @isTest static void checkRecordTypeCreationStatusTest(){
		MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		WaveDataManagerController cnt = new WaveDataManagerController();

		Test.setMock(HttpCalloutMock.class, multimock);
		cnt.pageLoad();

		cnt.selectedWaveApp = 'Simple';
        cnt.selectedInstallationProcess = 'loadObjects';
        cnt.selectedProcess();
        
        
		cnt.loadAllObjects();
        cnt.checkDashboardLoadStatus();
        
        cnt.processingRecordTypes = True;
        cnt.executeSelectedProcess();
        
		Test.startTest();
		cnt.checkRecordTypeCreationStatus();
		Test.stopTest();
	}
    
    @isTest static void createCompleteAppTest(){
        MultiStaticResourceCalloutMock multimock = createStaticResources(); 
		Test.setMock(HttpCalloutMock.class, multimock);
        
        MetadataServiceWebServiceMockImpl mock = new MetadataServiceWebServiceMockImpl();
		Test.setMock(WebServiceMock.class, mock);
        
        WaveDataManagerController cnt = new WaveDataManagerController();
        
        Test.startTest();
        cnt.handleCompleteApp(true);
        Test.stopTest();
    }
    
    
	public class MetadataServiceWebServiceMockImpl implements WebServiceMock 
	{
		public Map<String, List<String>> filePropertiesFullNames;

		public MetadataServiceWebServiceMockImpl(){
			this.filePropertiesFullNames = new Map<String, List<String>>();
		}

		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof MetadataService.retrieve_element)
				response.put('response_x', new MetadataService.retrieveResponse_element());
			else if(request instanceof MetadataService.checkDeployStatus_element)
				response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
			else if(request instanceof MetadataService.listMetadata_element){
				MetadataService.listMetadataResponse_element listMetadataResponseElem = new MetadataService.listMetadataResponse_element();
				List<MetadataService.FileProperties> lstFileProps = new List<MetadataService.FileProperties>();
				for (String fpName : this.filePropertiesFullNames.keySet()) {
					for (String fpNameInner : this.filePropertiesFullNames.get(fpName)) {
					   MetadataService.FileProperties fp = new MetadataService.FileProperties();
					   fp.fullName = fpName + '.' + fpNameInner;
					   lstFileProps.add(fp);
					}
				}
				listMetadataResponseElem.result = new MetadataService.FileProperties[]{};
				for (MetadataService.FileProperties f : lstFileProps) {
				   listMetadataResponseElem.result.add(f);
				}
				
				response.put('response_x', listMetadataResponseElem);
			}
			else if(request instanceof MetadataService.checkRetrieveStatus_element)
				response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
			else if(request instanceof MetadataService.describeMetadata_element)
				response.put('response_x', new MetadataService.describeMetadataResponse_element());
			else if(request instanceof MetadataService.deploy_element)
				response.put('response_x', new MetadataService.deployResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof MetadataService.renameMetadata_element)
                response.put('response_x', new MetadataService.renameMetadataResponse_element());
            else if(request instanceof  MetadataService.cancelDeploy_element)
                response.put('response_x', new MetadataService.cancelDeployResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof  MetadataService.deployRecentValidation_element)
                response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof MetadataService.describeValueType_element)
                response.put('response_x', new MetadataService.describeValueTypeResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
			return;
		}
	}
}