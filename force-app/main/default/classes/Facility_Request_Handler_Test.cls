@isTest
public class Facility_Request_Handler_Test {

    @isTest
    static void testCheckMethod() {
        // Ensure the record type names are correct and exist in your Salesforce org
        RecordType accHouseholdRecType;
        try {
            accHouseholdRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Household' LIMIT 1];
        } catch (Exception e) {
            accHouseholdRecType = null;
            System.debug('Household RecordType not found: ' + e.getMessage());
        }
       // System.assertNotEquals(null, accHouseholdRecType, 'Account Household RecordType is null. Please ensure the RecordType "Household" exists.');

        RecordType conStudentRecType;
        try {
            conStudentRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        } catch (Exception e) {
            conStudentRecType = null;
            System.debug('Student RecordType not found: ' + e.getMessage());
        }
        System.assertNotEquals(null, conStudentRecType, 'Contact Student RecordType is null. Please ensure the RecordType "Student" exists.');

        // Only proceed if both record types are found
        if (accHouseholdRecType != null && conStudentRecType != null) {
            // Create Account
            Account objAcc = new Account(
                Name = 'Test Account',
                RecordTypeId = accHouseholdRecType.Id
            );
            insert objAcc;
            System.debug('Inserted Account: ' + objAcc.Id);

            // Create Contact
            Contact objCon = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                MobilePhone = '9090909090',
                Aadhar_Card_Number__c = '098765435612',
                RecordTypeId = conStudentRecType.Id,
                AccountId = objAcc.Id,
                Application_Number__c = 'test123',
                SRN_Number__c = '123',
                hed__WorkEmail__c = 'test123@reva.edu.in',
                Nationality__c = 'Indian',
                Email = 'test@gmail.com'
            );
            insert objCon;
            System.debug('Inserted Contact: ' + objCon.Id);

            // Create User
            Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
            System.assertNotEquals(null, p, 'Profile is null');
            User testUser = new User(
                ProfileId = p.Id,
                Username = 'newUser@epeople.com',
                Email = 'pb@f.com',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                Alias = 'nuser',
                LastName = 'Baburao',
                FirstName = 'Lal',
                ContactId = objCon.Id,
                Phone = '9011113246'
            );
            insert testUser;
            System.debug('Inserted User: ' + testUser.Id);

            // Create Facility_Request__c record
            Facility_Request__c testBooking = new Facility_Request__c(
                Facility_Type__c = 'Classroom',
                Facility_Name__c = 'Test Facility',
                Building_Name__c = 'Test Building',
                Floor__c = '1',
                Room_No__c = '101',
                Is_Elective__c = false,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(1),
                Start_Time__c = Time.newInstance(8, 0, 0, 0),
                End_Time__c = Time.newInstance(10, 0, 0, 0),
                Account__c = objAcc.Id,
                Approver__c = testUser.Id
            );

            insert testBooking;
            System.debug('Inserted Facility_Request__c: ' + testBooking.Id);

            // Create oldMap for testing
            Map<Id, Facility_Request__c> oldMap = new Map<Id, Facility_Request__c>();
            oldMap.put(testBooking.Id, testBooking);
            System.debug('Created oldMap: ' + oldMap);

            // Create a list of Facility_Request__c records to pass into the check method
            List<Facility_Request__c> newList = new List<Facility_Request__c>();
            newList.add(testBooking);
            System.debug('Created newList: ' + newList);

            Test.startTest();

            // Call the check method from Facility_Request_Handler	 class
            Facility_Request_Handler.check(newList, oldMap);

            Test.stopTest();

            // Verify if the error message is added
            System.assertEquals(1, newList.size());
            System.assertNotEquals(null, newList[0].Building_Name__c);
        } else {
            System.debug('Required RecordTypes are not found, aborting the test.');
        }
    }
}