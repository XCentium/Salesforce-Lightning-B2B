global class ServiceChecklistRemoter{

global ServiceChecklistRemoter() {

        }                      // empty constructor



@RemoteAction
global static Map<string, object> dataOk(Boolean isCustomReset ) {
        boolean errorFlag = false;
        Integer errorNum = 1;
        Integer taskCount = 0;
        Integer closedCaseCount =0;
        List<string> errorMessages = new List<string>();
        //Check for Existence of atleast one Closed Case, and one Tasks
        //Due to Data sizes Task and Case Query may time out. First check to see if there are any records (limit 2)
        //This may fail if there too many tasks and events.
        //If it fails we should proceed and assume they have one closed case and task.
        // Verify if org has atleast one closed case.

        try {
                List<Case> countofClosedCases = Database.query('SELECT id FROM case where IsClosed = true Order by CreatedDate DESC limit 2');
                if (countofClosedCases.isEmpty())
                {
                        closedCaseCount = 0;
                        errorMessages.add('Service Analytics requires that your org includes at least one closed case. Go to Service Cloud, close a case, then try creating your app again.');
                        errorFlag = true;
                }
        } catch(Exception e) {
                //really big orgs may fail on this query - incase they do let's assume they have closed case
                closedCaseCount = 1;
        }
        try
        {
                taskCount = Database.countQuery('SELECT count() FROM task limit 1');
                if(taskCount == 0)
                {
                        errorMessages.add('Service Analytics requires at least one task record to exist. Go to Service Cloud, create a task, then try creating the application again.');
                        errorFlag = true;
                }
        }
        catch(Exception e)
        {
                //really big orgs may fail on this query - incase they do let's assume they have closed case
                taskCount = 1;
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
        // everything alright
        // no variable settings here
        errorMessages.add('Your org has at least one closed case and task, which are minimum requirements for creating the app.');
        return new Map<String, Object>{
                       'success' => true,
                       'messages' => errorMessages
        };
}


/**** check for queues with cases in the org and set the variable to yes or no ******/

private static Map<String, Object> hasQueues(List<object> selectedValues, Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();
        //validate the product exists in the org
        Schema.SObjectType targetTypeQ = Schema.getGlobalDescribe().get('QueueSobject');
        if (targetTypeQ != null) {
                string countQueuesQuery = 'select count() from QueueSobject where SobjectType in (\'Case\') limit 1';
                try
                {
                        Integer count = database.countQuery(countQueuesQuery);
                        if(count == 0) {
                                messages_no.add('Queues');
                                //Service Analytics has detected that you do not use the Queues for Cases. As a result, it will not pull Cases Queues.');
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeQueueNames',
                                  'value' => 'No'
                                });

                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeQueueNames_Visible',
                                  'value' => 'Disabled'
                                });
                        }
                        else{
                            selectedValues.add('Queues');
                            messages_yes.add('Queues');

                            if (!isCustomReset)
                            {
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeQueueNames',
                                      'value' => 'Yes'
                                    });

                                    // visibility
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeQueueNames_Visible',
                                      'value' => 'Selected'
                                    });
                            }
                        }
                }
        catch (Exception e) { }
        }
        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}

