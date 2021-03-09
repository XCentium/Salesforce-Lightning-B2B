@isTest
global with sharing class ChronosBot_LSRESTTestClass {
    @isTest
 	public static List<Event> validateFreeSlots() 
    {
 		Test.setMock(HttpCalloutMock.class, new ChronosBot_WebServiceMockImpl()); 
        List<Event> ev1=ChronosBot_LightningSchedulerREST.getSlots('08q3i000000CiaxAAC', '0013i0000033jyDAAQ', '0Hh3i000000CibHCAS', '0Hn3i000000CivlCAC','3MVG9vtcvGoeH2bgyVqtcZDdXYl95.RR9Lqb6_VdciYjYA_WESji9sEQmYj29OYbtrnjBF5pSr43jWprfU5fW', '119256F2F2004F6D23AF3353E2863E80F41CD11FAA0BB38F3DABE1A81B1F614E', 3, '0033i000002BXPcAAO');
    	HttpResponse response = new HttpResponse();
        String actualValue = response.getBody();
        System.debug('**********' + response.getBody());
        System.assertEquals(actualValue, '');
        System.assertEquals(0, response.getStatusCode());
        System.assertEquals(3, ev1.size());
        return ev1;
    }
}