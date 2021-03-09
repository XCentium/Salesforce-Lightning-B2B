@isTest
private with sharing class ChronosBot_JSON2ApexTestClass {
	static testMethod void validateJson() 
    {
        String jsonString='{"timeSlots" :[ { "endTime" : "2019-01-21T19:15:00.000+0000", "startTime" : "2019-01-21T16:15:00.000+0000","territoryId" : "0HhB0000000TO9WKAW"}, {"endTime" : "2019-01-21T19:30:00.000+0000","startTime" : "2019-01-21T16:30:00.000+0000", "territoryId" : "0HhB0000000TO9WKAW" }, { "endTime" : "2019-01-21T19:45:00.000+0000","startTime" : "2019-01-21T16:45:00.000+0000","territoryId" : "0HhB0000000TO9WKAW"}]}';
    	ChronosBot_JSON2Apex ts=ChronosBot_JSON2Apex.parse(jsonString);
        System.assertEquals(3,ts.timeSlots.size());
    }
}