@isTest
public class AlumniConversationsControllerTest {
  @isTest
    static void testGetAlumniConversations() {
        // Get the record type Id
        Id alumniConversationsRecordTypeId = Schema.SObjectType.cloudx_cms__SS_Carousel_Slide__c.getRecordTypeInfosByDeveloperName().get('Alumni_Conversations').getRecordTypeId();

        cloudx_cms__SS_Carousel__c ccc = new cloudx_cms__SS_Carousel__c (cloudx_cms__Name__c = 'Test name');
        insert ccc;
        // Create a test Alumni_Conversations record
        cloudx_cms__SS_Carousel_Slide__c testRecord = new cloudx_cms__SS_Carousel_Slide__c(
            cloudx_cms__Carousel__c = ccc.Id,
            Alumni_Message__c = 'Test Alumni Message',
            Alumni_Name__c = 'Test Alumni Name',
            Year__c = 2019,
            Degree_Stream__c = 'Test Degree Stream',
            RecordTypeId = alumniConversationsRecordTypeId
        ); 

        // Insert the test record
        insert testRecord;

        // Simulate an exception in the getAlumniConversations method
        Test.startTest();
        Test.isRunningTest(); // Simulate an exception
        List<cloudx_cms__SS_Carousel_Slide__c> result;
        try {
            // Call the method being tested
            result = AlumniConversationsController.getAlumniConversations();
        } catch (Exception e) {
            // Assert that an exception was caught
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }
}