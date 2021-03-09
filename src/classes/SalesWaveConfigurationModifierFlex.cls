public class SalesWaveConfigurationModifierFlex extends wavetemplate.WaveTemplateConfigurationModifier
{
  //Values which are always in the dataflow
  Set<String> globalDefaultOpportunity = new Set<String>{'AccountId','OwnerId','Name','StageName','IsWon','IsClosed','ForecastCategory','ForecastCategoryName','CreatedDate','CloseDate','CreatedById','LastModifiedDate','LastActivityDate'};
  Set<String> globalDefaultAccount = new Set<String> {'Name','OwnerId','NumberOfEmployees','AnnualRevenue','CreatedDate','LastModifiedDate'};
  Set<String> globalDefaultLeads = new Set<String> {'Name','OwnerId','Company','ConvertedAccountId','ConvertedContactId','ConvertedDate','ConvertedOpportunityId','CreatedDate','LastModifiedDate','IsConverted','IsUnreadByOwner','Status'};
  Set<String> globalDefaultCase = new Set<String> {'AccountId','ContactId','OwnerId','Id','IsClosed','Origin','Type','Subject','LastModifiedDate','CreatedDate','ClosedDate','IsEscalated','Status','CaseNumber'};
  Set<String> globalDefaultOptyProducts = new Set<String> {'OpportunityId','ProductCode','ListPrice','Quantity','PricebookEntryId'};
  Set<String> globalDefaultProducts = new Set<String> {'ProductCode'};
  Set<String> globalDefaultCampaign = new Set<String> {'Name','OwnerId','StartDate','EndDate','Type','IsActive','CreatedDate','LastModifiedDate','AmountAllOpportunities','AmountWonOpportunities','ActualCost','NumberOfContacts','NumberOfLeads','NumberOfOpportunities','NumberOfWonOpportunities','NumberOfResponses','NumberSent','Status'};
  Set<String> globalDefaultTask = new Set<String> {'ActivityDate','CallDisposition','CallDurationInSeconds','CallType','CreatedDate','IsClosed','LastModifiedDate','Priority','Status','Subject','TaskSubtype'};
  Set<String> globalDefaultEvent = new Set<String> {'AccountId','ActivityDate','CreatedDate','DurationInMinutes','EventSubtype','LastModifiedDate','Subject','WhatId'};
  
  public enum WizardPages 
  {
    CHECKLIST,
    ONECLICK,
    OBJECTS,
    ACCOUNT, 
    OPPORTUNITY, 
    PRODUCT, 
    SETTINGS, 
    LEADS, 
    ADDITIONALFIELDS, 
    ADDITIONALOBJECTS, 
    CAMPAIGNFIELDS, 
    CHECKORG  
  }
  
  /*****main method upon wizard config retirval *****/
  public override void onConfigurationRetrieval(wavetemplate.WaveTemplateInfo template)
  {
    setHistoricalAmountFields(template);
    //3.
    // stays here
    setORT(template);

    // check integration user access to variable defaults,
    checkDefaultsVisible(template);

    // check if backdoor flag is set on integration user
    checkBackdoor(template);

    // fill the options to the OpportunitySplitType question
    setSplitTypes(template);
  }

  /******3.Method to AutoScan Opportunity Record Type *****/
  private void setHistoricalAmountFields(wavetemplate.WaveTemplateInfo template){
    Map<string, wavetemplate.VariableDefinition> variables = template.getVariables();
    wavetemplate.VariableDefinition historicalFields = variables.get('CustomHistoricalAmount');
    Map <String, Schema.SObjectField> opptyfieldMap = Schema.SObjectType.Opportunity.fields.getMap();
    String fieldOptions = opptyfieldMap.get('Amount').getDescribe().getLabel() + ',';
       
       List<object> enums = historicalFields.getVariableType().getItemsType().getEnums();   
       
      
       
      Schema.SObjectType targetTypeP = Schema.getGlobalDescribe().get('Opportunity__hd');
       if (targetTypeP != null)
       {
          Map <String, Schema.SObjectField> fieldMap = targetTypeP.getDescribe().fields.getMap();
         
          enums.add(opptyfieldMap.get('Amount').getDescribe().getLabel());
          
          For(Schema.SObjectField sfield : fieldMap.Values())
          {
            schema.describefieldresult dfield = sfield.getDescribe();
            
             if ((dfield.getType() == Schema.DisplayType.CURRENCY || dfield.getType() == Schema.DisplayType.DOUBLE) && dfield.getName().contains('_hst') && dfield.getName() != 'Amount__hst')
             {          
                enums.add(dfield.getName().replace('_hst',''));
                fieldOptions = fieldOptions + ' '+ opptyfieldMap.get(dfield.getName().replace('_hst','')).getDescribe().getLabel() +',';
      
             }
             
             
          }
          historicalFields.getVariableType().getItemsType().setEnums(enums);
          
          
       }
       fieldOptions = fieldOptions.left(fieldOptions.length() - 1);
    
       template.getVariables().get('CustomHistoricalAmount').setComputedValue(enums);
       template.getVariables().get('CustomHistoricalCheck').setLabel('Analytics has detected that opportunity ('+ fieldOptions +')  field(s) support Historical Trending. Select one of those fields otherwise the app will use the standard Amount field for historical trend data');
        
     
  }
     
  // check if the backdoor flag is set on integration user
  private Boolean checkBackdoor(wavetemplate.WaveTemplateInfo template){
      // get the integration user's phone
      List<Object> userList = Database.query('SELECT Name, Phone, Profile.Name FROM User WHERE Profile.Name = \'Analytics Cloud Integration User\'');
      if (userList.size() == 0)
      {
        System.debug('Something is wrong, no integration user in the org');
        return false;
      }
      String phone = (String) ((SObject) userList[0]).get('Phone');

      // if the phone is 0, set the variable
      if (phone == '0'){
        System.debug('Setting Backdoor to skip checks');
        template.getVariables().get('Backdoor').setComputedValue(true);
        return true;
      }

      return false;
  }

  // check integration user access to variable defaults, set defaultsVisible variable
  private void checkDefaultsVisible(wavetemplate.WaveTemplateInfo template)
  {
      boolean allVisible = true;
      List<String> messages = new List<String>();

      // go through all the variables we have
      for (wavetemplate.VariableDefinition variable: template.getVariables().values()) {
          String variableName = variable.getName();

          // only check array variables with sObjectFields inside them
          if (variable.getVariableType().getType() != wavetemplate.VariableTypeEnum.SobjectFieldType)
              continue;

          // get the default field
          Map<String, Object> dflt = (Map<String, Object>)variable.getDefaultValue();

          String fieldName = (String) dflt.get('fieldName');
          String sObjectName = (String) dflt.get('sobjectName');
          boolean visible = wavetemplate.Access.integUserHasAccessToSObjectField(sObjectName, fieldName);
          System.debug('Checking Integration user access ' + variableName + ': ' + sObjectName + ' - ' + fieldName + ': ' + visible);
          // one field not visible - set defaultsVisible to false
          if (! visible){
            System.debug('Field inaccessible');
            messages.add(sObjectName + ': ' + fieldName);
            allVisible = false;
          }
      }
      // if at least one field not visible, set the variable and messages
      if (! allVisible){
        template.getVariables().get('DefaultsVisible').setComputedValue(false);
        template.getVariables().get('autoconfig').setComputedValue('false');
        template.getVariables().get('DefaultsVisibleMessages').setComputedValue(String.join(messages, '\n'));
      }
  }

  private List<SObject> getSplits(){
      List<SObject> emptySplits = new List<SObject>();
      
      // find out if splits are enabled in the org
      Schema.SObjectType targetTypeP = Schema.getGlobalDescribe().get('OpportunitySplitType');
      if (targetTypeP == null){
          System.debug('OpportunitySplitType doesn\'t exist in the org.');
          return emptySplits;
      }

      // find out if there are any active splits that add up to 100%
      String query = 'SELECT Id, DeveloperName, MasterLabel, SplitField, SplitEntity FROM OpportunitySplitType WHERE IsActive = true AND IsTotalValidated = true AND SplitEntity = \'Opportunity\'';
      try {
          List<SObject> splitTypes = Database.query(query);
          if (splitTypes.isEmpty()){
              System.debug('No active 100% split types for opportunity');
              return emptySplits;
          }

          // There's at least one
          System.debug('These are the split types: ' + splitTypes);
          return splitTypes;

      } catch(Exception e)
      {
          System.debug('something went wrong, no splits:' + e);
          return emptySplits;
      }

  }

  // first part of the split logic - figure out what types are available and present them to the user in a question
  // hide amount question if there's something
  private void setSplitTypes(wavetemplate.WaveTemplateInfo template){
      
      List<SObject> splitTypes = getSplits();
      wavetemplate.VariableDefinition splitTypeQuestion = template.getVariables().get('OpportunitySplitType');

      if (splitTypes.isEmpty()){
          // it doesn't have splits, set required to false and leave it empty
          splitTypeQuestion.setRequired(false);
          return;
      }    

      // construct the enums for the splits question
      List<Object> enums = new List<Object>();
      List<Object> idEnums = new List<Object>();

      String amountSplit = null;
      String enumValue = null;
      // put the split types into the question enums
      for (SObject st: splitTypes){
          String entity = (String)st.get('SplitEntity');
          String field = (String)st.get('SplitField');
          enumValue = (String)st.get('MasterLabel') + ' (' + entity + ' - ' + field + ' ) [' + (String)st.get('DeveloperName') + ']';
          enums.add(enumValue);
          idEnums.add(st.get('Id'));
          if (entity == 'Opportunity' && field == 'Amount'){
              amountSplit = enumValue;
          }
      }

      System.debug('These are the enums: ' + enums);
      
      // set the enums to the variable
      splitTypeQuestion.getVariableType().setEnums(enums);

      // if there was a Amount split, set it as default
      if (amountSplit != null){
          template.getVariables().get('OpportunitySplitType').setComputedValue(amountSplit);
      }
      else{
          template.getVariables().get('OpportunitySplitType').setComputedValue(enumValue);
      }
  }    

  /******3.Method to AutoScan Opportunity Record Type *****/
  private void setORT(wavetemplate.WaveTemplateInfo template)
  {
      Set<String> objectFields = Schema.SObjectType.Opportunity.fields.getMap().keySet();
      if(objectFields.contains('recordtypeid'))
      {
     String query = 'SELECT count() from Opportunity WHERE RecordTypeId != null limit 1';
      try
      {
          Integer countRTs = database.countQuery(query);
          if(countRTs == 0)
          {
              template.getVariables().get('Has_OpportunityRecordType').setComputedValue('No');
              template.getVariables().get('Has_OpportunityRecordType_Dataflow').setComputedValue('No');
              
              template.getUI().getPages().get(WizardPages.SETTINGS.ordinal()).getVariables().get('OpptyRecordType').setVisibility(wavetemplate.VisibilityEnum.Hidden);
          }
          else
          {
              template.getVariables().get('Has_OpportunityRecordType').setComputedValue('Yes');
              template.getVariables().get('Has_OpportunityRecordType').setDescription('Wave has detected that you segment Opportunities by one or more Record Types. Select Yes if you want dashboards to include Record Type filters.');
              template.getVariables().get('Has_OpportunityRecordType_Dataflow').setComputedValue('Yes');
              //display record type if record type is yes
              Map<string, wavetemplate.VariableDefinition> variables = template.getVariables();
              wavetemplate.VariableDefinition recordType = variables.get('OpptyRecordType');
              List<object> enums = recordType.getVariableType().getItemsType().getEnums();
              RecordType[] results = [SELECT
                  Name
              FROM
                  RecordType
              WHERE
                  SObjectType = 'Opportunity' AND IsActive = true];
              for(RecordType record: results)
              {
                  enums.add((string)record.get('Name'));
              }
              recordType.getVariableType().getItemsType().setEnums(enums);
          }
      }
      catch(Exception e)
      {
      }
  }
      else
      {
              template.getVariables().get('Has_OpportunityRecordType').setComputedValue('No');
              template.getVariables().get('Has_OpportunityRecordType_Dataflow').setComputedValue('No');
              template.getUI().getPages().get(WizardPages.SETTINGS.ordinal()).getVariables().get('OpptyRecordType').setVisibility(wavetemplate.VisibilityEnum.Hidden);
      }
  }

  public Map<String, Set<String>> checkIntegrationUserAccessToDefaults(Boolean checkDefaults, wavetemplate.Answers answers){

     
    
     Map<String, Set<String>> defaultValues = new Map<String, Set<String>>();
     Map<String, Set<String>> inaccessible = new Map<String, Set<String>>();
     
     //Default values as determined by variables.json
     Set<String> defaultOpportunity = new Set<String>{'Amount','Type','LeadSource'};
     Set<String> defaultAccount = new Set<String> {'AccountSource','BillingCountry','BillingState','Type','Industry'};
     Set<String> defaultLeads = new Set<String> {'LeadSource','Rating','Country','Industry'};
     Set<String> defaultOptyProduct = new Set<String> {'TotalPrice'};
     Set<String> defaultProduct = new Set<String> {'Family','Name'};

     String extraObjects = String.valueOf(answers.get('SObjectChoices'));
     Boolean leadsFlag = extraObjects.contains('Leads');
     Boolean caseFlag = extraObjects.contains('Cases');
     Boolean productFlag = extraObjects.contains('Products');
     Boolean campaignFlag = extraObjects.contains('Campaigns');
    
     
     if(!checkDefaults)
     {
        //this means we have checked the real values that the user has selected, so we will not just check default values
        defaultOpportunity.clear();
        defaultAccount.clear();
        defaultLeads.clear();
        defaultLeads.clear();
        defaultOptyProduct.clear();
        defaultProduct.clear();
      
     }
     
     String hasAccountHierarchy = (string) answers.get('UsingAccountHierarchy');
     if (hasAccountHierarchy == 'Yes')
     {
       defaultAccount.add('ParentId');
     }

     //Add values which are always present in the dataflow
     defaultOpportunity.addAll(globalDefaultOpportunity);
     defaultAccount.addAll(globalDefaultAccount);
     defaultLeads.addAll(globalDefaultLeads);
     defaultOptyProduct.addAll(globalDefaultOptyProducts);
     defaultProduct.addAll(globalDefaultProducts);
     
     
      if (leadsFlag)
      {
        defaultValues.put('Lead',defaultLeads);
      }
        
      if(caseFlag)
      {
        defaultValues.put('Case', globalDefaultCase);
      }
      if(campaignFlag)
      {
        defaultValues.put('Campaign', globalDefaultCampaign);
        defaultOpportunity.add('CampaignId');
      }
        
      if(productFlag)
      {
        defaultValues.put('Product2',defaultProduct);
        defaultValues.put('OpportunityLineItem',defaultOptyProduct);
      }
             
      
      defaultValues.put('Account',defaultAccount);
      defaultValues.put('Opportunity',defaultOpportunity);
      defaultValues.put('Task', globalDefaultTask);
      defaultValues.put('Event', globalDefaultEvent);
      
      // go through all the variables we have
      for (String sObjectName: defaultValues.keySet()) 
      {
          for(String field: defaultValues.get(sObjectName))
          {
            if(!wavetemplate.Access.integUserHasAccessToSObjectField(sObjectName, field))
            {
           
                // add the inaccessible fields to the list
                if ( inaccessible.containsKey(sObjectName)){
                    // add it to existing entry
                    inaccessible.get(sObjectName).add(field);
                } else {
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
          String message = 'The following fields are inaccessible for the Integration User. Go to org setup, grant the Ingetration user access and hit Create again.\n';
          for (String sobj: inaccessible.keySet()) {
              Set<String> fields = inaccessible.get(sobj);
              message += sobj + ': ' + String.join(new List<String>(fields), ', ') + '\n';
          }

          

      }
      return inaccessible;
  }

  public String checkIntegrationUserAccessToEverything(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers){


      Map<String, Set<String>> inaccessible = new Map<String, Set<String>>();

      String extraObjects = String.valueOf(answers.get('SObjectChoices'));
      Boolean leadsFlag = extraObjects.contains('Leads');
      Boolean caseFlag = extraObjects.contains('Cases');
      Boolean productFlag = extraObjects.contains('Products');
      Boolean campaignFlag = extraObjects.contains('Campaigns');
   
      
      // go through all the variables we have
      for (wavetemplate.VariableDefinition variable: template.getVariables().values()) {
          String variableName = variable.getName();
            wavetemplate.VariableTypeEnum type = variable.getVariableType().getType();
          System.debug('variable: ' + variableName);
          System.debug('typ: ' + type);

          // according to the type of the variable call the right function to check access
          if (type == wavetemplate.VariableTypeEnum.ArrayType){
              // array variable - can have multiple fields selected
              wavetemplate.VariableTypeEnum itemsType = variable.getVariableType().getItemsType().getType();
              System.debug('items type: ' + itemsType);

              // only check array variables with sObjectFields inside them
              if (itemsType == wavetemplate.VariableTypeEnum.SobjectFieldType){
                  List<Object> dflt = (List<Object>) variable.getDefaultValue();
                  Map<String, Object> fdflt = (Map<String, Object>) dflt[0];
                  String variableSobject = (String) fdflt.get('sobjectName');
                  if((variableSobject == 'Campaign' && campaignFlag) || (variableSobject == 'Lead' && leadsFlag) || (variableSobject == 'Case' && caseFlag) || (variableSobject == 'Product2' && productFlag) || (variableSobject == 'OpportunityLineItem' && productFlag) || (variableSobject != 'Case' &&  variableSobject != 'Lead' && variableSobject != 'Campaign' && variableSobject != 'Product2' && variableSobject != 'OpportunityLineItem'))     
                  
                  {
                    List<String> inaccessibleFields = wavetemplate.Access.checkIntegUserAccessToArrayOfSObjectFields(variableName, template, answers);
                    System.debug('inaccessibleFields ' + inaccessibleFields);

                    if (! inaccessibleFields.isEmpty()){
                        // find out what sobject the variable is on
                        // you don't wanna know what's going on here
                        

                        System.debug('variableSobject: ' + variableSobject);
                        // add the inaccessible fields to the list
                        if ( inaccessible.containsKey(variableSobject)){
                            // add it to existing entry
                            inaccessible.get(variableSobject).addAll(inaccessibleFields);
                        } else {
                            // create a new entry
                            inaccessible.put(variableSobject, new Set<String>(inaccessibleFields));
                        }
                    }
                    }
              }
          } else if (type == wavetemplate.VariableTypeEnum.SobjectFieldType) {

              Map<String, Object>  variableAnswer = (Map<String, Object>) answers.get(variableName);
              String variableField = (String) variableAnswer.get('fieldName');
              String variableSobject = (String) variableAnswer.get('sobjectName');
              
              if((variableSobject == 'Campaign' && campaignFlag) || (variableSobject == 'Lead' && leadsFlag) || (variableSobject == 'Case' && caseFlag) || (variableSobject == 'Product2' && productFlag) || (variableSobject == 'OpportunityLineItem' && productFlag) || (variableSobject != 'Case' &&  variableSobject != 'Lead' && variableSobject != 'Campaign' && variableSobject != 'Product2' && variableSobject != 'OpportunityLineItem'))     
              
              {
                   Boolean hasAccess = wavetemplate.Access.integUserHasAccessToSObjectField(variableName, template, answers);
                   // if no access add it to the list
                  
                 
                  
                  System.debug('variableField: ' + variableField + ' ' + variableSobject);
                  System.debug('access? ' + hasAccess);
                  if (! hasAccess){
                      // add the inaccessible fields to the list
                      if ( inaccessible.containsKey(variableSobject)){
                          // add it to existing entry
                          inaccessible.get(variableSobject).add(variableField);
                      } else {
                          // create a new entry
                          Set<String> s = new Set<String>();
                          s.add(variableField);
                          inaccessible.put(variableSobject, s);
                      }

                  }
              }
            }
      }
      System.debug('inaccessible stuff: ' + inaccessible);
      Map<String, Set<String>> defaultsInaccessible = checkIntegrationUserAccessToDefaults(false, answers);
      for(String sObjectNames : defaultsInaccessible.KeySet())
      {
        if ( inaccessible.containsKey(sObjectNames)){
            // add it to existing entry
            inaccessible.get(sObjectNames).addAll(defaultsInaccessible.get(sObjectNames));
        } else {
            // create a new entry
            inaccessible.put(sObjectNames, defaultsInaccessible.get(sObjectNames));
        }
      }
      //Remove any objects that should not be checked
      if (! String.valueOf(answers.get('SObjectChoices')).contains('Leads'))
      {
        inaccessible.remove('Lead');
      }
        
      if(! String.valueOf(answers.get('SObjectChoices')).contains('Products'))
      {
        inaccessible.remove('Product2');
        inaccessible.remove('OpportunityLineItem');
      }
      if (! inaccessible.isEmpty()){
          // Construct the message
          String message = 'The Analytics Cloud Integration User requires field level access to all Salesforce fields that will be available in Wave. Please update the Field-Level-Security for the Analytics Cloud Integration User Profile for the following fields before creating the app. \n';
          for (String sobj: inaccessible.keySet()) {
              Set<String> fields = inaccessible.get(sobj);
              message += sobj + ': ' + String.join(new List<String>(fields), ', ') + '\n';
          }

          return message;

      }
        
        //Check visibility for Lead Score Object and override the Has_LeadScore if Integration User doesn't have access for some reason
        if((boolean)answers.get('Has_LeadScore'))
        {
          answers.put('Has_LeadScore', wavetemplate.Access.integUserHasAccessToSObjectField('ScoreIntelligence', 'Id')); 
        }
       
      return null;
  }

  /****6.Method to verify objects that may affect the dataflow *****/
  private Boolean throwException(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
  {
    boolean errorFlag = false;
    Integer ErrorCount = 1;
    Integer TaskCount = 0;
    Integer EventCount = 0;
    Integer HistoryCount = 0;
    Integer RoleCount = 0;
    string ErrorString = 'Your org does not currently meet minimum data requirements to proceed. Please fix the following issues before creating a Sales Analytics Application. ';


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
  private void checkQuotaTpye (wavetemplate.Answers answers)
  {
      object forecastingType = (string)answers.get('ForecastingType');

      object quotaType = (string)answers.get('Has_Quota');
      object collab = (string)answers.get('Has_CollaborativeForecasting');
      System.debug('QUOTA OPTINON' + quotaType);
      if (quotaType == 'Collaborative Forecasting Quota')
      {
        // check if there is a valid quota for the right forecasting type
        String idQuery = 'SELECT Id FROM ForecastingType WHERE DeveloperName = :forecastingType';
        List<sObject> validForecastingId = Database.query(idQuery);
        String quotaQuery = 'SELECT Id FROM ForecastingQuota WHERE ForecastingTypeId IN :validForecastingId LIMIT 1';
        List<sObject> validQuota = Database.query(quotaQuery);
        if (validQuota.size() == 0) {
          answers.put('Has_Quota', 'CSV Quota');
        }
      }

      if (quotaType == 'Collaborative Forecasting Quota' && collab == 'No')
      {
        System.debug('Update Quota Option');
        answers.put('Has_Quota', 'CSV Quota');
      }
    }
  
    private void setAnswers(wavetemplate.Answers answers) {
          // Call Java class to get variable values
          Map<String, Object> answerMap = new Map<String, Object>{'isCumulativeEnabled' => false};
          
          // Set isCumulative Enabled variable
          answers.put('isCumulativeEnabled', answerMap.get('isCumulativeEnabled'));
  }

  private Object getFieldDevName(wavetemplate.Answers answers, String splitField){
      List<Object> idMapList = (List<Object>)answers.get('OpportunityFieldMap');
      System.debug('This is the id - name map: ' + idMapList);

      // construct a map id->developerName from OpportunityFieldMap variable
      Map<String, String> idMap = new Map<String, String>();
      for (Object pair: idMapList) {
        List<String> strPair = ((String)pair).split(':');
        idMap.put(strPair[0], strPair[1]);
      }

      // if it's in the map then get the value, if not return the original string
      String devName = idMap.get(splitField);
      String result = devName == null ? splitField : devName + '__c';

      System.debug('this is the field ' + result);
      return result;
  }

  // if they have split on standard amount, use it for one click
  // if they don't - one click has splits turned off, but they can get turn it on in custom
  private void handleSplits(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers){
      // second part of the split logic - extract the answer from the split question

      // check if the splits are there and selected on the add_objects page
      String splitType = (string)answers.get('OpportunitySplitType');

      System.debug('This is the split type: ' + splitType);
      // throw new  wavetemplate.TemplateInterruptException(splitType);

      // no split type set (splits not enabled in org)
      if (String.isEmpty(splitType)) {
          System.debug('No Split type here');
          answers.put('ForecastingType', 'OpportunityRevenue');
          return;
      }

      // splits not selected in add_objects page
      Set<Object> additionalObjects = new Set<Object>((List<Object>)answers.get('SObjectChoices'));
      if (! additionalObjects.contains('Opportunity Splits')) {
          System.debug('Splits not selected: ' + additionalObjects);
          answers.put('ForecastingType', 'OpportunityRevenue');
          return;
      }

      // developer name of the selected split
      String developerName = splitType.substring(splitType.indexOf('[') + 1, splitType.indexOf(']'));

      String query = 'SELECT Id, DeveloperName, SplitField, SplitEntity FROM OpportunitySplitType WHERE DeveloperName = \''+developerName+'\'';
      try {
          List<SObject> splitTypes = Database.query(query);

          // set amount field based on that answer
          Object amount = splitTypes[0].get('SplitField');
          Object obj = splitTypes[0].get('SplitEntity');
          Object amountDevName = getFieldDevName(answers, (String)amount);

          Map<String, Object> amountField = new Map<String, Object>{
            'sobjectName'=> obj, 
            'fieldName' => amountDevName
          };
          answers.put('Opportunity_Amount', amountField);

          // - set a variable to filter opportunity splits in the dataflow on SplitTypeId
          String splitTypeId = (String)splitTypes[0].get('Id');

          answers.put('OpportunitySplitTypeId', splitTypeId);

          String forecastType = 'OpportunitySplitRevenue';
          if (developerName != 'Revenue') {
            forecastType = developerName;
          }

          answers.put('ForecastingType', forecastType);

          System.debug('Selected split type: ' + developerName + 'amountField: ' + amountField + ' splitTypeId ' + splitTypeId);
          System.debug('Variable values: id: ' + answers.get('OpportunitySplitTypeId') + ' amount: ' + answers.get('Opportunity_Amount'));
          System.debug('Selected split type: ' + developerName + 'amountField: ' + amountField + 'Opportunity_Amount: ' + answers.get('Opportunity_Amount') + ' splitTypeId: ' + answers.get('OpportunitySplitTypeId'));
      } catch(Exception e){
          System.debug(e.getMessage() + e.getCause() + e.getLineNumber());
          // throw new wavetemplate.TemplateInterruptException
      }         
  }
  private static Set<String> initCountryCodeMap(){
    //add all mappings for Supported Locales and their Start Day offset here
    Set<String> mymap = new Set<String>();
    mymap.add('REU');
    mymap.add('MUS');
    mymap.add('JEY');
    mymap.add('GLP');
    mymap.add('FRO');
    mymap.add('BHR');
    mymap.add('SGP');
    mymap.add('HKG');
    mymap.add('AFG');
    mymap.add('AGO');
    mymap.add('ALB');
    mymap.add('ARE');
    mymap.add('ARG');
    mymap.add('ARM');
    mymap.add('ATF');
    mymap.add('AUS');
    mymap.add('AUT');
    mymap.add('AZE');
    mymap.add('BDI');
    mymap.add('BEL');
    mymap.add('BEN');
    mymap.add('BFA');
    mymap.add('BGD');
    mymap.add('BGR');
    mymap.add('BHS');
    mymap.add('BIH');
    mymap.add('BLR');
    mymap.add('BLZ');
    mymap.add('BMU');
    mymap.add('BOL');
    mymap.add('BRA');
    mymap.add('BRN');
    mymap.add('BTN');
    mymap.add('BWA');
    mymap.add('CAF');
    mymap.add('CAN');
    mymap.add('CHE');
    mymap.add('CHL');
    mymap.add('CHN');
    mymap.add('CIV');
    mymap.add('CMR');
    mymap.add('COD');
    mymap.add('COG');
    mymap.add('COL');
    mymap.add('CRI');
    mymap.add('CUB');
    mymap.add('CYP2');
    mymap.add('CYP');
    mymap.add('CZE');
    mymap.add('DEU');
    mymap.add('DJI');
    mymap.add('DNK');
    mymap.add('DOM');
    mymap.add('DZA');
    mymap.add('ECU');
    mymap.add('EGY');
    mymap.add('ERI');
    mymap.add('ESP');
    mymap.add('EST');
    mymap.add('ETH');
    mymap.add('FIN');
    mymap.add('FJI');
    mymap.add('FLK');
    mymap.add('FRA');
    mymap.add('GAB');
    mymap.add('GBR');
    mymap.add('GEO');
    mymap.add('GHA');
    mymap.add('GIN');
    mymap.add('GMB');
    mymap.add('GNB');
    mymap.add('GNQ');
    mymap.add('GRC');
    mymap.add('GRL');
    mymap.add('GTM');
    mymap.add('GUF');
    mymap.add('GUY');
    mymap.add('HND');
    mymap.add('HRV');
    mymap.add('HTI');
    mymap.add('HUN');
    mymap.add('IDN');
    mymap.add('IND');
    mymap.add('IRL');
    mymap.add('IRN');
    mymap.add('IRQ');
    mymap.add('ISL');
    mymap.add('ISR');
    mymap.add('ITA');
    mymap.add('JAM');
    mymap.add('JOR');
    mymap.add('JPN');
    mymap.add('KAZ');
    mymap.add('KEN');
    mymap.add('KGZ');
    mymap.add('KHM');
    mymap.add('KOR');
    mymap.add('CS-KM');
    mymap.add('KWT');
    mymap.add('LAO');
    mymap.add('LBN');
    mymap.add('LBR');
    mymap.add('LBY');
    mymap.add('LKA');
    mymap.add('LSO');
    mymap.add('LTU');
    mymap.add('LUX');
    mymap.add('LVA');
    mymap.add('MAR');
    mymap.add('MDA');
    mymap.add('MDG');
    mymap.add('MEX');
    mymap.add('MKD');
    mymap.add('MLI');
    mymap.add('MLT');
    mymap.add('MMR');
    mymap.add('MNE');
    mymap.add('MNG');
    mymap.add('MOZ');
    mymap.add('MRT');
    mymap.add('MWI');
    mymap.add('MYS');
    mymap.add('NAM');
    mymap.add('NCL');
    mymap.add('NER');
    mymap.add('NGA');
    mymap.add('NIC');
    mymap.add('NLD');
    mymap.add('NOR');
    mymap.add('NPL');
    mymap.add('NZL');
    mymap.add('OMN');
    mymap.add('PAK');
    mymap.add('PAN');
    mymap.add('PER');
    mymap.add('PHL');
    mymap.add('PNG');
    mymap.add('POL');
    mymap.add('PRI');
    mymap.add('PRK');
    mymap.add('PRT');
    mymap.add('PRY');
    mymap.add('QAT');
    mymap.add('ROU');
    mymap.add('RUS');
    mymap.add('RWA');
    mymap.add('ESH');
    mymap.add('SAU');
    mymap.add('SDN');
    mymap.add('SSD');
    mymap.add('SEN');
    mymap.add('SLB');
    mymap.add('SLE');
    mymap.add('SLV');
    mymap.add('SOM2');
    mymap.add('SOM');
    mymap.add('SRB');
    mymap.add('SUR');
    mymap.add('SVK');
    mymap.add('SVN');
    mymap.add('SWE');
    mymap.add('SWZ');
    mymap.add('SYR');
    mymap.add('TCD');
    mymap.add('TGO');
    mymap.add('THA');
    mymap.add('TJK');
    mymap.add('TKM');
    mymap.add('TLS');
    mymap.add('TTO');
    mymap.add('TUN');
    mymap.add('TUR');
    mymap.add('TWN');
    mymap.add('TZA');
    mymap.add('UGA');
    mymap.add('UKR');
    mymap.add('URY');
    mymap.add('USA');
    mymap.add('UZB');
    mymap.add('VEN');
    mymap.add('VNM');
    mymap.add('VUT');
    mymap.add('PSE');
    mymap.add('YEM');
    mymap.add('ZAF');
    mymap.add('ZMB');
    mymap.add('ZWE');

    return mymap;
  }
  private static Set<String> initCountryNameMap(){
    //add all mappings for Supported Locales and their Start Day offset here
    Set<String> mymap = new Set<String>();
    mymap.add('Reunion');
    mymap.add('Mauritius');
    mymap.add('Jersey');
    mymap.add('Guadeloupe');
    mymap.add('Faeroe Is.');
    mymap.add('Bahrain');
    mymap.add('Singapore');
    mymap.add('Hong Kong');
    mymap.add('Afghanistan');
    mymap.add('Angola');
    mymap.add('Albania');
    mymap.add('United Arab Emirates');
    mymap.add('Argentina');
    mymap.add('Armenia');
    mymap.add('French Southern and Antarctic Lands');
    mymap.add('Australia');
    mymap.add('Austria');
    mymap.add('Azerbaijan');
    mymap.add('Burundi');
    mymap.add('Belgium');
    mymap.add('Benin');
    mymap.add('Burkina Faso');
    mymap.add('Bangladesh');
    mymap.add('Bulgaria');
    mymap.add('The Bahamas');
    mymap.add('Bosnia and Herzegovina');
    mymap.add('Belarus');
    mymap.add('Belize');
    mymap.add('Bermuda');
    mymap.add('Bolivia');
    mymap.add('Brazil');
    mymap.add('Brunei');
    mymap.add('Bhutan');
    mymap.add('Botswana');
    mymap.add('Central African Republic');
    mymap.add('Canada');
    mymap.add('Switzerland');
    mymap.add('Chile');
    mymap.add('China');
    mymap.add('Ivory Coast');
    mymap.add('Cameroon');
    mymap.add('Democratic Republic of the Congo');
    mymap.add('Republic of the Congo');
    mymap.add('Colombia');
    mymap.add('Costa Rica');
    mymap.add('Cuba');
    mymap.add('Northern Cyprus');
    mymap.add('Cyprus');
    mymap.add('Czech Republic');
    mymap.add('Germany');
    mymap.add('Djibouti');
    mymap.add('Denmark');
    mymap.add('Dominican Republic');
    mymap.add('Algeria');
    mymap.add('Ecuador');
    mymap.add('Egypt');
    mymap.add('Eritrea');
    mymap.add('Spain');
    mymap.add('Estonia');
    mymap.add('Ethiopia');
    mymap.add('Finland');
    mymap.add('Fiji');
    mymap.add('Falkland Islands');
    mymap.add('France');
    mymap.add('Gabon');
    mymap.add('United Kingdom');
    mymap.add('Georgia');
    mymap.add('Ghana');
    mymap.add('Guinea');
    mymap.add('Gambia');
    mymap.add('Guinea Bissau');
    mymap.add('Equatorial Guinea');
    mymap.add('Greece');
    mymap.add('Greenland');
    mymap.add('Guatemala');
    mymap.add('French Guiana');
    mymap.add('Guyana');
    mymap.add('Honduras');
    mymap.add('Croatia');
    mymap.add('Haiti');
    mymap.add('Hungary');
    mymap.add('Indonesia');
    mymap.add('India');
    mymap.add('Ireland');
    mymap.add('Iran');
    mymap.add('Iraq');
    mymap.add('Iceland');
    mymap.add('Israel');
    mymap.add('Italy');
    mymap.add('Jamaica');
    mymap.add('Jordan');
    mymap.add('Japan');
    mymap.add('Kazakhstan');
    mymap.add('Kenya');
    mymap.add('Kyrgyzstan');
    mymap.add('Cambodia');
    mymap.add('South Korea');
    mymap.add('Kosovo');
    mymap.add('Kuwait');
    mymap.add('Laos');
    mymap.add('Lebanon');
    mymap.add('Liberia');
    mymap.add('Libya');
    mymap.add('Sri Lanka');
    mymap.add('Lesotho');
    mymap.add('Lithuania');
    mymap.add('Luxembourg');
    mymap.add('Latvia');
    mymap.add('Morocco');
    mymap.add('Moldova');
    mymap.add('Madagascar');
    mymap.add('Mexico');
    mymap.add('Macedonia');
    mymap.add('Mali');
    mymap.add('Malta');
    mymap.add('Myanmar');
    mymap.add('Montenegro');
    mymap.add('Mongolia');
    mymap.add('Mozambique');
    mymap.add('Mauritania');
    mymap.add('Malawi');
    mymap.add('Malaysia');
    mymap.add('Namibia');
    mymap.add('New Caledonia');
    mymap.add('Niger');
    mymap.add('Nigeria');
    mymap.add('Nicaragua');
    mymap.add('Netherlands');
    mymap.add('Norway');
    mymap.add('Nepal');
    mymap.add('New Zealand');
    mymap.add('Oman');
    mymap.add('Pakistan');
    mymap.add('Panama');
    mymap.add('Peru');
    mymap.add('Philippines');
    mymap.add('Papua New Guinea');
    mymap.add('Poland');
    mymap.add('Puerto Rico');
    mymap.add('North Korea');
    mymap.add('Portugal');
    mymap.add('Paraguay');
    mymap.add('Qatar');
    mymap.add('Romania');
    mymap.add('Russia');
    mymap.add('Rwanda');
    mymap.add('Western Sahara');
    mymap.add('Saudi Arabia');
    mymap.add('Sudan');
    mymap.add('South Sudan');
    mymap.add('Senegal');
    mymap.add('Solomon Islands');
    mymap.add('Sierra Leone');
    mymap.add('El Salvador');
    mymap.add('Somaliland');
    mymap.add('Somalia');
    mymap.add('Republic of Serbia');
    mymap.add('Suriname');
    mymap.add('Slovakia');
    mymap.add('Slovenia');
    mymap.add('Sweden');
    mymap.add('Swaziland');
    mymap.add('Syria');
    mymap.add('Chad');
    mymap.add('Togo');
    mymap.add('Thailand');
    mymap.add('Tajikistan');
    mymap.add('Turkmenistan');
    mymap.add('East Timor');
    mymap.add('Trinidad and Tobago');
    mymap.add('Tunisia');
    mymap.add('Turkey');
    mymap.add('Taiwan');
    mymap.add('United Republic of Tanzania');
    mymap.add('Uganda');
    mymap.add('Ukraine');
    mymap.add('Uruguay');
    mymap.add('United States of America');
    mymap.add('Uzbekistan');
    mymap.add('Venezuela');
    mymap.add('Vietnam');
    mymap.add('Vanuatu');
    mymap.add('West Bank');
    mymap.add('Yemen');
    mymap.add('South Africa');
    mymap.add('Zambia');
    mymap.add('Zimbabwe');

    return mymap;
  }
  private static Set<String> initStateNameMap(){
    //add all mappings for Supported Locales and their Start Day offset here
    Set<String> mymap = new Set<String>();
    mymap.add('Alabama');
    mymap.add('Alaska');
    mymap.add('Arizona');
    mymap.add('Arkansas');
    mymap.add('California');
    mymap.add('Colorado');
    mymap.add('Connecticut');
    mymap.add('Delaware');
    mymap.add('District of Columbia');
    mymap.add('Florida');
    mymap.add('Georgia');
    mymap.add('Hawaii');
    mymap.add('Idaho');
    mymap.add('Illinois');
    mymap.add('Indiana');
    mymap.add('Iowa');
    mymap.add('Kansas');
    mymap.add('Kentucky');
    mymap.add('Louisiana');
    mymap.add('Maine');
    mymap.add('Maryland');
    mymap.add('Massachusetts');
    mymap.add('Michigan');
    mymap.add('Minnesota');
    mymap.add('Mississippi');
    mymap.add('Missouri');
    mymap.add('Montana');
    mymap.add('Nebraska');
    mymap.add('Nevada');
    mymap.add('New Hampshire');
    mymap.add('New Jersey');
    mymap.add('New Mexico');
    mymap.add('New York');
    mymap.add('North Carolina');
    mymap.add('North Dakota');
    mymap.add('Ohio');
    mymap.add('Oklahoma');
    mymap.add('Oregon');
    mymap.add('Pennsylvania');
    mymap.add('Rhode Island');
    mymap.add('South Carolina');
    mymap.add('South Dakota');
    mymap.add('Tennessee');
    mymap.add('Texas');
    mymap.add('Utah');
    mymap.add('Vermont');
    mymap.add('Virginia');
    mymap.add('Washington');
    mymap.add('West Virginia');
    mymap.add('Wisconsin');
    mymap.add('Wyoming');
    mymap.add('American Samoa');
    mymap.add('Guam');
    mymap.add('Marshall Islands');
    mymap.add('Micronesia');
    mymap.add('Northern Marianas');
    mymap.add('Palau');
    mymap.add('Puerto Rico');
    mymap.add('Virgin Islands');

    return mymap;
  }
      private static Set<String> initStateCodeMap(){
        //add all mappings for Supported Locales and their Start Day offset here
        Set<String> mymap = new Set<String>();
        mymap.add('AL');
        mymap.add('AK');
        mymap.add('AZ');
        mymap.add('AR');
        mymap.add('CA');
        mymap.add('CO');
        mymap.add('CT');
        mymap.add('DE');
        mymap.add('DC');
        mymap.add('FL');
        mymap.add('GA');
        mymap.add('HI');
        mymap.add('ID');
        mymap.add('IL');
        mymap.add('IN');
        mymap.add('IA');
        mymap.add('KS');
        mymap.add('KY');
        mymap.add('LA');
        mymap.add('ME');
        mymap.add('MD');
        mymap.add('MA');
        mymap.add('MI');
        mymap.add('MN');
        mymap.add('MS');
        mymap.add('MO');
        mymap.add('MT');
        mymap.add('NE');
        mymap.add('NV');
        mymap.add('NH');
        mymap.add('NJ');
        mymap.add('NM');
        mymap.add('NY');
        mymap.add('NC');
        mymap.add('ND');
        mymap.add('OH');
        mymap.add('OK');
        mymap.add('OR');
        mymap.add('PA');
        mymap.add('RI');
        mymap.add('SC');
        mymap.add('SD');
        mymap.add('TN');
        mymap.add('TX');
        mymap.add('UT');
        mymap.add('VT');
        mymap.add('VA');
        mymap.add('WA');
        mymap.add('WV');
        mymap.add('WI');
        mymap.add('WY');
        mymap.add('AS');
        mymap.add('GU');
        mymap.add('MH');
        mymap.add('FM');
        mymap.add('MP');
        mymap.add('PW');
        mymap.add('PR');
        mymap.add('VI');

        return mymap;
      }
  private void handleMaps(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers){
      // Check to see if the Geo Selections are US States or Countries
      Set<String> CountryNames = initCountryNameMap();
      Set<String> CountryCodes = initCountryCodeMap();
      Set<String> StateNames = initStateNameMap();
      Set<String> StateCodes = initStateCodeMap();
      Integer Country = 0;
      Integer State = 0;
      
      try
      {
        Map<String, Object>  Geo1 = (Map<String, Object>) answers.get('Geography');
        String Geo1Field = (String) Geo1.get('fieldName');
        Map<String, Object>  Geo2 = (Map<String, Object>) answers.get('Geography_L2');
        String Geo2Field = (String) Geo2.get('fieldName');
        List<SObject> Geo1Values = new List<SObject>();
        List<SObject> Geo2Values = new List<SObject>();
         
         Map <String, Schema.SObjectField> acctfieldMap = Schema.SObjectType.Account.fields.getMap();
         Boolean checkField1 = acctfieldMap.get(Geo1Field).getDescribe().isGroupable();
         Boolean checkField2 = acctfieldMap.get(Geo2Field).getDescribe().isGroupable();
         
         if(checkField1)
         {      
            String query = 'SELECT '+Geo1Field+' FROM Account WHERE '+Geo1Field+' != null group by '+Geo1Field+' limit 20';
            Geo1Values = Database.query(query);        
                    
         
             System.debug('Checking '+ Geo1Field );
             for(SObject s : Geo1Values)
             {
                  //Has Countries or States?
                  String geovalue = (String)s.get(Geo1Field);
                  if (CountryNames.contains(geovalue))
                  {
                    Country++;
                    System.debug(Geo1Field + ' Has CountryName');           
                  }
                  else if (CountryCodes.contains(geovalue))
                  {
                    Country++;
                    System.debug(Geo1Field + ' Has CountryCode');                 
                  }
                  else if (StateNames.contains(geovalue))
                  {
                    State++;
                    System.debug(Geo1Field + ' Has StateName');              
                  }
                  else if (StateCodes.contains(geovalue))
                  {
                    State++;
                    System.debug(Geo1Field + ' Has StateCodes');               
                  }
             
             }
             System.debug('Country count = '+ Country + 'State Count = '+State);
             //Set Maps for Geo1
             if(Country == Geo1Values.size())
             {
                answers.put('MapType_Geo1', 'World');
             }
             else if(State == Geo1Values.size())
             {
                answers.put('MapType_Geo1', 'US');
             }
             else
             {
                answers.put('MapType_Geo1', 'Bar') ;
             }
         }
         else
         {
            answers.put('MapType_Geo1', 'Bar') ;
         }
         if(checkField2)
         {
           String query = 'SELECT '+Geo2Field+' FROM Account WHERE '+Geo2Field+' != null group by '+Geo2Field+' limit 20';
           Geo2Values = Database.query(query);
         
           Country = 0;
           State = 0;
           for(SObject s : Geo2Values)
           {
                //Has Countries or States?
                String geovalue = (String)s.get(Geo2Field);
                if (CountryNames.contains(geovalue))
                {
                  Country++;              
                }
                else if (CountryCodes.contains(geovalue))
                {
                  Country++;              
                }
                else if (StateNames.contains(geovalue))
                {
                  State++;              
                }
                else if (StateCodes.contains(geovalue))
                {
                  State++;              
                }
           
           }
           //Set Maps for Geo1
           if(Country == Geo2Values.size())
           {
              answers.put('MapType_Geo2', 'World');
           }
           else if(State == Geo2Values.size())
           {
              answers.put('MapType_Geo2', 'US');
           }
           else
           {
              answers.put('MapType_Geo2', 'Bar') ;
           }
         }
         else
         {
            answers.put('MapType_Geo1', 'Bar') ;
         }
     } catch(Exception e){
         System.debug(e.getMessage() + e.getCause() + e.getLineNumber());
         // throw new wavetemplate.TemplateInterruptException
     }         

      
  }
  private void setDemoAnswers(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
  {
    
    answers.put('Can_Continue', true) ;
    answers.put('SObjectChoices', new String[]{'Products','Collaborative Forecasting','Leads','Cases'}) ;
    answers.put('Has_Quota', 'Collaborative Forecasting Quota') ;
    answers.put('Has_SecurityPredicate', 'Option 1: Users view data owned by them and subordinates') ;
    answers.put('UsingAccountHierarchy', 'No') ;
    answers.put('Geography', new Map<String, Object>{ 'sobjectName' => 'Account', 'fieldName' => 'BillingState'} ) ;
    answers.put('Geography_L2', new Map<String, Object>{ 'sobjectName' => 'Account', 'fieldName' => 'ShippingState'} ) ;
    answers.put('MapType_Geo1', 'US') ;
    answers.put('MapType_Geo2', 'US') ;

  }
  /******Main method from app framework to call other methods upon create ***/
  public override void beforeAppCreate(wavetemplate.WaveTemplateInfo template, wavetemplate.Answers answers)
  {
        if (answers.get('isDemoApplication') == 'Yes') 
        {
           setDemoAnswers(template, answers);
        }
        else
        {
      handleSplits(template, answers);
  	      setAnswers(answers);

          if (answers.get('Backdoor') == false) {
      System.debug('Handling Maps' );
      handleMaps(template, answers);
          }
          else {
            System.debug('Skip Maps setup');
          }


      String extraObjects = String.valueOf(answers.get('SObjectChoices'));        
      Boolean campaignFlag = extraObjects.contains('Campaigns');

      System.debug('SObjectChoices' + answers.get('SObjectChoices') + ' flag = ' + campaignFlag);
      checkQuotaTpye(answers);
       
      throwException(template, answers);
      //no exceptions so we will just set this to no so we don't rerun checks again
       answers.put('autoconfig', 'false');
        }
        
    
    System.debug('Starting dump of selected answers...');
    System.debug('Can_Continue: ' + answers.get('Can_Continue'));
    System.debug('DefaultsVisible: ' + answers.get('DefaultsVisible'));
    System.debug('Backdoor: ' + answers.get('Backdoor'));
    System.debug('SObjectChoices: ' + answers.get('SObjectChoices'));
    System.debug('Has_Campaigns_Visible: ' + answers.get('Has_Campaigns_Visible'));
    System.debug('SObjectDescriptions: ' + answers.get('SObjectDescriptions'));
    System.debug('Direct_Reports: ' + answers.get('Direct_Reports'));
    System.debug('Show_First_Page: ' + answers.get('Show_First_Page'));
    System.debug('One_Click_Install: ' + answers.get('One_Click_Install'));
    System.debug('OpptyRecordType: ' + answers.get('OpptyRecordType'));
    System.debug('DontOverwriteQuota: ' + answers.get('DontOverwriteQuota'));
    System.debug('Fiscal_Month: ' + answers.get('Fiscal_Month'));
    System.debug('Geo_Maps: ' + answers.get('Geo_Maps'));
    System.debug('First_Day_Of_Week: ' + answers.get('First_Day_Of_Week'));
    System.debug('Has_OpportunityRecordType: ' + answers.get('Has_OpportunityRecordType'));
    System.debug('Has_OpportunityRecordType_Dataflow: ' + answers.get('Has_OpportunityRecordType_Dataflow'));
    System.debug('Has_Products_Visible: ' + answers.get('Has_Products_Visible'));
    System.debug('Has_Exception: ' + answers.get('Has_Exception'));
    System.debug('Has_Activities: ' + answers.get('Has_Activities'));
    System.debug('Has_Cases_Visible: ' + answers.get('Has_Cases_Visible'));
    System.debug('Has_Quota: ' + answers.get('Has_Quota'));
    System.debug('Has_ForecastCategory: ' + answers.get('Has_ForecastCategory'));
    System.debug('RoleSecurity: ' + answers.get('RoleSecurity'));
    System.debug('Opportunity_Amount: ' + answers.get('Opportunity_Amount'));
    System.debug('Bookings: ' + answers.get('Bookings'));
    System.debug('Account_All: ' + answers.get('Account_All'));
    System.debug('Account_Measure: ' + answers.get('Account_Measure'));
    System.debug('Account_Dimension: ' + answers.get('Account_Dimension'));
    System.debug('Opportunity_Dimension: ' + answers.get('Opportunity_Dimension'));
    System.debug('Opportunity_All: ' + answers.get('Opportunity_All'));
    System.debug('Opportunity_Measure: ' + answers.get('Opportunity_Measure'));
    System.debug('Geography: ' + answers.get('Geography'));
    System.debug('Geography_L2: ' + answers.get('Geography_L2'));
    System.debug('Source: ' + answers.get('Source'));
    System.debug('Source_L2: ' + answers.get('Source_L2'));
    System.debug('Product_Amount: ' + answers.get('Product_Amount'));
    System.debug('Customer: ' + answers.get('Customer'));
    System.debug('Customer_L2: ' + answers.get('Customer_L2'));
    System.debug('Campaign_All: ' + answers.get('Campaign_All'));
    System.debug('Campaign_Measure: ' + answers.get('Campaign_Measure'));
    System.debug('Campaign_Dimension: ' + answers.get('Campaign_Dimension'));
    System.debug('Lead_All: ' + answers.get('Lead_All'));
    System.debug('Lead_Measure: ' + answers.get('Lead_Measure'));
    System.debug('Lead_Dimension: ' + answers.get('Lead_Dimension'));
    System.debug('Product: ' + answers.get('Product'));
    System.debug('Product_L2: ' + answers.get('Product_L2'));
    System.debug('Has_SecurityPredicate_Visible: ' + answers.get('Has_SecurityPredicate_Visible'));
    System.debug('Has_SecurityPredicate: ' + answers.get('Has_SecurityPredicate'));
    System.debug('Has_Opps_With_No_LineItems: ' + answers.get('Has_Opps_With_No_LineItems'));
    System.debug('UsingRoleHierarchy: ' + answers.get('UsingRoleHierarchy'));
    System.debug('UsingAccountHierarchy: ' + answers.get('UsingAccountHierarchy'));
    System.debug('Has_Managers: ' + answers.get('Has_Managers'));
    System.debug('Has_AccountTeams_Visible: ' + answers.get('Has_AccountTeams_Visible'));
    System.debug('Has_AccountTeams: ' + answers.get('Has_AccountTeams'));
    System.debug('Has_OpportunityTeams_Visible: ' + answers.get('Has_OpportunityTeams_Visible'));
    System.debug('Has_OpportunityTeams: ' + answers.get('Has_OpportunityTeams'));
    System.debug('Has_Leads_Visible: ' + answers.get('Has_Leads_Visible'));
    System.debug('Lead_Source: ' + answers.get('Lead_Source'));
    System.debug('Lead_Rating: ' + answers.get('Lead_Rating'));
    System.debug('Lead_Geography: ' + answers.get('Lead_Geography'));
    System.debug('Lead_Industry: ' + answers.get('Lead_Industry'));
    System.debug('Has_CollaborativeForecasting_Visible: ' + answers.get('Has_CollaborativeForecasting_Visible'));
    System.debug('Has_OpportunitySplits_Visible: ' + answers.get('Has_OpportunitySplits_Visible'));
    System.debug('OpportunitySplitTypeId: ' + answers.get('OpportunitySplitTypeId'));
    System.debug('Has_CollaborativeForecasting: ' + answers.get('Has_CollaborativeForecasting'));
    System.debug('Finished dump of selected answers.');
  }

  public override void beforeAppUpdate(wavetemplate.WaveTemplateInfo template, String previousAppVersion, wavetemplate.Answers answers)
  {
      if (answers.get('isDemoApplication') == 'Yes') 
      {
         setDemoAnswers(template, answers);
      }
      else
      {
        handleSplits(template, answers);
        setAnswers(answers);

        if (answers.get('Backdoor') == false) {
        System.debug('Handling Maps' );
        handleMaps(template, answers);
        }
        else {
          System.debug('Skip Maps setup');
        }


      String extraObjects = String.valueOf(answers.get('SObjectChoices'));        
      Boolean campaignFlag = extraObjects.contains('Campaigns');

      System.debug('SObjectChoices' + answers.get('SObjectChoices') + ' flag = ' + campaignFlag);
      checkQuotaTpye(answers);
       
      throwException(template, answers);
      }
  }
}