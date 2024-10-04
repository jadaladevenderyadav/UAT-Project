@isTest
global class razorPayMockforpayment implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('<?xml version="1.0" encoding="UTF-8"?><RESPONSE><TXNDATA><TXNSUMMARY><PGMERCID>REVAECOMSF</PGMERCID><PGCUSTOMERID>1875808211</PGCUSTOMERID><RECORDS>19</RECORDS><AMOUNT>500.00.00</AMOUNT><STATUSCODE>7</STATUSCODE><STATUSDESC>Invalid AMOUNT</STATUSDESC><FILLER1>NA</FILLER1><FILLER2>NA</FILLER2><FILLER3>NA</FILLER3></TXNSUMMARY><RECORD ID="1"><CUSTOMERID>18758082111</CUSTOMERID><ECOMTXNID>NA</ECOMTXNID></RECORD></TXNDATA><CHECKSUM>NA</CHECKSUM></RESPONSE>');
        response.setStatusCode(200);
        return response; 
    }
}