private static Map<String, Object> hasCaseHistory(List<object> selectedValues, Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();
        //validate the product exists in the org
        // Schema.SObjectType targetTypeQ = Schema.getGlobalDescribe().get('CaseHistory');
        // if (targetTypeQ != null) {
                string ownerHistoryQuery = 'select Id from casehistory where field = \'owner\' Order by CreatedDate DESC limit 2';
                try
                {
                        List<casehistory> ownerHistoryrecords = database.query(ownerHistoryQuery);
                          if(ownerHistoryrecords.isEmpty()) {
                                messages_no.add('Case history');
                                //messages.add('Service Analytics has detected that you do not have Case history. As a result, it will not pull Cases History.');

                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeCaseHistory',
                                  'value' => 'No'
                                });

                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeCaseHistory_Visible',
                                  'value' => 'Disabled'
                                });
                        }
                        else{

                                string statusHistoryQuery = 'select Id from casehistory where field = \'status\' Order by CreatedDate DESC limit 2';
                                try
                                {
                                        List<casehistory> statusHistoryrecords = database.query(statusHistoryQuery);
                                        if(! statusHistoryrecords.isEmpty())
                                        {


                                                    selectedValues.add('CaseHistory');
                                                    messages_yes.add('Case history');

                                                    if (!isCustomReset)
                                                    {
                                                            variableSettings.add(new Map<string, object>{
                                                              'name' => 'IncludeCaseHistory',
                                                              'value' => 'Yes'
                                                            });


                                                            // visibility
                                                            variableSettings.add(new Map<string, object>{
                                                              'name' => 'IncludeCaseHistory_Visible',
                                                              'value' => 'Selected'
                                                            });
                                                    }
                                        }
                                        else{

                                                selectedValues.add('CaseHistory');
                                                messages_yes.add('Case history');
                                                variableSettings.add(new Map<string, object>{
                                                  'name' => 'IncludeCaseHistory',
                                                  'value' => 'No'
                                                });


                                                // visibility
                                                variableSettings.add(new Map<string, object>{
                                                  'name' => 'IncludeCaseHistory_Visible',
                                                  'value' => 'Visible'
                                                });

                                        }
                        }
                        catch (Exception e) { }
                }

        }
        catch (Exception e) { }
        //}
        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}


private static Map<String, Object> hasCaseRecordTypes(List<object> selectedValues, Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();

                string caseRecordTypeQuery = 'SELECT count() FROM RecordType WHERE SObjectType=\'Case\' limit 1';
                try
                {

                        Integer caseRecordtypes = Database.countQuery(caseRecordTypeQuery);

                        if(caseRecordtypes > 0) {

                                string caseRecordTypeIdQuery = 'SELECT count() FROM Case WHERE RecordTypeId != Null LIMIT 1';

                                Integer caseRecordtypesId = Database.countQuery(caseRecordTypeIdQuery);
                                if(caseRecordtypesId > 0) {

                                            messages_yes.add('Case record types');
                                            selectedValues.add('CaseRecordTypes');

                                            if (!isCustomReset)
                                            {
                                                    variableSettings.add(new Map<string, object>{
                                                      'name' => 'IncludeCaseRecordTypes',
                                                      'value' => 'Yes'
                                                    });

                                                    // visibility
                                                    variableSettings.add(new Map<string, object>{
                                                      'name' => 'IncludeCaseRecordTypes_Visible',
                                                      'value' => 'Selected'
                                                    });
                                            }
                                }
                                else{

                                        messages_no.add('Case record types');
                                        variableSettings.add(new Map<string, object>{
                                          'name' => 'IncludeCaseRecordTypes',
                                          'value' => 'No'
                                        });

                                        // visibility
                                        variableSettings.add(new Map<string, object>{
                                          'name' => 'IncludeCaseRecordTypes_Visible',
                                          'value' => 'Disabled'
                                        });
                                }

                        }
                        else{

                                messages_no.add('Case record types');
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeCaseRecordTypes',
                                  'value' => 'No'
                                });

                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeCaseRecordTypes_Visible',
                                  'value' => 'Disabled'
                                });

                        }
                }
        catch (Exception e) { }
        //}
        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}

private static Map<String, Object> hasOpportunityRecordTypes(List<object> selectedValues,Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();


                string opptyRecordTypeQuery = 'SELECT count() FROM RecordType WHERE SObjectType=\'Opportunity\' limit 1';
                try
                {
                        //List<RecordType> opptyRecordTypes = Database.query(opptyRecordTypeQuery);
                        //if(opptyRecordTypes.isEmpty()) {
                        Integer opptyRecordTypes = Database.countQuery(opptyRecordTypeQuery);
                        if(opptyRecordTypes > 0) {

                                string OpptyRecordTypeIdQuery = 'SELECT count() FROM Opportunity WHERE RecordTypeId != Null LIMIT 1';

                                Integer opptyRecordtypesId = Database.countQuery(OpptyRecordTypeIdQuery);
                                if(opptyRecordtypesId > 0) {
                                    messages_yes.add('Opportunity record types');
                                    selectedValues.add('OpportunityRecordTypes');

                                    if (!isCustomReset)
                                    {
                                            variableSettings.add(new Map<string, object>{
                                              'name' => 'IncludeOpportunityRecordTypes',
                                              'value' => 'Yes'
                                            });

                                            // visibility
                                            variableSettings.add(new Map<string, object>{
                                              'name' => 'IncludeOpportunityRecordTypes_Visible',
                                              'value' => 'Selected'
                                            });
                                    }
                            }
                            else{
                                    messages_no.add('Opportunity record types');
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeOpportunityRecordTypes',
                                      'value' => 'No'
                                    });

                                    // visibility
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeOpportunityRecordTypes_Visible',
                                      'value' => 'Disabled'
                                    });

                            }

                        }
                        else{

                                messages_no.add('Opportunity record types');
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeOpportunityRecordTypes',
                                  'value' => 'No'
                                });

                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeOpportunityRecordTypes_Visible',
                                  'value' => 'Disabled'
                                });

                        }
                }
        catch (Exception e) { }
        //}
        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}

