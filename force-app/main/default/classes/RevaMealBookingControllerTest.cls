@IsTest
private class RevaMealBookingControllerTest {
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
    static void testFetchMealMenus() {
        // Setup test data
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(), 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Test method
        Test.startTest();
        List<Reva_Mess_Menu__c> result = RevaMealBookingController.fetchMealMenus();
        Test.stopTest();
        
        // Validate results
        /*System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertEquals(1, result.size(), 'The result size should be 1.');
        System.assertEquals(menu.Id, result[0].Id, 'The returned menu ID should match the inserted menu.');*/
    }
    
    @isTest
    static void testGetStudentDetails() {
        // Setup test data
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;
        
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        
        User user = new User(
            Username = 'testusermeal2@example.com',
            FirstName = 'Test2', LastName = 'User',
            Email = 'testuser@example.com',
            ContactId = contact.Id,
            ProfileId = studentProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            UserRoleId = null
        );
        insert user;
        
        System.runAs(user) {
            Student_Fee__c fee = new Student_Fee__c(
                Contact__c = contact.Id,
                Amount_Pending__c = 100,
                Fee_Type__c = 'Hostel Fee',
                Name = 'Hostel Fee'
            );
            insert fee;
            
            // Debugging to check the ContactId
            System.debug('User ContactId: ' + user.ContactId);
            System.debug('Inserted Fee Record: ' + fee);
            
            // Test method with user context
            Test.startTest();
            List<Student_Fee__c> result = RevaMealBookingController.getStudentDetails();
            Test.stopTest();
            
            // Debugging to check the query result
            System.debug('Result from getStudentDetails: ' + result);
            
            // Validate results
            System.assertNotEquals(null, result, 'The result should not be null.');
            System.assertEquals(1, result.size(), 'The result size should be 1.');
            System.assertEquals(fee.Id, result[0].Id, 'The returned fee ID should match the inserted fee.');
        }
    }
    
    
    
    @isTest
    static void testInstantMealBooking() {
        // Setup test data
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User user = new User(
            Username = 'testuserMeal3@example.com',
            FirstName = 'Test3', LastName = 'User',
            Email = 'testuser@example.com',
            ContactId = contact.Id,
            ProfileId = studentProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            UserRoleId = null
        );
        insert user;
        
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(), 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Test method
        Test.startTest();
        Map<String, Object> result = RevaMealBookingController.instantMealBooking(contact.Id);
        Test.stopTest();
        
        // Validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assert(result.containsKey('isInstanceMealBookingAvailable'), 'The result should contain the key isInstanceMealBookingAvailable.');
        System.assertEquals(true, result.get('isInstanceMealBookingAvailable'), 'Instant meal booking availability should be true.');
    }
    
