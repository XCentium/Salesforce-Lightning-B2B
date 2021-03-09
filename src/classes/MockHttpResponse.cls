global class MockHttpResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://test.photo.com', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/image');
        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        res.setBodyAsBlob(myBlob);
        res.setStatusCode(200);
        return res;
    }
}