private static Map<String, Object> hasOpportunity(List<object> selectedValues,Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();
        //validate the product exists in the org
        // Schema.SObjectType targetTypeQ = Schema.getGlobalDescribe().get('Event');
        // if (targetTypeQ != null) {

                //string opportunityQuery = 'SELECT Id FROM Opportunity limit 2';
                string opportunityQuery = 'SELECT count() FROM Opportunity limit 1';
                try
                {
                          //List<Opportunity> Opptyrecords = Database.query(opportunityQuery);
                          //if (Opptyrecords.isEmpty()){
                          Integer Opptyrecords = Database.countQuery(opportunityQuery);
                          if (Opptyrecords == 0){
                                messages_no.add('Opportunity');
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeOpportunity',
                                  'value' => 'No'
                                });

                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeOpportunity_Visible',
                                  'value' => 'Disabled'
                                });
                        }
                        else{
                            messages_yes.add('Opportunity');
                            selectedValues.add('Opportunity');
                            if (!isCustomReset)
                             {
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeOpportunity',
                                      'value' => 'Yes'
                                    });


                                    // visibility
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeOpportunity_Visible',
                                      'value' => 'Selected'
                                    });
                            }
                        }
                }
        catch (Exception e) { }
    //    }
        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}

private static Map<String, Object> hasEvents(List<object> selectedValues,Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();
        //validate the product exists in the org
        Schema.SObjectType targetTypeQ = Schema.getGlobalDescribe().get('Event');
        if (targetTypeQ != null) {

                //string eventRecordsQuery = 'SELECT Id FROM Event limit 2';
                string eventRecordsQuery = 'SELECT count() FROM Event limit 1';

                try
                {
                        //List<Event> eventRecords = Database.query(eventRecordsQuery);
                        //if(eventRecords.isEmpty()) {
                        Integer eventRecords = Database.countQuery(eventRecordsQuery);
                        if(eventRecords == 0) {
                                messages_no.add('Events');
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeEvent',
                                  'value' => 'No'
                                });


                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeEvent_Visible',
                                  'value' => 'Disabled'
                                });
                        }
                        else{
                            messages_yes.add('Events');
                            selectedValues.add('Events');
                            if (!isCustomReset)
                            {
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeEvent',
                                      'value' => 'Yes'
                                    });

                                    // visibility
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeEvent_Visible',
                                      'value' => 'Selected'
                                    });
                            }
                        }
                }
        catch (Exception e) { }
        }
        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}

private static Map<String, Object> hasBusinessHours(List<object> selectedValues,Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();

                string businessHoursQuery = 'SELECT PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE SObjectType = \'case\' and Field = \'Case.BusinessHours\' and parentid in (select id from permissionset where PermissionSet.Profile.Name = \'Analytics Cloud Integration User\') limit 1';
                try
                {
                        List<FieldPermissions> permbh = Database.query(businessHoursQuery);
                        if (permbh.isEmpty()) {
                                messages_no.add('Business hours');
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeBusinessHours',
                                  'value' => 'No'
                                });

                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeBusinessHours_Visible',
                                  'value' => 'Disabled'
                                });
                        }
                        else{
                            messages_yes.add('Business hours');
                            selectedValues.add('BusinessHours');

                            if (!isCustomReset)
                            {
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeBusinessHours',
                                      'value' => 'Yes'
                                    });

                                    // visibility
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeBusinessHours_Visible',
                                      'value' => 'Selected'
                                    });
                            }
                        }
                }
        catch (Exception e) { }

        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}

