public class ctr_WhyNot
{
    public String scheduledStatus {get; set;}
    public String strCommResponse {get; set;}
    public string iconCheckBig = '<span class="slds-icon_container slds-icon-action-approval" style="margin-right:10px;"> <svg aria-hidden="true" class="slds-icon  slds-icon_large"> <use href="/_slds/icons/action-sprite/svg/symbols.svg#approval"></use></svg> </span>';
    public string iconCrossBig = '<span class="slds-icon_container slds-icon-action-close" style="margin-right:10px;"> <svg aria-hidden="true" class="slds-icon slds-icon_large"> <use href="/_slds/icons/action-sprite/svg/symbols.svg#close"></use></svg> </span>';
    public string iconCheck = '<span class="slds-icon_container slds-icon-action-approval" style="padding:.25rem;"> <svg aria-hidden="true" style="width:1.25rem;height:1.25rem" class="slds-icon  slds-icon_small"> <use href="/_slds/icons/action-sprite/svg/symbols.svg#approval"></use></svg> </span>';
    public string iconCross = '<span class="slds-icon_container slds-icon-action-close" style="padding:.25rem;"> <svg aria-hidden="true" style="width:1.25rem;height:1.25rem" class="slds-icon slds-icon_small"> <use href="/_slds/icons/action-sprite/svg/symbols.svg#close"></use></svg> </span>';
    public WorkOrder objWO {get; set;}
    public ServiceAppointment objSA {get; set;}
    public Why_Not_Settings__mdt whynotSettings {get; set;}
    FSL__Scheduling_Policy__c objMainPolicy {get; set;}
    List<FSL__Scheduling_Policy__c> objPolicies {get; set;}
        
    public Boolean isRunning {get; set;}
    public Boolean blTimer {get; set;}
    
    public ctr_WhyNot(ApexPages.StandardController stdController)
    {
        isRunning = false;
        blTimer = false;
        List<Why_Not_Settings__mdt> lstSettings = [SELECT ID, Main_Policy_Label__c, Availability_Policy_Label__c, Alt_Policy_1_Label__c, Alt_Policy_2_Label__c, Alt_Policy_3_Label__c, Alt_Policy_4_Label__c FROM Why_Not_Settings__mdt LIMIT 1];
        if (lstSettings == null || lstSettings.size() != 1 || String.isBlank(lstSettings[0].Main_Policy_Label__c))
        {
            System.debug('WhyNot: Couldnt find valid settings...');
            scheduledStatus = 'Error';
            return;
        }
        whynotSettings = lstSettings[0];
        
        Schema.sObjectType entityType = stdController.getRecord().Id.getSObjectType();
        if (entityType == WorkOrder.sObjectType)
        {
            objWO = (WorkOrder)stdController.getRecord();
            if (objWO == null || objWO.id ==null || ([SELECT ID FROM ServiceAppointment WHERE ParentRecordId =: objWO.ID LIMIT 1]).size() == 0)
            {
                scheduledStatus = 'Error';
                return;
            }
            objSA = [SELECT ID FROM ServiceAppointment WHERE ParentRecordId =: objWO.ID LIMIT 1];
        }
        else if (entityType == ServiceAppointment.sObjectType)
        {
            objSA = [SELECT ID FROM ServiceAppointment WHERE Id =: stdController.getRecord().Id LIMIT 1];
        }
        else
        {
            scheduledStatus = 'Error';
            return;
        }
        
        //Get all the scheduling policies
        List<String> objPolicyNames = new List<String>();
        if (String.isNotBlank(whynotSettings.Alt_Policy_1_Label__c))
        {
            objPolicyNames.add(whynotSettings.Alt_Policy_1_Label__c);
        }
        if (String.isNotBlank(whynotSettings.Alt_Policy_2_Label__c))
        {
            objPolicyNames.add(whynotSettings.Alt_Policy_2_Label__c);
        }
        if (String.isNotBlank(whynotSettings.Alt_Policy_3_Label__c))
        {
            objPolicyNames.add(whynotSettings.Alt_Policy_3_Label__c);
        }
        if (String.isNotBlank(whynotSettings.Alt_Policy_4_Label__c))
        {
            objPolicyNames.add(whynotSettings.Alt_Policy_4_Label__c);
        }
        if (String.isNotBlank(whynotSettings.Availability_Policy_Label__c))
        {
            objPolicyNames.add(whynotSettings.Availability_Policy_Label__c);
        }
        objMainPolicy = [SELECT ID, Name FROM FSL__Scheduling_Policy__c WHERE Name =: whynotSettings.Main_Policy_Label__c LIMIT 1];
        if (objMainPolicy == null)
        {
            scheduledStatus = 'Error. Could Not find main policy.';
            return;
        }
        if (objPolicyNames.size() > 0)
        {
            objPolicies = new List<FSL__Scheduling_Policy__c>([SELECT ID, Name FROM FSL__Scheduling_Policy__c WHERE Name IN: objPolicyNames]);
        }
        
        this.refreshSA();
    }
    