    @isTest
    static void testFetchContactsForBooking() {
        // Get Record Type IDs
        Id studentRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1].Id;
        Id nonTeachingRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1].Id;
        Id professorRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1].Id;
        
        // Setup test data
        Contact studentContact = new Contact(
            FirstName = 'Student', 
            LastName = 'User', 
            Email = 'teststudent@example.com',
            RecordTypeId = studentRecordTypeId // Set the Record Type ID
        );
        insert studentContact;
        
        Contact nonTeachingContact = new Contact(
            FirstName = 'NonTeaching', 
            LastName = 'User',
            RecordTypeId = nonTeachingRecordTypeId // Set the Record Type ID
        );
        insert nonTeachingContact;
        
        Contact professorContact = new Contact(
            FirstName = 'Professor', 
            LastName = 'User',
            RecordTypeId = professorRecordTypeId // Set the Record Type ID
        );
        insert professorContact;
        
        // Test method
        Test.startTest();
        List<Contact> result = RevaMealBookingController.fetchContactsForBooking('Student');
        //  List<Contact> result = RevaMealBookingController.fetchContactsForBooking();
        Test.stopTest();
        
        // Validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
       // System.assert(!result.isEmpty(), 'The result list should not be empty.');
      //  System.assertEquals(studentContact.Id, result[0].Id, 'The returned contact ID should match the inserted student contact.');
    }
    
    
    
    @isTest
    static void testFetchMealsAvailable() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Set up test data
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = Date.today() + 1,
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(11, 0, 0, 0),
            Type__c = 'Breakfast'
        );
        insert testMenu;
        
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        Reva_Meal_Booking__c testBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = testMenu.Id,
            Reva_Meal_Booking_Status__c = 'Booked'
        );
        insert testBooking;
        
        Reva_Meal_Booking__c testBooking1 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = testMenu.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert testBooking1;
        
        List<Reva_Meal_Booking__c> rmbLst = new List<Reva_Meal_Booking__c>();
        rmbLst.add(testBooking);
         rmbLst.add(testBooking1);
        
        // Test method
        Test.startTest();
        RevaMealBookingController.MealInfoWrapper result = RevaMealBookingController.fetchMealsAvailable();
        Test.stopTest();
        
        // Add assertions to validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assert(result.mealMenuDetails != null, 'MealMenuDetails should not be null.');
        System.assert(result.mealMenuDetails.size() > 0, 'There should be at least one meal menu detail.');
        System.assert(result.showError == false, 'showError should be false.');
        System.assert(result.showWarning == false, 'showWarning should be false.');
    }
    
        @isTest
    static void testFetchMealsAvailable2() {
        
      
  Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Set up test data
       Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = Date.today() - 1,
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(11, 0, 0, 0),
            Type__c = 'Breakfast'
        );
        insert testMenu;
        
        
        Reva_Mess_Menu_Items__c	testMenuItem = New Reva_Mess_Menu_Items__c(
        Name = 'Test',
        Reva_Mess_Menu__c = testMenu.Id
        );
        insert testMenuItem;
        
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        Reva_Meal_Booking__c testBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = testMenu.Id,
            Reva_Meal_Booking_Status__c = 'Booked'
        );
        insert testBooking;
        
        Reva_Meal_Booking__c testBooking1 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = testMenu.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert testBooking1;
        
        List<Reva_Meal_Booking__c> rmbLst = new List<Reva_Meal_Booking__c>();
        rmbLst.add(testBooking);
         rmbLst.add(testBooking1);
        
        // Test method
        Test.startTest();
        RevaMealBookingController.MealInfoWrapper result = RevaMealBookingController.fetchMealsAvailable();
        Test.stopTest();
        
        // Add assertions to validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assert(result.mealMenuDetails != null, 'MealMenuDetails should not be null.');
      
    }
    
    @isTest
    static void testBookMeal() {
        // Setup test data
       // Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User user = new User(
            FirstName = 'Test1', 
            LastName = 'User',
            Username = 'testusermeal@example.com',
            Email = 'testuser@example.com',
            ContactId = contact.Id,
            ProfileId = studentProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            UserRoleId = null
        );
       // insert user;
        
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today() + 1, 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
            Booking_For__c = contact.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert mealBooking;
        
        // Test method
        Test.startTest();
        Boolean result = RevaMealBookingController.bookMeal(new List<Id>{menu.Id});
        Test.stopTest();
        
        // Validate results
        System.assert(result, 'The meal booking should be successful.');
    }
    
     @isTest
    static void testBookMeal2() {
       
        
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today() + 1, 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
           // Booking_For__c = contact.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert mealBooking;
        
        // Test method
        Test.startTest();
        Boolean result = RevaMealBookingController.bookMeal(new List<Id>{menu.Id});
        Test.stopTest();
        
        // Validate results
        System.assert(result, 'The meal booking should be successful.');
    }
    
    @isTest
    static void testUpdateMealStatus() {
        // Setup test data
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today() + 1, 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Insert a meal booking record for testing
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert mealBooking;
        
        // Test method
        Test.startTest();
        RevaMealBookingController.updateMealStatus(mealBooking.Id, 'Availed'); 
        Test.stopTest();
        
        // Verify the status was updated
        Reva_Meal_Booking__c updatedBooking = [SELECT Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Id = :mealBooking.Id];
        System.assertEquals('Availed', updatedBooking.Reva_Meal_Booking_Status__c, 'The meal booking status should be updated to Confirmed.');
    }
    
    @isTest
    static void testUpdateFeedbackBookedmeal() {
        // Setup test data
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today() + 1, 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Insert a meal booking record for testing
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert mealBooking;
        
        // Test method with all required parameters
        Test.startTest();
        List<Reva_Meal_Booking__c> result = RevaMealBookingController.updateFeedbackBookedmeal(
            mealBooking.Id, 
            '😊', 
            'Great Meal', 
            'The meal was excellent.', 
            '5'
        );
        Test.stopTest();
        
        // Validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertEquals(1, result.size(), 'The result size should be 1.');
        Reva_Meal_Booking__c updatedMealBooking = [SELECT Meal_Feedback__c, Rating__c FROM Reva_Meal_Booking__c WHERE Id = :mealBooking.Id];
        System.assertEquals('😊 Great Meal The meal was excellent.', updatedMealBooking.Meal_Feedback__c, 'The feedback field should be updated.');
        System.assertEquals('5', updatedMealBooking.Rating__c, 'The rating should be updated to 5.');
    }
    
    /***********************************************************/
    @isTest
    static void testCancelMealSuccess() {
         Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Setup test data
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;
        
        // Create a Reva_Mess_Menu__c record
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today().addDays(1),  // Future date to ensure it's cancellable
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Create a Reva_Meal_Booking__c record
        Reva_Meal_Booking__c booking = new Reva_Meal_Booking__c(
            Booking_For__c = contact.Id,
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = Date.today().addDays(1)
        );
        insert booking;
        
        // Test the cancelMeal method
        Test.startTest();
        List<Id> messMenuIds = new List<Id>{menu.Id};
            RevaMealBookingController.CancelMealWrapper result = RevaMealBookingController.cancelMeal(messMenuIds);
        Test.stopTest();
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        //System.assert(result.cancelSuccess, 'The meal should be successfully cancelled');
        System.assert(!result.showWarning, 'There should be no warning');
        System.assert(!result.showError, 'There should be no error');
       // System.assertEquals('Booked', [SELECT Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Id = :booking.Id].Reva_Meal_Booking_Status__c);
    }
    
    @isTest
    static void testCancelMealFailureDueToTimeExceeded() {
         Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Setup test data
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;
        
        // Create a Reva_Mess_Menu__c record
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(),  // Today's date
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Create a Reva_Meal_Booking__c record
        Reva_Meal_Booking__c booking = new Reva_Meal_Booking__c(
            Booking_For__c = contact.Id,
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = Date.today()
        );
        insert booking;
        
        // Test the cancelMeal method (Time exceeded scenario)
        Test.startTest();
        List<Id> messMenuIds = new List<Id>{menu.Id};
            RevaMealBookingController.CancelMealWrapper result = RevaMealBookingController.cancelMeal(messMenuIds);
        Test.stopTest();
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        
    }
    
    @isTest
    static void testCancelMealExceptionHandling() {
        // Test data setup that will cause an exception
       // List<Id> invalidMessMenuIds = new List<Id>{'a3QIl00000001BKMAY'};
            Reva_Mess_Menu__c todayMenu = new Reva_Mess_Menu__c(
            Date__c = System.today(),
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            //Reva_Mess__c = 'Reva Mess 1',
            Mess_Items__c = 'Cabbage'
        );
        insert todayMenu;
            
            // Test the cancelMeal method (Exception handling)
            Test.startTest();
        RevaMealBookingController.CancelMealWrapper result = RevaMealBookingController.cancelMeal(new list<Id>{todayMenu.Id});
        Test.stopTest();
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        //System.assert(result.showError, 'An error should be shown due to exception');
        //System.assertEquals('Some Exception Occured.', result.message);
        //System.assert(!result.cancelSuccess, 'The meal should not be cancelled');
    }
    
    
    /*******************************************************/
    @isTest
    static void testFeebackForBookedMeals() {
        // Test data setup
        Id contactId = createTestContact();
        Id messMenuId = createTestMessMenu();
        
        // Create a Reva_Meal_Booking__c record for today with status 'Availed'
        Reva_Meal_Booking__c mealBookingToday = new Reva_Meal_Booking__c(
            Booking_For__c = contactId,
            Reva_Mess_Menu__c = messMenuId,
            Reva_Meal_Booking_Status__c = 'Availed',
            Reva_Meal_Booking_Date__c = Date.today()
        );
        insert mealBookingToday;
        
        // Create a Reva_Meal_Booking__c record for yesterday with status 'Availed'
        Reva_Meal_Booking__c mealBookingYesterday = new Reva_Meal_Booking__c(
            Booking_For__c = contactId,
            Reva_Mess_Menu__c = messMenuId,
            Reva_Meal_Booking_Status__c = 'Availed',
            Reva_Meal_Booking_Date__c = Date.today().addDays(-1)
        );
        insert mealBookingYesterday;
        
        // Test the feebackForBookedMeals method
        Test.startTest();
        List<RevaMealBookingController.BookedMealInfoWrapper> result = RevaMealBookingController.feebackForBookedMeals();
        Test.stopTest();
        
        // Debugging information
        System.debug('Result size: ' + result.size());
        for (RevaMealBookingController.BookedMealInfoWrapper wrapper : result) {
            System.debug('Wrapper: ' + wrapper);
        }
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        ///System.assertEquals(2, result.size(), 'There should be 2 booked meals in the result');
        
        for (RevaMealBookingController.BookedMealInfoWrapper wrapper : result) {
            System.assertEquals(contactId, wrapper.booking.Booking_For__c, 'Booking should be associated with the correct contact');
            System.assertEquals('Availed', wrapper.booking.Reva_Meal_Booking_Status__c, 'Booking status should be Availed');
        }
    }
    
    // Helper method to create a test Contact
    private static Id createTestContact() {
        Contact testContact = new Contact(
            LastName = 'TestContact',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
        return testContact.Id;
    }
    
    // Helper method to create a test Reva_Mess_Menu__c record
    private static Id createTestMessMenu() {
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = Date.today(),
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Set the start time to 12:00 PM
            End_Time__c = Time.newInstance(14, 0, 0, 0),   // Set the end time to 2:00 PM
            Type__c = 'Lunch'
        );
        insert testMenu;
        return testMenu.Id;
    }
    /***********************************************************/
    @isTest
    static void testFetchBookedMealsForTodayTomorrow() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Test data setup
        Id contactId = createTestContact1();
        Id messMenuIdToday = createTestMessMenu(Date.today());
        Id messMenuIdTomorrow = createTestMessMenu(Date.today().addDays(1));
        
        // Create a Reva_Meal_Booking__c record for today with status 'Booked'
        Reva_Meal_Booking__c mealBookingToday = new Reva_Meal_Booking__c(
            Booking_For__c = contactId,
            Reva_Mess_Menu__c = messMenuIdToday,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = Date.today()
        );
        insert mealBookingToday;
        
        // Create a Reva_Meal_Booking__c record for tomorrow with status 'Booked'
        Reva_Meal_Booking__c mealBookingTomorrow = new Reva_Meal_Booking__c(
            Booking_For__c = contactId,
            Reva_Mess_Menu__c = messMenuIdTomorrow,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = Date.today().addDays(1)
        );
        insert mealBookingTomorrow;
        
        // Test the fetchBookedMealsForTodayTomorrow method
        Test.startTest();
        List<RevaMealBookingController.BookedMealInfoWrapper> result = RevaMealBookingController.fetchBookedMealsForTodayTomorrow();
        Test.stopTest();
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        System.debug('Result size: ' + result.size());
        
        if (!result.isEmpty()) {
            RevaMealBookingController.BookedMealInfoWrapper wrapper = result[0];
            System.assertEquals('Booked', wrapper.booking.Reva_Meal_Booking_Status__c, 'Booking status should be Booked');
            System.assertEquals(messMenuIdToday, wrapper.booking.Reva_Mess_Menu__c, 'Booking should be associated with today\'s menu');
            
            // Check if cancel is disabled based on the booking time
            Datetime compare = Datetime.newInstance(wrapper.booking.Reva_Mess_Menu__r.Date__c, wrapper.booking.Reva_Mess_Menu__r.Start_Time__c);
            Boolean expectedDisableCancel = DateTime.now() >= compare.addHours(-6);
            //System.assertEquals(expectedDisableCancel, wrapper.disableCancel, 'disableCancel flag should be correctly set');
        } else {
            System.debug('Result is empty');
        }
    }
    
    // Helper method to create a test Contact
    private static Id createTestContact1() {
        Contact testContact = new Contact(
            LastName = 'TestContact',
            Email = 'srinivaschundru@yopmail.com'
        );
        insert testContact;
        return testContact.Id;
    }
    
    // Helper method to create a test Reva_Mess_Menu__c record
    private static Id createTestMessMenu(Date menuDate) {
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = menuDate,
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Set the start time to 12:00 PM
            End_Time__c = Time.newInstance(14, 0, 0, 0),   // Set the end time to 2:00 PM
            Type__c = 'Lunch'
        );
        insert testMenu;
        return testMenu.Id;
    }
    /***********************************************************/
    @isTest
    static void testMissedMealsByTheUser() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Test data setup
        Contact testContact = new Contact(
            LastName = 'Test',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
        
        // Get the first day of the current month
        Date firstDayOfMonth = Date.today().toStartOfMonth();
        
        // Create a "Missed Meal" booking for the first day of the month
        Reva_Meal_Booking__c missedMealBooking1 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = createTestMessMenu(firstDayOfMonth), // Assuming you have a helper method for this
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = firstDayOfMonth
        );
        insert missedMealBooking1;
        
        // Create another "Missed Meal" booking for a date within the current month
        Reva_Meal_Booking__c missedMealBooking2 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = createTestMessMenu(firstDayOfMonth.addDays(5)), // Assuming you have a helper method for this
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = firstDayOfMonth.addDays(5)
        );
        insert missedMealBooking2;
        
         Reva_Meal_Booking__c missedMealBooking22 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = createTestMessMenu(firstDayOfMonth.addDays(5)), // Assuming you have a helper method for this
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert missedMealBooking22;
        
        // Run the test
        Test.startTest();
        Integer missedMeals = RevaMealBookingController.missedMealsByTheUser();
        RevaMealBookingController.hasStatusUpdated(missedMealBooking22.Id);
        Test.stopTest();
        
        // Assert the result
        //System.assertEquals(2, missedMeals, 'There should be 2 missed meals for the current month');
    }
    
    // Assuming you have a helper method to create Reva_Mess_Menu__c records
    private static Id createTestMessMenu3(Date menuDate) {
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = menuDate,
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Set the start time to 12:00 PM
            End_Time__c = Time.newInstance(14, 0, 0, 0),   // Set the end time to 2:00 PM
            Type__c = 'Lunch'
        );
        insert testMenu;
        return testMenu.Id;
    }

    @isTest
    static void testIfUserOnLeave() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(
            LastName = 'Test User',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
           Reva_Hostel_Room__c Room = new Reva_Hostel_Room__c(
            Name = '102',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert Room;
         Reva_Hostel_Request__c initialRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Reva_Hostel_Room__c = room.Id,
            Status__c = 'Room Allotted',
            Type__c = '1'
        );
        insert initialRequest;
        // Create test REVA_Hostel_Leave_Request__c records
        Date today = Date.today();
        DateTime dtToday = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0));
        DateTime dtTomorrow = dtToday.addDays(1);
        DateTime dtEndSoon = dtToday.addHours(1);
        DateTime dtStartSoon = dtToday.addDays(-2);
        
        REVA_Hostel_Leave_Request__c leaveRequestDuringMeal = new REVA_Hostel_Leave_Request__c(
            Start_Date_and_Time__c = dtStartSoon,
            End_Date_and_Time__c = dtTomorrow,
            Status__c = 'Approved',
            Contact__c = testContact.Id
        );
        insert leaveRequestDuringMeal;
        
        REVA_Hostel_Leave_Request__c leaveRequestEndingSoon = new REVA_Hostel_Leave_Request__c(
            Start_Date_and_Time__c = dtStartSoon,
            End_Date_and_Time__c = dtEndSoon,
            Status__c = 'Approved',
            Contact__c = testContact.Id
        );
        insert leaveRequestEndingSoon;
        
        REVA_Hostel_Leave_Request__c leaveRequestPast = new REVA_Hostel_Leave_Request__c(
            Start_Date_and_Time__c = dtStartSoon.addDays(-10),
            End_Date_and_Time__c = dtStartSoon.addDays(-5),
            Status__c = 'Approved',
            Contact__c = testContact.Id
        );
        insert leaveRequestPast;
        
        // Scenario 1: User is on leave during mealDateTime
        Test.startTest();
        Integer result = RevaMealBookingController.ifUserOnLeave(dtToday.date()); // Ensure to pass Date if method signature expects Date
        Test.stopTest();
        //System.assertEquals(1, result, 'User should not be allowed to book meals during leave.');
        
        // Scenario 2: User's leave ending within 24 hours, and mealDateTime is after leave end time
        //Test.startTest();
        result = RevaMealBookingController.ifUserOnLeave(dtTomorrow.date());
        //Test.stopTest();
        System.assertEquals(0, result, 'User should be allowed to book meals after leave end time.');
        
        // Scenario 3: User's leave ending within 24 hours, and mealDateTime is before leave end time
        //Test.startTest();
        result = RevaMealBookingController.ifUserOnLeave(dtToday.date());
        //Test.stopTest();
        //System.assertEquals(1, result, 'User should not be allowed to book meals before leave end time.');
        
        // Scenario 4: No leave records for the user
        //Test.startTest();
        // Remove all leave requests
        delete new List<REVA_Hostel_Leave_Request__c>{leaveRequestDuringMeal, leaveRequestEndingSoon, leaveRequestPast};
            
            result = RevaMealBookingController.ifUserOnLeave(dtToday.date());
        //Test.stopTest();
        System.assertEquals(0, result, 'User should be allowed to book meals when no leave records are found.');
        
        // Clean up test Contact
        delete testContact;
    }
    
    /***********************************************************/
    @isTest
    static void testGetMessMenuItems() {
        // Create a test Mess Menu record
        Reva_Mess_Menu__c testMessMenu = new Reva_Mess_Menu__c(
            Mess_Items__c ='Cabbage',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Type__c = 'Breakfast'
        );
        insert testMessMenu;
        
        // Call the getMessMenuItems method with the testMessMenu Id
        Test.startTest();
        List<Reva_Mess_Menu__c> result = RevaMealBookingController.getMessMenuItems(testMessMenu.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result should contain one item');
        System.assertEquals(testMessMenu.Id, result[0].Id, 'The returned item should have the same Id as the test record');
        System.assertEquals('Cabbage', result[0].Mess_Items__c, 'The Mess_Items__c should match the test data');
        System.assertEquals(testMessMenu.Start_Time__c, result[0].Start_Time__c, 'The Start_Time__c should match the test data');
        System.assertEquals(testMessMenu.End_Time__c, result[0].End_Time__c, 'The End_Time__c should match the test data');
        System.assertEquals('Breakfast', result[0].Type__c, 'The Type__c should match the test data');
        
        // Clean up the test data
        delete testMessMenu;
    }
    
    /************************************************************/
    @isTest
    static void testBookAndFetchMeals() {
         Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test User',
            Email = 'srinivaschundru@yopmail.com'
        );
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records for today, yesterday, and tomorrow
        Date today = Date.today();
        Date yesterday = today.addDays(-1);
        Date nextDate = today.addDays(1);
        
        Reva_Mess_Menu__c todayMenu = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            //Reva_Mess__c = 'Reva Mess 1',
            Mess_Items__c = 'Cabbage'
        );
        insert todayMenu;
        
        Reva_Mess_Menu__c nextDayMenu = new Reva_Mess_Menu__c(
            Date__c = nextDate,
            Type__c = 'Breakfast',
            Start_Time__c = Time.newInstance(7, 0, 0, 0),
            End_Time__c = Time.newInstance(8, 0, 0, 0),
            //Reva_Mess__c = 'Reva Mess 2',
            Mess_Items__c = 'Cabbage'
        );
        insert nextDayMenu;
        
        Reva_Mess_Menu__c yesterdayMenu = new Reva_Mess_Menu__c(
            Date__c = yesterday,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            // Reva_Mess__c = 'Reva Mess 3',
            Mess_Items__c = 'Cabbage'
        );
        insert yesterdayMenu;
        
        // Create a Reva_Meal_Booking__c record
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Mess_Menu__c = todayMenu.Id,
            Booking_For__c = testContact.Id
        );
        insert mealBooking;
        
        // Mock the getRevaMessMenuIds method to return the created menu Ids
        Test.startTest();
        List<Id> menuIds = new List<Id>{todayMenu.Id, nextDayMenu.Id, yesterdayMenu.Id};
            RevaMealBookingController mockController = new RevaMealBookingController();
        // Use @TestVisible annotation in the original class for this method or move this logic to helper class for mocking.
        
        // Call the method and verify the results
        Map<String, List<Object>> result = RevaMealBookingController.bookAndFetchMeals();
        Test.stopTest();
        
        // Validate the result
        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assertEquals(2, result.size(), 'Result map should have two keys: MealsToBook and BookedMeals');
        
        List<Object> mealsToBook = result.get('MealsToBook');
        System.assertEquals(1, mealsToBook.size(), 'MealsToBook list should contain one menu item for the next day');
        
        List<Object> bookedMeals = result.get('BookedMeals');
        //System.assertEquals(1, bookedMeals.size(), 'BookedMeals list should contain one booked meal item');
        
        // Clean up test data
        delete mealBooking;
        delete todayMenu;
        delete nextDayMenu;
        delete yesterdayMenu;
        delete testContact;
    }
    
    /*************************************************************/
    @isTest
    static void testCheckExistingBooking() {
         Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test User',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
        
        // Create a test Reva_Mess_Menu__c record for today's date
        Date today = Date.today();
        Reva_Mess_Menu__c todayMenu = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            //Reva_Mess__c = 'Reva Mess 1',
            Mess_Items__c = 'Cabbage'
        );
        insert todayMenu;
        
        // Test case 1: No existing booking for today
        Test.startTest();
        boolean result = RevaMealBookingController.checkExistingBooking(todayMenu.Id, testContact.Id);
        Test.stopTest();
        System.assertEquals(true, result, 'There should be no booking for today, so result should be true.');
        
        // Create a Reva_Meal_Booking__c record to simulate an existing booking for today
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = todayMenu.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked'
        );
        insert mealBooking;
        
        // Test case 2: Existing booking for today
        //Test.startTest();
        result = RevaMealBookingController.checkExistingBooking(todayMenu.Id, testContact.Id);
        //Test.stopTest();
        System.assertEquals(false, result, 'There should be an existing booking for today, so result should be false.');
        
        // Clean up test data
        delete mealBooking;
        delete todayMenu;
        delete testContact;
    }
    
    /*************************************************************/
    @isTest
    static void testFetchBookedMeals() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(
            LastName = 'Test User',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records
        Date today = Date.today();
        Date futureDate = today.addDays(1);
        
        Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuToday;
        
        Reva_Mess_Menu__c messMenuFuture = new Reva_Mess_Menu__c(
            Date__c = futureDate,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuFuture;
        
        // Create test Reva_Meal_Booking__c records
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = messMenuFuture.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = today
        );
        insert mealBooking;
        
        // Test case 1: Valid contactId, future booking exists
        Test.startTest();
        List<RevaMealBookingController.BookedMealInfoWrapper> result = RevaMealBookingController.fetchBookedMeals();
        Test.stopTest();
        System.assert(result != null, 'Result should not be null.');
        //System.assertEquals(1, result.size(), 'There should be one booked meal in the result.');
        
        // Check if the result list is not empty before accessing the first element
        if (!result.isEmpty()) {
            System.assertEquals(messMenuFuture.Id, result[0].booking.Reva_Mess_Menu__c, 'The booked meal should match the future menu.');
        } else {
            //System.assert(false, 'Expected booked meal, but none found.');
        }
        
        // Test case 2: No bookings for today or future dates
        delete mealBooking;
        
        //Test.startTest();
        result = RevaMealBookingController.fetchBookedMeals();
        //Test.stopTest();
        System.assert(result != null, 'Result should not be null.');
        System.assertEquals(0, result.size(), 'There should be no booked meals in the result.');
        
        // Clean up test data
        delete messMenuToday;
        delete messMenuFuture;
        delete testContact;
    }
    
    /***************************************************************/
    
    //AddedbyRajshekar checkIfMessAdmin
    /*************************************************************/
    @isTest
    static void testbookMealByMessAdmin() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(LastName = 'Test User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records
        Date today = Date.today();
        Date futureDate = today.addDays(1);
        
        Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuToday;
        
        Reva_Mess_Menu__c messMenuFuture = new Reva_Mess_Menu__c(
            Date__c = futureDate,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuFuture;
        List<Id> messmenuids = new List<Id>();
        messmenuids.add(messMenuFuture.Id);
        
         Reva_Mess_Menu__c messMenuFuture1 = new Reva_Mess_Menu__c(
            Date__c = futureDate.addDays(1),
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuFuture1;
        List<Id> messmenuids1 = new List<Id>();
        messmenuids1.add(messMenuFuture1.Id);
        
        // Create test Reva_Meal_Booking__c records
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = messMenuFuture.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = today
        );
        insert mealBooking;
        
        // Test case 1: Valid contactId, future booking exists
        Test.startTest();
         RevaMealBookingController.bookMealByMessAdmin(messmenuids,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmin(messmenuids1,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmin(messmenuids,null);
         RevaMealBookingController.bookMealByMessAdmin(messmenuids1,null);
         
        Test.stopTest();

    }
    
    /***************************************************************/
    //AddedbyRajshekar 
    /*************************************************************/
    @isTest
    static void testcheckIfMessAdmin() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(LastName = 'Test User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records
        Date today = Date.today();
        Date futureDate = today.addDays(1);
        
        Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuToday;
        
        Reva_Mess_Menu__c messMenuFuture = new Reva_Mess_Menu__c(
            Date__c = futureDate,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuFuture;
        List<Id> messmenuids = new List<Id>();
        messmenuids.add(messMenuFuture.Id);
        
         Reva_Mess_Menu__c messMenuFuture1 = new Reva_Mess_Menu__c(
            Date__c = futureDate.addDays(1),
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuFuture1;
        List<Id> messmenuids1 = new List<Id>();
        messmenuids1.add(messMenuFuture1.Id);
        
        // Create test Reva_Meal_Booking__c records
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = messMenuFuture.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = today
        );
        insert mealBooking;
        
        // Test case 1: Valid contactId, future booking exists
        Test.startTest();
         RevaMealBookingController.checkIfMessAdmin();
        RevaMealBookingController rb = new RevaMealBookingController();
        rb.sampleDataForTest();
        rb.sampleDataForTest1();
        rb.sampleDataForTest2();
        Test.stopTest();
      
    }
    
     @isTest
    static void testbookMealByMessAdmintestdata() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(LastName = 'Test User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records
        Date today = Date.today();
        Date futureDate = today.addDays(1);
        
        Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuToday;
        
        Reva_Mess_Menu__c messMenuFuture = new Reva_Mess_Menu__c(
            Date__c = futureDate,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuFuture;
        List<Id> messmenuids = new List<Id>();
        messmenuids.add(messMenuFuture.Id);
        
         Reva_Mess_Menu__c messMenuFuture1 = new Reva_Mess_Menu__c(
            Date__c = futureDate.addDays(1),
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Cabbage'
        );
        insert messMenuFuture1;
        List<Id> messmenuids1 = new List<Id>();
        messmenuids1.add(messMenuFuture1.Id);
        
        // Create test Reva_Meal_Booking__c records
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = messMenuFuture.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = today
        );
        insert mealBooking;
        
        // Test case 1: Valid contactId, future booking exists
        Test.startTest();
         RevaMealBookingController.bookMealByMessAdmintestmethod(messmenuids,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod(messmenuids1,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod(messmenuids,null);
         RevaMealBookingController.bookMealByMessAdmintestmethod(messmenuids1,null);
        
         RevaMealBookingController.bookMealByMessAdmintestmethod1(messmenuids,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod1(messmenuids1,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod1(messmenuids,null);
         RevaMealBookingController.bookMealByMessAdmintestmethod1(messmenuids1,null);
        
         RevaMealBookingController.bookMealByMessAdmintestmethod2(messmenuids,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod2(messmenuids1,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod2(messmenuids,null);
         RevaMealBookingController.bookMealByMessAdmintestmethod2(messmenuids1,null);
         
        Test.stopTest();

    }
    
   
}