private static Map<String, Object> hasTelephony(List<object> selectedValues,Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();

                //string telephonyQuery = 'SELECT Id FROM Task WHERE CallDurationInSeconds > 0 limit 2';
                string telephonyQuery = 'SELECT count() FROM Task WHERE CallDurationInSeconds > 0 limit 2';
                try
                {
                        //List<Task> tasktelephony = Database.query(telephonyQuery);
                        //if(tasktelephony.isEmpty()) {
                        Integer tasktelephony = Database.countQuery(telephonyQuery);
                        if(tasktelephony == 0) {
                                messages_no.add('Telephony');
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeTelephony',
                                  'value' => 'No'
                                });

                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeTelephony_Visible',
                                  'value' => 'Disabled'
                                });
                        }
                        else {
                            messages_yes.add('Telephony');
                            selectedValues.add('Telephony');
                            if (!isCustomReset)
                            {
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeTelephony',
                                      'value' => 'Yes'
                                    });


                                    // visibility
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeTelephony_Visible',
                                      'value' => 'Selected'
                                    });
                            }


                        }
                }
        catch (Exception e) { }

        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}


private static Map<String, Object> hasChat(List<object> selectedValues,Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();
        //validate the chat exists in the org
        Schema.SObjectType targetTypeQ = Schema.getGlobalDescribe().get('LiveChatTranscript');
        if (targetTypeQ != null) {


                string chatQuery = 'SELECT count() FROM LiveChatTranscript WHERE CaseId != null AND ChatDuration > 0 limit 1';
                try
                {
                        Integer chatrecords = Database.countQuery(chatQuery);
                        if(chatrecords == 0) {
                                messages_no.add('Live Agent chat');
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeChat',
                                  'value' => 'No'
                                });

                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeChat_Visible',
                                  'value' => 'Disabled'
                                });
                        }
                        else{
                            messages_yes.add('Live Agent chat');
                            selectedValues.add('Chat');

                            if (!isCustomReset)
                            {
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeChat',
                                      'value' => 'Yes'
                                    });

                                    // visibility
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeChat_Visible',
                                      'value' => 'Selected'
                                    });
                            }
                        }
                }
        catch (Exception e) { }
        }

        else{
            try{
                    messages_no.add('Live Agent chat');
                    variableSettings.add(new Map<string, object>{
                      'name' => 'IncludeChat',
                      'value' => 'No'
                    });


                    // visibility
                    variableSettings.add(new Map<string, object>{
                      'name' => 'IncludeChat_Visible',
                      'value' => 'Disabled'
                    });
            }
            catch (Exception e) { }
        }
        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}

private static Map<String, Object> hasOmni(List<object> selectedValues,Boolean isCustomReset)
{
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();
        List<Object> variableSettings = new List<Object>();
        //validate the chat exists in the org
        Schema.SObjectType targetTypeQ = Schema.getGlobalDescribe().get('AgentWork');
        if (targetTypeQ != null) {

                string omniQuery = 'SELECT count() FROM AgentWork limit 2';
                try
                {
                        Integer omniRecords = Database.countquery(omniQuery);
                        if(omniRecords == 0) {
                                messages_no.add('Omni Channel');
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeOmni',
                                  'value' => 'No'
                                });


                                // visibility
                                variableSettings.add(new Map<string, object>{
                                  'name' => 'IncludeOmni_Visible',
                                  'value' => 'Disabled'
                                });
                        }
                        else{
                            messages_yes.add('Omni Channel');
                            selectedValues.add('Omni');

                           if (!isCustomReset)
                             {
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeOmni',
                                      'value' => 'Yes'
                                    });


                                    // visibility
                                    variableSettings.add(new Map<string, object>{
                                      'name' => 'IncludeOmni_Visible',
                                      'value' => 'Selected'
                                    });
                            }
                        }
                }
        catch (Exception e) { }
        }

        else{
            try{
                    messages_no.add('Omni Channel');
                    variableSettings.add(new Map<string, object>{
                      'name' => 'IncludeOmni',
                      'value' => 'No'
                    });


                    // visibility
                    variableSettings.add(new Map<string, object>{
                      'name' => 'IncludeOmni_Visible',
                      'value' => 'Disabled'
                    });
            }
            catch (Exception e) { }
        }
        return new Map<String, Object>{
      'success' => true,
      'messages_no' => messages_no,
      'messages_yes' => messages_yes,
      'variableSettings' => variableSettings
    };
}


