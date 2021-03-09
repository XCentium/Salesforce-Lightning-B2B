/** ServiceWaveConfig
* Smart Wizard - Apex class to auto scan Service ORG and pre-poulate wizard Questions
* Date: Oct, 2016 , Jul 2017
* */

public with sharing class ServiceWaveConfigurationModifier extends wavetemplate.WaveTemplateConfigurationModifier{

    public override void onConfigurationRetrieval(wavetemplate.WaveTemplateInfo template)
    {
     //******************************************Initial-Requirements**********************************************************************/

        // check integration user access to variable defaults,
        checkDefaultsVisible(template);

        // check if backdoor flag is set on integration user
        checkBackdoor(template);

        //setSLA(template);
    }

    private void handleDemoConfiguration(wavetemplate.WaveTemplateInfo template){
    
        Map<string, wavetemplate.VariableDefinition> variables = template.getVariables();
        wavetemplate.VariableDefinition isDemoAppVar = variables.get('isDemoApplication');

        if(isDemoAppVar != null) {
            String isDemoApp = (String)isDemoAppVar.getDefaultValue();
             
            if(isDemoApp.equals('Yes')){
                // Set all the variable values required for demo

                //CaseDuration variable
                wavetemplate.VariableDefinition caseDurationVar = variables.get('CaseDuration');
                if(caseDurationVar != null) {
                    caseDurationVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'Time_Open__c', 'fieldLabel' => '' });    
                }

                //CaseDurationMoreFields variable
                wavetemplate.VariableDefinition caseDurationMoreFieldsVar = variables.get('CaseDurationMoreFields');
                if(caseDurationMoreFieldsVar != null) {
                    caseDurationMoreFieldsVar.setComputedValue(new List<Map<String, Object>> { new Map<String, Object> { 'sobjectName' => 'Case', 'fieldName' => '' } });    
                }

                //CaseSLA variable
                wavetemplate.VariableDefinition caseSLAVar = variables.get('CaseSLA');
                if(caseSLAVar != null) {
                    caseSLAVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'MilestoneStatus__c', 'fieldLabel' => '' });    
                }

                //CaseFCR variable
                wavetemplate.VariableDefinition caseFCRVar = variables.get('CaseFCR');
                if(caseFCRVar != null) {
                    caseFCRVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'First_Contact_Close__c', 'fieldLabel' => '' });    
                }

                //Fiscal_Month variable
                wavetemplate.VariableDefinition fiscalMonthVar = variables.get('Fiscal_Month');
                if(fiscalMonthVar != null) {
                    fiscalMonthVar.setComputedValue('01 - January');    
                }

                //CaseStatus variable
                wavetemplate.VariableDefinition caseStatusVar = variables.get('CaseStatus');
                if(caseStatusVar != null) {
                    caseStatusVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'Status' });    
                }

                //CaseSupportLevel variable
                wavetemplate.VariableDefinition caseSupportLevelVar = variables.get('CaseSupportLevel');
                if(caseSupportLevelVar != null) {
                    caseSupportLevelVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'Type_of_Support__c', 'fieldLabel' => '' });    
                }

                //CaseSeverityLevel variable
                wavetemplate.VariableDefinition caseSeverityLevelVar = variables.get('CaseSeverityLevel');
                if(caseSeverityLevelVar != null) {
                    caseSeverityLevelVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'Priority' });    
                }

                //CaseProduct variable
                wavetemplate.VariableDefinition caseProductVar = variables.get('CaseProduct');
                if(caseProductVar != null) {
                    caseProductVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'Product_Family_KB__c' });    
                }

                //CaseReason variable
                wavetemplate.VariableDefinition caseReasonVar = variables.get('CaseReason');
                if(caseReasonVar != null) {
                    caseReasonVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'Reason' });    
                }

                //CaseType variable
                wavetemplate.VariableDefinition caseTypeVar = variables.get('CaseType');
                if(caseTypeVar != null) {
                    caseTypeVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'Type' });    
                }

                //CaseOrigin variable
                wavetemplate.VariableDefinition caseOriginVar = variables.get('CaseOrigin');
                if(caseOriginVar != null) {
                    caseOriginVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'Origin' });    
                }

                //CSATField variable
                wavetemplate.VariableDefinition cSATFieldVar = variables.get('CSATField');
                if(cSATFieldVar != null) {
                    cSATFieldVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case', 'fieldName' => 'CSAT__c' });    
                }

                //GeographyObject variable
                wavetemplate.VariableDefinition geographyObjectVar = variables.get('GeographyObject');
                if(geographyObjectVar != null) {
                    geographyObjectVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Account' });    
                }

                //Geography variable
                wavetemplate.VariableDefinition geographyVar = variables.get('Geography');
                if(geographyVar != null) {
                    geographyVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Account', 'fieldName' => 'BillingState' });    
                }

                //IncludeCaseRecordTypes variable
                wavetemplate.VariableDefinition includeCaseRecordTypesVar = variables.get('IncludeCaseRecordTypes');
                if(includeCaseRecordTypesVar != null) {
                    includeCaseRecordTypesVar.setComputedValue('Yes');    
                }

                //IncludeQueueNames variable
                wavetemplate.VariableDefinition includeQueueNamesVar = variables.get('IncludeQueueNames');
                if(includeQueueNamesVar != null) {
                    includeQueueNamesVar.setComputedValue('Yes');    
                }

                //CaseMoreMeasures variable
                wavetemplate.VariableDefinition caseMoreMeasuresVar = variables.get('CaseMoreMeasures');
                if(caseMoreMeasuresVar != null) {
                    caseMoreMeasuresVar.setComputedValue(new List<Map<String, Object>> { new Map<String, Object> { 'sobjectName' => 'Case', 'fieldName' => '' } } );    
                }

                //CaseMoreDims variable
                wavetemplate.VariableDefinition caseMoreDimsVar = variables.get('CaseMoreDims');
                if(caseMoreDimsVar != null) {
                    caseMoreDimsVar.setComputedValue(new List<Map<String, Object>> { new Map<String, Object> { 'sobjectName' => 'Case', 'fieldName' => '' } });    
                }

                //IncludeCaseHistory variable
                wavetemplate.VariableDefinition includeCaseHistoryVar = variables.get('IncludeCaseHistory');
                if(includeCaseHistoryVar != null) {
                    includeCaseHistoryVar.setComputedValue('Yes');    
                }

                //TrackCSAT variable
                wavetemplate.VariableDefinition trackCSATVar = variables.get('TrackCSAT');
                if(trackCSATVar != null) {
                    trackCSATVar.setComputedValue('Yes');    
                }

                //IncludeKnowledge variable
                wavetemplate.VariableDefinition includeKnowledgeVar = variables.get('IncludeKnowledge');
                if(includeKnowledgeVar != null) {
                    includeKnowledgeVar.setComputedValue('Yes');    
                }

                //IncludeTelephony variable
                wavetemplate.VariableDefinition includeTelephonyVar = variables.get('IncludeTelephony');
                if(includeTelephonyVar != null) {
                    includeTelephonyVar.setComputedValue('Yes');    
                }

                //IncludeOpportunity variable
                wavetemplate.VariableDefinition includeOpportunityVar = variables.get('IncludeOpportunity');
                if(includeOpportunityVar != null) {
                    includeOpportunityVar.setComputedValue('Yes');    
                }

                //IncludeOpportunityRecordTypes variable
                wavetemplate.VariableDefinition includeOpportunityRecordTypesVar = variables.get('IncludeOpportunityRecordTypes');
                if(includeOpportunityRecordTypesVar != null) {
                    includeOpportunityRecordTypesVar.setComputedValue('Yes');    
                }

                //IncludeEvent variable
                wavetemplate.VariableDefinition includeEventVar = variables.get('IncludeEvent');
                if(includeEventVar != null) {
                    includeEventVar.setComputedValue('Yes');    
                }

                //IncludeBusinessHours variable
                wavetemplate.VariableDefinition includeBusinessHoursVar = variables.get('IncludeBusinessHours');
                if(includeBusinessHoursVar != null) {
                    includeBusinessHoursVar.setComputedValue('No');    
                }

                //IncludeChat variable
                wavetemplate.VariableDefinition includeChatVar = variables.get('IncludeChat');
                if(includeChatVar != null) {
                    includeChatVar.setComputedValue('Yes');    
                }

                //IncludeOmni variable
                wavetemplate.VariableDefinition includeOmniVar = variables.get('IncludeOmni');
                if(includeOmniVar != null) {
                    includeOmniVar.setComputedValue('Yes');    
                }

                //CSATObj variable
                wavetemplate.VariableDefinition cSATObjVar = variables.get('CSATObj');
                if(cSATObjVar != null) {
                    cSATObjVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Case' });    
                }

                //KnowldegeArticleType variable
                wavetemplate.VariableDefinition knowldegeArticleTypeVar = variables.get('KnowldegeArticleType');
                if(knowldegeArticleTypeVar != null) {
                    knowldegeArticleTypeVar.setComputedValue(new Map<String, Object>{ 'sobjectName' => 'Knowledge', 'sobjectLabel' => 'Knowledge' });    
                }

                //ScanOrg variable
                wavetemplate.VariableDefinition scanOrgVar = variables.get('ScanOrg');
                if(scanOrgVar != null) {
                    scanOrgVar.setComputedValue('No');    
                }
            }
        }
    }

    //*********************Validation Before APP Creation**************************************************
    // Executes when we click on Create-APP button
    public override void beforeAppCreate(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
    {
        // Get the user preference on org scanning
        String ScanOrg_ans = (String) answers.get('ScanOrg');

        setCustom(template, answers);
        checkIfCSATSelected(template, answers);
        checkIfKnowledgeArticleSelected(template, answers);


        // Validate only when answer's Yes to the wizard
        if(ScanOrg_ans == 'Yes')
        {
           caseHistoryStatusCheck(template, answers);

            //Verify if 'Analytics Cloud Integration User' has access to the necessary fields on the selected Objects based on Users responses
            integrationUserCheck(template, answers);
        }
    }

    //*********************Validation Before APP Update**************************************************
    // Executes when we click on Reset or Update button
     public override void beforeAppUpdate(wavetemplate.WaveTemplateInfo template, String previousAppVersion, wavetemplate.Answers answers)
     {
         // Get the user preference on org scanning
         String ScanOrg_ans = (String) answers.get('ScanOrg');

         setCustom(template, answers);
         checkIfCSATSelected(template, answers);
         checkIfKnowledgeArticleSelected(template, answers);

         // Validate only when answer's Yes to the wizard
         if(ScanOrg_ans == 'Yes')
         {

            caseHistoryStatusCheck(template, answers);
             //Verify if 'Analytics Cloud Integration User' has access to the necessary fields on the selected Objects based on Users responses
             integrationUserCheck(template, answers);
         }
     }

    //***** Initial validation - verify Existence of Closed Cases
    private void checkIfCSATSelected(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
    {

            if (answers.get('IncludeCSAT') == 'Yes' )
            {

             Map<String, Object>  variableAnswer = (Map<String, Object>) answers.get('CSATField');
             String variableField = (String) variableAnswer.get('fieldName');
             String variableSobject = (String) variableAnswer.get('sobjectName');

                if(String.isBlank(variableField))
                {
                	 String CsatErrorMessage = ' You answered "yes" to the configuration wizard question that asked if you track CSAT in Service Cloud, but you did not indicate the fields you use to track the data. Go back to the wizard and select the fields.';
            		 throw new wavetemplate.TemplateInterruptException(CsatErrorMessage);
                           }
            }

    }

        private void checkIfKnowledgeArticleSelected(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
    {
        try{
            String IncludeKnowledge_ans = (String)answers.get('IncludeKnowledge');
            if (IncludeKnowledge_ans == 'Yes')
            {

                Map<String, Object>  KnowldegeArticleType_ans = (Map<String, Object>) answers.get('KnowldegeArticleType');

                if(KnowldegeArticleType_ans == null)
                {

                    String knowledgeArticleErrorMessage = 'You answered "yes" to the configuration wizard question that asked if you use Salesforce Knowledge in Service Cloud, but you did not indicate an article type to include in Service Analtyics. Go back to the wizard and select an article type.';
                    throw new wavetemplate.TemplateInterruptException(knowledgeArticleErrorMessage);

                }
            }
        }
        catch(TypeException e)
        {

        }
    }

   private void caseHistoryStatusCheck(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
   {
       try {
           String IncludeCaseHistory_ans = (String) answers.get('IncludeCaseHistory');

           if (IncludeCaseHistory_ans == 'Yes')
           {
               String variableName = 'CaseStatus';
               Map<String, Object>  variableAnswer = (Map<String, Object>) answers.get(variableName);
               String caseHistoryStatusField = (String) variableAnswer.get('fieldName');

            //   String caseHistoryStatusField = answers.get('CaseStatus').get('fieldName');

               String statusQuery = 'select Id from casehistory where field = \'' +  caseHistoryStatusField + '\' Order by CreatedDate limit 2';

               List<casehistory> casehistorystatusrecords = Database.query(statusQuery);
               if (casehistorystatusrecords.isEmpty())
               {
                  String exceptionMsg ='Your org does not have any history records for field that you selected on page 5, question 4 : ' + caseHistoryStatusField + '.\n Please go back and change it to a field that has case history enabled or unselect Case History from the object picker page.';

                  throw new wavetemplate.TemplateInterruptException(exceptionMsg);
               }
           }
       } catch(Exception e) { }
   }

    //default integration user check
    public Map<String, Set<String>> checkIntegrationUserAccessToDefaults(Boolean checkDefaults,wavetemplate.Answers answers){

        //Fields which are always in the dataflow

        Set<String> globalDefaultAccount = new Set<String> {'Name','Id','Industry'};
        Set<String> globalDefaultCase = new Set<String>{'AccountId','ContactId','OwnerId','Id','IsClosed','CreatedDate','LastModifiedDate','IsEscalated','CaseNumber'};
        Set<String> globalDefaultContact = new Set<String> {'Name','Id'};
        Set<String> globalDefaultTask = new Set<String> {'Id','CallObject','CallDurationInSeconds','CallDisposition','CallType','OwnerId','Status','Priority','IsClosed','TaskSubtype','CreatedDate','ActivityDate','LastModifiedDate','Subject'};
        Set<String> globalDefaultUser = new Set<String> {'CallCenterId','Name','UserRoleId','Id'};
        Set<String> globalDefaultUserRole = new Set<String> {'Id','Name','ParentRoleId','LastModifiedDate','LastModifiedById','SystemModstamp'};

        //Depends on IncludeBusinessHours=Yes
        Set<String> globalDefaultBusinessHours = new Set<String> {'Id','FridayEndTime','FridayStartTime','Name','MondayEndTime','MondayStartTime','SaturdayEndTime','SaturdayStartTime','SundayEndTime','SundayStartTime','ThursdayEndTime','ThursdayStartTime','TimeZoneSidKey','TuesdayEndTime','TuesdayStartTime','WednesdayEndTime','WednesdayStartTime'};

        //Depends on IncludeCaseHistory=Yes
        Set<String> globalDefaultCaseHistory = new Set<String> {'CaseId','CreatedById','CreatedDate','Field','Id','NewValue','OldValue'};

        //Depends on IncludeEvent=Yes
        Set<String> globalDefaultEvent = new Set<String> {'OwnerId','CreatedDate','LastModifiedDate','ActivityDate','EndDateTime','Subject','ShowAs','DurationInMinutes','EventSubtype','WhatId'};

        //Depends on IncludeOpportunity=Yes
        Set<String> globalDefaultOpportunity = new Set<String> {'Id','AccountId','OwnerId','Name','StageName','LeadSource','IsWon','IsClosed','ForecastCategory','ForecastCategoryName','CreatedDate','CloseDate','Amount','CreatedById'};

        //Depends on IncludeQueue=Yes
        Set<String> globalDefaultQueue = new Set<String> {'Id','Name'};

        //Recordtypes is included in following condition
        //"condition": "${((Variables.IncludeOpportunityRecordTypes == 'No' || Variables.IncludeOpportunity == 'No')  && Variables.IncludeCaseRecordTypes == 'No')}",
        Set<String> globalDefaultRecordTypes = new Set<String> {'Id','Name'};

        //Chat related objects
        //Depends on IncludeChat=Yes
        Set<String> globalDefaultLiveChatTranscriptEvent = new Set<String> {'Detail','Time','Type','LastModifiedDate','Type','AgentId'};
        Set<String> globalDefaultLiveChatTranscript = new Set<String> {'Abandoned','AverageResponseTimeOperator','MaxResponseTimeOperator','OperatorMessageCount','Body','Browser','BrowserLanguage','CaseId','ChatDuration','ChatKey','CreatedDate','IsDeleted','EndTime','EndedBy','LastModifiedDate','LastReferencedDate','LastViewedDate','LiveChatButtonId','Id','Name','Location','OwnerId','Platform','ReferrerUri','RequestTime','ScreenResolution','StartTime','Status','SupervisorTranscriptBody','SystemModstamp','UserAgent','AverageResponseTimeVisitor','IpAddress','MaxResponseTimeVisitor','VisitorMessageCount','WaitTime'};
        Set<String> globalDefaultLiveChatButton = new Set<String> {'MasterLabel','CustomAgentName','Id'};

        //Omni related objects
        //Depends on IncludeOmni=Yes
        Set<String> globalDefaultAgentWork = new Set<String> {'AcceptDateTime','ActiveTime','AgentCapacityWhenDeclined','Id','AssignedDateTime','CancelDateTime','CloseDateTime','CreatedDate','DeclineDateTime','DeclineReason','IsDeleted','HandleTime','LastModifiedDate','Name','CapacityPercentage','PushTimeout','PushTimeoutDateTime','RequestDateTime','SpeedToAnswer','Status','SystemModstamp','CapacityWeight','UserId','OriginalQueueId','ServiceChannelId','WorkItemId'};
        Set<String> globalDefaultServiceChannel = new Set<String> {'DeveloperName','MasterLabel','Id'};
        Set<String> globalDefaultUserServicePresence = new Set<String> {'AtCapacityDuration','AverageCapacity','ConfiguredCapacity','CreatedDate','IsDeleted','IdleDuration','IsAway','IsCurrentState','LastModifiedDate','Name','StatusDuration','StatusEndDate','StatusStartDate','SystemModstamp','Id','UserId','ServicePresenceStatusId'};
        Set<String> globalDefaultServicePresenceStatus = new Set<String> {'MasterLabel','Id'};

        //Depends on 'IncludeQueueNames') == 'Yes'OR 'IncludeOmni' == 'Yes'
        Set<String> globalDefaultGroup = new Set<String> {'Name','Id'};

        // knowledge related objects
        // //Depends on IncludeKnowledge=Yes
        Set<String> globalDefaultCaseArticle = new Set<String> {'ArticleVersionNumber','CreatedDate','CaseId','CreatedById','KnowledgeArticleId','IsSharedByEmail'};
        Set<String> globalDefaultDataCategorySelection = new Set<String> {'DataCategoryGroupName','DataCategoryName','ParentId'};
        Set<String> globalDefaultViewStat = new Set<String> {'Channel','ParentId','ViewCount','NormalizedScore'};
        Set<String> globalDefaultVoteStat = new Set<String> {'Channel','ParentId','NormalizedScore'};
        Set<String> globalDefaultKa = new Set<String> {'Id','ArticleNumber','CaseAssociationCount','CreatedById','CreatedDate','FirstPublishedDate','LastPublishedDate','LastModifiedById'};
        Set<String> globalDefaultKav = new Set<String> {'Id','ArticleNumber','CreatedById','CreatedDate','OwnerId','PublishStatus','IsLatestVersion','IsVisibleInApp','IsVisibleInCsp','IsVisibleInPkb','IsVisibleInPrm','KnowledgeArticleId','Title','VersionNumber'};

        Map<String, Set<String>> defaultValues = new Map<String, Set<String>>();
        Map<String, Set<String>> inaccessible = new Map<String, Set<String>>();

        //Default values as determined by variables.json
        Set<String> defaultCase = new Set<String>{'Reason','Type','Origin','ClosedDate','Status','Priority'};
		    Set<String> defaultTask = new Set<String>{'WhatId'};
        if(!checkDefaults)
        {
            //this means we have checked the real values that the user has selected, so we will not check default values
            //will be useful for one click install
            defaultCase.clear();
        }


        //Add values which are always present in the dataflow

        defaultCase.addAll(globalDefaultCase);

        //Build an object map of fields that will be extracted in app .
        //We will check check Integration user access on this map next

        if (answers.get('IncludeTelephony') == 'No')
        {
            defaultTask.clear();
        }
        defaultTask.addAll(globalDefaultTask);

        if (answers.get('IncludeBusinessHours') == 'Yes')
        {

            Set<String> bussinessHourId = new Set<String>{'BusinessHoursId'};
            defaultCase.addAll(bussinessHourId);
        }

        if (answers.get('IncludeOpportunityRecordTypes') == 'Yes')
        {

            Set<String> recordTypeId = new Set<String>{'RecordTypeId'};
            globalDefaultOpportunity.addAll(recordTypeId);
        }

        if (answers.get('IncludeCaseRecordTypes') == 'Yes')
        {

            Set<String> recordTypeId = new Set<String>{'RecordTypeId'};
            defaultCase.addAll(recordTypeId);
        }
        defaultValues.put('Case',defaultCase);
        defaultValues.put('Account',globalDefaultAccount);
        defaultValues.put('Contact',globalDefaultContact);

        defaultValues.put('User',globalDefaultUser);
        defaultValues.put('UserRole',globalDefaultUserRole);
        defaultValues.put('Task',defaultTask);

        if (answers.get('IncludeBusinessHours') == 'Yes')
        {
            defaultValues.put('BusinessHours',globalDefaultBusinessHours);
        }
        if (answers.get('IncludeCaseHistory') == 'Yes')
        {
            defaultValues.put('CaseHistory',globalDefaultCaseHistory);
        }
        if (answers.get('IncludeEvent') == 'Yes')
        {
            defaultValues.put('Event',globalDefaultEvent);
        }
        if (answers.get('IncludeOpportunity') == 'Yes')
        {
            defaultValues.put('Opportunity',globalDefaultOpportunity);
        }
        if (answers.get('IncludeQueueNames') == 'Yes'|| answers.get('IncludeOmni') == 'Yes')
        {
            defaultValues.put('Group',globalDefaultQueue);
        }
        //"condition": "${((Variables.IncludeOpportunityRecordTypes == 'No' || Variables.IncludeOpportunity == 'No')  && Variables.IncludeCaseRecordTypes == 'No')}",
        if (!((answers.get('IncludeOpportunityRecordTypes') == 'No' || answers.get('IncludeOpportunity') == 'No') && answers.get('IncludeCaseRecordTypes') == 'No'))
        {
            defaultValues.put('RecordType',globalDefaultRecordTypes);
        }
        if (answers.get('IncludeChat') == 'Yes')
        {
            defaultValues.put('LiveChatTranscriptEvent',globalDefaultLiveChatTranscriptEvent);
            defaultValues.put('LiveChatTranscript',globalDefaultLiveChatTranscript);
            defaultValues.put('LiveChatButton',globalDefaultLiveChatButton);
        }
        if (answers.get('IncludeOmni') == 'Yes')
        {
        //    defaultValues.put('AgentWork',globalDefaultAgentWork);
        //    defaultValues.put('ServiceChannel',globalDefaultServiceChannel);
        //    defaultValues.put('ServicePresenceStatus',globalDefaultServicePresenceStatus);
        //    defaultValues.put('UserServicePresence',globalDefaultUserServicePresence);
        }
        if (answers.get('IncludeKnowledge') == 'Yes')
        {
            defaultValues.put('CaseArticle',globalDefaultCaseArticle);


            Map<String, Object>  variableAnswer = (Map<String, Object>) answers.get('KnowldegeArticleType');

            String KnowledgeObject_Prefix = (String) variableAnswer.get('sobjectName');
    		KnowledgeObject_Prefix = KnowledgeObject_Prefix.remove('__kav');

            String DataCategorySelectionObject = KnowledgeObject_Prefix +'__DataCategorySelection';
            defaultValues.put(DataCategorySelectionObject,globalDefaultDataCategorySelection);

            String ViewStatObject = KnowledgeObject_Prefix +'__ViewStat';
            defaultValues.put(ViewStatObject,globalDefaultViewStat);

            String VoteStatObject = KnowledgeObject_Prefix +'__VoteStat';
            defaultValues.put(VoteStatObject,globalDefaultVoteStat);

            String KaObject = KnowledgeObject_Prefix +'__ka';
            defaultValues.put(KaObject,globalDefaultKa);

            String KavObject = KnowledgeObject_Prefix +'__kav';
            defaultValues.put(KavObject,globalDefaultKav);


        }
        // Now check each field that we added to the map to see if Integration user actually has access
        for (String sObjectName: defaultValues.keySet())
        {
            for(String field: defaultValues.get(sObjectName))
            {
                if(!wavetemplate.Access.integUserHasAccessToSObjectField(sObjectName, field))
                {
                    //this means Integration user does not have access to this field

                    //System.debug('inaccessibleObject ' + sObjectName);
                    //System.debug('inaccessibleFields ' + field);

                    // add the inaccessible fields to the list
                    if ( inaccessible.containsKey(sObjectName))
                    {
                    // add it to existing entry
                        inaccessible.get(sObjectName).add(field);
                    } else
                    {
                        // create a new entry
                        Set<String> s = new Set<String>();
                        s.add(field);
                        inaccessible.put(sObjectName, s);
                    }
                }

            }
        }
        if (! inaccessible.isEmpty()){
            // Construct the message
            String message = 'The following fields are inaccessible for the Integration User. Go to org setup, grant the Integration User access and hit Create again.\n';
            for (String sobj: inaccessible.keySet()) {
                Set<String> fields = inaccessible.get(sobj);
                message += sobj + ': ' + String.join(new List<String>(fields), ',') + '\n';
            }
        }
        return inaccessible;
    }
    //***** Integration User Check
    public String checkIntegrationUserAccessToEverything(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
    {
        Map<String, Set<String>> inaccessible = new Map<String, Set<String>>();

        // go through all the Variables we have
        for (wavetemplate.VariableDefinition variable: template.getVariables().values()) {
            String variableName = variable.getName();
            variable.getDescription();

            wavetemplate.VariableTypeEnum type = variable.getVariableType().getType();
            //System.debug('Variable: ' + variableName);
            //System.debug('Type: ' + type);

            // according to the type of the variable call the right function to check access
            if (type == wavetemplate.VariableTypeEnum.ArrayType)
            {
                // array variable - can have multiple fields selected
                wavetemplate.VariableTypeEnum itemsType = variable.getVariableType().getItemsType().getType();
                //System.debug('Items type: ' + itemsType);

                // only check array variables with sObjectFields inside them
                if (itemsType == wavetemplate.VariableTypeEnum.SobjectFieldType)
                {
                    List<Object> dflt = (List<Object>) variable.getDefaultValue();

                    Map<String, Object> fdflt = (Map<String, Object>) dflt[0];
                    String variableSobject = (String) fdflt.get('sobjectName');

                    List<String> inaccessibleFields = wavetemplate.Access.checkIntegUserAccessToArrayOfSObjectFields(variableName, template, answers);
                    //System.debug('inaccessibleFields ' + inaccessibleFields);

                    if (! inaccessibleFields.isEmpty())
                    {
                        // find out what sobject the variable is on

                        //System.debug('variableSobject: ' + variableSobject);
                        // add the inaccessible fields to the list
                        if ( inaccessible.containsKey(variableSobject))
                        {
                            // add it to existing entry
                            inaccessible.get(variableSobject).addAll(inaccessibleFields);
                        } else
                        {
                            // create a new entry
                            inaccessible.put(variableSobject, new Set<String>(inaccessibleFields));
                        }
                    }

                }
            } else if (type == wavetemplate.VariableTypeEnum.SobjectFieldType)
            {
                Map<String, Object>  variableAnswer = (Map<String, Object>) answers.get(variableName);
                String variableField = (String) variableAnswer.get('fieldName');
                String variableSobject = (String) variableAnswer.get('sobjectName');
            	Boolean hasAccess = true;

                //System.debug('variableField: ' + variableField + 'from object:  ' + variableSobject);
                //System.debug('access? ' + hasAccess);

                if(answers.get('IncludeCSAT') == 'No')
                {
                    if(variableName != 'CSATField' && variableName != '{{Variables.CSATObj.sobjectName}}' )
                    {
                         hasAccess = wavetemplate.Access.integUserHasAccessToSObjectField(variableName, template, answers);

                    }
                }
                else
                {
                    hasAccess = wavetemplate.Access.integUserHasAccessToSObjectField(variableName, template, answers);
                }

                // if no access add it to the list
                if (! hasAccess)
                {
                        // add the inaccessible fields to the list
                        if ( inaccessible.containsKey(variableSobject))
                        {
                            // add it to existing entry
                            inaccessible.get(variableSobject).add(variableField);
                        } else
                        {
                            // create a new entry
                            Set<String> s = new Set<String>();
                            s.add(variableField);
                            inaccessible.put(variableSobject, s);
                        }

                }
            }
        }
        //System.debug('inaccessible stuff: ' + inaccessible);

        //now check for defaults
        Boolean checkDefault = false; //we will use this for one click install

        //check default selection and things always present in dataflow

        Map<String, Set<String>> defaultsInaccessible = checkIntegrationUserAccessToDefaults(checkDefault,answers);
        for(String sObjectNames : defaultsInaccessible.KeySet())
        {
            if ( inaccessible.containsKey(sObjectNames))
            {
                // add it to existing entry
                inaccessible.get(sObjectNames).addAll(defaultsInaccessible.get(sObjectNames));
            } else
            {
                // create a new entry
                inaccessible.put(sObjectNames, defaultsInaccessible.get(sObjectNames));
            }
        }

        if (! inaccessible.isEmpty())
        {
            // Construct the message and add the inaccessible items to the message
            String message = 'The Analytics Cloud Integration User requires access to all Salesforce fields that will be available in the app. In Salesforce Setup, set field-level security to enable the Analytics Integration User to see the following fields. See "Create and Share the Service Analytics App" in Salesforce Help for details. \n';

            for (String sobj: inaccessible.keySet())
            {
                Set<String> fields = inaccessible.get(sobj);
                message += sobj + ': ' + String.join(new List<String>(fields), ', ') + '\n';
            }
            return message;

        }
        return null;
    }

    /**** Method to do integration User check and display error message if any *****/
    private Boolean integrationUserCheck(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
    {

        boolean errorFlag = false;
        Integer ErrorCount = 1;
        string ErrorString = 'Your org does not currently meet minimum data requirements. Fix the following issues before creating Service Analytics.';

        String IntegrationMessage = checkIntegrationUserAccessToEverything(template, answers);

        if(IntegrationMessage != null)
        {

            ErrorString = ErrorString + '\n' + '(' + ErrorCount +')' + IntegrationMessage;
            errorFlag = true;
            ErrorCount++;

        }
        if(errorFlag == true)
        {
            throw new  wavetemplate.TemplateInterruptException(ErrorString);

        }

        return true;
    }

    // check if the backdoor flag is set on integration user
private Boolean checkBackdoor(wavetemplate.WaveTemplateInfo template)
{
    // get the integration user's phone
    List<Object> userList = Database.query('SELECT Name, Phone, Profile.Name FROM User WHERE Profile.Name = \'Analytics Cloud Integration User\'');
    if (userList.size() == 0)
    {
      //System.debug('Something is wrong, no integration user in the org');
      return false;
    }
    String phone = (String) ((SObject) userList[0]).get('Phone');

    // if the phone is 0, set the variable
    if (phone == '0'){
      //System.debug('Setting Backdoor to skip checks');
      template.getVariables().get('Backdoor').setComputedValue(true);
      template.getVariables().get('ScanOrg').setComputedValue('No');
      return true;
    }

    return false;
}



private void setCustom(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
{

         String autoconfig_ans = (String) answers.get('autoconfig');
        if (autoconfig_ans == 'true'){

           System.debug('Setting Custom app to false');
           //answers.put('isCustomApp', 'false');
           answers.put('isCustomApp', false);
        }
        else{

           System.debug('Setting Custom app to true');
           //answers.put('isCustomApp', 'true');
          answers.put('isCustomApp', true);

        }

}

// check integration user access to variable defaults, set defaultsVisible variable
private void checkDefaultsVisible(wavetemplate.WaveTemplateInfo template)
{
    boolean allVisible = true;
    Map<String, Set<String>> inaccessible = new Map<String, Set<String>>();
    // go through all the variables we have
    for (wavetemplate.VariableDefinition variable: template.getVariables().values()) {
        String variableName = variable.getName();

        // only check array variables with sObjectFields inside them
        if (variable.getVariableType().getType() != wavetemplate.VariableTypeEnum.SobjectFieldType)
            continue;

        //Skip checking for Geography field
        if(variableName == 'Geography')
        {
         boolean visible = wavetemplate.Access.integUserHasAccessToSObjectField('Account', 'BillingState');
          //System.debug('Checking Integration user access ' + variableName + ': Account - BillingState' + ': ' + visible);
          // one field not visible - set defaultsVisible to false
          if (! visible){

              allVisible = false;

              if ( inaccessible.containsKey('Account'))
              {
              // add it to existing entry
                  inaccessible.get('Account').add('BillingState');
              } else
              {
                  // create a new entry
                  Set<String> s = new Set<String>();
                  s.add('BillingState');
                  inaccessible.put('Account', s);
              }

          }
          continue;

        }


        //Skip checking for CSAT field
        if(variableName == 'CSATField')
            continue;
        // get the default field
        Map<String, Object> dflt = (Map<String, Object>)variable.getDefaultValue();

        String fieldName = (String) dflt.get('fieldName');
        String sObjectName = (String) dflt.get('sobjectName');
        boolean visible = wavetemplate.Access.integUserHasAccessToSObjectField(sObjectName, fieldName);
        //System.debug('Checking Integration user access ' + variableName + ': ' + sObjectName + ' - ' + fieldName + ': ' + visible);
        // one field not visible - set defaultsVisible to false
        if (! visible){

            allVisible = false;

            if ( inaccessible.containsKey(sObjectName))
            {
            // add it to existing entry
                inaccessible.get(sObjectName).add(fieldName);
            } else
            {
                // create a new entry
                Set<String> s = new Set<String>();
                s.add(fieldName);
                inaccessible.put(sObjectName, s);
            }

        }
    }
    if (! allVisible)
    {

        if (! inaccessible.isEmpty()){
            // Construct the message

            List<String> messagesList = new List<String>();
            //String message = 'The Analytics Integration User doesn't have access to the following fields required for standard settings. As a result the Basic install option is disabled on the next page. If you would like to set up a basic app please go to org setup, grant the Integration User field level access to following fields and re-run the set up';
            String message = 'The Analytics Integration User does not have access to required fields, and basic app creation is disabled.';
            messagesList.add(message);
            message = 'Go to Setup and give the Integration User field-level access to the following fields to enable basic app creation.';
            messagesList.add(message);
            for (String sobj: inaccessible.keySet()) {
                Set<String> fields = inaccessible.get(sobj);
                message = sobj + ': ' + String.join(new List<String>(fields), ', ') + '\n';
                messagesList.add(message);
            }

            //messagesList.add(message);
            template.getVariables().get('DefaultsVisibleMsg').setComputedValue(messagesList);
        }


      //System.debug('Field inaccessible, setting autoconfig to false and defaultsVisible too ');

      template.getVariables().get('DefaultsVisible').setComputedValue(false);
      template.getVariables().get('autoconfig').setComputedValue('false');
      return;
    }
}

/* todo: need to work on this for smart detection of values (suggested)
private void setSLA(wavetemplate.WaveTemplateInfo template)
{
        //validate the product exists in the org
        //Schema.SObjectType targetTypeQ = Schema.getGlobalDescribe().get('QueueSobject');

        Map<String, Schema.SObjectField> C = Schema.SObjectType.Case.fields.getMap();


      Set<string> FieldsSet = new Set<string> ();
      FieldsSet = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().keySet();
        //
      //   System.debug('FieldsSet ' + FieldsSet);

        for (String field : FieldsSet) {

           if(field.containsIgnoreCase('sla') && !field.containsIgnoreCase('date'))
           {

             System.debug('field ' + field);
            Schema.SObjectFieldType sfield = C.get(field);


            template.getVariables().get('CaseSLA').setComputedValue(sfield);
            System.debug('CaseSLA' + template.getVariables().get('CaseSLA'));

           }

       }

}
*/

}