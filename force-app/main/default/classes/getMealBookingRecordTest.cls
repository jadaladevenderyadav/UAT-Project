@isTest
public class getMealBookingRecordTest {
    
    @isTest
    static void testGetRecord() {
        // Step 1: Create a test Contact record
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com'
        );
        insert testContact;
        
        // Step 2: Create a test REVA_Mess_Menu__c record with mandatory fields
        REVA_Mess_Menu__c testMenu = new REVA_Mess_Menu__c(
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Example start time: 09:00 AM
            End_Time__c = Time.newInstance(13, 0, 0, 0),   // Example end time: 05:00 PM
            Date__c = System.today() // Example date: today's date
        );
        insert testMenu;
        
        // Step 3: Create a test Reva_Meal_Booking__c record with all mandatory fields
        Reva_Meal_Booking__c testRecord = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = System.today(),
            Reva_Mess_Menu__c = testMenu.Id,
            Booking_For__c = testContact.Id
        );
        insert testRecord;
        
        // Step 4: Call the method
        Test.startTest();
        Reva_Meal_Booking__c result = getMealBookingRecord.getRecord(testRecord.Id);
        Test.stopTest();
        
        // Step 5: Assertions
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertEquals(testRecord.Id, result.Id, 'The record ID should match.');
        System.assertEquals('Booked', result.Reva_Meal_Booking_Status__c, 'The meal booking status should match.');
        /*System.assertEquals(System.today(), result.Reva_Meal_Booking_Date__c, 'The meal booking date should match.');
        System.assertEquals(testMenu.Id, result.Reva_Mess_Menu__c, 'The mess menu ID should match.');
        System.assertEquals(testContact.Id, result.Booking_For__c, 'The contact ID should match.');*/
    }
}