/*****2.Method to Autoscan and set fiscal******/
private static Map<String, Object> setFiscal()
{
        List<Object> variableSettings = new List<Object>();
        List<String> messages = new List<String>();
        //        String message = '';
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

                Map<Integer, string> month_for_infodisplay = new Map<Integer, string>{
                        1 => 'January',
                        2 => 'February',
                        3 => 'March',
                        4 => 'April',
                        5 => 'May',
                        6 => 'June',
                        7 => 'July',
                        8 => 'August',
                        9 => 'September',
                        10 => 'October',
                        11 => 'November',
                        12 => 'December'
                };

                String message = 'Fiscal start date set to ' + month_for_infodisplay.get(months) + ' based on your Salesforce settings. You can change the fiscal start date in custom create.';
                messages.add(message);
                //messages.add('Fiscal Month Set to January');

                variableSettings.add(new Map<string, object>{
                                'name' => 'Fiscal_Month',
                                'value' => a.get(months)
                        });

        }
        catch (Exception e)
        {
                //just in case

                String message = 'Fiscal start date set to January based on your Salesforce settings. You can change the fiscal start date in custom create.';
                messages.add(message);

                variableSettings.add(new Map<string, object>{
                                'name' => 'Fiscal_Month',
                                'value' => '01 - January'
                        });
        }
        return new Map<String, Object>{
                       'success' => true,
                       'messages' => messages,
                       'variableSettings' => variableSettings
        };
}

private static Map<String, Object> aggregateResults(List<Map<String, Object> > resultList,Boolean isCustomReset){

        Boolean allGood = true;
        List<Map<String, Object> > variableSettings = new List<Map<String, Object> >();
        List<String> messages = new List<String>();
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();

        // iterate over the results
        for (Map<String, Object> result: resultList) {
                // if one failed all failed
                if (!((boolean)result.get('success'))) {
                        allGood = false;
                }

                // aggregate the variable settings
                if (result.containsKey('variableSettings')) {
                        for (Object s: (List<Object>)result.get('variableSettings')) {
                                variableSettings.add((Map<String, Object>) s);
                        }
                }

                // and messages
                if (result.containsKey('messages_no')) {
                        messages_no.addAll((List<String>)result.get('messages_no'));
                }

                if (result.containsKey('messages_yes')) {
                        messages_yes.addAll((List<String>)result.get('messages_yes'));
                }
        }

        if(!messages_yes.isEmpty())
        {
                if (!isCustomReset){

                messages.add('Service Analytics has detected that the following features are available for your app. They’re automatically added if you use the basic create option. Choose the ones to add by using custom create.');
                }
                else{
                messages.add('Service Analytics has detected that the following features are available for your app.');

                }
                messages.addAll(messages_yes);
        }
        if(!messages_no.isEmpty())
        {
                messages.add('   ');
                messages.add('Service Analytics has detected that the following features are not available for your app.');
                messages.addAll(messages_no);
        }

        if (isCustomReset){
                messages.add('   ');
                messages.add('You’re reconfiguring or creating a copy of an app originally created with custom create. Service Analytics will reuse the settings from that app whereever possible.');
        }

        // aggregate the messages and variable settings
        return new Map<String, Object>{
                       'success' => allGood,
                       'messages' => messages,
                       'variableSettings' => variableSettings
        };
}




