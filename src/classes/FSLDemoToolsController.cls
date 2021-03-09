public with sharing class FSLDemoToolsController{
    public FSLDemoToolsController() {
    }

  private static Point originalTerritoryCoordinate;
  private static Point newLocationCoordinate;
  
  @RemoteAction
  public static List<ServiceTerritory> GetLocations(){
    List<ServiceTerritory> locations = [SELECT Id,Name, Longitude,Latitude,OperatingHoursId FROM ServiceTerritory];
    return locations;
  }

   @RemoteAction
  public static List<OperatingHours> GetOperatingHours(){
    List<OperatingHours> operatingHours = [SELECT Id,Name, timezone from OperatingHours];
    return operatingHours;
  }
     
  @RemoteAction
  public static List<Schema.PicklistEntry>  GetTimeZones(){
    List<SelectOption> timezoneOptions = new List<SelectOption>();
    Schema.DescribeFieldResult fieldResult = OperatingHours.TimeZone.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    return ple;
  }
     

  @RemoteAction
  public static String GetUserTz(){
    TimeZone tz = UserInfo.getTimeZone();
    return tz.toString();
    //return tz.getDisplayName();
  }

  @RemoteAction
  public static String RestoreData(Integer year, Integer month, Integer day){
        system.debug('*************** Date to restore to (y,m,d):'+ year+','+month+','+day);
    Date dtToRestore = date.newinstance(year, month, day);
    ResourceAbsence demoEmployeeAbsence = [SELECT Id, Start FROM ResourceAbsence WHERE FSLDemoTools_Master_Data__c = TRUE ORDER BY Start ASC LIMIT 1];
    Integer daysDiff = demoEmployeeAbsence.Start.dateGMT().daysBetween(dtToRestore);
    system.debug('*************** RestoreData daysDiff:'+daysDiff);
    FSLDemoTools_BatchRestoreData batch = new FSLDemoTools_BatchRestoreData('ResourceAbsence', daysDiff, 'delete');
    Database.executeBatch(batch);

    RestoreServiceTerritoryMembers();
    RestoreTerritories();

    return 'Success '+ dtToRestore.format();
  }


  @RemoteAction
  public static String MoveDates(Integer numOfDays){
    FSLDemoTools_BatchMoveDates batch = new FSLDemoTools_BatchMoveDates('ServiceTerritoryMember', numOfDays);
    Database.executeBatch(batch);
    return 'Success';
  }


    @RemoteAction
  public static String UpdateTimezones(Id territoryId, String newTZString){
    OperatingHours op = [select id,timezone from operatinghours where id in(select operatinghoursid from ServiceTerritory where id=:territoryId)][0];
    DateTime currentDate = Datetime.now();
    Timezone currentTZ = Timezone.getTimeZone(op.Timezone);
    Timezone newTZ = Timezone.getTimeZone(newTZString);
    Integer numOfMins = (currentTZ.getOffset(currentDate)-newTZ.getOffset(currentDate))/60000;
    system.debug('************ numOfMins:'+numOfMins);
    FSLDemoTools_BatchMoveMins batch = new FSLDemoTools_BatchMoveMins('ServiceAppointment', territoryId, numOfMins);
    Database.executeBatch(batch);

    UpdateOperatingHoursTZ(op.Id, newTZString);
    UpdateUserTZ(newTZString);
    return 'Success - adding '+ numOfMins +' mins';
  }


  @RemoteAction
  public static String ChangeLocation(Id territoryId, String newLocationName,  Double latitude, Double longitude){
        //Getting the original Coordinate
      ServiceTerritory originalTerritory = [SELECT Id,Latitude, Longitude FROM ServiceTerritory WHERE Id=: territoryId LIMIT 1];
      originalTerritoryCoordinate = new Point(originalTerritory.Latitude, originalTerritory.Longitude);
      newLocationCoordinate=new Point(latitude, longitude);
      
      //Updating the Territory Long/Lat
      originalTerritory.Latitude=latitude;
      originalTerritory.Longitude=longitude;
      originalTerritory.Name=newLocationName;
      update originalTerritory;

      FSLDemoTools_BatchUpdateLocation batch = new FSLDemoTools_BatchUpdateLocation('ServiceTerritoryMember', territoryId, originalTerritoryCoordinate, newLocationCoordinate);
      Database.executeBatch(batch);

      return 'Success!';
    }

    private static Void RestoreServiceTerritoryMembers() {
    List<ServiceTerritoryMember> stms = [Select Id, FSLDemoTools_Original_Geolocation__Latitude__s, FSLDemoTools_Original_Geolocation__Longitude__s, Latitude, Longitude From ServiceTerritoryMember where FSLDemoTools_Master_Data__c=true and Territorytype='P'];
      
      for(ServiceTerritoryMember terr : stms) {
        if(terr.FSLDemoTools_Original_Geolocation__Latitude__s != null && terr.FSLDemoTools_Original_Geolocation__Latitude__s != 0) terr.Latitude = terr.FSLDemoTools_Original_Geolocation__Latitude__s;
        if(terr.FSLDemoTools_Original_Geolocation__Longitude__s != null && terr.FSLDemoTools_Original_Geolocation__Longitude__s != 0) terr.Longitude = terr.FSLDemoTools_Original_Geolocation__Longitude__s;
      } 
      update stms;
    }

    private static Void RestoreTerritories() {
      List<ServiceTerritory> territories = [Select Id, Name, FSLDemoTools_Original_Name__c, FSLDemoTools_Original_Geolocation__Latitude__s, FSLDemoTools_Original_Geolocation__Longitude__s, Latitude, Longitude,FSLDemoTools_Original_Timezone__c,OperatingHoursId From ServiceTerritory];
      List<Id> lstOpertingHoursIds = new List<Id>();
      Map<Id,String> mapOperatingHoursTimezones = new  Map<Id,String>();

      for(ServiceTerritory terr : territories) {
        if(terr.FSLDemoTools_Original_Timezone__c!=null && !mapOperatingHoursTimezones.containsKey(terr.OperatingHoursId)){
        mapOperatingHoursTimezones.put(terr.OperatingHoursId, terr.FSLDemoTools_Original_Timezone__c);
        lstOpertingHoursIds.add(terr.OperatingHoursId);
      }

        if(terr.FSLDemoTools_Original_Name__c != null && terr.FSLDemoTools_Original_Name__c != '') terr.Name = terr.FSLDemoTools_Original_Name__c;
        if(terr.FSLDemoTools_Original_Geolocation__Latitude__s != null && terr.FSLDemoTools_Original_Geolocation__Latitude__s != 0) terr.Latitude = terr.FSLDemoTools_Original_Geolocation__Latitude__s;
        if(terr.FSLDemoTools_Original_Geolocation__Longitude__s != null && terr.FSLDemoTools_Original_Geolocation__Longitude__s != 0) terr.Longitude = terr.FSLDemoTools_Original_Geolocation__Longitude__s;
      } 
      update territories;

          system.debug('************ mapOperatingHoursTimezones:'+mapOperatingHoursTimezones);
      List<OperatingHours> operatingHours = [Select Id, timezone from operatinghours where Id in : lstOpertingHoursIds];
       for(OperatingHours op : operatingHours) {
         system.debug('************ mapOperatingHoursTimezones.get(op.Id)!=null:'+mapOperatingHoursTimezones.get(op.Id));
        if(mapOperatingHoursTimezones.get(op.Id)!=null)
            op.Timezone = mapOperatingHoursTimezones.get(op.Id);
       }

       Update operatingHours;

    }

    private static Void UpdateOperatingHoursTZ(Id operatingHoursId, String newTz){
      OperatingHours op = new OperatingHours(Id=operatingHoursId);
      op.TimeZone=newTz;
      Update op;
    } 

    private static Void UpdateUserTZ(String newTz){
      User usr = new User(Id=UserInfo.getUserId());
      usr.TimeZoneSidKey=newTz;
      Update usr;
    } 
    
}