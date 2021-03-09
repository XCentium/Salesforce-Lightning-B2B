public class AALSGetCandidatesJSONOnly1 {
//**** this class fetches timeslots from lightning scheduler. 
//**** the flow passes in a payload which is defined by a class called AALSInput - basically territory,resource,start,end,work type group and slotsonly flag
//**** this uses the getAppointmentCandidates API which returns times slots for all resources in the territories
//**** it return a JSON payload for either all of the resources and timeslots are just all of the timeslots
//**** depending on the value of the slotsonly flag.  Its analagous to GetCandidates (all resources and their time slots) and BookAppointment (just timeslots)
    static double weight = 0;
    static string caccountId = null;

    
    @InvocableMethod
    public static list<returnpayload> AALSGetCS(list<AALSInput> thePayloadList) {
        if(thePayloadList == null) return null;
        String pw = 'salesforce1';
        String secret = 'CE00199DE9CB00355741022E8069EF291234D69AEDA9D7224EB512A98C5C0114	';
        String un = 'admin@win20rcg.ido	';
        String key = '3MVG9KsVczVNcM8xNXjBrE1PXf9AsLn69D02ZKkzyH6jhDMpqo_cYfwSzIpUHDKWR8FLD1q_hGMjXmHxO59Xk	';
        

        //**** invokable requires a list but there is only 1 record in the list
        AALSInput thePayload = thePayloadList[0];
        //**** is this get timeslots only or do we want resources and timeslots
        boolean slotsOnly = thePayload.slotsonly;
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String restAPIURL = sfdcURL + '/services/data/v45.0/scheduling/getAppointmentCandidates';
        //**** we're going to put all of payload into a map so we can json serialize it for the REST call
        map<string,object> theMap = new map<string,object>();
        //**** territory could be a list of values so lets add those to a list and remove leading and trailing spaces
        list<string> theTerritoryList = new list<string>();
        for(string thestring : thePayload.territoryids.split(';')) theTerritoryList.add(thestring.trim());
        /*theMap.put('schedulingPolicyId', thePayload.schedulingPolicyId);*/
        theMap.put('territoryIds',theTerritoryList);
        //**** if we have an account or oppty pass the accountid to the api, otherwise don't
        caccountId = determineAccountId(thePayload.parentRecordId);
        if(caccountId <> null) theMap.put('accountId',caccountId);
        theMap.put('workTypeGroupId',thePayload.worktypegroupid);
        theMap.put('startTime',thePayload.starttime);
        theMap.put('endTime',thePayload.endtime);
        //**** serialize the map into JSON so we can pass it into the REST call
        string thebodyJS = JSON.serialize(theMap); 

        //**** First Get Access token 
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token?grant_type=password&client_id=' + key
 + '&client_secret=' + secret + '&username=' + un + '&password=' + pw);
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        Map<String, Object> responseJson = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        string access_token = (string)responseJson.get('access_token');  

        //**** now we can call the REST API to get the slots   
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('POST');   
        httpRequest.setHeader('Authorization', 'Bearer ' + access_token); 
        httpRequest.setHeader('Content-Type', 'application/json; charset=UTF-8');
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setBody(thebodyJS);
        httpRequest.setEndpoint(restAPIURL);  
        String response = '';
        try { 
            //**** make the call to the REST API and stick it in a string called response 
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) { 
                list<returnpayload> theResults = new list<returnpayload>{addid(httpResponse.getBody(),slotsOnly)}; 
               return theResults; 
            } else { }   
        } 
        catch( System.Exception e) {  
            System.debug('ERROR: '+ e);   
            }       
        return new list<returnpayload>{null}; //**** return nothing if there's an error
    }
    
    //**** addid runs through the API results and adds a unique row id.  for anonymous booking it returns only 1 unique row per timeslot
    //**** it also applies logic to exclude excluded resources, limit to required resources and prefer resources based on resource preference and rating
    static returnpayload addid(string theResponse,boolean slotsOnly){
         //**** next bunch of lines deserializes the JSON into a list of time slots
         Map<String, Object> protoobject = (Map<String, Object>) JSON.deserializeUntyped(theResponse);
         List<Map<String, Object>> mySlots = new List<Map<String, Object>>();
         List<Object> myMapObjects = (List<Object>) protoobject.get('candidates');
         List<Object> myResourceTimeSlots = new List<Object>();
         //**** TerritoryMap and ResourceMap are used to lookup the territory names and resource names 
         Map<id,ServiceTerritory> TerritoryMap = new map<id,ServiceTerritory>([select id,name from serviceterritory]);
         Map<id,ServiceResource> ResourceMap = new map<id,ServiceResource>([select id,name,ls_resource_priority__c from serviceresource]);
         for (Object obj : myMapObjects) {
            mySlots.add((Map<String, Object>)obj);
            myResourceTimeSlots.add(obj);
         }

         //**** Determine weighted score for each resource.  it equals the resource rating plus the preferred resource if present
         boolean containsRequired = false;
         boolean containsExcluded = false;
         list<resourcepreference> listResourcePref = new list<resourcepreference>([select id,serviceresourceid,preferencetype from resourcepreference where relatedrecordid =:caccountId]);
         map<id,string> mapResourcePref = new map<id,string>();
         for (resourcepreference thisrp : listResourcePref) {
            mapResourcePref.put(thisrp.serviceresourceid,thisrp.preferencetype);
            if (!containsRequired) containsRequired = (thisrp.preferencetype=='Required');
            if (!containsExcluded) containsExcluded = (thisrp.preferencetype=='Excluded');
          }
         //**** loop through all the slots to determine the total of resource priorities
         double totalResourcePriority = 0;
         map<String,Double> mapUniqueResource = new map<String,Double>();
         for (Object obj : myResourceTimeSlots) {   
              map<String,Object> tmap = (map<string,Object>) obj; //**** each entry contains the resource time slot  
              map<string,Object> mapWithId = new map<string,object>();    
              list<Object> rlist = (list<Object>) tmap.get('resources'); 
              string resourceId = (string) rlist[0];
              mapUniqueResource.put(resourceId,ResourceMap.get(resourceId).LS_Resource_Priority__c);           
            }
         //**** now that we have a unique list of resources, add up all of their Ratings     
         for(double thisPriority : mapUniqueResource.values()) totalResourcePriority+= thisPriority; 
         map<string,double> mapResourceScore = new map<string,double>();
         for(ServiceResource thisResource : ResourceMap.values()) {
             double thescore = totalResourcePriority == 0 ? 0 : thisResource.LS_Resource_Priority__c / totalResourcePriority*weight;
             if(mapResourcePref.containsKey(thisResource.id)) {if(mapResourcePref.get(thisResource.id) =='Preferred' ) { thescore+= (100-weight);}}
             mapResourceScore.put(thisResource.Id,thescore);
            }

         //**** loop through each time slot and create timestamp record for highest priority resource. 
         //**** slotPriorityMaster will be used to filter out all slots for a timestamp except for the highest priority resource       
         map<long,string> slotPriorityMaster = new map<long,string>();
         for (Object obj : myResourceTimeSlots) {   
              map<String,Object> tmap = (map<string,Object>) obj; //**** each entry contains the resource time slot  
              list<Object> rlist = (list<Object>) tmap.get('resources'); 
              string theResource =  (string)rlist[0];
              long theKey =  StringToDateTime((string)tmap.get('startTime')).gettime();
              decimal thePriority = mapResourceScore.get(theResource);     
              boolean excludedrequired = false;
              if(containsExcluded && mapResourcePref.containsKey(theResource) ) excludedrequired =  mapResourcePref.get(theResource) != 'Excluded' ;
              if(containsExcluded && !mapResourcePref.containsKey(theResource) ) excludedrequired = true;
              if(!containsExcluded && !containsRequired) excludedrequired = true;
     
              if(excludedrequired && !slotPriorityMaster.containsKey(theKey)){slotPriorityMaster.put(theKey,theResource);}
                else 
                    if (excludedrequired && mapResourceScore.get(SlotPriorityMaster.get(theKey)) < thePriority)
                      {slotPriorityMaster.put(theKey,theResource);}
            }

         list<map<string,object>> slotList = new list<map<string,object>>();
         integer xId=1;
         //**** loop through each time slot and create one LSSlot record for each one.
         for (Object obj : myResourceTimeSlots) {   
              map<String,Object> tmap = (map<string,Object>) obj; //**** each entry contains the resource time slot  
              map<string,Object> mapWithId = new map<string,object>();    
              mapWithId.put('id',xId.format());
              list<Object> rlist = (list<Object>) tmap.get('resources'); 
              mapWithId.put('resources', rlist[0]);
              mapWithId.put('territoryId', tmap.get('territoryId'));
              mapWithId.put('startTime', StringToDateTime((string)tmap.get('startTime')).gettime());
              mapWithId.put('endTime', StringToDateTime((string)tmap.get('endTime')).gettime());
              mapWithId.put('resourceName', ResourceMap.get((string)mapWithId.get('resources')).name);
              mapWithId.put('resourcePriority', ResourceMap.get((string)mapWithId.get('resources')).LS_Resource_Priority__c);
              mapWithId.put('territoryName', TerritoryMap.get((string)mapWithId.get('territoryId')).name);  
              xId++;
              boolean excludedrequired = false;
              if(containsRequired && mapResourcePref.containsKey((string)rlist[0])) excludedrequired =  mapResourcePref.get((string)rlist[0]) == 'Required' ;
              if(containsExcluded && mapResourcePref.containsKey((string)rlist[0]) ) excludedrequired =  mapResourcePref.get((string)rlist[0]) != 'Excluded' ;
              if(containsExcluded && !mapResourcePref.containsKey((string)rlist[0]) ) excludedrequired = true;
              if(!containsExcluded && !containsRequired) excludedrequired = true;            
              if((!slotsOnly && excludedrequired)  || (slotsOnly && slotPriorityMaster.get(StringToDateTime((string)tmap.get('startTime')).gettime()) == (string)mapWithId.get('resources')) )
              slotList.add(mapWithId);             
            }
        returnpayload thispayload = new returnpayload();
        thispayload.thepayload = JSON.serialize(slotList);
        thispayload.thepayloadsize = slotList.size();
        return thispayload;
        }

    static datetime StringToDateTime (string theString) {
        //**** use newstanceGMT to properly manage timezones
        //**** this function is used to populate 2 local datetime fields on the LSSlots object to support formula fields
        return datetime.newinstanceGMT(integer.valueOf(theString.mid(0,4)) , integer.valueOf(theString.mid(5,2)),integer.valueOf(theString.mid(8,2)),
                 integer.valueOf(theString.mid(11,2)),integer.valueOf(theString.mid(14,2)),0);
        }  
        
    static string determineAccountId (string parentRecordId) {
        string theprefix = parentRecordId.left(3);
        if (theprefix == '001') return parentRecordId; //**** this is an account
        if (theprefix == '00Q') return null; //****  this is a lead so there is no account
        if (theprefix == '006') {
          opportunity theOpportunity = [select id,accountid from opportunity where id = :parentRecordId];
          return theOpportunity.accountid; //**** this is an opportunity
          }
    return null;
    }
       
    public class returnpayload{
        @InvocableVariable(required=true)
        public String thepayload;
        @InvocableVariable(required=true)
        public integer thepayloadsize;  
        }
    public class AALSInput {
        @InvocableVariable(required=true)
        public String schedulingpolicyid;
        @InvocableVariable(required=true)
        public String territoryids;
        @InvocableVariable(required=true)
        public String parentRecordId;
        @InvocableVariable(required=true)
        public String worktypegroupid;  
        @InvocableVariable(required=true)
        public datetime starttime;     
        @InvocableVariable(required=true)
        public datetime endtime;     
        @InvocableVariable(required=false)
        public boolean slotsonly;          
}
}