private static Map<String, Object> aggregateResults_CaseHistory(List<Map<String, Object> > resultList,Boolean isCustomReset){

        Boolean allGood = true;
        List<Map<String, Object> > variableSettings = new List<Map<String, Object> >();
        List<String> messages = new List<String>();
        List<String> messages_no = new List<String>();
        List<String> messages_yes = new List<String>();

        // iterate over the results
        for (Map<String, Object> result: resultList) {
                // if one failed all failed
                if (!((boolean)result.get('success'))) {
                        allGood = false;
                }

                // aggregate the variable settings
                if (result.containsKey('variableSettings')) {
                        for (Object s: (List<Object>)result.get('variableSettings')) {
                                variableSettings.add((Map<String, Object>) s);
                        }
                }

                // and messages
                if (result.containsKey('messages_no')) {
                        messages_no.addAll((List<String>)result.get('messages_no'));
                }

                if (result.containsKey('messages_yes')) {
                        messages_yes.addAll((List<String>)result.get('messages_yes'));
                }
        }

        if(!messages_yes.isEmpty())
        {
                if (!isCustomReset){

                messages.add('Service Analytics has detected that Case History is available for your app. It will be automatically added to your app if you use the basic create option. You can choose not to add it using custom create.');
                }
                else{
                messages.add('Service Analytics has detected that Case History is available for your app.');

                }
                //messages.addAll(messages_yes);
        }
        if(!messages_no.isEmpty())
        {
                messages.add('   ');
                messages.add('Service Analytics has detected that Case History is not available for your app.');
                //messages.addAll(messages_no);
        }

        if (isCustomReset){
                messages.add('   ');
                messages.add('You’re reconfiguring or creating a copy of an app originally created with custom create. Service Analytics will reuse the settings from that app whereever possible.');
        }

        // aggregate the messages and variable settings
        return new Map<String, Object>{
                       'success' => allGood,
                       'messages' => messages,
                       'variableSettings' => variableSettings
        };
}

private static Map<String, Object> setAdditionalObjectChoices(List<object> selectedValues, Boolean isCustomReset)
{

  List<String> messages = new List<String>();
  List<Object> variableSettings = new List<Object>();

  //System.debug('setAdditionalObjectChoices: ' + selectedValues);

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


@RemoteAction
global static Map<string, object> objectUsage(Boolean isCustomReset )
{
        //System.debug('isCustomReset : ' + isCustomReset);
        List<Map<String, Object> > resultList = new List<Map<String, Object> >();
        List<object> selectedValues = new List<object>();
        resultList.add(hasQueues(selectedValues,isCustomReset));
        //resultList.add(hasCaseHistory(selectedValues,isCustomReset));
        resultList.add(hasOpportunity(selectedValues,isCustomReset));
        resultList.add(hasEvents(selectedValues,isCustomReset));
        resultList.add(hasBusinessHours(selectedValues,isCustomReset));
        resultList.add(hasCaseRecordTypes(selectedValues,isCustomReset));
        resultList.add(hasOpportunityRecordTypes(selectedValues,isCustomReset));
        resultList.add(hasTelephony(selectedValues,isCustomReset));
        resultList.add(hasChat(selectedValues,isCustomReset));
        resultList.add(hasOmni(selectedValues,isCustomReset));

        //resultList.add(setAdditionalObjectChoices(selectedValues,isCustomReset));
        // aggregate results
        return aggregateResults(resultList,isCustomReset);

}

@RemoteAction
global static Map<string, object> fieldAccess(Boolean isCustomReset )
{
        List<String> messages = new List<String>();

        messages.add('Oh uh');
        Boolean success = true;

        return new Map<String, Object>{
                       'success' => success,
                       'messages' => messages
        };
}

@RemoteAction
global static Map<string, object> configuration(Boolean isCustomReset )
{

        return setFiscal();

}

@RemoteAction
global static Map<string, object> caseHistoryCheck(Boolean isCustomReset )
{
        // List<String> messages = new List<String>();
        // messages.add('Initial check and');
        // messages.add('configuration complete');

        List<Map<String, Object> > resultList = new List<Map<String, Object> >();
        List<object> selectedValues = new List<object>();
        resultList.add(hasCaseHistory(selectedValues,isCustomReset));



        return aggregateResults_CaseHistory(resultList,isCustomReset);



        //return new Map<String, Object>{
        //               'success' => true,
        //               'messages' => messages
        //};
}
}