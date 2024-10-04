@isTest
public class WhatsAppFollowUpBatchTest {
/*
    @isTest
    static void testBatchExecution1() {
        
    id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();        
              
        hed__Program_Plan__c progBatch = new hed__Program_Plan__c();
        progBatch.Name = 'B. Tech in Mechatronics Engineering-(2024-2028)';
        insert progBatch;
        
        Fee_Master__c feeMaster = new Fee_Master__c();
        feeMaster.Program_Batch__c = progBatch.Id;
        feeMaster.IsActive__c = true; 
        feeMaster.Fee_Type__c ='Application Fee'; 
        feeMaster.Applicant_Category__c = 'Indian (SAARC)';
        insert feeMaster;

        Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
       // accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        //accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024-2026)';
       // mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
        mbaAcc.hed__Account__c =accRecPhd.Id;
        insert mbaAcc;
        
        // Create test data - Contact records
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 100; i++) {
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = False,
               Primary_Academic_Program__c = accRecPhd.Id,
               RecordTypeId  = conRecTypeId,
                Program_Batch__c=mbaAcc.Id
            );
            testContacts.add(applicant);
        }
        insert testContacts;

        // Set up mock response for WhatsApp utility callout
      //  Test.setMock(HttpCalloutMock.class, new WhatsAppMockResponse());

        Test.startTest();       
        WhatsAppFollowUpBatch1 batch = new WhatsAppFollowUpBatch1();
        Database.executeBatch(batch);
        Test.stopTest();
  } */   
       