    public void refreshSA()
    {
        objSA = [SELECT ID, Status, StatusCategory, FSL__Schedule_over_lower_priority_appointment__c, Why_Not_Last_Run__c, Why_Not_Main_Count__c, Why_Not_Main_Candidates__c, Why_Not_Alt1_Count__c, Why_Not_Alt2_Count__c, Why_Not_Alt3_Count__c, Why_Not_Alt4_Count__c, Why_Not_Alt1_Candidates__c, Why_Not_Alt2_Candidates__c, Why_Not_Alt3_Candidates__c, Why_Not_Alt4_Candidates__c, Why_Not_NoAvail_Count__c, Why_Not_NoAvail_Candidates__c FROM ServiceAppointment WHERE Id =: objSA.Id LIMIT 1];
        
        if (!isRunning && objSA.Why_Not_Last_Run__c == null)
        {
            //Else get the status of the WorkOrder
            if (objSA.StatusCategory == 'None' || objSA.StatusCategory == 'Canceled')
            {
                scheduledStatus = iconCrossBig + '<br />Not Scheduled';
            }
            else
            {
                scheduledStatus = iconCheckBig + '<br />Scheduled';
            }
        }
        
        if (!isRunning && String.IsNotBlank(strCommResponse))
        {
            blTimer = false;
            return;
        }
        
        if (objSA.Why_Not_Last_Run__c != null)
        {
            isRunning = false;
            scheduledStatus = '';
            //Display the results
            string strMainSlot = '<tr style="vertical-align:middle;"><td>' + (objSA.Why_Not_Main_Count__c > 0 ? iconCheckBig : iconCrossBig) + '</td><td>' + objMainPolicy.Name + ': With the \'' + objMainPolicy.Name + '\' policy, this Service Appointment <strong>' + (objSA.Why_Not_Main_Count__c > 0 ? 'CAN' : 'CANNOT') +
                '</strong> be scheduled' + (objSA.Why_Not_Main_Count__c > 0 ? ' with <strong>' + objSA.Why_Not_Main_Count__c + '</strong> scheduling option(s) across <strong>' + objSA.Why_Not_Main_Candidates__c + '</strong> candidate(s).' : '.') + '</td></tr><tr><td colspan="2"><hr style="color:#000000;margin-top:15px;margin-bottom:15px;"></td></tr>';
            
            List<ScheduleOptions> altPolicies = new List<ScheduleOptions>();
            for (FSL__Scheduling_Policy__c currentPolicy : objPolicies)
            {
                Decimal altOptionCount = 0;
                Decimal altCandidateCount = 0;
                if (String.IsNotBlank(whynotSettings.Alt_Policy_1_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Alt_Policy_1_Label__c.toLowerCase())
                {
                    altOptionCount = objSA.Why_Not_Alt1_Count__c;
                    altCandidateCount = objSA.Why_Not_Alt1_Candidates__c;
                }
                else if (String.IsNotBlank(whynotSettings.Alt_Policy_2_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Alt_Policy_2_Label__c.toLowerCase())
                {
                    altOptionCount = objSA.Why_Not_Alt2_Count__c;
                    altCandidateCount = objSA.Why_Not_Alt2_Candidates__c;
                }
                else if (String.IsNotBlank(whynotSettings.Alt_Policy_3_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Alt_Policy_3_Label__c.toLowerCase())
                {
                    altOptionCount = objSA.Why_Not_Alt3_Count__c;
                    altCandidateCount = objSA.Why_Not_Alt3_Candidates__c;
                }
                else if (String.IsNotBlank(whynotSettings.Alt_Policy_4_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Alt_Policy_4_Label__c.toLowerCase())
                {
                    altOptionCount = objSA.Why_Not_Alt4_Count__c;
                    altCandidateCount = objSA.Why_Not_Alt4_Candidates__c;
                }
                else if (String.IsNotBlank(whynotSettings.Availability_Policy_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Availability_Policy_Label__c.toLowerCase())
                {
                    altOptionCount = objSA.Why_Not_NoAvail_Count__c;
                    altCandidateCount = objSA.Why_Not_NoAvail_Candidates__c;
                }
                altPolicies.add(new ScheduleOptions(currentPolicy.Name, Integer.ValueOf(altOptionCount), Integer.ValueOf(objSA.Why_Not_Main_Count__c), Integer.ValueOf(altCandidateCount), Integer.ValueOf(objSA.Why_Not_Main_Candidates__c)));
            }
            
            altPolicies.sort();
            string strAltOptions = '';
            for (ScheduleOptions currentOption : altPolicies)
            {
                strAltOptions += currentOption.GetOutputString(iconCheck, iconCross);
            }
            
            strCommResponse = '<table>' +
                strMainSlot + strAltOptions + '<tr><td style="text-align:center;" colspan="2"><br/ >Last Updated: ' + objSA.Why_Not_Last_Run__c.format('MMM d, yyyy    h:mm a') + '</td></tr></table>';
        }
    }
    
    public void WhyNot()
    {
        //Clear the values and run....
        objSA.Why_Not_Last_Run__c = null;
        objSA.Why_Not_Main_Count__c = -1;
        objSA.Why_Not_Main_Candidates__c = 0;
        objSA.Why_Not_Alt1_Count__c = 0;
        objSA.Why_Not_Alt2_Count__c = 0;
        objSA.Why_Not_Alt3_Count__c = 0;
        objSA.Why_Not_Alt4_Count__c = 0;
        objSA.Why_Not_Alt1_Candidates__c = 0;
        objSA.Why_Not_Alt2_Candidates__c = 0;
        objSA.Why_Not_Alt3_Candidates__c = 0;
        objSA.Why_Not_Alt4_Candidates__c = 0;
        UPDATE objSA;

        IsRunning = true;
        blTimer = true;
        
        QWhyNot objQWhyNote = new QWhyNot(objSA, objMainPolicy, objPolicies, whynotSettings);
        System.enqueueJob(objQWhyNote);

    } 
}