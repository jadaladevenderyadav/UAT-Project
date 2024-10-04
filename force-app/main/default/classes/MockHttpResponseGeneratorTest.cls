@isTest
global class MockHttpResponseGeneratorTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"Id": "0031t000007d8nFAAQ", "LastName": "Test Student"}]');
        res.setStatusCode(200);
        return res;
    }
}