global class Tracker_ConvertDT 
{
    @InvocableMethod(label='Tracker - Convert DT')
    global static List<convertDTResponse> convertDT(List<convertDTRequest> requests)
    {
        List<convertDTResponse> results = new List<convertDTResponse>();
        try
        {
            for (convertDTRequest request : requests)
            {
                //Get timezone of runing user
                TimeZone tz = UserInfo.getTimeZone();
                
                //See if we can get the contact's tz from service territory
                if (request.territoryId != null)
                {
                    //Get service Territory TimeZone
                    List<ServiceTerritory> objSTs = new List<ServiceTerritory>([SELECT ID, OperatingHours.TimeZone FROM ServiceTerritory WHERE ID =: request.territoryId LIMIT 1]);
                    if (objSTs.size() > 0 && String.isNotBlank(objSTs[0].OperatingHours.TimeZone))
                    {
                        tz = Timezone.getTimeZone(objSTs[0].OperatingHours.TimeZone);
                    }
                }
                convertDTResponse result = new convertDTResponse();
                result.outDT = request.inDT.addseconds(tz.getOffset(request.inDT)/-1000);
                result.displayText = request.inDT.formatGMT('EEE MMM d h:mmaaa');
                results.add(result);
            }
        }
        catch (Exception ex)
        {
            
        }
        return results;
    }
    
    global class convertDTResponse
    {
        @InvocableVariable(required=false)
        global String displayText;
        @InvocableVariable(required=false)
        global Datetime outDT;
    }
    
    global class convertDTRequest
    {
        @InvocableVariable(required=false)
        global Id territoryId;
        @InvocableVariable(required=false)
        global Datetime inDT;
    }
}