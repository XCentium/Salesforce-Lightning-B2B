@isTest
private class Rider_Tests 
{
    static testMethod void validateGenerateServiceReport() 
    {
        //Insert an account
        Account objAccount = new Account();
        objAccount.Name = 'test account';
        INSERT objAccount;
        
        //Insert a Service Appointment
        ServiceAppointment objSA = new ServiceAppointment();
        objsa.EarliestStartTime = datetime.now();
        objSA.DueDate = datetime.now().adddays(7);
        objSA.ParentRecordId = objAccount.Id;
        objSA.Subject = 'test sa';
        objSA.Duration = 1;
        objSA.DurationType = 'Hours';
        objSA.Status = 'None';
        INSERT objSA;
        
        List<String> objStrings = Rider_GenerateServiceReportURL.getURL(new List<String>{objSA.Id});
        // Assert it is blank
        System.assertEquals('', objStrings[0]);
        
        //Insert a template
        ServiceReportLayout objTemplate = [SELECT Id FROM ServiceReportLayout LIMIT 1];
        
        //Now insert a service report
        ServiceReport objSReport = new ServiceReport();
        objSReport.ParentId = objSA.Id;
        objSReport.DocumentBody = Blob.valueOf('hwerhrwewrj');
        objSReport.DocumentContentType = 'image/png';
        objSReport.DocumentName = 'Service Report';
        objSReport.IsSigned = false;
        objSReport.ServiceReportLanguage = 'en_US';
        objSReport.Template = objTemplate.Id;
        Insert objSReport;
        
        //Now run again
        objStrings = Rider_GenerateServiceReportURL.getURL(new List<String>{objSA.Id});
        // Assert it is blank
        System.assertNotEquals('', objStrings[0]);
        
        //Now run again to verify report already exists
        objStrings = Rider_GenerateServiceReportURL.getURL(new List<String>{objSA.Id});
    }
    
