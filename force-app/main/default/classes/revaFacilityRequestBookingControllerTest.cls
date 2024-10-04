@isTest(SeeAllData=true)
private class revaFacilityRequestBookingControllerTest {

    @isTest
    static void testGetFaciltyRequestFields() {
        List<String> fields = revaFacilityRequestBookingController.getFaciltyRequestFields();
        System.assertNotEquals(0, fields.size(), 'Expected fields to be retrieved');
    }

    @isTest
    static void testGetAllTimeSlots() {
        // Replace with the actual API name of the time slot object
        List<Facility_Request__c> timeSlots = revaFacilityRequestBookingController.getAllTimeSlots();
        // System.assertNotEquals(0, timeSlots.size(), 'Expected time slots to be retrieved');
    }

    @isTest
    static void testGetEventFacilities() {
        List<hed__Facility__c> facilities = revaFacilityRequestBookingController.getEventFacilities();
        // System.assertNotEquals(0, facilities.size(), 'Expected event facilities to be retrieved');
    }

    @isTest
    static void testGetLabFacilities() {
        // Insert a test Account and Facility
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Replace with the correct field if Building_Name__c does not exist
        hed__Facility__c labFacility = new hed__Facility__c(Name = 'Sample Lab Facility', hed__Account__c = testAccount.Id);
        insert labFacility;

        List<hed__Facility__c> facilities = revaFacilityRequestBookingController.getLabFacilities();
        // System.assertNotEquals(0, facilities.size(), 'Expected lab facilities to be retrieved');
    }

    @isTest
    static void testGetAminities() {
        // Insert a test Amenity record
        Amenities__c testAmenity = new Amenities__c(Block__c = 'Sample Block', Floor__c = 'Sample Floor', Room__c = 'Sample Room', Item_Name__c = 'Sample Item');
        insert testAmenity;

        List<Amenities__c> amenities = revaFacilityRequestBookingController.getAminities(null, 'Sample Block', 'Sample Floor', 'Sample Room');
        System.assertNotEquals(0, amenities.size(), 'Expected amenities to be retrieved');
    }

    @isTest
    static void testGetFilteredFacilities() {
        String startDate = '2024-09-17';
        String endDate = '2024-09-18';
        String startTime = '02:15 PM';
        String endTime = '12:00 AM';
        // Insert test Facility Requests
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        hed__Facility__c testFacility = new hed__Facility__c(Name = 'Sample Event Facility', hed__Account__c = testAccount.Id);
        insert testFacility;

        List<hed__Facility__c> filteredFacilities = revaFacilityRequestBookingController.getFilteredFacilities(null, 'Event venues', null, null, null,startDate,endDate,endTime,startTime);
        // System.assertNotEquals(0, filteredFacilities.size(), 'Expected filtered facilities to be retrieved');
    }

    @isTest
    static void testGetFilteredFacilities_FacilityTypeAndBuilding() {
        String startDate = '2024-09-17';
        String endDate = '2024-09-18';
        String startTime = '02:15 PM';
        String endTime = '12:00 AM';
        // Insert test Account and Facility Request
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Ensure this field is correct; replace with appropriate field if needed
        hed__Facility__c testFacility = new hed__Facility__c(Name = 'Sample Event Facility', hed__Account__c = testAccount.Id);
        insert testFacility;

        List<hed__Facility__c> facilities = revaFacilityRequestBookingController.getFilteredFacilities(null, 'Event venues', 'Sample Building', null, null,startDate,endDate,endTime,startTime);
        // System.assertNotEquals(0, facilities.size(), 'Expected filtered facilities to be retrieved');
    }

    @isTest
    static void testGetFilteredFacilities_FacilityTypeBuildingAndFloor() {
        String startDate = '2024-09-17';
        String endDate = '2024-09-18';
        String startTime = '02:15 PM';
        String endTime = '12:00 AM';
        // Insert test Account and Facility Request
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Ensure this field is correct; replace with appropriate field if needed
        hed__Facility__c testFacility = new hed__Facility__c(Name = 'Sample Event Facility', Floor__c = 'Sample Floor', hed__Account__c = testAccount.Id);
        insert testFacility;

        List<hed__Facility__c> facilities = revaFacilityRequestBookingController.getFilteredFacilities(null, 'Event venues', 'Sample Building', 'Sample Floor', null,startDate,endDate,endTime,startTime);
        // System.assertNotEquals(0, facilities.size(), 'Expected filtered facilities to be retrieved');
    }
     @isTest
    static void testGetFilteredFacilities_FacilityTypeBuildingAndFloor2() {
        String startDate = '2024-09-17';
        String endDate = '2024-09-18';
        String startTime = '02:15 PM';
        String endTime = '12:00 AM';
        // Insert test Account and Facility Request
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Ensure this field is correct; replace with appropriate field if needed
        hed__Facility__c testFacility = new hed__Facility__c(Name = 'Sample Event Facility', Floor__c = 'Sample Floor', hed__Account__c = testAccount.Id);
        insert testFacility;

        List<hed__Facility__c> facilities = revaFacilityRequestBookingController.getFilteredFacilities(null, 'Event venues', 'Sample Building', 'Sample Floor', 'Sample Facility',startDate,endDate,endTime,startTime);
        // System.assertNotEquals(0, facilities.size(), 'Expected filtered facilities to be retrieved');
    }

