@isTest
private with sharing class ChronosBot_FindFreeTimeSlotsTestClass {
    @isTest(SeeAllData=true)
 	static  void checkSlots() 
    {
       List<ChronosBot_FindFreeTimeSlots.ChatRequests> chatRequests = new List<ChronosBot_FindFreeTimeSlots.ChatRequests>();
        ChronosBot_FindFreeTimeSlots.ChatRequests c1=new ChronosBot_FindFreeTimeSlots.ChatRequests();
        c1.thisAccount=[SELECT Id from Account where Id ='0013i0000033jyDAAQ'];
        c1.thisContact=[SELECT Id from Contact where Id ='0033i000002BXPcAAO'];
        c1.connectedAppClientId='3MVG9vtcvGoeH2bgyVqtcZDdXYl95.RR9Lqb6_VdciYjYA_WESji9sEQmYj29OYbtrnjBF5pSr43jWprfU5fW';
        c1.connectedAppClientSecret='119256F2F2004F6D23AF3353E2863E80F41CD11FAA0BB38F3DABE1A81B1F614E';
        c1.thisServiceTerritoryMember=[Select Id,ServiceResourceId from ServiceTerritoryMember where Id='0Hu3i000000CiIUCA0'];
        c1.thisWorkTypeGroup=[SELECT Id from WorkTypeGroup where Id='0VS3i000000CcdSGAS'];
        c1.thisServiceTerritory=[SELECT Id from ServiceTerritory where Id='0Hh3i000000CibHCAS'];
        chatRequests.add(c1);
       List<List<Event>> chatResponses = new List<List<Event>>();
       chatResponses=ChronosBot_FindFreeTimeSlots.getTSlots(chatRequests);
       System.assertEquals(3, chatResponses[0].size());

    }

}