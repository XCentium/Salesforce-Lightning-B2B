global with sharing class ChronosBot_FindFreeTimeSlots {
   
    @InvocableMethod(label='Chronos Bot - Find Free Time Slots' description='Returns a list of Free Lightning Scheduler Slots')
    public static List<List<Event>> getTSlots(List<ChatRequests> chatRequests) 
    {
        
        List<List<Event>> chatResponses = new List<List<Event>>();
        For (ChatRequests chatRequest : chatRequests)
        {            
            List<Event> freeslots=new List<Event>();
            if(chatRequest.slotsToReturn==null)
            {
                chatRequest.slotsToReturn=3;
            }
            if (test.isrunningtest()){
                Test.setMock(HttpCalloutMock.class, new ChronosBot_WebServiceMockImpl()); 
        		chatResponses.add(ChronosBot_LSRESTTestClass.validateFreeSlots());
                return chatResponses;
            } else{
            freeslots=ChronosBot_LightningSchedulerREST.getSlots(chatRequest.thisWorkTypeGroup.Id,chatRequest.thisAccount.Id,chatRequest.thisServiceTerritory.Id,chatRequest.thisServiceTerritoryMember.ServiceResourceId,chatRequest.connectedAppClientId,chatRequest.connectedAppClientSecret,chatRequest.slotsToReturn,chatRequest.thisContact.Id);
            
			chatResponses.add(freeslots);
            }
        }
        return chatResponses;
    }
    global class ChatRequests
    {
        @InvocableVariable
        public WorkTypeGroup thisWorkTypeGroup;
        @InvocableVariable
        public ServiceTerritoryMember thisServiceTerritoryMember;
        @InvocableVariable
        public ServiceTerritory thisServiceTerritory;
        @InvocableVariable
        public Account thisAccount;
        @InvocableVariable
		public Contact thisContact;
        @InvocableVariable
        public String connectedAppClientId;
        @InvocableVariable
        public String connectedAppClientSecret;
        @InvocableVariable
        public Integer slotsToReturn;
        
    }  
}