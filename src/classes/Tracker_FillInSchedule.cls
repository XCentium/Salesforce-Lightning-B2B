global class Tracker_FillInSchedule 
{
    @InvocableMethod(label='Tracker - Send Fill-in Schedule Request')
    global static List<String> sendFIS(List<sendFISRequest> requests) 
    {
        List<String> results = new list<String>();
        try
        {
            for (sendFISRequest request : requests)
            {
                //Get the policy
                List<FSL__Scheduling_Policy__c> objPolicies = new List<FSL__Scheduling_Policy__c>([SELECT Id FROM FSL__Scheduling_Policy__c WHERE Name =: request.PolicyName LIMIT 1]);
                //Get the SR
                List<ServiceResource> lstSRs = new list<ServiceResource>([SELECT ID, RelatedRecordId FROM ServiceResource WHERE Tracker_Contact__c =: request.objContact.Id LIMIT 1]);
                
                if (objPolicies.size() > 0 && lstSRs.size() > 0)
                {
                    String result = FSL.FillInScheduleService.CallFillInBatch(Datetime.now(), lstSRs[0].Id, objPolicies[0].Id);
                }
                else
                {
                    results.add('Error: Could not find Scheduling policy or Service Resource.');
                }
            }
        }
        catch (Exception ex)
        {
            results.add(ex.getMessage());
        }
        return results;
    }
    
    global class sendFISRequest
    {
        @InvocableVariable(required=true)
        global String PolicyName;
        @InvocableVariable(required=true)
        global Contact objContact;
    }
}