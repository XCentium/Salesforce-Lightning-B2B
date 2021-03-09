global class EinsteinChatbotsFindServiceResource
{
    @InvocableMethod(label='Einstein Chatbots - Find Service Resource' description='Returns a list of Service Resources')
    global static List<getSRActionResult> getSR(List<ServiceAppointment> requests) 
    {
        List<getSRActionResult> results = new List<getSRActionResult>();
        For (ServiceAppointment objSA : requests)
        {
            if (objSA != null && String.IsNotBlank(objSA.Id))
            {
                getSRActionResult result = new getSRActionResult();
                //Try to get the Assigned Resource
                List<AssignedResource> objAssResources = [SELECT ID, ServiceResourceId, EstimatedTravelTime FROM AssignedResource WHERE ServiceAppointmentId =: objSA.Id LIMIT 1];
                if (objAssResources != null && objAssResources.size() > 0 && objAssResources[0].ServiceResourceId != null)
                {
                    result.objAssignedUser = objAssResources[0];
                    
                    //Try to get the Service Resource
                    List<ServiceResource> objsResources = [SELECT ID, ResourceType, RelatedRecordId FROM ServiceResource WHERE Id =: objAssResources[0].ServiceResourceId LIMIT 1];
                    if (objsResources != null && objsResources.size() > 0)
                    {
                        result.objServiceResource = objsResources[0];
                        
                        //Try to get the User
                        List<User> objUsers = [SELECT ID, Name, FirstName, LastName, Phone FROM User WHERE Id =: objsResources[0].RelatedRecordId LIMIT 1];
                        if (objUsers != null && objUsers.size() > 0)
                        {
                            result.objUser = objUsers[0];
                            results.add(result);
                            return results; 
                        }
                    }
                }
            }
            break;
        }
        
        return new List<getSRActionResult>{new getSRActionResult()};
    }
    
    global class getSRActionResult
    {
        @InvocableVariable(required=true)
        global AssignedResource objAssignedUser;
        @InvocableVariable(required=true)
        global ServiceResource objServiceResource;
        @InvocableVariable(required=true)
        global User objUser;
    }
}