@isTest
public class RevaStaffQuartersRequestAndAllotmentTest {
    
    @isTest
    static void testQuarterRequestProcess() {
        // Create test data
        Staff_Quarters_Room__c testRoom = new Staff_Quarters_Room__c(Type__c = '1 BHK');
        insert testRoom;
        
        // Mock User Profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserteaching@example.com',
            FirstName = 'Test',
            LastName = 'User',
            CompanyName = 'Test Company'
        );
        insert testUser;
        System.runAs(testUser) {
            // Test quarter request process
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.quarterRequestProcess('1 BHK', Date.today());
            Map<String, String> result1 = RevaStaffQuartersRequestAndAllotment.quarterRequestProcess('10 BHK', Date.today());
            Test.stopTest();
            
            // Assertions
            System.assertEquals('true', result.get('isSuccess'));
            System.assertNotEquals(null, result.get('quartersReq'));
            System.assertEquals('Request for Quarters successfully submitted.', result.get('successMessage'));
        }
    }
    
    @isTest
    static void testFetchExistingQuartersReq() {
        // Create test data
        User testUser = createTestUser();
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Request Submitted'
        );
        insert testRequest;


        System.runAs(testUser) {
            // Test fetch existing quarters request
            Test.startTest();
            Staff_Quarters_Request__c result = RevaStaffQuartersRequestAndAllotment.fetchExistingQuartersReq(testUser.Id);
            Staff_Quarters_Request__c result1 = RevaStaffQuartersRequestAndAllotment.fetchExistingQuartersDetails(testUser.Id);
            Test.stopTest();
            
            // Assertions
            System.assertNotEquals(null, result);
            System.assertEquals('Request Submitted', result.Status__c);
        }
    }
    
    
  @isTest
    static void testFetchExistingvac() {
        // Create test data
        User testUser = createTestUser();
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Request Submitted'
        );
        insert testRequest;

       Staff_Quarter_Vacation_Request__c  testvacreq = new Staff_Quarter_Vacation_Request__c(
        Staff_Quarters_Request__c = testRequest.Id,
           Status__c = 'Initiated'
        );
        insert testvacreq;
        
        System.runAs(testUser) {
            // Test fetch existing quarters request
            Test.startTest();
            Staff_Quarter_Vacation_Request__c result = RevaStaffQuartersRequestAndAllotment.fetchExistVacationReq(testvacreq.Id);
            Test.stopTest();
            
     }
    }
    
    @isTest
    static void testInitiateVacation() {
        // Create test data
        User testUser = createTestUser();
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Room Allotted'
        );
        insert testRequest;
        
        System.runAs(testUser) {
            // Test initiate vacation
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.initiateVacation(testUser.Id);
            Test.stopTest();
            
            // Assertions
            System.assertEquals('true', result.get('isSuccess'));
            System.assertEquals('Staff Vacation Initiated', result.get('successMessage'));
            
            // Fetch updated request
            Staff_Quarters_Request__c updatedRequest = [SELECT Status__c FROM Staff_Quarters_Request__c WHERE Id = :testRequest.Id];
            System.assertEquals('Vacation Initiated', updatedRequest.Status__c);
        }
    }
    
    @isTest
    static void testFetchInitialInfo() {
        // Create test data
        User testUser = createTestUser();
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Request Submitted'
        );
        insert testRequest;
/*

     
         Staff_Quarters_Request__c testRequest5 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Initiated'
        );
       // insert testRequest5;
        
         Staff_Quarters_Request__c testRequest6 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Completed'
        );
        //insert testRequest6;
        
*/
        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }
    

   @isTest
    static void testFetchallotedInfo() {
        // Create test data
        User testUser = createTestUser();
             
         Staff_Quarters_Request__c testRequest1 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Room Allotted'
        );
        insert testRequest1;

        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }

  @isTest
    static void testFetchApprovedInfo() {
        // Create test data
        User testUser = createTestUser();
             Staff_Quarters_Request__c testRequest2 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Approved'
        );
     insert testRequest2;
        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }

  @isTest
    static void testFetchRejectedInfo() {
        // Create test data
        User testUser = createTestUser();

         Staff_Quarters_Request__c testRequest3 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Rejected'
        );
        insert testRequest3;

        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }

  @isTest
    static void testFetchVacationInfo() {
        // Create test data
        User testUser = createTestUser();
       
         Staff_Quarters_Request__c testRequest4 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Vacation Initiated'
        );
        insert testRequest4;

        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }

  @isTest
    static void testFetchCompletedInfo() {
        // Create test data
        User testUser = createTestUser();
              Staff_Quarters_Request__c testRequest7 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Vacation Completed'
        );
        insert testRequest7;

        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }
    
 @isTest
    static void testFetchVacInitiatedInfo() {
        // Create test data
        User testUser = createTestUser();
              Staff_Quarters_Request__c testRequest7 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Vacation Initiated'
        );
        insert testRequest7;

        Staff_Quarter_Vacation_Request__c testvacrequest = new Staff_Quarter_Vacation_Request__c(
        Staff_Quarters_Request__c = testRequest7 .Id,
          Status__c =   'Initiated',
            Initiated_Date__c =system.Today()
        );
        insert testvacrequest;
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }


 @isTest
    static void testFetchVacCompletedInfo() {
        // Create test data
        User testUser = createTestUser();
              Staff_Quarters_Request__c testRequest7 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Vacation Initiated'
        );
        insert testRequest7;

        Staff_Quarter_Vacation_Request__c testvacrequest = new Staff_Quarter_Vacation_Request__c(
        Staff_Quarters_Request__c = testRequest7 .Id,
          Status__c =   'Completed',
            Initiated_Date__c =system.Today()
        );
        insert testvacrequest;
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }



    @isTest
    static void testFetchExistingQuartersUserDetails() {
        // Create test data
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Type__c = '1 BHK',
            Status__c = 'Request Submitted'
        );
        insert testRequest;
        
        // Test fetch existing quarters user details
        Test.startTest();
        List<Staff_Quarters_Request__c> result = RevaStaffQuartersRequestAndAllotment.fetchExistingQuartersUserDetails('1 BHK');
        Test.stopTest();
        
        // Assertions
        System.assert(!result.isEmpty());
        System.assertEquals('1 BHK', result[0].Type__c);
    }
    
    // Helper method to create test user
    static User createTestUser() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser = new User(
            Alias = 'tuserrrr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserProfessror@example.com',
            FirstName = 'Test',
            LastName = 'User',
            CompanyName = 'Test Company'
        );
        insert testUser;
        return testUser;
    }
}