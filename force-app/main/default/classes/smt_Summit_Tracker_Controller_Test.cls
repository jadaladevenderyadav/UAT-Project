@isTest
private class smt_Summit_Tracker_Controller_Test {
    @isTest
    static void testCreateSummitTracker() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        String summitTrackerName = 'Test Summit Tracker';
        String schoolId = acc.Id;
        String batch = '2024';

        Test.startTest();
        String summitTrackerId = smt_Summit_Tracker_Controller.createSummitTracker(summitTrackerName, schoolId, batch);
        Test.stopTest();

        System.assertNotEquals(null, summitTrackerId, 'Summit Tracker was not created successfully');
    }

    @isTest
    static void testGetSummitParticulars() {
        String summitSectionId = '001';
        String oddSemester = 'Odd';
		String evenSemester = 'Even';
        
        Test.startTest();
        List<smt_Summit_Particular__c> oddSummitParticulars = smt_Summit_Tracker_Controller.getSummitParticulars(summitSectionId, oddSemester);
        List<smt_Summit_Particular__c> evenSummitParticulars = smt_Summit_Tracker_Controller.getSummitParticulars(summitSectionId, evenSemester);

        Test.stopTest();

        System.assertEquals(0, oddSummitParticulars.size(), 'Summit Particulars not retrieved successfully');
        System.assertEquals(0, evenSummitParticulars.size(), 'Summit Particulars not retrieved successfully');

    }

    @isTest
    static void testGetAllSummitParticulars() {
        // Test data setup
        String summitSectionId = '001';

        // Call the method under test
        Test.startTest();
        List<smt_Summit_Particular__c> allSummitParticulars = smt_Summit_Tracker_Controller.getAllSummitParticulars(summitSectionId);
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, allSummitParticulars, 'All Summit Particulars not retrieved successfully');
    }

    @isTest
    static void testGetSummitTracker() {
        // Test data setup
        String schoolId = '001';

        // Call the method under test
        Test.startTest();
        List<smt_Summit_Tracker__c> summitTrackers = smt_Summit_Tracker_Controller.getSummitTracker(schoolId);
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, summitTrackers, 'Summit Tracker not retrieved successfully');
    }

    @isTest
    static void testUpdateSummitParticular() {
         Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024,smt_School__c =acc.Id);
        insert summitTracker;
        
        smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c= summitTracker.Id);
        insert summitSection;
        
		smt_Summit_Particular__c summitParticular = new smt_Summit_Particular__c(Name = 'Test Particular', smt_Achieved__c = 10, smt_Summit_Section__c = summitSection.Id);  
        insert summitParticular;
       
        String jsonData = '{"Id": "'+ summitParticular.Id+'", "achievedValue": "10", "evidenceValue": "https://google.com"}';

        Test.startTest();
        smt_Summit_Tracker_Controller.updateSummitParticular(jsonData);
        Test.stopTest();
		List<smt_Summit_Particular__c> updatedSummitParticular = [Select Id, smt_Achieved__c	 From smt_Summit_Particular__c Where Id =: summitParticular.Id];
        System.assertEquals(10, updatedSummitParticular[0].smt_Achieved__c);
    }

    @isTest
    static void testUpdateAllSummitParticular() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024,smt_School__c =acc.Id);
        insert summitTracker;
        
        smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c= summitTracker.Id);
        insert summitSection;
        
		smt_Summit_Particular__c summitParticular = new smt_Summit_Particular__c(Name = 'Test Particular', smt_Achieved__c = 10, smt_Summit_Section__c = summitSection.Id);  
        insert summitParticular;
        
        String jsonData = '[{"id": "001", "summitParticularName": "Test", "summitParticularId": "'+summitParticular.Id +'", "timeline": "2024-04-16", "target": 50, "targetText": "Test target", "isTargetApplicable": true, "isEvidenceApplicable": true}]';
        Test.startTest();
        smt_Summit_Tracker_Controller.updateAllSummitParticular(jsonData);
        Test.stopTest();
        
        List<smt_Summit_Particular__c> updatedSummitParticular = [Select Id, smt_Target__c	 From smt_Summit_Particular__c Where Id =: summitParticular.Id];
        System.assertEquals(50, updatedSummitParticular[0].smt_Target__c);
        
        
    }

    @isTest
    static void testIsDecimal() {
        // Call the method under test
        Boolean result = smt_Summit_Tracker_Controller.isDecimal('10');

        // Perform assertions
        System.assertEquals(true, result, 'Expected true for valid decimal input');
    }

    @isTest
    static void testGetSummitSectionsMetadata() {
        // Call the method under test
        Test.startTest();
        List<Summit_Section_Metadata__mdt> summitSectionsMetadata = smt_Summit_Tracker_Controller.getSummitSectionsMetadata();
        Test.stopTest();

        // Perform assertions - No direct assertions can be made as the method does not return anything
    }

    @isTest
    static void testGetSummitParticularsMetadata() {
        // Test data setup
        String summitSectionLabel = 'Test Section';

        // Call the method under test
        Test.startTest();
        List<Summit_Particular__mdt> summitParticularsMetadata = smt_Summit_Tracker_Controller.getSummitParticularsMetadata(summitSectionLabel);
        Test.stopTest();

        // Perform assertions - No direct assertions can be made as the method does not return anything
    }

    @isTest
    static void testGetSummitSectionRecords() {
        // Test data setup
        String summitTrackerId = '001';

        // Call the method under test
        Test.startTest();
        List<smt_Summit_Section__c> summitSections = smt_Summit_Tracker_Controller.getSummitSectionRecords(summitTrackerId);
        Test.stopTest();

        // Perform assertions - No direct assertions can be made as the method does not return anything
    }

    @isTest
    static void testCreateSummitSections() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024,smt_School__c =acc.Id);
        insert summitTracker;
        
        String jsonData = '[{"sectionName": "Test Section", "weightage": 50}]';
        String summitTrackerId = summitTracker.Id;

        Test.startTest();
        smt_Summit_Tracker_Controller.createSummitSections(jsonData, summitTrackerId);
        Test.stopTest();
        
        List<smt_Summit_Section__c> summitSections = [ Select Id From smt_Summit_Section__c Where smt_Summit_Tracker__c =: summitTrackerId];
        System.assertEquals(1, summitSections.size());

    }

    @isTest
    static void testCreateSummitParticular() {
        
		Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024,smt_School__c =acc.Id);
        insert summitTracker;
        
        smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c= summitTracker.Id);
        insert summitSection;
        
        
        String jsonData = '[{"summitParticularName": "Test", "summitParticularId": "001", "timeline": "2024-04-16", "target": 50, "targetText": "Test target", "isTargetApplicable": true, "isEvidenceApplicable": true}]';
        String summitSectionId = summitSection.Id;

        Test.startTest();
        smt_Summit_Tracker_Controller.createSummitParticular(jsonData, summitSectionId);
        Test.stopTest();
        
        List<smt_Summit_Particular__c> summitParticulars = [Select Id From smt_Summit_Particular__c 
                                                            Where smt_Summit_Section__c =:summitSection.Id];
        
        System.assertEquals(1, summitParticulars.size());

    }

    @isTest
    static void testJsonToSummitSection() {

        String json = '[{"id": 1, "sectionName": "Test Section", "weightage": 50}]';
        List<smt_Summit_Tracker_Controller.JsonToSummitSection> result = new smt_Summit_Tracker_Controller.JsonToSummitSection().parse(json);
        System.assertNotEquals(null, result, 'JsonToSummitSection parsing failed');
    }

    @isTest
    static void testJsonToSummitParticular() {
        String json = '[{"id": 1, "summitParticularName": "Test", "summitParticularId": "001", "timeline": "2024-04-16", "target": 50, "targetText": "Test target", "isTargetApplicable": true, "isEvidenceApplicable": true}]';
        List<smt_Summit_Tracker_Controller.JsonToSummitParticular> result = new smt_Summit_Tracker_Controller.JsonToSummitParticular().parse(json);
        System.assertNotEquals(null, result, 'JsonToSummitParticular parsing failed');
    }

    @isTest
    static void testJsonToUpdateSummitParticular() {
        String json = '{"id": "001", "achievedValue": "10", "evidenceValue": "Some evidence"}';
        smt_Summit_Tracker_Controller.JsonToUpdateSummitParticular result = new smt_Summit_Tracker_Controller.JsonToUpdateSummitParticular().parse(json);
        System.assertNotEquals(null, result, 'JsonToUpdateSummitParticular parsing failed');
    }
}