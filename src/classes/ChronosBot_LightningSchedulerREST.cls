global with sharing class ChronosBot_LightningSchedulerREST {
	public static List<Event> getSlots(String workTypeId,String accountId,String territoryId,String resourceId,String clientId,String clientSecret,Integer slots,String contactId)
    {
        Integer counter=0;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Lightning_Scheduler_API_User/services/oauth2/token');
        req.setMethod('POST');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username={!$Credential.Username}&password={!$Credential.Password}');
        HttpResponse res = h.send(req);
        Map<String, Object> responseJson = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        string access_token = (string)responseJson.get('access_token');  

        String restAPIURL = 'callout:Lightning_Scheduler_API_User/services/data/v45.0/scheduling/getAppointmentSlots';    

        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('POST');   
        httpRequest.setHeader('Authorization', 'Bearer '+access_token);
        httpRequest.setHeader('Content-Type','application/json');
        httpRequest.setHeader('Accept','application/json');
	    String body = '{"workTypeGroupId" : "'+workTypeId+'","accountId" : "'+accountId+'","territoryIds" : ["'+territoryId+'"],"requiredResourceIds" : ["'+resourceId+'"]}';
        httpRequest.setBody(body);
        httpRequest.setEndpoint(restAPIURL);  
        String response = '';
        try {  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) {  
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
                response=httpResponse.getBody();
                
            } else {  
                throw new CalloutException( httpResponse.getBody() );  
            }   
        } catch( System.Exception e) {  
            throw e;  
        }  
        
        List<Event> allTimeSlots = new List<Event>();
        ChronosBot_JSON2Apex ts=ChronosBot_JSON2Apex.parse(response);
       	List<ChronosBot_JSON2Apex.TimeSlots> ls = ts.timeSlots;
        if(ls.size()<slots)
        {
            slots=ls.size();
        }
        for(counter=0;counter<slots;counter++)
        {
            Event slot = new Event();
            if (contactId != null)
                {
                    User communityUser = [SELECT Id, TimeZoneSidKey FROM User WHERE ContactId = :contactId LIMIT 1];
                    slot.Description=ls[counter].startTime.format('EEEE, MMM d', communityUser.TimeZoneSidKey)+' '+ls[counter].startTime.format('h:mm aaa', communityUser.TimeZoneSidKey)+' - '+ls[counter].endTime.format('h:mm aaa', communityUser.TimeZoneSidKey);
                } else {
                    TimeZone tz = UserInfo.getTimeZone();
                    slot.Description=ls[counter].startTime.format('EEEE, MMM d', tz.getID())+' '+ls[counter].startTime.format('h:mm aaa', tz.getID())+' - '+ls[counter].endTime.format('h:mm aaa', tz.getID());
                }
            slot.EndDateTime=ls[counter].endTime;
            slot.StartDateTime=ls[counter].startTime;
            allTimeSlots.add(slot);

        }
        
		return allTimeSlots;
    }
}