	 static testMethod void testBatchExecution2() {
         
         // ***************************************************************
         /*
      
       id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
       
        Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
       // accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        //accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024-2026)';
       // mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
        mbaAcc.hed__Account__c =accRecPhd.Id;
        insert mbaAcc;
      
        // Test data setup
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 1; i++) { // create multiple records for testing
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
                Primary_Academic_Program__c = accRecPhd.Id,
                RecordTypeId  = conRecTypeId,
                Admission_Mode__c ='UQ',
                Program_Batch__c=mbaAcc.Id 
            );
            contacts.add(applicant);
        }
        insert contacts;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts.size(); i++) { 
            hed__Application__c app = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0')+'2',
                hed__Application_Status__c = 'Started'
            );
            applications.add(app);
        }
        insert applications;
         
         */
         
         // ***************************************************************
         
     //     [SELECT Program_Batch__r.Name FROM Fee_Master__c WHERE IsActive__c =true AND Fee_Type__c ='Application Fee' AND Applicant_Category__c = 'Indian (SAARC)'];
              /*
         hed__Program_Plan__c progBatch = new hed__Program_Plan__c();
         progBatch.Name = 'B. Tech in Mechatronics Engineering-(2024-2028)';          
         insert progBatch;     
          
      
          List<Fee_Master__c> feeMasterList = new List<Fee_Master__c>();
         
          for (Integer i = 0; i < 1; i++) { 
          	 Fee_Master__c feeMaster = new Fee_Master__c(
                Program_Batch__c = progBatch.Id,
                IsActive__c = true, 
                Fee_Type__c ='Application Fee',
                Applicant_Category__c = 'Indian (SAARC)'
             );
              feeMasterList.add(feeMaster);
          }
      	 insert feeMasterList;        
       
      
        // Test data setup
        List<Contact> contacts1 = new List<Contact>();
        for (Integer i = 0; i < 3; i++) { // create multiple records for testing
            Contact applicant1 = new Contact(
                FirstName = 'TetFirstName' + i,
                LastName = 'TetLastName' + i,
                MobilePhone = '122345678' + i,
                Application_Fee_Paid__c = true,
             //   Primary_Academic_Program__c = accRecPhd.Id,
                RecordTypeId  = conRecTypeId,
              //  Record_Type_Name__c='Applicant',
                Admission_Mode__c ='UQ',
                Program_Batch__c = feeMasterList[0].Program_Batch__c              
            );
            contacts1.add(applicant1);
        }
        insert contacts1;

         
    
         
        List<hed__Application__c> applications1 = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts1.size(); i++) { 
            hed__Application__c app1 = new hed__Application__c(
                hed__Applicant__c = contacts1[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0'),
                hed__Application_Status__c = 'Started'
            );
            applications.add(app1);
        }
        insert applications1; */
     
        // Start the batch
        Test.startTest();
    //   WhatsAppFollowUpBatch2 batch = new WhatsAppFollowUpBatch2();
    //    Database.executeBatch(batch);
      
//***********************************************************************************

            // Define the list to hold the active program batch names
            List<String> activeProgBatchListaa = new List<String>();
            
            // Execute the SOQL query
            List<Fee_Master__c> feeMasterRecords = [
                SELECT Program_Batch__c, Program_Batch__r.Name 
                FROM Fee_Master__c 
                WHERE IsActive__c = true 
                AND Fee_Type__c = 'Application Fee' 
                AND Applicant_Category__c = 'Indian (SAARC)'                 
            ];
            
            // Loop through the query results and add the program batch names to the list
            for (Fee_Master__c feeMaster : feeMasterRecords) {
                // Ensure that Program_Batch__r is not null before accessing its Name
                if (feeMaster.Program_Batch__r != null) {
                    activeProgBatchListaa.add(feeMaster.Program_Batch__c);
                }
            }
         
         // Optionally, print out the list for debugging purposes
		 System.debug('Active Program Batch List: ' + activeProgBatchListaa);
       
         System.debug('Array--> '+activeProgBatchListaa); // B. Tech in Mechatronics Engineering-(2024-2028)
         System.debug('Array object -->'+activeProgBatchListaa.size());
         
         System.debug('ProgBatch Id -->'+[SELECT Id FROM hed__Program_Plan__c WHERE Name = 'B. Tech in Mechatronics Engineering-(2024-2028)']);
         
         System.debug('ProgBatch Name -->'+[SELECT Id,Name FROM hed__Program_Plan__c]);
         
         System.debug('Fee Master -->'+[SELECT Id, Program_Batch__c, IsActive__c, Fee_Type__c, Applicant_Category__c FROM Fee_Master__c]);
         
         System.debug('Contact -->'+[SELECT Id,FirstName,LastName,MobilePhone,Application_Fee_Paid__c,RecordTypeId,Admission_Mode__c,Program_Batch__c FROM Contact]);
     //    List<Contact> listCon = [SELECT Id,FirstName,LastName,MobilePhone,Application_Fee_Paid__c,RecordTypeId,Admission_Mode__c,Program_Batch__c FROM Contact];
        
         // System.debug('Application -->'+[SELECT hed__Applicant__c,Application_Number__c,hed__Application_Status__c FROM hed__Application__c]);
         
      //    System.debug('Application Query -->'+[SELECT hed__Applicant__r,Application_Number__c,hed__Application_Status__c FROM hed__Application__c];
        
         
  //***********************************************************************************       
         
         //a0KIl000000L1v0MAC
         
    /* 	 System.debug('Query result -->'+ [select id,hed__Applicant__r.Program_Batch__r.Name, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,
                hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c from hed__Application__c 
                where  hed__Applicant__r.Program_Batch__c = 'a0KIl000000L2BHMA0'].size());  */
       
         Test.stopTest();
    }
    
    
    
    
   /* 
    static testMethod void testBatchExecution21() {
        
         id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
      	hed__Program_Plan__c progBatch = new hed__Program_Plan__c();
        	progBatch.Name = 'B. Tech in Mechatronics Engineering-(2024-2028)';
         //	progBatch.hed__Account__c = acc.Id;
        insert progBatch;         
        
   
      
          List<Fee_Master__c> feeMasterList = new List<Fee_Master__c>();
         
          for (Integer i = 0; i < 200; i++) { 
          	 Fee_Master__c feeMaster = new Fee_Master__c(
                Program_Batch__c = progBatch.Id,
                IsActive__c = true, 
                Fee_Type__c ='Application Fee',
                Applicant_Category__c = 'Indian (SAARC)'
             );
              feeMasterList.add(feeMaster);
          }
      	 insert feeMasterList;        
       
      
        // Test data setup
        List<Contact> contacts1 = new List<Contact>();
        for (Integer i = 0; i < 200; i++) { // create multiple records for testing
            Contact applicant1 = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
             //   Primary_Academic_Program__c = accRecPhd.Id,
                RecordTypeId  = conRecTypeId,
                Admission_Mode__c ='UQ',
                Program_Batch__c=feeMasterList[i].Id              
            );
            contacts.add(applicant1);
        }
        insert contacts1;

        List<hed__Application__c> applications1 = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts1.size(); i++) { 
            hed__Application__c app1 = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0'),
                hed__Application_Status__c = 'Started'
            );
            applications.add(app1);
        }
        insert applications1;
     
        // Start the batch
        Test.startTest();
        WhatsAppFollowUpBatch2 batch = new WhatsAppFollowUpBatch2();
        Database.executeBatch(batch);
        Test.stopTest();
    
    }
    */
    /*
     static testMethod void testBatchExecution3() {
      
       id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
       Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
       // accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        //accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024)';
       // mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
        mbaAcc.hed__Account__c =accRecPhd.Id;
        insert mbaAcc;
      
        // Test data setup
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) { // create multiple records for testing
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
                Primary_Academic_Program__c = accRecPhd.Id,
                RecordTypeId  = conRecTypeId,
                Admission_Mode__c ='UQ',
                Program_Batch__c=mbaAcc.Id
                
            );
            contacts.add(applicant);
        }
        insert contacts;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts.size(); i++) { 
            hed__Application__c app = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0'),
                hed__Application_Status__c = 'Incomplete'
            );
            applications.add(app);
        }
        insert applications;

     //  Test.setMock(HttpCalloutMock.class, new WhatsAppMockResponse());
        // Start the batch
        Test.startTest();
        WhatsAppFollowUpBatch3 batch = new WhatsAppFollowUpBatch3();
        Database.executeBatch(batch);
        Test.stopTest();
      }  
    */
     /*
    static testMethod void testBatchExecution5() {        
     id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
       Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
       // accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecBtech = new Account();
        accRecBtech.Name = 'B.Tech in Mechanical Engineering';
        accRecBtech.Program_Type__c = 'UG';
        insert accRecBtech;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024-2026)';
       // mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
       // mbaAcc.hed__Account__c =accRecPhd.Id;
         mbaAcc.hed__Account__c =accRecBtech.Id;
        insert mbaAcc;
      
        // Test data setup
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) { // create multiple records for testing
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
                Primary_Academic_Program__c = accRecBtech.Id,
                RecordTypeId  = conRecTypeId,
                Admission_Mode__c ='UQ',
                Program_Batch__c=mbaAcc.Id
             //   OwnerId = user.Id
            );
            contacts.add(applicant);
        }
        insert contacts;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts.size(); i++) { 
            hed__Application__c app = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0'),
                hed__Application_Status__c = 'In Review'                
            );
            applications.add(app);
        }
        insert applications;

     //  Test.setMock(HttpCalloutMock.class, new WhatsAppMockResponse());
        // Start the batch
        Test.startTest();
        WhatsAppFollowUpBatch5 batch = new WhatsAppFollowUpBatch5();
        Database.executeBatch(batch);
        Test.stopTest();
  }
    
    @isTest
    static void testScheduler() {
        // Enqueue job
        Test.startTest();
        String jobId = System.schedule('Test WhatsAppFollowUp Scheduler', '0 0 0 * * ?', new WhatsAppFollowUp_Scheduler());
        Test.stopTest();

        // Verify job has been scheduled
        CronTrigger ct = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('Test WhatsAppFollowUp Scheduler', ct.CronJobDetail.Name);
        
        }    
      @isTest
    static void testSchedulerPAF() {
        // Enqueue job
        Test.startTest();
        String jobId = System.schedule('Test WhatsAppFollowUp Scheduler', '0 0 0 * * ?', new WhatsAppFollowUp_PAF_Scheduler());
        Test.stopTest();

        // Verify job has been scheduled
        CronTrigger ct = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('Test WhatsAppFollowUp Scheduler', ct.CronJobDetail.Name);
    }
        */
    // Mock response class for WhatsApp callout
    private class WhatsAppMockResponse implements HttpCalloutMock {
        // This method mocks the response for the HTTP request
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
 
}