@isTest
global with sharing class ChronosBot_WebServiceMockImpl implements HttpCalloutMock  {
   global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"timeSlots" :[ { "endTime" : "2019-01-21T19:15:00.000+0000", "startTime" : "2019-01-21T16:15:00.000+0000","territoryId" : "0HhB0000000TO9WKAW"}, {"endTime" : "2019-01-21T19:30:00.000+0000","startTime" : "2019-01-21T16:30:00.000+0000", "territoryId" : "0HhB0000000TO9WKAW" }, { "endTime" : "2019-01-21T19:45:00.000+0000","startTime" : "2019-01-21T16:45:00.000+0000","territoryId" : "0HhB0000000TO9WKAW"}]}');
        response.setStatusCode(200);
        return response; 
    }

}