    static testMethod void validateGetSlotsAndSchedule()
    {
        system.runAs(getTestUser())
        {
            //Insert an account
            Account objAccount = new Account();
            objAccount.Name = 'test account';
            INSERT objAccount;
            
            //Insert operating hours
            OperatingHours objOH = new OperatingHours();
            objOH.Name = 'test OH';
            objOH.TimeZone = 'America/Los_Angeles';
            INSERT objOH;
            
            //Insert TimeSlots
            List<TimeSlot> objTimeSlots = new List<TimeSlot>();
            List<String> daysofWeek = (new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'});
            for (string dayofweek : daysofWeek)
            {
                TimeSlot currTS = new TimeSlot();
                currTS.DayOfWeek = dayofweek;
                currTS.StartTime = Time.newInstance(9, 0, 0, 0);
                currTS.EndTime = Time.newInstance(18, 0, 0, 0);
                currTs.OperatingHoursId = objOH.Id;
                currTS.Type = 'Normal';
                objTimeSlots.add(currTS);
            }
            INSERT objTimeSlots;
            
            //Insert ST
            ServiceTerritory objT = new ServiceTerritory();
            objT.Name = 'test terr';
            objT.OperatingHoursId = objOH.id;
            objT.IsActive = true;
            insert objT;
            
            //Insert a Service Appointment
            ServiceAppointment objSA = new ServiceAppointment();
            objsa.EarliestStartTime = datetime.now();
            objSA.DueDate = datetime.now().adddays(7);
            objSA.ParentRecordId = objAccount.Id;
            objSA.Subject = 'test sa';
            objSA.Duration = 1;
            objSA.DurationType = 'Hours';
            objSA.Status = 'None';
            objSA.ServiceTerritoryId = objT.id;
            INSERT objSA;
            
            
            //Insert the contact
            Contact objContact = new Contact();
            objContact.LastName = 'Rider';
            objContact.AccountId = objAccount.Id;
            objContact.Rider_ServiceTerritory__c = objT.Id;
            INSERT objContact;
            
            //Insert Resource
            ServiceResource objSR = new ServiceResource();
            objSR.Name = 'Test Resource';
            objSR.ResourceType = 'T';
            objSR.IsActive = true;
            objSR.RelatedRecordId = UserInfo.getUserId();
            Insert objSR;
            
            //Insert STM
            ServiceTerritoryMember objSTM = new ServiceTerritoryMember();
            objSTM.ServiceResourceId = objSR.Id;
            objSTM.ServiceTerritoryId = objT.Id;
            objSTM.TerritoryType = 'P';
            objSTM.EffectiveStartDate = datetime.now();
            INSERT objSTM;
            
            //Now Get slots
            Rider_GetSlots.getSlotsActionRequest objRequest = new Rider_GetSlots.getSlotsActionRequest();
            objRequest.objContact = objContact;
            objRequest.objSA = objSA;
            objRequest.strOperatingHrs = objOH.Name;
            objRequest.strSchedulingPolicy = null;
            List<List<Event>> objSlots = Rider_GetSlots.getSlots(new List<Rider_GetSlots.getSlotsActionRequest>{objRequest});
            
            // Assert it is blank
            System.assertNotEquals(null, objSlots);
            System.assertNotEquals(0, objSlots[0].size());
            
            //Now test scheduling them
            List<Rider_ScheduleSA.scheduleSAActionRequest> schedRequests = new List<Rider_ScheduleSA.scheduleSAActionRequest>();
            Rider_ScheduleSA.scheduleSAActionRequest schedRequest = new Rider_ScheduleSA.scheduleSAActionRequest();
            schedRequest.objContact = objContact;
            schedRequest.objSA = objSA;
            
            //First schedule without policy
            schedRequests.add(schedRequest);
            List<Rider_ScheduleSA.scheduleSAActionResponse> schedResponses = Rider_ScheduleSA.scheduleSA(schedRequests);
            
            //verify error
            System.assertNotEquals('', schedResponses[0].strError);
            
            //Next schedule without a time
            schedRequests.clear();
            schedRequest.strSchedulingPolicy = null;
            schedRequests.add(schedRequest);
            schedResponses = Rider_ScheduleSA.scheduleSA(schedRequests);
            
            //verify error
            System.assertNotEquals('', schedResponses[0].strError);
            
            //Now try with Invalid slot
            schedRequests.clear(); 
            schedRequest.nlpStart = Datetime.now().addyears(-2000);
            schedRequests.add(schedRequest);
            schedResponses = Rider_ScheduleSA.scheduleSA(schedRequests);
            
            //verify error
            System.assertNotEquals('', schedResponses[0].strError);
            
            schedRequests.clear();
            schedRequest.nlpStart = null;
            
            schedRequest.objSlot = objSlots[0][0];
            schedRequests.add(schedRequest);
            schedResponses = Rider_ScheduleSA.scheduleSA(schedRequests);
            
            //Verify error (not actually scheduling)
            System.assertNotEquals(null, schedResponses[0].strError);
            
            //Now test the start time display string
            List<Rider_UpdateDisplayStartTime.updateDisplayStartTimeRequest> dtRequests = new List<Rider_UpdateDisplayStartTime.updateDisplayStartTimeRequest>();
            Rider_UpdateDisplayStartTime.updateDisplayStartTimeRequest dtRequest = new Rider_UpdateDisplayStartTime.updateDisplayStartTimeRequest();
            dtRequest.saID = objSA.Id;
            dtRequest.starttime = objSlots[0][0].StartDateTime;
            dtRequest.territoryId = objSA.ServiceTerritoryId;
            dtRequest.contactId = objContact.Id;
            dtRequests.add(dtRequest);
            
            List<String> dtResult = Rider_UpdateDisplayStartTime.updateDisplayStartTime(dtRequests);
        }
    }
    
    static testMethod void validateGetAppointmentStatus()
    {
        system.runAs(getTestUser())
        {
            
            //Insert an account
            Account objAccount = new Account();
            objAccount.Name = 'test account';
            INSERT objAccount;
            
            //Insert a Service Appointment
            ServiceAppointment objSA = new ServiceAppointment();
            objsa.EarliestStartTime = datetime.now();
            objSA.DueDate = datetime.now().adddays(7);
            objSA.ParentRecordId = objAccount.Id;
            objSA.Subject = 'test sa';
            objSA.Duration = 1;
            objSA.DurationType = 'Hours';
            objSA.Status = 'None';
            INSERT objSA;
            
            //Get operating hours
            OperatingHours objOH = new OperatingHours();
            objOH.Name = 'test OH';
            objOH.TimeZone = 'America/Los_Angeles';
            INSERT objOH;
            
            //Insert TimeSlots
            List<TimeSlot> objTimeSlots = new List<TimeSlot>();
            List<String> daysofWeek = (new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'});
            for (string dayofweek : daysofWeek)
            {
                TimeSlot currTS = new TimeSlot();
                currTS.DayOfWeek = dayofweek;
                currTS.StartTime = Time.newInstance(9, 0, 0, 0);
                currTS.EndTime = Time.newInstance(18, 0, 0, 0);
                currTs.OperatingHoursId = objOH.Id;
                currTS.Type = 'Normal';
                objTimeSlots.add(currTS);
            }
            INSERT objTimeSlots;
            
            
            //Insert ST
            ServiceTerritory objT = new ServiceTerritory();
            objT.Name = 'test terr';
            objT.OperatingHoursId = objOH.id;
            objT.IsActive = true;
            insert objT;
            
            //Insert the contact
            Contact objContact = new Contact();
            objContact.LastName = 'Rider';
            objContact.AccountId = objAccount.Id;
            objContact.Rider_ServiceTerritory__c = objT.Id;
            INSERT objContact;
            
            //Insert Messaging template
            MessagingTemplate objMT = new MessagingTemplate();
            objMT.MasterLabel = 'testMT';
            objMT.DeveloperName = 'testMT';
            objMT.Message = '{!ServiceAppointment.Subject}{!ServiceAppointment.DueDate}';
            //INSERT objMT;
            
            List<Rider_GetAppointmentStatus.getStatusDialogRequest> apptStatusrequests = new List<Rider_GetAppointmentStatus.getStatusDialogRequest>();
            Rider_GetAppointmentStatus.getStatusDialogRequest apptStatusrequest = new Rider_GetAppointmentStatus.getStatusDialogRequest();
            apptStatusrequest.MessagingTemplate_DeveloperName = objMT.DeveloperName;
            apptStatusrequest.objContact = objContact;
            apptStatusrequest.objSA = objSA;
            apptStatusrequests.add(apptStatusrequest);
            
            List<Rider_GetAppointmentStatus.getStatusDialogResult> objResults = Rider_GetAppointmentStatus.getStatusDialog(apptStatusrequests);
            
            //verify error because i can't insert the messaging template
            System.assert(String.isNotBlank(objResults[0].strError));
            //System.assert(objResults[0].strStatus.contains('test sa'));
        }
        
        
    }
    
    static testMethod void validatePostInstallScript()
    {
        Rider_PostInstallScript postinstall = new Rider_PostInstallScript();
        postinstall.onInstall(null);
    }
    
    static User getTestUser()
    {
        //Insert user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        string username = 'testuser@rider-' + Datetime.now().getTime() + '.com';
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName=username);
        INSERT u2;
        List<PermissionSetLicense> objLicenses = new List<PermissionSetLicense>([SELECT ID FROM PermissionSetLicense WHERE DeveloperName =: 'FieldServiceStandardPsl' OR DeveloperName =: 'FieldServiceSchedulingPsl']);
        List<PermissionSetLicenseAssign> objAssigns = new List<PermissionSetLicenseAssign>();
        for (PermissionSetLicense currentLicense : objLicenses)
        {
            PermissionSetLicenseAssign newAssign = new PermissionSetLicenseAssign();
            newAssign.AssigneeId = u2.id;
        	newAssign.PermissionSetLicenseId = currentLicense.Id;
            objAssigns.add(newAssign);
        }
        INSERT objAssigns;
        
        List<PermissionSet> objPermSets = new List<PermissionSet>([SELECT ID FROM PermissionSet WHERE Name =: 'FSL_Resource_Permissions' OR Name =: 'FSL_Resource_License']);
        List<PermissionSetAssignment> objPermSetsAssign = new List<PermissionSetAssignment>();
        for (PermissionSet currentPerm : objPermSets)
        {
            PermissionSetAssignment newAssign = new PermissionSetAssignment();
            newAssign.AssigneeId = u2.id;
            newAssign.PermissionSetId = currentPerm.Id;
            objPermSetsAssign.add(newAssign);
        }
        INSERT objPermSetsAssign;
        
        Return u2;
    }
}