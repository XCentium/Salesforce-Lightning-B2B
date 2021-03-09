public class QWhyNot implements Queueable
{
    private ServiceAppointment objSA;
    private Why_Not_Settings__mdt whynotSettings;
    private FSL__Scheduling_Policy__c objMainPolicy;
    private List<FSL__Scheduling_Policy__c> objPolicies;
    
    public QWhyNot(ServiceAppointment sa, FSL__Scheduling_Policy__c mp, List<FSL__Scheduling_Policy__c> polys, Why_Not_Settings__mdt settings)
    {
        objSA = sa;
        objMainPolicy = mp;
        objPolicies = polys;
        whynotSettings = settings;
    }
    
    public void execute(QueueableContext context) 
    {
        //first get number of slots for main scheduling policy
        //integer mainSlotCount = getSlotCount(objSA.ID, whynotSettings.Main_Policy_ID__c, opCalendar);
        List<Integer> mainOptionCount = getSchedulingOptions(objSA.Id, objMainPolicy.Id);
        
        objSA.Why_Not_Last_Run__c = Datetime.Now();
        objSA.Why_Not_Main_Count__c = mainOptionCount[0];
        objSA.Why_Not_Main_Candidates__c = mainOptionCount[1];
               
        for (FSL__Scheduling_Policy__c currentPolicy : objPolicies)
        {
            //Check for Availability Policy
            Boolean updateMade = false;
            if (String.IsNotBlank(whynotSettings.Availability_Policy_Label__c) && currentPolicy.Name == whynotSettings.Availability_Policy_Label__c && !objSA.FSL__Schedule_over_lower_priority_appointment__c)
            {
                objSA.FSL__Schedule_over_lower_priority_appointment__c = true;
                update objSA;
                updateMade = true;
            }
            List<Integer> optionCount = getSchedulingOptions(objSA.Id, currentPolicy.Id);
            
            //Cache the results
            if (String.IsNotBlank(whynotSettings.Alt_Policy_1_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Alt_Policy_1_Label__c.toLowerCase())
            {
                objSA.Why_Not_Alt1_Count__c = optionCount[0];
                objSA.Why_Not_Alt1_Candidates__c = optionCount[1];
            }
            else if (String.IsNotBlank(whynotSettings.Alt_Policy_2_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Alt_Policy_2_Label__c.toLowerCase())
            {
                objSA.Why_Not_Alt2_Count__c = optionCount[0];
                objSA.Why_Not_Alt2_Candidates__c = optionCount[1];
            }
            else if (String.IsNotBlank(whynotSettings.Alt_Policy_3_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Alt_Policy_3_Label__c.toLowerCase())
            {
                objSA.Why_Not_Alt3_Count__c = optionCount[0];
                objSA.Why_Not_Alt3_Candidates__c = optionCount[1];
            }
            else if (String.IsNotBlank(whynotSettings.Alt_Policy_4_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Alt_Policy_4_Label__c.toLowerCase())
            {
                objSA.Why_Not_Alt4_Count__c = optionCount[0];
                objSA.Why_Not_Alt4_Candidates__c = optionCount[1];
            }
            else if (String.IsNotBlank(whynotSettings.Availability_Policy_Label__c) && currentPolicy.Name.toLowerCase() == whynotSettings.Availability_Policy_Label__c.toLowerCase())
            {
                objSA.Why_Not_NoAvail_Count__c  = optionCount[0];
                objSA.Why_Not_NoAvail_Candidates__c = optionCount[1];
            }
            
            //See if we need to change back
            if (updateMade)
            {
                objSA.FSL__Schedule_over_lower_priority_appointment__c = false;
                update objSA;
            }
        }
        
        //Update the SA
        update objSA;
    }
    
    public List<Integer> getSchedulingOptions(Id objSAId, id policyID)
    {
        integer candidateCount = 0;
        integer slotCount = 0;
        
        // Generate the graded time slots for the service appointment
        FSL.GradeSlotsService mySlotService = new FSL.GradeSlotsService(policyID, objSAId);
        // Store the matrix of service resource id's and graded time slots
        FSL.AdvancedGapMatrix myResultMatrix = mySlotService.GetGradedMatrix(true);
        Map<Id,FSL.ResourceScheduleData> mySRGradedTimeSlotMap = myResultMatrix.ResourceIDToScheduleData;
        for (id thisresourceid : mySRGradedTimeSlotMap.keySet())
        {
            Boolean resourceAdd = false;
            for (FSL.SchedulingOption thisso : mySRGradedTimeSlotMap.get(thisresourceid).SchedulingOptions )
            {
                resourceAdd = true;
                slotCount++;
                //system.debug('***** Resource id' + thisresourceid);
                //system.debug('***** Start - ' + thisso.Interval.Start);
                //system.debug('***** Finish - ' + thisso.Interval.Finish);
                //system.debug('****** Grade - ' + thisso.Grade);
            }
            if (resourceAdd)
            {
                candidateCount++;
            }
        }
        
        List<Integer> lstResults = new List<Integer>();
        lstResults.add(slotCount);
        lstResults.add(candidateCount);
        
        return lstResults;
    }
    
     public integer getSlotCount(id objSAID, id policyID, OperatingHours opCalendar)
    {
        List<FSL.AppointmentBookingSlot> mySlots;
        mySlots = FSL.AppointmentBookingService.GetSlots(objSAID, policyID, opCalendar, UserInfo.getTimeZone(), 'Grade', false);
        return mySlots.size();
    }
    
}