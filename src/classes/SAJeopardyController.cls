Global class SAJeopardyController {

  string resourceId;
  string stmId;
  string start;
  string endresource;


    // This is the main method called by the VF button.  It moves SAs from source tech to target tech and creates RA for source tech
    public PageReference bam() {
        resourceId = ApexPages.currentPage().getParameters().get('id');
        stmId = ApexPages.currentPage().getParameters().get('stm');
        start = ApexPages.currentPage().getParameters().get('start');
        endresource = ApexPages.currentPage().getParameters().get('end');

        String[] startDate = start.split('-');
        String[] endDate = endresource.split('-');
        String hour ='00';
        String minute ='00';
        String second ='00';
        String startDateconv = startDate[2] + '-' + startDate[0] + '-' + startDate[1] + ' ' + hour + ':' + minute +  ':' + second;
        String endDateconv = endDate[2] + '-' + endDate[0] + '-' + endDate[1] + ' ' + hour + ':' + minute +  ':' + second;
        DateTime startDatedt = DateTime.valueOf(startDateconv);
        DateTime endDatedt = DateTime.valueOf(endDateconv);

        //code to create RA for source tech
        ResourceAbsence na = new ResourceAbsence();
        //find record type for a non availability
        RecordType recordTypeNA = [SELECT Id, SobjectType, Name FROM RecordType WHERE DeveloperName =: 'Non_Availability' AND SObjectType =: ResourceAbsence.getSobjectType().getDescribe().getName()];

        na.RecordTypeId = recordTypeNA.Id;
        na.ResourceId = resourceId;
        na.FSL__Approved__c = true;
        na.Start = startDatedt;
        na.End = endDatedt;
        na.FSL__GanttLabel__c = 'Out Sick';
        //create Resource Absence for source tech
        insert na;
        
        //Find selected SR record
        ServiceResource OnCallSR = [select isActive, name, id from ServiceResource where Id =: srSelected limit 1];
        
        //Find the source SR
        ServiceResource resource = [SELECT Name,id FROM ServiceResource WHERE Id =: resourceId];
        //Find all assigned resource records for the source tech
        list<AssignedResource> arlist = [select id,serviceappointmentid,serviceresourceid from assignedresource where serviceresourceid =: resource.id AND serviceappointmentid in (select id from serviceappointment where schedstarttime >= :startDatedt and schedendtime <= :endDatedt)];
        //change the AR's Service Resource id to equal target tech (switch em!)
        for(assignedresource thisar : arlist) {thisar.serviceresourceid = OnCallSR.id;}   
        //write the updated AR's to the database
        if (arlist.size()>0) update arlist;
        //write a message to the envelope icon      
            
        PageReference pr = new PageReference('/lightning/n/FSL__FieldService');
        return pr;            
    }

  public String getTheSAs(){
        resourceId = ApexPages.currentPage().getParameters().get('id');
        stmId = ApexPages.currentPage().getParameters().get('stm');
        start = ApexPages.currentPage().getParameters().get('start');
        endresource = ApexPages.currentPage().getParameters().get('end');

        String[] startDate = start.split('-');
        String[] endDate = endresource.split('-');
        String hour ='00';
        String minute ='00';
        String second ='00';
        String startDateconv = startDate[2] + '-' + startDate[0] + '-' + startDate[1] + ' ' + hour + ':' 
    + minute +  ':' + second;
        String endDateconv = endDate[2] + '-' + endDate[0] + '-' + endDate[1] + ' ' + hour + ':' 
    + minute +  ':' + second;
        DateTime startDatedt = DateTime.valueOf(startDateconv);
        DateTime endDatedt = DateTime.valueOf(endDateconv);
        
        //Find the selected resource
        ServiceResource resource = [SELECT Name,id FROM ServiceResource WHERE Id =: resourceId];
        //Find all assigned resource records for the selected resource
        list<AssignedResource> arlist = [select id,serviceappointmentid,serviceresourceid from assignedresource where serviceresourceid =: resource.id 
            AND serviceappointmentid in (select id from serviceappointment where schedstarttime >= :startDatedt and schedendtime <= :endDatedt)];
        list<serviceappointment> SAList = new list<serviceappointment>();
        set<id> saIDSet = new set<ID>();
        for(assignedresource thisar : arlist){saIDSet.add(thisar.serviceappointmentid);}
        for(serviceappointment thissa : [select id,appointmentnumber from serviceappointment where id in :saIDSet]){SAList.add(thissa);}
        return SAList.size() + ' Service Appointments owned by ' + resource.name + ' will be reassigned';         
  }

  //this method returns the list of target techs so the user can pick one  
  public List<SelectOption> getsroptions(){
      stmId = ApexPages.currentPage().getParameters().get('stm');
      resourceId = ApexPages.currentPage().getParameters().get('id');
      List<ServiceTerritoryMember> stmRecord = [SELECT EffectiveEndDate,EffectiveStartDate,Id,MemberNumber,ServiceResourceId,ServiceTerritoryId FROM ServiceTerritoryMember where Id =: stmId LIMIT 1];
      //get a list of all of the STM records so we we can find the other techs in the same territory
      List<ServiceTerritoryMember> membersList = [SELECT EffectiveEndDate,EffectiveStartDate,Id,MemberNumber,ServiceResourceId,ServiceTerritoryId FROM ServiceTerritoryMember where ServiceTerritoryId =: stmRecord[0].ServiceTerritoryId];
      //build a list of SR ids for all of the STMs
      List<Id> srIds = new List<Id>();
      for(ServiceTerritoryMember assignedRes : membersList){
        srIds.add(assignedRes.ServiceResourceId);
      }
            
      List<SelectOption> sroptions = new List<SelectOption>();
      //create a list of techs minus the source tech
      List<ServiceResource> srList = [SELECT Description,Id,Name,ResourceType FROM ServiceResource where Id =: srIds AND Id != :resourceId];
      for (ServiceResource srresopt : srList ) 
      {
          sroptions.add(new SelectOption(srresopt.Id,srresopt.Name));
      }
      return sroptions;
           
  }
    //srSelected contains the SR id for the selected tech and is set by the user in the vf page       
    public String srSelected  {get;set;}
    public List<SelectOption> sroptions {set;}
    //remote action is used for the close window call from the vf page. there must be a better way to do this but Im not a vf or js programmer
    @RemoteAction
    Global static void getMeOutOfHere() {}
     
}