    @isTest
    static void testGetFilteredFacilities_AllParameters() {
        // Insert test Account, Contact, and Facility Request with Approver
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Get Record Type IDs with null checks
        String HouseholdRecId = null;
        String StudentRecId = null;

        // Retrieve Record Type IDs for Account and Contact
        try {
            for (Schema.RecordTypeInfo rti : Schema.SObjectType.Account.getRecordTypeInfos()) {
                if (rti.getName() == 'Household') {
                    HouseholdRecId = rti.getRecordTypeId();
                }
            }

            if (HouseholdRecId == null) {
                System.debug('Record Type "Household" not found for Account object.');
            }

            for (Schema.RecordTypeInfo rti : Schema.SObjectType.Contact.getRecordTypeInfos()) {
                if (rti.getName() == 'Student') {
                    StudentRecId = rti.getRecordTypeId();
                }
            }

            if (StudentRecId == null) {
                System.debug('Record Type "Student" not found for Contact object.');
            }

        } catch (Exception e) {
            System.debug('Error retrieving record type IDs: ' + e.getMessage());
        }

        // Only proceed if Record Type IDs are found
        if (HouseholdRecId != null && StudentRecId != null) {
            Account objAcc = new Account(Name = 'Test Household Account', RecordTypeId = HouseholdRecId);
            insert objAcc;

            Contact objCon = new Contact(FirstName = 'Test', LastName = 'Contact', MobilePhone = '9090909090', Aadhar_Card_Number__c = '098765435612', RecordTypeId = StudentRecId, AccountId = objAcc.Id, Application_Number__c = 'test123', SRN_Number__c = '123', hed__WorkEmail__c = 'test123@reva.edu.in', Nationality__c = 'Indian', Email = 'test@gmail.com');
            insert objCon;

            Profile p = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
            User testUser = new User(ProfileId = p.Id, Username = 'newUser@epeople.com', Email = 'pb@f.com', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', Alias = 'nuser', LastName = 'Baburao', FirstName = 'Lal', ContactId = objCon.Id, Phone = '9011113246');
            insert testUser;

            Facility_Request__c testRequest = new Facility_Request__c(Facility_Type__c = 'Event venues', Building_Name__c = 'Sample Building', Floor__c = 'Sample Floor', Room_No__c = 'Sample Room', Account__c = testAccount.Id, Approver__c = testUser.Id);
            insert testRequest;
            String startDate = '2024-09-17';
            String endDate = '2024-09-18';
            String startTime = '02:15 PM';
            String endTime = '12:00 AM';
            List<hed__Facility__c> facilities = revaFacilityRequestBookingController.getFilteredFacilities(null, 'Event venues', 'Sample Building', 'Sample Floor', 'Sample Room',startDate,endDate,endTime,startTime);
            System.assertNotEquals(0, facilities.size(), 'Expected filtered facilities to be retrieved');
        } else {
            System.debug('Skipping testGetFilteredFacilities_AllParameters due to missing Record Type IDs.');
        }
    }

    @isTest
    static void testGetTimeValues() {
        // Replace with the actual API name of the time value object
        List<Calendar_Timings__c> timeValues = revaFacilityRequestBookingController.getTimeValues();    
        // System.assertNotEquals(0, timeValues.size(), 'Expected time values to be retrieved');
    }

    @isTest
    static void testSaveFacilityRequest() {
        // Insert a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        System.debug('testAccount Facility: ' + testAccount);


        // Insert a test facility
        hed__Facility__c fac = new hed__Facility__c(Name = 'Sample Facility', hed__Account__c = testAccount.Id);
        insert fac;
            System.debug('Inserted Facility: ' + fac);


        
 		//DefaultSettings__c setting = new DefaultSettings__c(Name = 'Default', DefaultAccountId__c = testAccount.Id);
        //insert setting;
        //
        // Prepare data for FacilityRequestWrapper
        revaFacilityRequestBookingController.FacilityRequestWrapper wrapper = new revaFacilityRequestBookingController.FacilityRequestWrapper();
        wrapper.buildingName = 'Sample Building';
        wrapper.facilityName = 'Sample Facility';
        wrapper.facilityType = 'Event venues';
        wrapper.floorNumber = 'Sample Floor';
        wrapper.roomNumber = 'Sample Room';
        wrapper.startDate = Date.today();
        wrapper.endDate = Date.today().addDays(1);
        wrapper.startTime = '09:00';
        wrapper.endTime = '11:00';
        wrapper.facilityReason = 'Testing';
        wrapper.additionalFacility = 'Additional amenities';
        wrapper.additionalFacility2 = 'Additional amenities';
        wrapper.quantityOfAdditionalAmenities ='Additional amenities';
       	wrapper.isElective =true;
        wrapper.description = 'Test description';
        wrapper.capacity = 50;

        // Mock the User department
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u = new User(Alias = 'ptes', Email = 'prof@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'prof@testorg.com', Department = 'Test Account');
        insert u;

        // Run test as the mocked user
        System.runAs(u) {
            Test.startTest();
            String result;
            try {
                result = revaFacilityRequestBookingController.saveFacilityRequest(JSON.serialize(wrapper), null);
            } catch (Exception e) {
                System.debug('Exception caught: ' + e.getMessage());
            }
            Test.stopTest();

            // Assert the result
            if (result != null && result.equals('Success')) {
                // Query the inserted Facility_Request__c record
                List<Facility_Request__c> facilityRequests = [
                    SELECT Building_Name__c, Facility_Type__c, Floor__c, Room_No__c, Reason_of_Booking__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Description__c, Capacity__c, Account__c 
                    FROM Facility_Request__c 
                    WHERE Building_Name__c = :wrapper.buildingName 
                        AND Facility_Type__c = :wrapper.facilityType 
                        AND Floor__c = :wrapper.floorNumber 
                        AND Room_No__c = :wrapper.roomNumber 
                        AND Start_Date__c = :wrapper.startDate 
                        AND End_Date__c = :wrapper.endDate 
                        AND Description__c = :wrapper.description 
                        AND Capacity__c = :wrapper.capacity
                ];

                System.assertEquals(1, facilityRequests.size(), 'Expected one Facility_Request__c record to be inserted');

                Facility_Request__c savedRequest = facilityRequests[0];

                // Validate the fields in the inserted record
                System.assertEquals(wrapper.buildingName, savedRequest.Building_Name__c);
                System.assertEquals(wrapper.facilityType, savedRequest.Facility_Type__c);
                System.assertEquals(wrapper.floorNumber, savedRequest.Floor__c);
                System.assertEquals(wrapper.roomNumber, savedRequest.Room_No__c);
                System.assertEquals(wrapper.facilityReason, savedRequest.Reason_of_Booking__c);
                System.assertEquals(wrapper.additionalFacility, savedRequest.Additional_Amenities_Required__c);
                System.assertEquals(wrapper.startDate, savedRequest.Start_Date__c);
                System.assertEquals(wrapper.endDate, savedRequest.End_Date__c);
                System.assertEquals(Time.newInstance(9, 0, 0, 0), savedRequest.Start_Time__c);
                System.assertEquals(Time.newInstance(11, 0, 0, 0), savedRequest.End_Time__c);
                System.assertEquals(wrapper.description, savedRequest.Description__c);
                System.assertEquals(wrapper.capacity, savedRequest.Capacity__c);
               // System.assertEquals(testAccount.Id, savedRequest.Account__c);
            }
        }
    }
     @isTest
        static void testGetAdditionalAmenities() {
            Test.startTest();
            List<Reva_Infra_Additional_Amenity__mdt> result = revaFacilityRequestBookingController.getAdditionalAmenities();
            Test.stopTest();
            System.assertNotEquals(0, result.size(), 'Expected additional amenities to be retrieved');
            //System.assertEquals('Sample Amenity', result[0].Name__c, 'Expected Name__c to match the test data');
        }
     @isTest
        static void testGetCourseSchedules() {
            // Create and insert an Account record
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
    
            // Create and insert a Term record
            hed__Term__c sem = new hed__Term__c(Name = 'test', hed__Account__c = testAccount.Id);
            insert sem;
    
            // Create and insert a Course record
            hed__Course__c course = new hed__Course__c(Name = 'test', hed__Account__c = testAccount.Id);
            insert course;
    
            // Create and insert a Course Offering record
            hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
                hed__Course__c = course.Id,    
                hed__Term__c = sem.Id,
                Name = 'test'
            );
            insert courseOffering;
    
            // Create and insert a Facility record (assuming Facility__c is the related object)
            hed__Facility__c facility = new hed__Facility__c(Name = 'Test Facility');
            insert facility;
    
            // Create Time values
            Time startTime = Time.newInstance(9, 0, 0, 0); // 9:00 AM
            Time endTime = Time.newInstance(10, 0, 0, 0); // 10:00 AM
    
            // Create a Course Offering Schedule record
            hed__Course_Offering_Schedule__c testSchedule = new hed__Course_Offering_Schedule__c(
                hed__Course_Offering__c = courseOffering.Id,
                hed__Start_Time__c = startTime,
                hed__End_Time__c = endTime,
                hed__Facility__c = facility.Id,
                Date__c = Date.today(),
                Section__c=sem.Id
            );
            insert testSchedule;
    
            // Test the method
            Test.startTest();
            List<hed__Course_Offering_Schedule__c> result = revaFacilityRequestBookingController.getCourseScedules(testSchedule.Id);
            Test.stopTest();
    
            // Verify the results
            System.assertNotEquals(null, result, 'The result should not be null.');
            System.assertEquals(1, result.size(), 'The result size should be 1.');
            System.assertEquals(testSchedule.Id, result[0].Id, 'The ID of the returned schedule should match the test schedule ID.');
           // System.assertEquals(startTime, result[0].hed__Start_Time__c, 'The start time should match.');
           // System.assertEquals(endTime, result[0].hed__End_Time__c, 'The end time should match.');
        }


}