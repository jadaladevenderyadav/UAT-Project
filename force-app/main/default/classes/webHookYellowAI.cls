/*********************************************************
 Author : Santoshkumar
 Description : Class to handle webhook from YellowAI
 Date : 14 May 2024
 *********************************************************/

@RestResource(urlMapping='/api/WebHooks/pushDetails/*')
global without sharing class webHookYellowAI {
    
    @HttpPost
    global static void handleNotification(){
        try{
            RestRequest request = RestContext.request;
        
            // RestResponse response = RestContext.response;
            String result;

            //Account acc = new Account(Name='Webhook Account 1');
            //insert acc;
            // DateTime now = DateTime.now();
            // String createdName = String.valueOf(now);
/*
            Datetime currentDateTime = Datetime.now().addHours(5).addMinutes(30); // IST is 5 hours 30 minutes ahead of UTC        
            // Convert datetime to string
            String formattedDateTime = currentDateTime.format('dd-MM-yyyy HH:mm:ss');
            Test1__c test = new Test1__c(Name=formattedDateTime);
            insert test; */

/*
            if (response.statusCode == 200){
                    // result = (String)JSON.deserializeUntyped(response.responseBody);
                    // Datetime currentDateTime = Datetime.now();
                    result = EncodingUtil.base64Encode(response.responseBody);
                    Datetime currentDateTime = Datetime.now().addHours(5).addMinutes(30); // IST is 5 hours 30 minutes ahead of UTC
        
                    // Convert datetime to string
                    String formattedDateTime = currentDateTime.format('dd-MM-yyyy HH:mm:ss');           

                    Test1__c test = new Test1__c(Name=formattedDateTime, response__c = result);
                    insert test; 
            } */

            // This Query returns the completed date of WhatsAppFollowUpBatch1 batch
            AsyncApexJob feeNotPaidBatchDate = [SELECT CreatedDate
            FROM AsyncApexJob
            WHERE JobType = 'BatchApex'and ApexClass.Name = 'WhatsAppFollowUpBatch4' 	
            ORDER BY CompletedDate DESC           
            LIMIT 1];
            
            // return feeNotPaidBatchDate;  
            // Datetime scheduledDateTime = (feeNotPaidBatchDate.CompletedDate).addHours(5).addMinutes(30);
            // String formattedScheduleDateTime = scheduledDateTime.format('dd-MM-yyyy HH:mm:ss');  
            Datetime scheduledDateTime = feeNotPaidBatchDate.CreatedDate;

            Datetime currentDateTime = Datetime.now().addHours(5).addMinutes(30); // IST is 5 hours 30 minutes ahead of UTC
        
            // Convert datetime to string
            String formattedDateTime = currentDateTime.format('dd-MM-yyyy HH:mm:ss');           
            //  result = EncodingUtil.base64Encode(response.responseBody);  //, response__c = result
            
            String payload = request.requestBody.toString();
        
            // Parse JSON payload
            Map<String, Object> payloadMap = (Map<String, Object>)JSON.deserializeUntyped(payload);
            
            // Extract data from payload
            Map<String, Object> event = (Map<String, Object>)payloadMap.get('event');
            String status = (String)event.get('status');
            String userId = (String)payloadMap.get('userId'); //status  userId templateId msgId phone / UID  sentAt DelieveredAt RecievedAt ReadAt ErrorMsg Comments
            String source = (String)payloadMap.get('source');
            String campaign = (String)payloadMap.get('campaign');
            String templateId = (String)payloadMap.get('templateId');
            String msgId = (String)payloadMap.get('msgId');
            String workflowId = (String)payloadMap.get('workflowId');
            String firstName = (String)payloadMap.get('firstName');
            String phone = (String)payloadMap.get('phone');
            String UID = (String)payloadMap.get('UID');
            
            // Process webhook data
        //    processWebhook(status, userId, source, campaign, templateId, msgId, workflowId, firstName, phone, UID);
            
            


            // Test1__c test = new Test1__c(Name=templateId,name__c=phone,response__c=status);
            Test1__c test = new Test1__c(
                Name = formattedDateTime,
                msgId__c = msgId,
                userId__c = userId,
                status__c = status,
                templateId__c = templateId,
                statusTimestamp__c = formattedDateTime
            );
            insert test; 
            
            // Set response
            RestResponse response = RestContext.response;
            response.addHeader('Content-Type', 'application/json');
            response.responseBody = Blob.valueOf('Webhook processed successfully.');
            response.statusCode = 200;
           
        //     List<Test1__c> matchingRecords = [SELECT Name,userId__c,msgId__c,templateId__c,statusTimestamp__c,status__c FROM Test1__c WHERE msgId__c =: msgId LIMIT 1];     // userId__c =: '%'+userId+'%' AND  
           
        //     if (!matchingRecords.isEmpty()) {   
                
        //         // Test1__c testRec = matchingRecords[0];
        //         // testRec.statusTimestamp__c = formattedDateTime;
        //         // testRec.status__c = status;
        //         // update testRec; 

        //         Test1__c testRec = matchingRecords[0];
        //         testRec.statusTimestamp__c = formattedDateTime;
        //         testRec.status__c = status;

        //         if(status == 'sent'){
        //             testRec.sentAt__c = Datetime.now();
        //         }else if(status == 'read'){
        //             testRec.readAt__c = Datetime.now();
        //         }else if(status == 'delivered'){ 
        //             testRec.deliveredAt__c = Datetime.now();
        //         }               
        //         update testRec; 
                               
        //     }else{

        //    /*     if(status == 'sent'){
        //             Test1__c test = new Test1__c(
        //             Name = formattedDateTime,
        //             msgId__c = msgId,
        //             userId__c = userId,
        //             status__c = status,
        //             templateId__c = templateId,
        //             statusTimestamp__c = formattedDateTime,
        //             sentAt__c = Datetime.now(),
        //             scheduledAt__c = scheduledDateTime
        //         );
        //         insert test;
                    
        //         }else if(status == 'read'){
        //             Test1__c test = new Test1__c(
        //                 Name = formattedDateTime,
        //                 msgId__c = msgId,
        //                 userId__c = userId,
        //                 status__c = status,
        //                 templateId__c = templateId,
        //                 statusTimestamp__c = formattedDateTime,
        //                 readAt__c = Datetime.now(),
        //                 scheduledAt__c = scheduledDateTime
        //             );
        //             insert test;
                    
        //         }else if(status == 'delivered'){ 
        //             Test1__c test = new Test1__c(
        //                 Name = formattedDateTime,
        //                 msgId__c = msgId,
        //                 userId__c = userId,
        //                 status__c = status,
        //                 templateId__c = templateId,
        //                 statusTimestamp__c = formattedDateTime,
        //                 deliveredAt__c = Datetime.now(),
        //                 scheduledAt__c = scheduledDateTime
        //             );
        //             insert test;                   
        //         }    */

        //         Test1__c test = new Test1__c(
        //             Name = formattedDateTime,
        //             msgId__c = msgId,
        //             userId__c = userId,
        //             status__c = status,
        //             templateId__c = templateId,
        //             statusTimestamp__c = formattedDateTime,                   
        //             scheduledAt__c = scheduledDateTime
        //         );
        //         insert test;   

        //         // Test1__c test = new Test1__c(
        //         //     Name = formattedDateTime,
        //         //     msgId__c = msgId,
        //         //     userId__c = userId,
        //         //     status__c = status,
        //         //     templateId__c = templateId,
        //         //     statusTimestamp__c = formattedDateTime
        //         // );
        //         // insert test;                             
        //     }           
      
/*
                Test1__c test = new Test1__c(
                    Name = formattedDateTime,
                    msgId__c = msgId,
                    userId__c = userId,
                    status__c = status,
                    templateId__c = templateId,
                    statusTimestamp__c = formattedDateTime
                );
                insert test;  */

            System.debug('Response Data :'+payload);

        }
        catch(Exception e){
            System.debug('Exception is created in webHookYellowAI :'+e.getMessage());
        }
    }    
}