global class Tracker_GetFirstLastMonth 
{
    @InvocableMethod(label='Tracker - Get First and Last of Month')
    global static List<getFLMonthActionResponse> getChosenSlots()
    {
        List<getFLMonthActionResponse> results = new List<getFLMonthActionResponse>();
        getFLMonthActionResponse result = new getFLMonthActionResponse();
        result.firstofMonth = date.today().tostartofmonth();
        result.lastofMonth = date.today().toStartofMonth().addMonths(1).addDays(-1);
        results.add(result);
        return results;
    }
    
    global class getFLMonthActionResponse
    {
        @InvocableVariable(required=false)
        global date firstofMonth;
        @InvocableVariable(required=false)
        global date lastofMonth;
    }
}