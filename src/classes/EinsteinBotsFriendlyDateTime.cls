global class EinsteinBotsFriendlyDateTime 
{
    @InvocableMethod(label='Einstein Bots - Friendly DateTime' description='Returns a formatted string from the specified UTC')
    global static List<String> getDT(List<formatDTRequest> requests) 
    {
        string returnVar = '';
        
        for (formatDTRequest request : requests)
        {
            if (request.dtInputDateTime != null)
            {
                if (String.isNotBlank(request.TimeZoneCode) && String.isNotBlank(request.formatString))
                {
                    returnVar = request.dtInputDateTime.format(request.formatString, request.TimeZoneCode);
                }
                else if (String.isNotBlank(request.TimeZoneCode))
                {
                    returnVar = request.dtInputDateTime.format('EEE MMM d h:mmaaa', request.TimeZoneCode);
                }
                else if (String.isNotBlank(request.formatString))
                {
                    returnVar = request.dtInputDateTime.formatGmt(request.formatString);
                }
            }
        }
        
        return new List<String>{returnVar};
    }
    
    global class formatDTRequest
    {
        @InvocableVariable(required=true)
        global Datetime dtInputDateTime;
        @InvocableVariable(required=false)
        global String TimeZoneCode;
        @InvocableVariable(required=false)
        global String formatString;
    }
}