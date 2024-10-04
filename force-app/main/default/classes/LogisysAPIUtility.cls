/*********************************************
 * This class to is Logisys API Utility
 * It has logic to query Auth Details & Endpoints related to Logisys APIs
 * In this we are mapping the Http Request with all the headers & other params
 * It's called from
 * ********************************************/

public class LogisysAPIUtility {
    public static HttpRequest mapRequest(String apiName, String jsonBody){
        
        if(!test.isRunningtest()){
        //Get API Details
        API_Setup__mdt stdProfAPI = [SELECT Endpoint_1__c,Endpoint_2__c,Method__c,Timeout__c FROM API_Setup__mdt WHERE MasterLabel =: apiName];
        String endpoint = String.isNotBlank(stdProfAPI.Endpoint_2__c) ? stdProfAPI.Endpoint_1__c+stdProfAPI.Endpoint_2__c : stdProfAPI.Endpoint_1__c;
        
        //Get Auth Details
        Logisys_Auth_Details__mdt auth = [SELECT Username__c,Password__c FROM Logisys_Auth_Details__mdt][0];
        Blob headerValue = Blob.valueOf(auth.Username__c+ ':' +auth.Password__c);
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        //Map Http Request
        HttpRequest hReq = new HttpRequest();
        hReq.setHeader('Authorization', authHeader);
        hReq.setBody(jsonBody);
        hReq.setEndpoint(endpoint);
        hReq.setMethod(stdProfAPI.Method__c);                
        hReq.setTimeout((Integer)stdProfAPI.Timeout__c);
        
        return hReq;
        }
        else{
      //  String jsonBody = '{"status": "success", "data": {"resdata": [{"sem": "Semester", "examdate": "2024-05-15", "regno": "Student ID", "subshort": "COURSE001", "qpcode": "QP001", "doe": "15/05/2024", "session": "9:00 AM to 12:00 PM", "batch": "1"}]}}';
             //Map Http Request
        HttpRequest hReq = new HttpRequest();
        hReq.setHeader('Authorization', 'auth.Username__c'+ ':' +'auth.Password__c');
        hReq.setBody(jsonBody);
        hReq.setEndpoint('https://universitysolutions.in/revaapi/app.php?a=getThtimetable');
        hReq.setMethod('POST');                
        hReq.setTimeout(120000);
            return hReq;
        }
    }
}