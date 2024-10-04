@isTest
global class MockHttpResponseGeneratorForRevaHostel implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        // Simulate a more detailed response if needed
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success", "phoneNumber": "1234567890"}'); // Include necessary fields
        res.setStatusCode(200);
        return res;
    }
}