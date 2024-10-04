public without sharing class SLCMDashboard {    
 /*	@AuraEnabled(cacheable=true)
    public static SLCMDashboardResponse getDashboardData() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
     	SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('dashboard_data');
        String endpointURL = mdt.EndPointURL__c;
        
        request.setEndpoint(endpointURL);
        request.setMethod('POST');
        request.setBody('{}');
        request.setHeader('Content-Type', 'application/json');
        //request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);    
     

        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            SLCMDashboardResponse result = (SLCMDashboardResponse) JSON.deserialize(response.getBody(), SLCMDashboardResponse.class);
            system.debug('Result --->'+result);
            return result;            
        } else {
            throw new CalloutException('Error in HTTP request: ' + response.getStatusCode() + ' ' + response.getStatus());
        }
    }

    public class SLCMDashboardResponse {
        public Integer StatusCode { get; set; }
        public String StatusMessage { get; set; }
        public List<PeriodData> ResponseData { get; set; }
    }

    public class PeriodData {
        public String Period { get; set; }
        public Decimal Amount { get; set; }
        public String FromDate { get; set; }
        public String ToDate { get; set; }
    } */
    
    /*
    public class PeriodData {
        public String Period { get; set; }
        public Decimal Amount { get; set; }
        public String FromDate { get; set; }
        public String ToDate { get; set; }
    }

    public class SLCMDashboardResponse {
        public Integer StatusCode { get; set; }
        public String StatusMessage { get; set; }
        public List<PeriodData> ResponseData { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static SLCMDashboardResponse getDashboardData() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
     //   request.setEndpoint('https://sapbone.reva.edu.in/REVA_API_LIVE/API/SLCMDashBoardAPI');
        SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('dashboard_data');
        String endpointURL = mdt.EndPointURL__c;
        
        request.setEndpoint(endpointURL);
        request.setMethod('POST');
        request.setBody('{}'); // Send an empty JSON body
        request.setHeader('Content-Type', 'application/json');

        try {
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                SLCMDashboardResponse res = (SLCMDashboardResponse)JSON.deserialize(response.getBody(), SLCMDashboardResponse.class);
                return res;
            } else {
                throw new AuraHandledException('Error: ' + response.getStatus() + ' - ' + response.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
*/
  
    /*
    public class PeriodData {
        public String Period { get; set; }
        public Decimal Amount { get; set; }
        public String FromDate { get; set; }
        public String ToDate { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<PeriodData> getDashboardData() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
     	SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('dashboard_data');
        String endpointURL = mdt.EndPointURL__c;
        
        request.setEndpoint(endpointURL);
        request.setMethod('POST');
        request.setBody('{}');
        request.setHeader('Content-Type', 'application/json');        
        request.setTimeout(120000);  

        try {
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                if ((Integer)responseMap.get('StatusCode') == 1) {
                    List<Object> responseData = (List<Object>)responseMap.get('ResponseData');
                    List<PeriodData> periodDataList = new List<PeriodData>();
                    
                    for (Object obj : responseData) {
                        Map<String, Object> dataMap = (Map<String, Object>)obj;
                        PeriodData data = new PeriodData();
                        data.Period = (String)dataMap.get('Period');
                        data.Amount = (Decimal)dataMap.get('Amount');
                        data.FromDate = (String)dataMap.get('FromDate');
                        data.ToDate = (String)dataMap.get('ToDate');
                        periodDataList.add(data);
                    }
                    System.debug('Response data:-> ' + periodDataList);
                    return periodDataList;
                } else {
                    throw new AuraHandledException('Error:- ' + (String)responseMap.get('StatusMessage'));
                }
            } else {
                throw new AuraHandledException('Error:-- ' + response.getStatus() + ' - ' + response.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error:--- ' + e.getMessage());
        }
    
    }
*/
    
    @AuraEnabled(cacheable=true)
    public static String getResponseString(){
        return 'Hello REVA';
    }
    
     @AuraEnabled(cacheable=true)
    public static List<String> getDashboardData() {
        // Create a list to hold the JSON strings
        List<String> responseDataList = new List<String>();
        
        // Prepare the HTTP request
       	Http http = new Http();
        HttpRequest request = new HttpRequest();
     	SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('dashboard_data');
        String endpointURL = mdt.EndPointURL__c;
        
        request.setEndpoint(endpointURL);
        request.setMethod('POST');
        request.setBody('{}');
        request.setHeader('Content-Type', 'application/json');        
        request.setTimeout(120000);  

        try {
            // Send the HTTP request
            HttpResponse response = http.send(request);
            
            // Check if the response status is 200 (OK)
            if (response.getStatusCode() == 200) {
                // Parse the JSON response
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> responseData = (List<Object>) result.get('ResponseData');
                
                // Loop through the response data and serialize each item to a JSON string
                for (Object item : responseData) {
                    responseDataList.add(JSON.serialize(item));
                }
            } else {
                // Handle non-200 status codes
                throw new CalloutException('Failed to get a successful response. Status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            // Handle any exceptions
            throw new CalloutException('Error occurred while fetching data: ' + e.getMessage());
        }
        
        // Return the list of JSON strings
        return responseDataList;
    }
}