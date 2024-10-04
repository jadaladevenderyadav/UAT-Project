@isTest
public class revaHostelLeaveRequestTest {
     public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }


    @isTest
    static void testUpdateRecordStatus() {
        // Retrieve the test data
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Profile p = [SELECT Id FROM Profile WHERE Name='Warden' LIMIT 1]; // Use an appropriate profile
        User warden = new User(
            FirstName = 'Warden',
            LastName = 'Smith',
            Email = 'warden.smith@example.com',
            Username = 'warden.smith02@example.com.test', // Username must be unique across all orgs
            Alias = 'wsmith',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert warden;

        // Create a test Contact record
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '1234567890'
        );
        insert testContact;
        
          // Create Reva_Hostel_Request__c
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '4',
            Hostel_Room_Request_For__c = testContact.Id,
            Warden__c = warden.Id
        );
        insert hostelRequest;
        
        REVA_Hostel_Leave_Request__c leaveRequest = new REVA_Hostel_Leave_Request__c(
            Status__c = 'Leave Requested',
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1),
            Contact__c = testContact.Id, // Use the dynamically created Contact
            Warden__c = warden.Id, // Populating the Warden field with the test user
            Note_to_the_approver__c = 'Test note'
        );
        insert leaveRequest;
       
        Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        revaHostelLeaveRequest.updateRecordStatus(leaveRequest.Id);
        Test.stopTest();
        
        // Verify the record status is updated to a valid picklist value (e.g., 'Completed')
        leaveRequest = [SELECT Id, Status__c FROM REVA_Hostel_Leave_Request__c WHERE Id = :leaveRequest.Id];
        System.assertEquals('Cancelled', leaveRequest.Status__c);
    }
    
    @isTest
    static void testGetLeaveRecordDetails() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; // Use an appropriate profile
        User warden = new User(
            FirstName = 'Warden',
            LastName = 'Smith',
            Email = 'warden.smith@example.com',
            Username = 'warden.smith10@example.com.test', // Username must be unique across all orgs
            Alias = 'wsmith',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert warden;

        // Create a test Contact record
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '1234567890'
        );
        insert testContact;
          // Create Reva_Hostel_Request__c
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '4',
            Hostel_Room_Request_For__c = testContact.Id,
            Warden__c = warden.Id
        );
        insert hostelRequest;
        REVA_Hostel_Leave_Request__c leaveRequest = new REVA_Hostel_Leave_Request__c(
            Status__c = 'Leave Requested',
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1),
            Contact__c = testContact.Id, // Use the dynamically created Contact
            Warden__c = warden.Id, // Populating the Warden field with the test user
            Note_to_the_approver__c = 'Test note'
        );
        insert leaveRequest;
        // Retrieve the test data
       // REVA_Hostel_Leave_Request__c leaveRequest = [SELECT Id, Status__c, Start_Date_and_Time__c, End_Date_and_Time__c FROM REVA_Hostel_Leave_Request__c LIMIT 1];
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        REVA_Hostel_Leave_Request__c result = revaHostelLeaveRequest.getLeaveRecordDetails(leaveRequest.Id);
        Test.stopTest();
        
        // Verify the method returns the correct record
        System.assertEquals(leaveRequest.Id, result.Id);
        System.assertEquals(leaveRequest.Status__c, result.Status__c);
        System.assertEquals(leaveRequest.Start_Date_and_Time__c, result.Start_Date_and_Time__c);
        System.assertEquals(leaveRequest.End_Date_and_Time__c, result.End_Date_and_Time__c);
    }
}