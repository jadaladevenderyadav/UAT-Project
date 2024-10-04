@isTest
public class RPL_StudentRegistrationDetails_Test {

     @testSetup static void setup() {
        // Create common test accounts
        // Rpl_Student_Registration__c

        Contact eCon = RPL_TestDataFactory.createContact(true);
       
        Rpl_Student_Registration__c std = RPL_TestDataFactory.createStudentRegistration(true, econ.Id);

        Rpl_Reva_Placement__c rpl = RPL_TestDataFactory.createRevaPlacement(true);

        Rpl_Company__c  cmp = RPL_TestDataFactory.createCompany(true);
         
         
        Rpl_Placement_Drive__c plc = RPL_TestDataFactory.createPlacement(true, rpl.Id, cmp.Id);
        
        Rpl_Interview__c stdIntview = RPL_TestDataFactory.createInterview(true, plc.Id);
        
        
        Rpl_Student_Registration_Drive__c stdr = new Rpl_Student_Registration_Drive__c();
        stdr.Rpl_Placement_Drive__c =  plc.Id;
        stdr.Rpl_Student_Registration__c = std.Id;
        stdr.Rpl_Is_Active__c = true;
        insert stdr;
    }
 
    @isTest
    static void testGetContactDetails() {
        // Create a test contact
        Contact eCON = [Select id from Contact  limit 1];
        // Call the method to test
        test.StartTest();
         List<Contact> result = RPL_StudentRegistrationDetails.getContactDetails(eCON.Id);
        // Negative Statement.
        //RPL_StudentRegistrationDetails.getContactDetails('90291ndmjekeew');
        test.StopTest();
        
       

        // Assert that the result contains the test contact
        System.assertEquals(eCON.Id, result[0].Id);
    }
    
      @isTest
    static void testfailContactDetails() {
        // Create a test contact
        Rpl_Student_Registration__c eCON = [Select id from Rpl_Student_Registration__c  limit 1];
        // Call the method to test
        test.StartTest();
        try{
             RPL_StudentRegistrationDetails.checkTheStudentPreFinalYear(null);
          } 
           catch (DmlException ex) {
             	System.assertEquals('expected text', ex.getMessage());
           }
             test.stopTest();
        }

    @isTest
    static void testInsertStudentRegDetails() {
        // Create a test student registration record
        Rpl_Student_Registration__c testStudentReg = new Rpl_Student_Registration__c(
            // Set required fields here
        );

        Test.startTest();
        // Call the method to test
        Id result = RPL_StudentRegistrationDetails.insertStudentRegDetails(testStudentReg);
        Test.stopTest();

        // Assert that the method returned the expected ID
        //System.assertNotEquals(null, result);
    }

    @isTest
    static void testUpdateStudentRegDetails() {
        // Create a test student registration record
        Rpl_Student_Registration__c testStudentReg = new Rpl_Student_Registration__c(
            Rpl_Personal_Mail_ID__c = 'test@gmail.com'
            // Set required fields here
        );
        insert testStudentReg;

        // Call the method to test
        Id result = RPL_StudentRegistrationDetails.updateStudentRegDetails(testStudentReg);

        // Assert that the method returned the expected ID
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testUpdateStudentRegDetailsFail() {
        // Create a test student registration record
        Rpl_Student_Registration__c testStudentReg = [Select id, Rpl_Personal_Mail_ID__c from  Rpl_Student_Registration__c limit 1];
        
        try{
            testStudentReg.Rpl_Personal_Mail_ID__c = '';
            
            Id result = RPL_StudentRegistrationDetails.updateStudentRegDetails(testStudentReg);

            // Assert that the method returned the expected ID
            System.assertEquals(null, result);
            
        }catch(Exception e){
            
        }    
    }

    @isTest
    static void testGetTheStudentRegistrationDetails() {
        // Create a test student registration record
        Rpl_Student_Registration__c testStudentReg = new Rpl_Student_Registration__c(
            Rpl_Personal_Mail_ID__c = 'test@gmail.com'
            // Set required fields here
        );
        insert testStudentReg;

        // Call the method to test
        List<Rpl_Student_Registration__c> result = RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails(testStudentReg.Id);
        RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails(null);

        // Assert that the result contains the test student registration record
        System.assertEquals(testStudentReg.Id, result[0].Id);
    }

    @isTest
    static void testUpdateTheOtpDetails() {
        // Create a test contact
       Contact testContact = [Select id , Personal_Email__c  from Contact  limit 1];
        // Call the method to test
        String result = RPL_StudentRegistrationDetails.sendOtpToEmail(testContact.Personal_Email__c);
        //String result1 = RPL_StudentRegistrationDetails.sendOtpToMobile('9035381030');
        //RPL_StudentRegistrationDetails.updateTheOtpDetails('test.test');

        // Assert that the result is not null
        //System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testSendTheOtpDetails() {
        // Create a test contact
       Contact testContact = [Select id , Personal_Email__c  from Contact  limit 1];
        // Call the method to test
        //String result = RPL_StudentRegistrationDetails.sendOtpToEmail(testContact.Personal_Email__c);
        String result1 = RPL_StudentRegistrationDetails.sendOtpToMobile('9035381030');
        //RPL_StudentRegistrationDetails.updateTheOtpDetails('test.test');

        // Assert that the result is not null
        //System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testupdateTheOtpDetailsfail() {
        // Create a test contact
       Contact testContact = [Select id , Personal_Email__c from Contact  limit 1];
        // Call the method to test
        try{
            String result = RPL_StudentRegistrationDetails.sendOtpToEmail('test.test');
        	
        }catch(Exception e){
            
        }
        
    }

    @isTest
    static void testCheckForTheStudentList() {
        // Create a test contact
         Contact testContact = [Select id , Personal_Email__c from Contact  limit 1];

        // Call the method to test
        Integer result = RPL_StudentRegistrationDetails.checkForTheStudentList(testContact.Id);
        
 
    }
    
     @isTest
    static void testCheckForTheStudentListFail() {
        
        // Call the method to test
        Integer result = RPL_StudentRegistrationDetails.checkForTheStudentList(null);
        
        // Assert that the result is 0 (no student registration records)
        System.assertEquals(0, result);
    }

    @isTest
    static void testCheckTheStudentPreFinalYear() {
        // Create a test contact
         Contact testContact = [Select id , Personal_Email__c from Contact  limit 1];

        // Call the method to test
        RPL_StudentRegistrationDetails.contactWrapper result = RPL_StudentRegistrationDetails.checkTheStudentPreFinalYear(testContact.Id);

        // Assert that the result is not null
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetPlacementDetails() {
        // Create a test contact
       
          Contact testContact = [Select id , Personal_Email__c from Contact  limit 1];
        // Call the method to test
        RPL_StudentRegistrationDetails.revaWrapper result = RPL_StudentRegistrationDetails.getPlacementDetails(testContact.Id);

        // Assert that the result is not null
        System.assertNotEquals(null, result);
    }
}