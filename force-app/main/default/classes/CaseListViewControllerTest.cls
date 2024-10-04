@isTest
public class CaseListViewControllerTest {

    @TestSetup
    static void setupTestData() {
        // Retrieve an existing RecordType for Case
        RecordType infraSupportRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Infra_Support_Request' AND SObjectType = 'Case' LIMIT 1];
        
        // Retrieve an existing User
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        // Create a test Case
        Case testCase = new Case(
            RecordTypeId = infraSupportRecordType.Id,
            OwnerId = testUser.Id,
            Status = 'New',
            Priority = 'High',
            INFRA_Category__c = 'Electrical'
        );
        insert testCase;
    }

    @isTest
    static void testGetCasesWithInfraSupportRequest() {
        // Retrieve test data
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        // Call the method with 'Infra Support Request' record type
        Test.startTest();
        List<Case> cases = CaseListViewController.getCases(null, 'Infra Support Request', testUser.Id);
        Test.stopTest();

        // Assert results
        System.assertEquals(1, cases.size(), 'Expected one case to be returned');
        System.assertEquals(testUser.Id, cases[0].OwnerId, 'The returned case Owner ID should match');
    }

    @isTest
    static void testGetCasesWithOtherRecordType() {
        // Retrieve test data
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        // Call the method with a different record type name
        Test.startTest();
        List<Case> emptyCases = CaseListViewController.getCases(null, 'Other Record Type', testUser.Id);
        Test.stopTest();

        // Assert results for empty cases
        System.assertEquals(0, emptyCases.size(), 'Expected no cases to be returned for a different record type');
    }
}



   /* @isTest
    static void testGetHostelCases() {
        // Setup test data
        RecordType hostelSupportRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'REVA_Hostel_Support_Request' LIMIT 1];
        
        Case testCase = new Case(
            RecordTypeId = hostelSupportRecordType.Id,
            Status = 'New',
            Priority = 'Medium',
            Hostel_Category__c = 'Maintenance'
        );
        insert testCase;

        // Call the method
        Test.startTest();
      //  List<Case> cases = CaseListViewController.getHostelCases(null, 'REVA Hostel Support Request', null);
        Test.stopTest();

        // Assert results
     //   System.assertEquals(1, cases.size(), 'Expected one case to be returned');
       // System.assertEquals(testCase.Id, cases[0].Id, 'The returned case ID should match');
    }

    @isTest
    static void testGetCasesForNonTeaching() {
        // Setup test data
        RecordType hostelSupportRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'REVA_Hostel_Support_Request' LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        Case testCase = new Case(
            RecordTypeId = hostelSupportRecordType.Id,
            CreatedById = testUser.Id,
            OwnerId = testUser.Id,
            Status = 'New',
            Priority = 'Low',
            Hostel_Category__c = 'Maintenance'
        );
        insert testCase;

        // Call the method
        Test.startTest();
        List<Case> cases = CaseListViewController.getCasesForNonTeaching(null, 'REVA Hostel Support Request', testUser.Id, testUser.Id);
        Test.stopTest();

        // Assert results
        System.assertEquals(1, cases.size(), 'Expected one case to be returned');
        System.assertEquals(testCase.Id, cases[0].Id, 'The returned case ID should match');
    }

    @isTest
    static void testCreateCase() {
        // Call the method
        Test.startTest();
      //  String result = CaseListViewController.createCase('Test description', 'Maintenance', 'IT', 'High');
        Test.stopTest();

        // Assert results
       // System.assert(result.contains('Case created successfully'), 'Case should be created successfully');
    }*/

 /*  @isTest
    static void testGetPicklistValues() {
        // Call the method
        Test.startTest();
        Map<String, List<String>> picklistValues = CaseListViewController.getPicklistValues();
        Test.stopTest();

        // Assert results
        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
        System.assert(picklistValues.containsKey('Hostel_Category__c'), 'Picklist values should contain Hostel_Category__c');
        System.assert(picklistValues.containsKey('Hostel_Sub_Category__c'), 'Picklist values should contain Hostel_Sub_Category__c');
        System.assert(picklistValues.containsKey('Priority'), 'Picklist values should contain Priority');
        
        // Optionally, you can also check specific picklist values if needed
        List<String> categoryValues = picklistValues.get('Hostel_Category__c');
        System.assertNotEquals(null, categoryValues, 'Hostel_Category__c picklist values should not be null');
        System.assert(!categoryValues.isEmpty(), 'Hostel_Category__c picklist values should not be empty');
        
        List<String> priorityValues = picklistValues.get('Priority');
        System.assertNotEquals(null, priorityValues, 'Priority picklist values should not be null');
        System.assert(!priorityValues.isEmpty(), 'Priority picklist values should not be empty');
    }*/