global class ChecklistRemoter {

  global ChecklistRemoter() { } // empty constructor
  
    
  @RemoteAction
  global static Map<string, object> dataOk() {
    boolean errorFlag = false;
    Integer errorNum = 1;
    Integer taskCount = 0;
    Integer eventCount = 0;
    Integer historyCount = 0;
    List<string> errorMessages = new List<string>();
    //Check for Tasks and Events linked to Oppty
    //Due to Data sizes Task and Event Query may time out. First check to see if there are any records (limit 2) This may fail if there too many tasks and events. If it fails we should proceede and assume they have something attached to opportunities.
    //Must have at least 1 task connected to an opty
    try
    {
      taskCount = Database.countQuery('SELECT count() FROM task limit 1');
      if(taskCount == 0)
      {
        errorMessages.add('Sales Analytics requires at least one task record to exist. Create any task, then come back and finish the app creation process.');
        errorFlag = true;
      }
    }
    catch(Exception e)
    {
      //really big orgs may fail on this query - incase they do let's assume they have tasks
      taskCount = 1;
    }

    //must have at least 1 event connected to an oppty
    try
    {
      eventCount = Database.countQuery('SELECT count() FROM event limit 1');
      if(eventCount == 0)
      {
        errorMessages.add('Sales Analytics requires at least one event record to exist. Create any event, then come back and finish the app creation process.');
        errorFlag = true;
      }
    }
    catch(Exception e)
    {
      //really big orgs may fail on this query - incase they do let's assume they have tasks
      eventCount = 1;
    }

    //Check for History - have at least one opportunity with 2 closed dates and stage change
    try
    {
      historyCount = Database.countQuery('SELECT count() FROM OpportunityHistory limit 10000');
      if(historyCount < 2)
      {
        errorMessages.add('Sales Analytics requires at least three opportunity history records. If this is a Sandbox where historical data was not copied, some Sales Analytics dashboards may be incomplete. Go to any Opportunity record, update the stage name, update the amount and update the close date. Then come back and finish the app creation process.');
        errorFlag = true;
      }
    }
    catch(Exception e)
    {
      //really big orgs may fail on this query - incase they do let's assume they have tasks
      historyCount = 10000;
    }

    // return the result
    if(errorFlag)
    {
      // return the error message
      return new Map<String, Object>{
        'success' => false,
        'messages' => errorMessages
      };
    }


    // DEBUGGING FAIL
    // return new Map<String, Object>{
    //   'success' => false,
    //   // 'messages' => new List<String>{ "First thing that went wrong", "Second thing that went wrong"}
    //   'messages' => new List<String>{ 'Sales Analytics requires at least three opportunity history records. If this is a Sandbox where historical data was not copied, some Sales Analytics dashboards may be incomplete. Go to any Opportunity record, update the stage name, update the amount and update the close date. Then come back and finish the app creation process.', 'Sales Analytics requires at least one event connected to an opportunity. Go to any Opportunity record, add one event, then come back and finish the app creation process.'}
    // };

    // everything alright
    // no variable settings here
    return new Map<String, Object>{
      'success' => true,
      'messages' => new List<String>{
        'Your org meets the minimum requirements for creating the app. It has at least 1 account, opportunity, task, and event records as well as 3 opportunity history rows.'
      }
    };
  }

  private static List<List<String>> getInitialMessages2d(){
    return new List<List<String>>{
      new List<String>(),
      new List<String>()
    };
  }

  /****1.check for products in the org and set the variable to yes or no ******/
  private static Map<String, Object> hasProducts(List<object> selectedValues)
  {
    List<List<String>> messages2d = getInitialMessages2d();
    // where to put the message: 0 - has, 1 - doesn't have
    Integer i2d = 0;
    List<Object> variableSettings = new List<Object>();
    //validate the product exists in the org
    Schema.SObjectType targetTypeP = Schema.getGlobalDescribe().get('Product2');
    if (targetTypeP != null){
      string countLineItems = 'SELECT count() FROM OpportunityLineItem WHERE Product2Id != null AND PricebookEntryId != null LIMIT 1000';
      string countOpsWithoutProducts = 'SELECT count() FROM Opportunity where HasOpportunityLineItem = false Limit 1';
      try
      {
        Integer count = database.countQuery(countLineItems);
        if(count == 0){

          // visibility 
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_Products_Visible',
            'value' => 'Disabled'
          }); 
          i2d = 1;
        }
        else if(count < 10)
        {
          //Maybe they have some products, but not very many - we should recommend they answer no
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_Products_Visible',
            'value' => 'Visible'
          }); 
        }
        else
        {
          selectedValues.add('Products');
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_Products_Visible',
            'value' => 'Visible'
          }); 
          if(database.countQuery(countOpsWithoutProducts) == 0)
          {
            //They have Opportunity Products, but do they have any Opportunities without Products?
            variableSettings.add(new Map<string, object>{
              'name' => 'Has_Opps_With_No_LineItems',
              'value' => 'No'
            }); 
          }
        }
      }
      catch(Exception e)
      {
        //just in case
      }
    } 
    messages2d[i2d].add('Opportunity Line Items');
    return new Map<String, Object>{
      'success' => true,
      'messages2d' => messages2d,
      'variableSettings' => variableSettings
    };
  }

  private static List<SObject> getSplits(){
      List<SObject> emptySplits = new List<SObject>();
      
      // find out if splits are enabled in the org
      Schema.SObjectType targetTypeP = Schema.getGlobalDescribe().get('OpportunitySplitType');
      if (targetTypeP == null){
          System.debug('OpportunitySplitType doesn\'t exist in the org.');
          return emptySplits;
      }

      // find out if there are any active splits that add up to 100%
      String query = 'SELECT DeveloperName, MasterLabel, SplitField, SplitEntity FROM OpportunitySplitType WHERE IsActive = true AND IsTotalValidated = true AND SplitEntity = \'Opportunity\'';
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

  private static Map<String, Object> hasOpportunitySplits(List<object> selectedValues)
  {
    List<List<String>> messages2d = getInitialMessages2d();
    // where to put the message: 0 - has, 1 - doesn't have
    Integer i2d = 1;

    List<Object> variableSettings = new List<Object>();
    List<SObject> splitTypes = getSplits();
    if (splitTypes.isEmpty()){
      // when they don't have splits, just disable the splits panel
      variableSettings.add(new Map<string, object>{
        'name' => 'Has_OpportunitySplits_Visible',
        'value' => 'Disabled'
      }); 
    } else {
      // when they have splits
      // commenting this out while splits are in "beta" to be unchecked by default
      selectedValues.add('Opportunity Splits');
      
      i2d = 0;
    }
    messages2d[i2d].add('Opportunity Splits');

    return new Map<String, Object>{
      'success' => true,
      'messages2d' => messages2d,
      'variableSettings' => variableSettings
    };
  }
  private static Map<String, Object> hasProductSchedules(List<object> selectedValues)
  {
    List<List<String>> messages2d = getInitialMessages2d();
    // where to put the message: 0 - has, 1 - doesn't have
    Integer i2d = 0;
    
    List<Object> variableSettings = new List<Object>();
    //validate the product exists in the org
    Schema.SObjectType targetTypeP = Schema.getGlobalDescribe().get('OpportunityLineItemSchedule');

    if (targetTypeP != null){
      string countLineItems = 'SELECT count() FROM OpportunityLineItemSchedule LIMIT 1000';
      string countOpsWithoutProducts = 'SELECT count() FROM OpportunityLineItem where HasSchedule = false Limit 1';
      try
      {
        Integer count = database.countQuery(countLineItems);
        if(count == 0){

          // visibility 
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_ProductSchedules_Visible',
            'value' => 'Disabled'
          }); 
          i2d = 1;
        }
        else if(count < 10)
        {
          //Maybe they have some products, but not very many - we should recommend they answer no
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_ProductSchedules_Visible',
            'value' => 'Visible'
          }); 
        }
        else
        {
          if(!selectedValues.contains('Collaborative Forecasting') && !selectedValues.contains('Opportunity Splits'))
          {
            //Only add to selected value IF not already selecting Collaborative Forecasting or Splits
            selectedValues.add('Product Schedules');
           
            
          }
            
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_ProductSchedules_Visible',
            'value' => 'Visible'
          }); 
          if(database.countQuery(countOpsWithoutProducts) == 0)
          {
            //They have Opportunity Products, but do they have any Opportunities without Products?
            variableSettings.add(new Map<string, object>{
              'name' => 'Has_LineItems_with_No_Schedule',
              'value' => 'No'
            }); 
          }
        }
      }
      catch(Exception e)
      {
        //just in case
      }
    } 
    else
    {
      // visibility 
      variableSettings.add(new Map<string, object>{
        'name' => 'Has_ProductSchedules_Visible',
        'value' => 'Disabled'
      }); 
      i2d = 1;
    }
    
    messages2d[i2d].add('Product Revenue Schedules');

    return new Map<String, Object>{
      'success' => true,
      'messages2d' => messages2d,
      'variableSettings' => variableSettings
    };
  }
  /*****2.Method to Autoscan and set fiscal******/
  private static Map<String, Object> setFiscal()
  {
    List<Object> variableSettings = new List<Object>();
    String offset;
    try
    {
      Integer months = [SELECT
        FiscalYearStartMonth
      FROM
        Organization].FiscalYearStartMonth;

      Map<Integer, string> a = new Map<Integer, string>{
        1 => '01 - January',
        2 => '02 - February',
        3 => '03 - March',
        4 => '04 - April',
        5 => '05 - May',
        6 => '06 - June',
        7 => '07 - July',
        8 => '08 - August',
        9 => '09 - September',
        10 => '10 - October',
        11 => '11 - November',
        12 => '12 - December'
      };
      String monthOffset = a.get(months);

      variableSettings.add(new Map<string, object>{
        'name' => 'Fiscal_Month',
        'value' => monthOffset
      }); 
      offset = monthOffset;
      // set description? No.
      // template.getVariables().get('Fiscal_Month').setDescription('Wave has selected the month based on your Salesforce settings but you may override this value. If it is different than January, you also need to update the Quota dataset JSON file.');
    }
    catch (Exception e)
    {
      //just in case
      variableSettings.add(new Map<string, object>{
        'name' => 'Fiscal_Month',
        'value' => '01 - January'
      }); 
      offset = '01 - January';
    }
    return new Map<String, Object>{
      'success' => true,
      'variableSettings' => variableSettings,
      'messages' => new List<String> {'Fiscal month is set to ' + offset.substring(5) + ', '}
    };
  }

  private static Map<String, Object> hasManagerAndRoles()
  {
    List<Object> variableSettings = new List<Object>();
    String message;
    try
    {
      Integer RoleCount = 0;

      //Check for users with roles that have role parents
      RoleCount = Database.countQuery('SELECT count() FROM User WHERE userrole.parentRoleID != null');

      Integer ManagerCount = 0;
      
      //Check to see if users have user managers populated
      ManagerCount = Database.countQuery('SELECT count() FROM User WHERE ManagerId != null');
      if(ManagerCount > 0)
      {
        //Customer is using the User Manager feature so let's include this field
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_Managers',
          'value' => 'Yes'
        }); 
        message = 'Sales Analytics has detected that this org uses Manager Hierarchy ';
      } else {
        message = 'Sales Analytics has detected that this org doesn\'t use Manager Hierarchy ';

      }
      if(RoleCount > 0)
      {
        //Customer is using role hierarchy, so let's use it!!
        variableSettings.add(new Map<string, object>{
          'name' => 'UsingRoleHierarchy',
          'value' => 'Yes'
        }); 
        message += 'and uses Role Hierarchy.';
      }
      else
      {
        //Customer is not using Roles at all so we must remove it from Wave
        variableSettings.add(new Map<string, object>{
          'name' => 'UsingRoleHierarchy',
          'value' => 'No'
        }); 

        //Since there are no roles, we can't really use a security predicate
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_SecurityPredicate',
          'value' => 'Option 3: Users view all data',
          'eventName' => 'wizard.computed'
        }); 

        //Since we can't do a security predicate, there is no reason we should include these questions
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_SecurityPredicate_Visible',
          'value' => 'Disabled'
        }); 
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_AccountTeams_Visible',
          'value' => 'Hidden'
        }); 
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_OpportunityTeams',
          'value' => 'Hidden',
          'eventName' => 'wizard.computed'
        }); 
        message += 'and doesn\'t use Role Hierarchy.';
      }
    }
    catch(Exception e)
    {
        // fallback do nothing
    }
    return new Map<String, Object>{
      'success' => true,
      'variableSettings' => variableSettings,
      'messages' => new List<String>{message}
    };
  }

  /**
  * Private method to initialize the Locale Mapping
  * @returns Map<String, Integer>
  */
  private static Map<String, Integer> initLocaleMap(){
    //add all mappings for Supported Locales and their Start Day offset here
    Map<String, Integer> mymap = new Map<String, Integer>();
    mymap.put('sq_AL',6);
    mymap.put('ar_DZ',6);
    mymap.put('ar_BH',6);
    mymap.put('ar_EG',0);
    mymap.put('ar_IQ',0);
    mymap.put('ar_JO',6);
    mymap.put('ar_KW',6);
    mymap.put('ar_LB',6);
    mymap.put('ar_LY',6);
    mymap.put('ar_MA',6);
    mymap.put('ar_OM',6);
    mymap.put('ar_QA',6);
    mymap.put('ar_SA',6);
    mymap.put('ar_SD',6);
    mymap.put('ar_SY',6);
    mymap.put('ar_TN',6);
    mymap.put('ar_AE',6);
    mymap.put('ar_YE',6);
    mymap.put('hy_AM',0);
    mymap.put('az_AZ',0);
    mymap.put('eu_ES',0);
    mymap.put('be_BY',0);
    mymap.put('bn_BD',0);
    mymap.put('bs_BA',0);
    mymap.put('bg_BG',0);
    mymap.put('my_MM',0);
    mymap.put('ca_ES_EURO',1);
    mymap.put('ca_ES',1);
    mymap.put('zh_CN_PINYIN',0);
    mymap.put('zh_CN_STROKE',0);
    mymap.put('zh_CN',0);
    mymap.put('zh_HK_STROKE',0);
    mymap.put('zh_HK',0);
    mymap.put('zh_MO',0);
    mymap.put('zh_SG',0);
    mymap.put('zh_TW_STROKE',0);
    mymap.put('zh_TW',0);
    mymap.put('hr_HR',1);
    mymap.put('cs_CZ',1);
    mymap.put('da_DK',1);
    mymap.put('nl_AW',1);
    mymap.put('nl_BE',1);
    mymap.put('nl_NL',1);
    mymap.put('nl_SR',1);
    mymap.put('dz_BT',0);
    mymap.put('en_AG',0);
    mymap.put('en_AU',0);
    mymap.put('en_BS',0);
    mymap.put('en_BB',0);
    mymap.put('en_BZ',0);
    mymap.put('en_BM',0);
    mymap.put('en_BW',0);
    mymap.put('en_CM',0);
    mymap.put('en_CA',0);
    mymap.put('en_KY',0);
    mymap.put('en_ER',0);
    mymap.put('en_FK',0);
    mymap.put('en_FJ',0);
    mymap.put('en_GM',0);
    mymap.put('en_GH',0);
    mymap.put('en_GI',0);
    mymap.put('en_GY',0);
    mymap.put('en_HK',0);
    mymap.put('en_IN',0);
    mymap.put('en_ID',0);
    mymap.put('en_IE_EURO',1);
    mymap.put('en_IE',1);
    mymap.put('en_JM',0);
    mymap.put('en_KE',0);
    mymap.put('en_LR',0);
    mymap.put('en_MG',0);
    mymap.put('en_MW',0);
    mymap.put('en_MY',0);
    mymap.put('en_MU',0);
    mymap.put('en_NA',0);
    mymap.put('en_NZ',0);
    mymap.put('en_NG',0);
    mymap.put('en_PK',0);
    mymap.put('en_PG',0);
    mymap.put('en_PH',0);
    mymap.put('en_RW',0);
    mymap.put('en_SH',0);
    mymap.put('en_WS',0);
    mymap.put('en_SC',0);
    mymap.put('en_SL',0);
    mymap.put('en_SG',0);
    mymap.put('en_SX',0);
    mymap.put('en_SB',0);
    mymap.put('en_ZA',0);
    mymap.put('en_SZ',0);
    mymap.put('en_TZ',0);
    mymap.put('en_TO',0);
    mymap.put('en_TT',0);
    mymap.put('en_UG',0);
    mymap.put('en_GB',1);
    mymap.put('en_US',0);
    mymap.put('en_VU',0);
    mymap.put('et_EE',1);
    mymap.put('fi_FI_EURO',1);
    mymap.put('fi_FI',1);
    mymap.put('fr_BE',1);
    mymap.put('fr_CA',0);
    mymap.put('fr_KM',1);
    mymap.put('fr_FR_EURO',1);
    mymap.put('fr_FR',1);
    mymap.put('fr_GN',1);
    mymap.put('fr_HT',1);
    mymap.put('fr_LU',1);
    mymap.put('fr_MR',1);
    mymap.put('fr_MC',1);
    mymap.put('fr_CH',1);
    mymap.put('fr_WF',1);
    mymap.put('ka_GE',0);
    mymap.put('de_AT_EURO',1);
    mymap.put('de_AT',1);
    mymap.put('de_DE_EURO',1);
    mymap.put('de_DE',1);
    mymap.put('de_LU_EURO',1);
    mymap.put('de_LU',1);
    mymap.put('de_CH',1);
    mymap.put('el_GR',1);
    mymap.put('iw_IL',0);
    mymap.put('hi_IN',0);
    mymap.put('hu_HU',1);
    mymap.put('is_IS',1);
    mymap.put('in_ID',1);
    mymap.put('ga_IE',0);
    mymap.put('it_IT',1);
    mymap.put('it_CH',1);
    mymap.put('ja_JP',0);
    mymap.put('kk_KZ',0);
    mymap.put('km_KH',0);
    mymap.put('ky_KG',0);
    mymap.put('ko_KP',0);
    mymap.put('ko_KR',0);
    mymap.put('lo_LA',0);
    mymap.put('lv_LV',0);
    mymap.put('lt_LT',1);
    mymap.put('lu_CD',0);
    mymap.put('lb_LU',0);
    mymap.put('mk_MK',0);
    mymap.put('ms_BN',0);
    mymap.put('ms_MY',0);
    mymap.put('mt_MT',0);
    mymap.put('ne_NP',0);
    mymap.put('no_NO',1);
    mymap.put('ps_AF',0);
    mymap.put('fa_IR',0);
    mymap.put('pl_PL',1);
    mymap.put('pt_AO',1);
    mymap.put('pt_BR',0);
    mymap.put('pt_CV',1);
    mymap.put('pt_MZ',1);
    mymap.put('pt_PT',1);
    mymap.put('pt_ST',1);
    mymap.put('ro_MD',1);
    mymap.put('ro_RO',1);
    mymap.put('rm_CH',0);
    mymap.put('rn_BI',0);
    mymap.put('ru_RU',1);
    mymap.put('sr_BA',1);
    mymap.put('sr_RS',0);
    mymap.put('sr_CS',1);
    mymap.put('sh_BA',1);
    mymap.put('sh_ME',1);
    mymap.put('sh_CS',1);
    mymap.put('sk_SK',1);
    mymap.put('sl_SI',1);
    mymap.put('so_DJ',0);
    mymap.put('so_SO',0);
    mymap.put('es_AR',1);
    mymap.put('es_BO',1);
    mymap.put('es_CL',1);
    mymap.put('es_CO',1);
    mymap.put('es_CR',1);
    mymap.put('es_CU',1);
    mymap.put('es_DO',1);
    mymap.put('es_EC',1);
    mymap.put('es_SV',1);
    mymap.put('es_GT',1);
    mymap.put('es_HN',1);
    mymap.put('es_MX',1);
    mymap.put('es_NI',1);
    mymap.put('es_PA',1);
    mymap.put('es_PY',1);
    mymap.put('es_PE',1);
    mymap.put('es_PR',1);
    mymap.put('es_ES_EURO',1);
    mymap.put('es_ES',1);
    mymap.put('es_US',0);
    mymap.put('es_UY',1);
    mymap.put('es_VE',1);
    mymap.put('sv_SE',1);
    mymap.put('tl_PH',0);
    mymap.put('tg_TJ',0);
    mymap.put('ta_IN',0);
    mymap.put('ta_LK',0);
    mymap.put('th_TH',0);
    mymap.put('ti_ET',0);
    mymap.put('tr_TR',1);
    mymap.put('uk_UA',1);
    mymap.put('ur_PK',0);
    mymap.put('uz_LATN_UZ',0);
    mymap.put('vi_VN',0);
    mymap.put('cy_GB',0);
    mymap.put('yo_BJ',0);

    return mymap;
  }

  private static Map<String, Object> aggregateResults(List<Map<String, Object>> resultList){
    
    Boolean allGood = true;
    List<Map<String, Object>> variableSettings = new List<Map<String, Object>>();
    List<String> messages = new List<String>();
    List<List<String>> messages2d = new List<List<String>>();

    // iterate over the results
    for (Map<String, Object> result: resultList){
      // if one failed all failed
      if (! ((boolean)result.get('success'))){
        allGood = false;
      }

      // aggregate the variable settings
      if (result.containsKey('variableSettings')){
        for (Object s: (List<Object>)result.get('variableSettings')){
          variableSettings.add((Map<String, Object>)s);
        }
      }

      // and messages
      if (result.containsKey('messages')){
        List<String> addedMessages = (List<String>)result.get('messages');
        if (result.containsKey('mergeWithPrevious')){
          messages[messages.size()-1] += addedMessages[0];
        } else {
          messages.addAll(addedMessages);
        }
      }

      // and array of array of messages
      if (result.containsKey('messages2d')){
        List<Object> resultMessages = (List<Object>)result.get('messages2d');
        // for each array in 2d array
        for (Integer i = 0; i < resultMessages.size(); i++) { 
          // incoming array bigger than what we have
          if ((i + 1) > messages2d.size()){
            messages2d.add(new List<String>());
          }
          messages2d[i].addAll((List<String>)resultMessages[i]);
        }
      }
    }

    // flatten the messages2d into messages
    for (Integer i = 0; i < messages2d.size(); i++){
      List<String> messageList = messages2d[i];
      messages.addAll((List<String>)messageList);
      if (i < messages2d.size() - 1){
        // space between the lists - not for the last
        messages.add('');
      }
    }

    // aggregate the messages and variable settings
    return new Map<String, Object>{
      'success' => allGood,
      'messages' => messages,
      'variableSettings' => variableSettings
    };
  } 

   /**
   * Private method to get and assign the firstDayOfWeek
   */
  private static Map<String, Object>  assignFirstDay(){
    
    List<Object> variableSettings = new List<Object>();

    //initialize Map with Locales and their Start Days
    Map<String, Integer> localeMap = new Map<String, Integer>();
    localeMap = initLocaleMap();
    Integer firstday;
    String firstdayName;
    List<String> dayNames = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};

    //Check if Context User is an Integration User and get their Locale
    String contextUserType = UserInfo.getUserType();

    if(contextUserType == 'Analytics Cloud Integration User'){
      String contextUserLocale = UserInfo.getLocale();
      system.debug('This is the Integration User' + contextUserLocale);
      firstday = localeMap.get(contextUserLocale);
      system.debug(firstday);
    }
    //Else just get the current Organizations Locale
    else
    {
      Organization org = [SELECT DefaultLocaleSidKey FROM Organization];
      String contextOrgLocale = org.DefaultLocaleSidKey;
      system.debug('This is the Org ' + contextOrgLocale);
      firstday = localeMap.get(contextOrgLocale);
      system.debug(firstday);
    }

    if(firstday != null){
      //Assign Start Day to First_Day_Of_Week variable in variables.json
      variableSettings.add(new Map<string, object>{
        'name' => 'First_Day_Of_Week',
        'value' => firstday
      }); 
      firstdayName = dayNames[firstday];
    } 
    else 
    {
      //If the locale doesnt exist in the map, then set the variable to 0 by default.
      variableSettings.add(new Map<string, object>{
        'name' => 'First_Day_Of_Week',
        'value' => 0
      });  
      firstdayName = dayNames[0];     
    }

    return new Map<String, Object>{
      'success' => true,
      'variableSettings' => variableSettings,
      'messages' => new List<String>{'first day of week to ' + firstdayName + ', '},
      'mergeWithPrevious' => true
    };
  }

  /*****4.Method to verfiy account and opportunity teams *****/
  private static Map<String, Object> hasTeams()
  {
    List<Object> variableSettings = new List<Object>();
    List<List<String>> messages2d = getInitialMessages2d();

    Integer count = 0;
    /*returns a map of all SObject names to sObject tokens( values) for standard and custom objects */
    //see if an accountteam member is present, if not, Account teams are not enabled
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get('AccountTeamMember');
    Schema.SObjectType targetType1 = Schema.getGlobalDescribe().get('OpportunityTeamMember');
    if(targetType != null)
    {
      string query = 'Select count() from AccountTeamMember limit 1';
      count = database.countQuery(query);
    }
    if(targetType == null || count == 0)
    {
      variableSettings.add(new Map<string, object>{
        'name' => 'Has_AccountTeams_Visible',
        'value' => 'Hidden'
      }); 
      messages2d[1].add('Account Teams');
    } else {
      messages2d[0].add('Account Teams');
    }
    if(targetType1 != null)
    {
      string query1 = 'Select count() from OpportunityTeamMember limit 1';
      count = database.countQuery(query1);

    }
    if(targetType1 == null || count == 0)
    {
      variableSettings.add(new Map<string, object>{
        'name' => 'Has_OpportunityTeams_Visible',
        'value' => 'Hidden'
      }); 
      messages2d[1].add('Opportunity Teams');
    } else {
      messages2d[0].add('Opportunity Teams');
    }
    return new Map<String, Object>{
      'success' => true,
      'variableSettings' => variableSettings,
      'messages2d' => messages2d
    };
  }

  /******5.Method to verify other objects on the wizard ******/
  private static Map<String, Object> hasCases(List<object> selectedValues)
  {
    List<List<String>> messages2d = getInitialMessages2d();
    // where to put the message: 0 - has, 1 - doesn't have
    Integer i2d = 1;

    List<Object> variableSettings = new List<Object>();
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Case');
    if (targetType != null)
    {
      try
      {
        Integer count = Database.countQuery('SELECT count() FROM Case where accountId != null Limit 1000');
        if(count == 0)
        {
          // set default - no cases
          // not now

          variableSettings.add(new Map<string, object>{
            'name' => 'Has_Cases_Visible',
            'value' => 'Disabled'
          }); 
        }
        else if(count < 10)
        {
          //Maybe they have some cases, but not very many - we should recommend they answer no
          //
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_Cases_Visible',
            'value' => 'Visible'
          }); 
          i2d = 0;

        }
        else
        {
          // set default to has cases - we do this always now
          selectedValues.add('Cases');
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_Cases_Visible',
            'value' => 'Visible'
          }); 
          i2d = 0;
        }
      }
      catch(Exception e){}
    }
    else
    {
      variableSettings.add(new Map<string, object>{
        'name' => 'Has_Cases_Visible',
        'value' => 'Disabled'
      }); 
    }
    messages2d[i2d].add('Cases');
    return new Map<String, Object>{
      'success' => true,
      'variableSettings' => variableSettings,
      'messages2d' => messages2d
    };
  }

  private static Map<String, Object> hasCampaigns()
  {
    List<List<String>> messages2d = getInitialMessages2d();
    // where to put the message: 0 - has, 1 - doesn't have
    Integer i2d = 1;

    List<Object> variableSettings = new List<Object>();
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Campaign');
    if (targetType != null)
    {
      try
      {
        Integer count = Database.countQuery('SELECT count() FROM  Campaign WHERE NumberOfOpportunities > 0 Limit 100');
        if(count == 0)
        {
          // set campaigns to no

          variableSettings.add(new Map<string, object>{
            'name' => 'Has_Campaigns_Visible',
            'value' => 'Disabled'
          }); 
        }
        else if(count < 10)
        {
          // Maybe they have some campaigns, but not very many - we should recommend they answer no
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_Campaigns_Visible',
            'value' => 'Visible'
          }); 
          i2d = 0;
        }
        else
        {
          // set campaigns to yes
          variableSettings.add(new Map<string, object>{
            'name' => 'Has_Campaigns_Visible',
            'value' => 'Visible'
          }); 
          i2d = 0;
        }
      }
      catch(Exception e){}
    }
    else
    {
      variableSettings.add(new Map<string, object>{
        'name' => 'Has_Campaigns_Visible',
        'value' => 'Disabled'
      }); 
    }
    messages2d[i2d].add('Campaigns');
    return new Map<String, Object>{
      'success' => true,
      'variableSettings' => variableSettings,
      'messages2d' => messages2d
    };
  }

  private static Map<String, Object> canUseParentAccount()
  {
    List<Object> variableSettings = new List<Object>();
    String message;
    try
    {
      // check if there is at least one account with a parent
      List<Account> accountWithParent = Database.query('SELECT ParentId FROM Account WHERE ParentId != null LIMIT 1');
      if (!accountWithParent.isEmpty())
      {
        system.debug('There is at least one account with a parent');
        variableSettings.add(new Map<string, object>{
          'name' => 'UsingAccountHierarchy',
          'value' => 'Yes',
          'eventName' => 'wizard.computed'
          });
        message = 'There is at least one account with a parent.';
      } else {
        // Hide AccountHierarchy question from wizard
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_AccountHierarchy_Visible',
          'value' => 'Hidden'
        });
        message = 'There is no account with a parent.';
      }
    }
    catch(Exception e){}

    return new Map<String, Object>{
      'success' => true,
      'variableSettings' => variableSettings,
      'messages' => new List<String>{message}
    };
  }

  private static Map<String, Object> getUserCurrency()
  {

    return new Map<String, Object>{
      'success' => true,
      'variableSettings' => new List<Object>(),
      'messages' => new List<String>{'and currency to '+ System.UserInfo.getDefaultCurrency() + '. Sales Analytics made these selections based on your Salesforce settings.'},
      'mergeWithPrevious' => true
    };
  }

  private static List<Object> setLeads(string yesOrNo)
  {
    List<Object> variableSettings = new List<Object>();

    // set the suggested value
    // not for now
    
    // if no leads, grey out the question
    if (yesOrNo == 'No')
    {
      variableSettings.add(new Map<string, object>{
        'name' => 'Has_Leads_Visible',
        'value' => 'Disabled'
      });  
    }
    else{
    
    variableSettings.add(new Map<string, object>{
      'name' => 'Has_Leads_Visible',
      'value' => 'Visible'
    });  
    }
    return variableSettings;
  }

  private static List<Object> setLeadScoreVariables()
  {
    
    if (!(boolean)wavetemplate.Access.integUserHasAccessToSObjectField('ScoreIntelligence', 'Id')) {
      System.debug('ScoreIntelligence not available');
      return new List<Object>{
        new Map<String, Object>{
          'name' => 'Has_LeadScore',
          'value' => false
        },
        new Map<String, Object>{
          'name' => 'Lead_Rating_Visible',
          'value' => 'Visible'
        }
      };
    }
    
    String query = 'SELECT count() FROM Lead WHERE ScoreIntelligenceId != null LIMIT 1';
    Integer scoreIntelligenceCount = Database.countQuery(query);
    if (scoreIntelligenceCount == 0)
    {
      System.debug('No records in ScoreIntelligence');
     return new List<Object>{
       new Map<String, Object>{
         'name' => 'Has_LeadScore',
         'value' => false
       },
       new Map<String, Object>{
         'name' => 'Lead_Rating_Visible',
         'value' => 'Visible'
       }
     };
    }

    System.debug('Has ScoreIntelligence, setting the vars');
    return new List<Object>{
      new Map<String, Object>{
        'name' => 'Has_LeadScore',
        'value' => true
      },
      new Map<String, Object>{
        'name' => 'Lead_Rating_Visible',
        'value' => 'Hidden'
      }
    };
  }

  /*****4.Method to verfiy leads *****/
  private static Map<String, Object> hasLeads(List<object> selectedValues)
  {
    List<List<String>> messages2d = getInitialMessages2d();

    try
    {
      Integer count = 0;
      /*returns a map of all SObject names to sObject tokens( values) for standard and custom objects */
      //see if an accountteam member is present, if not, Account teams are not enabled
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Lead');
      if (targetType != null)
      {
        string query = 'Select count() from Lead limit 1';
        count = database.countQuery(query);
      }
      if (targetType == null || count == 0)
      {
        // they don't have leads
        system.debug('No leads');
        messages2d[1].add('Leads');
        return new Map<String, Object>{
          'success' => true,
          'variableSettings' => setLeads('No'),
          'messages2d' => messages2d
        };
      }

      // see if they have converted leads
      string query = 'Select count() from Lead where ConvertedOpportunityId != null limit 1';
      count = database.countQuery(query);
      if (count == 0)
      {
        // no converted leads
        system.debug('No converted leads');
        messages2d[1].add('Leads');
        return new Map<String, Object>{
          'success' => true,
          'variableSettings' => setLeads('No'),
          'messages2d' => messages2d
        };
      }

      // if we get here they have leads
      system.debug('Yes leads');
      selectedValues.add('Leads');
      messages2d[0].add('Leads');
      List<Object> leadSettings = setLeads('Yes');

      // check if they have lead score
      List<Object> leadScoreSettings = setLeadScoreVariables();

      leadSettings.addAll(leadScoreSettings);

      return new Map<String, Object>{
        'success' => true,
        'variableSettings' => leadSettings,
        'messages2d' => messages2d
      };
    }
    catch(Exception e)
    {
      // fallback no leads
      system.debug('something went wrong, setting no leads');
      messages2d[1].add('Leads');
      return new Map<String, Object>{
        'success' => true,
        'variableSettings' => setLeads('No'),
        'messages2d' => messages2d
      };
    }
  }
  private static Map<String, Object> setAdditionalObjectChoices(List<object> selectedValues)
  {
    
    List<String> messages = new List<String>();
    List<Object> variableSettings = new List<Object>();
    
    
    variableSettings.add(new Map<string, object>{
      'name' => 'SObjectChoices',
      'value' => selectedValues,
      'eventName' => 'wizard.computed'
    });
    
     return new Map<String, Object>{
       'success' => true,
       'messages' => messages,
       'variableSettings' => variableSettings
     }; 
  }

  private static boolean canUseQuotas(Id forecastingTypeId)
  {
    try
    {
      List<Object> quotaRecords = Database.query('SELECT Id FROM ForecastingQuota LIMIT 1');
      if (quotaRecords.isEmpty())
      {
        system.debug('There are no ForecastingQuota records');
        return false;
      }
      system.debug('There are ForecastingQuota records: '  + quotaRecords);
      return true;
    }
    catch(Exception e)
    {
      system.debug('something went wrong, cannot use collab quotas '+ e);
      return false;
    }
  }

  private static boolean canUseCollabForecast(Id forecastingTypeId)
  {
    try
    {
      // check if they're using collaborative forecasting
      if (forecastingTypeId == null)
      {
        system.debug('There are no OpportunityRevenue ForecastingType records');
        return false;
      }

      system.debug('There are OpportunityRevenue ForecastingType records: '  + forecastingTypeId);

      // check hierarchy setup
      // 1. at least one user with enabled forecast
      List<User> usersWithForecast = Database.query('SELECT Id FROM User WHERE ForecastEnabled = true LIMIT 1');
      if (usersWithForecast.isEmpty())
      {
        system.debug('No user has ForecastEnabled');
        return false;
      }
      system.debug('User with ForecastEnabled: ' + usersWithForecast);
      
      // 2. at least one role has a forecast user
      List<UserRole> roleWithForecastUser = Database.query('SELECT Id FROM UserRole WHERE ForecastUserId != null LIMIT 1');
      if (roleWithForecastUser.isEmpty())
      {
        system.debug('No role has a forecast user');
        return false;
      }
      system.debug('Role with ForecastUserId: ' + roleWithForecastUser);

      // 3. at least one role has a parent role
      List<UserRole> roleWithParent = Database.query('SELECT Id FROM UserRole WHERE ParentRoleId != null LIMIT 1');
      if (roleWithParent.isEmpty())
      {
        system.debug('No role has parent role');
        return false;
      }
      system.debug('Role with parent role: ' + roleWithParent);

      // 4. there's a forecast enabled user with role that has a parent role assigned to a forecast enabled user.
      // SELECT Id, Name FROM User WHERE ForecastEnabled = true
      // get a set of random roles assigned to a forecast user
      Set<Id> roleIdSet = new Set<Id>();
      for (User forecastUser: Database.query('SELECT Id, UserRoleId FROM User WHERE ForecastEnabled = true AND UserRoleId != null LIMIT 1000'))
      {
          roleIdSet.add(forecastUser.UserRoleId);
      }

      List<User> subOrdinates = Database.query('SELECT Id, UserRoleId FROM User WHERE ForecastEnabled = true AND UserRole.ParentRoleId IN :roleIdSet LIMIT 1');

      if (subOrdinates.isEmpty())
      {
        system.debug('No forecasting role found to report to another forecasting role');
        return false;
      }
      system.debug('Role with parent that has collab: ' + subOrdinates);

      // if we got here, it's all good
      return true;
    }
    catch(Exception e)
    {
      system.debug('something went wrong, cannot use collab '+ e);
      return false;
    }
  }

  private static Id getForecastingTypeId()
  {
    // check if object exists
    Schema.SObjectType forecastingType = Schema.getGlobalDescribe().get('ForecastingType');
    if (forecastingType == null)
    {
      // they don't have colab forcasting
      system.debug('No ForecastingType enabled in org');
      return null;
    }
    system.debug('there is ForecastingType enabled in org');


    // to set the right Forecast Type we need to check which split types are used.
    List<SObject> splitTypes = getSplits();
    List<String> validForecastTypes = new List<String>();

    for (sObject S : splitTypes) {
    validForecastTypes.add((String) S.get('DeveloperName'));
    }
    validForecastTypes.add('OpportunityRevenue');
    validForecastTypes.add('OpportunitySplitRevenue');


    // check if there is OpportunityRevenue forecast type active
    // Object and query from string because ForecastingType is not available in orgs that don't have forecasting enabled and therefore it doesn't deploy
    List<SObject> typeRecords = Database.query('SELECT Id, DeveloperName FROM ForecastingType WHERE (IsActive = true and DeveloperName IN :validForecastTypes)');
    if (typeRecords.isEmpty())
    {
      return null;
    }

    // get the id from the first ForecastingType
    return (Id)typeRecords[0].get('Id');
  }

  private static Map<String, Object> hasCollabForecast(List<object> selectedValues)
  {
    List<Object> variableSettings = new List<Object>();
    List<List<String>> messages2d = getInitialMessages2d();
    try
    {
      Id forecastingTypeId = getForecastingTypeId();
      


      // check if they can use the collaborative forecasting in Sales Analytics and they use collaborative forecasting quota
      if ((canUseCollabForecast(forecastingTypeId)) && (canUseQuotas(forecastingTypeId))){

        // 1. set suggested answer yes to collaborative forecast question, set quota question to collaborative forecasting quota.
        selectedValues.add('Collaborative Forecasting');
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_CollaborativeForecasting',
          'value' => 'Yes',
          'eventName' => 'wizard.computed'
        });
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_CollaborativeForecasting_Visible',
          'value' => 'Visible'
        }); 
        system.debug('set suggested yes to Has_CollaborativeForecasting');
        
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_Quota',
          'value' => 'Collaborative Forecasting Quota'
        }); 
        system.debug('set Has_Quota to default to Collaborative Forecasting Quota');
        messages2d[0].add('Collaborative Forecasts');
        messages2d[0].add('Collaborative Forecasting Quota');
      }
      // 1. check if they can use collaborative forecasting but not collaborative forecasting quota.
      else if ((canUseCollabForecast(forecastingTypeId)) && (!canUseQuotas(forecastingTypeId))) {
        // 2. set sugggested answer yes to collaborative forecasting question 
        // not removing any options (enums), since the question is not visible anymore
        selectedValues.add('Collaborative Forecasting');
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_CollaborativeForecasting',
          'value' => 'Yes',
          'eventName' => 'wizard.computed'
        }); 
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_CollaborativeForecasting_Visible',
          'value' => 'Visible'
        }); 
        system.debug('set suggested yes to Has_CollaborativeForecasting');
        messages2d[0].add('Collaborative Forecasts');
        messages2d[1].add('Collaborative Forecasting Quota');
      }
      else {
        // 1. hide collaborative forecasting question and remove collaborative forecasting quota option.
        variableSettings.add(new Map<string, object>{
          'name' => 'Has_CollaborativeForecasting_Visible',
          'value' => 'Disabled'
        }); 
        system.debug('hidden Has_CollaborativeForecasting');
        messages2d[1].add('Collaborative Forecasts');
        messages2d[1].add('Collaborative Forecasting Quota');
        
        // not removing anything from Has_Quota question, since it isn't visible anyways
      }
     }
     catch(Exception e)
     {
     }
    return new Map<String, Object>{
      'success' => true,
      'variableSettings' => variableSettings,
      'messages2d' => messages2d
    };
  }  

  @RemoteAction
  global static Map<string, object> objectUsage() 
  {
    List<Map<String, Object>> resultList = new List<Map<String, Object>>();
    resultList.add( new Map<String, Object>{
      'success' => true,
      'messages2d' => new List<Object> {
        new List<String>{'Sales Analytics has detected that your org uses the following, which you can add to your app:'},
        new List<String> {
        'Sales Analytics has detected your org does not use the following, and they cannot be added to your app:'}
      }
    });
    List<object> selectedValues = new List<object>();
    try
    {
      resultList.add(hasProducts(selectedValues));
      resultList.add(hasTeams());
      // renamed hasOtherObjects -> hasCases
      resultList.add(hasCases(selectedValues));
      resultList.add(hasCampaigns());
      resultList.add(hasLeads(selectedValues));
      resultList.add(hasCollabForecast(selectedValues));
      resultList.add(hasOpportunitySplits(selectedValues));

      resultList.add(hasProductSchedules(selectedValues));
      
            
      resultList.add(setAdditionalObjectChoices(selectedValues));
    }
    catch(Exception e)
    {
    }

    // aggregate results
    return aggregateResults(resultList);
  }

  @RemoteAction
  global static Map<string, object> fieldAccess() 
  {
    // read it from a variable set in Modifier
    return new Map<String, Object>{
      'success' => true,
      'messagesVariable' => 'DefaultsVisibleMessages'
    };
  }

  @RemoteAction
  global static Map<string, object> configuration() 
  {
    List<Map<String, Object>> resultList = new List<Map<String, Object>>();
    resultList.add(setFiscal());
    resultList.add(assignFirstDay());
    resultList.add(getUserCurrency());
    resultList.add(canUseParentAccount());

    // aggregate results
    return aggregateResults(resultList);
  }

  @RemoteAction
  global static Map<string, object> dataInconsistencies() 
  {
    return hasManagerAndRoles();
  }

  
}