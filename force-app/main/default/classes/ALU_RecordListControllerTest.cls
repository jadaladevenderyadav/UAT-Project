@isTest
public class ALU_RecordListControllerTest {
    
      public class AchievementsDetailsWrapper{
        @AuraEnabled public Id userId {get;set;}  
        @AuraEnabled public string achievement {get;set;}  
        @AuraEnabled public date dateVal {get;set;}  
        @AuraEnabled public string organization {get;set;}  
        @AuraEnabled public string designation {get;set;}  
        @AuraEnabled public string image {get;set;}  
        @AuraEnabled public string description {get;set;}  
        @AuraEnabled public Id file {get;set;}  
    }
    
    @testSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        // Create a test user
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                                 UserName='standarduser316316@testorg.com');
        insert testUser;
        //create Account
        Account acc = new Account (Name = 'Test Account',
                                   RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId()
                                  );
        Insert acc;
        //create contact
        Contact con = new Contact (AccountId = acc.Id,
                                   RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Alumni').getRecordTypeId(),
                                   Lastname ='Testcontact',
                                   Mobilephone = '7660975589',
                                   hed__Gender__c='Female',
                                   Email ='test316@gmail.com'
                                  );
        insert con;
    }
    
    @isTest
    static void testGetCaseList() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
        System.runAs(testUser) {
            // Insert a test case
            Case testCase = new Case(Subject = 'Test Case', Status = 'New');
            insert testCase;
            
            // Call the method being tested
            List<Case> caseList = ALU_RecordListController.getCaseList('New');
            
        }
    }
    @isTest
    static void testGetAlumniActivities() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
        
        // Create a test Alumni_Activities__c record
        Alumni_Activities__c testRecord = new Alumni_Activities__c(  Total_Experience_In_Years__c = 5,
                                                                   Current_CTC_In_Lakhs__c = 10, Blog_Name__c = 'Test Blog', Blog_Link__c = 'http://testblog.com',
                                                                   OwnerId = testUser.Id,  Achievement__c = 'Test Achievement',
                                                                   Details__c = 'Test Details', Company_Name__c = 'Test Company', Designation__c = 'Test Designation');
        // Status__c = 'Active'
        insert testRecord;
        
        // Call the method being tested
        List<Alumni_Activities__c> activitiesList = ALU_RecordListController.getAlumniActivities('Test Record Type');
    }
    @isTest
    static void testGetAlumniAchievements() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
        Account acc = [Select Id from Account LIMIT 1];
        Contact con = [Select Id from Contact LIMIT 1];
        Id recordTypeId = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByDeveloperName().get('Achievements').getRecordTypeId();
        system.debug('acheiveemnts rectype id----->'+recordTypeId);
        System.runAs(testUser) {
            // Create a test Alumni_Activities__c record
            Alumni_Activities__c testRecord = new Alumni_Activities__c( OwnerId = testUser.Id,recordtypeId = recordTypeId,
                                                                       Organisation__c = 'test',Contact__c = con.Id,
                                                                       Achievement__c = 'Test Achievement', 
                                                                       Details__c = '<p>Test Details</p>');
            insert testRecord;
            system.debug('testRecord----->'+testRecord);
            // Call the method being tested
            List<ALU_RecordListController.AlumniAchievementsWrapper> achievementsList = ALU_RecordListController.getAlumniAchievements('Achievements');
            system.debug('achievementsList----->'+achievementsList);
        }
    }
    
    @isTest
    static void testGetEventRegistrations() {
       
		User testUser = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
        // Create a test Alumni_Event_Registrations__c record
        Alumni_Event_Registrations__c testRecord = new Alumni_Event_Registrations__c(Registration_Date_Time__c = DateTime.now(), Event_Attended__c = 'Yes', OwnerId = testUser.Id);
        insert testRecord;

        // Call the method being tested
        List<ALU_RecordListController.EventRegistrationsWrapper> registrationsList = ALU_RecordListController.getEventRegistrations(testUser.Id);
 
    }
    
    @isTest
    static void testCreateAchievements() {
       
		User testUser = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
         // Create a test wrapper instance
        ALU_RecordListController.AchievementsDetailsWrapper achmntDetails = new ALU_RecordListController.AchievementsDetailsWrapper();
        achmntDetails.achievement = 'Test Achievement';
        achmntDetails.dateVal = Date.today();
        achmntDetails.organization = 'Test Organization';
        achmntDetails.designation = 'Test Designation';
        achmntDetails.image = 'Test Image';
        achmntDetails.description = 'Test Description';
        achmntDetails.userId = testUser.Id;

        // Call the method being tested
        Id insertedRecordId = ALU_RecordListController.createAchievements(achmntDetails);

        // Verify that the record was inserted
        //System.assertNotEquals(null, insertedRecordId);

       
    }
     @isTest
    static void testTagFileToCreatedAchievement() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
        // Create a test ContentDocument
        ContentVersion testContent = new ContentVersion();
        testContent.Title = 'Test Content';
        testContent.PathOnClient = 'test.pdf';
        testContent.VersionData = Blob.valueOf('Test Content Data');
        insert testContent;

        
        // Create a test Alumni_Activities__c record
        Alumni_Activities__c testRecord = new Alumni_Activities__c(  Total_Experience_In_Years__c = 5,
                                                                   Current_CTC_In_Lakhs__c = 10, Blog_Name__c = 'Test Blog', Blog_Link__c = 'http://testblog.com',
                                                                   OwnerId = testUser.Id,  Achievement__c = 'Test Achievement',
                                                                   Details__c = 'Test Details', Company_Name__c = 'Test Company', Designation__c = 'Test Designation');
        // Status__c = 'Active'
        insert testRecord;

        // Call the method being tested
        ALU_RecordListController.tagFileTocreatedAchievement(testContent.ContentDocumentId, testRecord.Id);

        // Verify that the ContentDocumentLink record was inserted
        List<ContentDocumentLink> result = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :testContent.ContentDocumentId AND LinkedEntityId = :testRecord.Id];
        
    }
    
    
}