global class Rider_GetAppointmentStatus 
{
    @InvocableMethod(label='Rider - Get Appointment Status')
    global static List<getStatusDialogResult> getStatusDialog(List<getStatusDialogRequest> requests) 
    {
        List<getStatusDialogResult> results = new List<getStatusDialogResult>();
        getStatusDialogResult result = new getStatusDialogResult();
        
        try
        {
            //First figure out the TZ
            //Default to user's TZ
            TimeZone tz = UserInfo.getTimeZone(); //TimeZone.getTimeZone('America/Los_Angeles');
            
            for (getStatusDialogRequest request : requests)
            {
                if (request != null && String.IsNotBlank(request.MessagingTemplate_DeveloperName) && request.objSA != null)
                {
                    //See if we can get the contact's tz from service territory
                    if (request.objContact != null && request.objContact.Rider_ServiceTerritory__c != null)
                    {
                        //Get service Territory TimeZone
                        List<ServiceTerritory> objSTs = new List<ServiceTerritory>([SELECT ID, OperatingHours.TimeZone FROM ServiceTerritory WHERE ID =: request.objContact.Rider_ServiceTerritory__c LIMIT 1]);
                        if (objSTs.size() > 0 && String.isNotBlank(objSTs[0].OperatingHours.TimeZone))
                        {
                            tz = Timezone.getTimeZone(objSTs[0].OperatingHours.TimeZone);
                        }
                    }
                    
                    //Get all the fields for the SA
                    string SAFields = '';
                    String SAID = request.objSA.Id;
                    Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('ServiceAppointment').getDescribe().fields.getMap();
                    for( integer i=0; i < mfields.values().size()-1; i++ )
                    {
                        SAFields += mfields.values()[i].getDescribe().getName() + ', ';
                    }
                    SAFields += mfields.values()[ mfields.values().size() - 1 ].getDescribe().getName();
                    List<ServiceAppointment> objSAs = database.query('SELECT ' + SAFields + ' FROM ServiceAppointment WHERE ID=: SAID');
                    
                    if (objSAs != null && objSAs.size() > 0)
                    {
                        ServiceAppointment sObj = objSAs[0];
                        result.strApptStatus = String.valueOf(sObj.get('Status'));

                        //Get Message Template 
                        List<MessagingTemplate> objTemplates = [SELECT Id, Message FROM MessagingTemplate WHERE DeveloperName =: request.MessagingTemplate_DeveloperName LIMIT 1];
                        if (objTemplates != null && objTemplates.size() > 0)
                        {
                            result.strStatus = objTemplates[0].Message;
                            
                            for (SObjectField field: mfields.values()) 
                            {
                                // Passed in object has the field
                                string fieldName = field.getDescribe().getName();
                                
                                try
                                {
                                    Schema.DisplayType fieldType = field.getDescribe().getType();
                                    string matchString = '{!' + sObj.getSobjectType().getDescribe().getName() + '.' + fieldName + '}';
                                    if (sObj.get(fieldName) == null)
                                    {
                                        result.strStatus = result.strStatus.replace(matchString, '');
                                    }
                                    else if (fieldType == Schema.DisplayType.DATETIME)
                                    {
                                        system.debug('formatting to tz: ' + tz.getDisplayName());
                                        result.strStatus = result.strStatus.replace(matchString, ((datetime)sObj.get(fieldName)).format('EEE MMM d h:mmaaa', tz.getID()));
                                    }
                                    else
                                    {
                                        //system.debug('fieldNameeee '+fieldName);
                                        result.strStatus = result.strStatus.replace(matchString, String.valueOf(sObj.get(fieldName)));
                                    }           
                                }
                                catch (Exception ex)
                                {
                                    
                                }
                            }
                        }
                        else
                        {
                            result.strError = 'Error fetching Messaging Template. Ensure to use a valid developername';
                        }
                    }
                    else
                    {
                        result.strError = 'Cannot find Appointment details';
                    }
                }
                else
                {
                    result.strError = 'Invalid input to get status';
                }
            }
        }
        catch (Exception ex)
        {
            result.strError = ex.getMessage();
        }
        
        results.add(result);
        return results;
    }
    
    global class getStatusDialogResult
    {
        @InvocableVariable(required=false)
        global string strApptStatus;
        @InvocableVariable(required=false)
        global string strStatus;
        @InvocableVariable(required=false)
        global String strError;
    }
    
    global class getStatusDialogRequest
    {
        @InvocableVariable(required=false)
        global Contact objContact;
        @InvocableVariable(required=false)
        global ServiceAppointment objSA;
        @InvocableVariable(required=false)
        global String MessagingTemplate_DeveloperName;
    }
}