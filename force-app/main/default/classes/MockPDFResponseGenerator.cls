@isTest
public class MockPDFResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/pdf');
        res.setBody('Sample PDF content'); // Simulate the PDF content as a simple string for testing
        res.setStatusCode(200);
        return res;
    }
    public HTTPResponse respond1(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","message":"Email sent successfully"}');
        response.setStatusCode(200);
        return response;
    }
}