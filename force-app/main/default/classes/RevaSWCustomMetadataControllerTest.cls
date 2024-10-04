@isTest
public class RevaSWCustomMetadataControllerTest {

    @isTest
    static void testCalculateHostelFee() {
        // Create and insert test data for custom setting
        REVA_Hostel_Fees__c testSetting1 = new REVA_Hostel_Fees__c(Name='TestSetting1', Hostel_Room_Fees__c=194000, Occupancy__c='Single', Is_Final_Year__c=true, Premium__c=true);
        REVA_Hostel_Fees__c testSetting2 = new REVA_Hostel_Fees__c(Name='TestSetting2', Hostel_Room_Fees__c=271000, Occupancy__c='Single', Is_Final_Year__c=false, Premium__c=true);
        REVA_Hostel_Fees__c testSetting3 = new REVA_Hostel_Fees__c(Name='TestSetting3', Hostel_Room_Fees__c=200, Occupancy__c='Double', Premium__c=true);
        REVA_Hostel_Fees__c testSetting4 = new REVA_Hostel_Fees__c(Name='TestSetting4', Hostel_Room_Fees__c=300, Occupancy__c='Double', Premium__c=false);
        List<REVA_Hostel_Fees__c> hostelSettings = new List<REVA_Hostel_Fees__c>{testSetting1, testSetting2, testSetting3, testSetting4};

        // Insert test data
        insert hostelSettings;

        // Test case 1: Final year student with matching setting
        revaSWCustomMetadataController.HostelFeeResponse result1 = revaSWCustomMetadataController.calculateHostelFee('Single', true, true);
        System.assertEquals(194000, result1.hostelFee, 'Expected hostelFee to be 194000');

        // Test case 2: Non-final year student with matching setting
        revaSWCustomMetadataController.HostelFeeResponse result2 = revaSWCustomMetadataController.calculateHostelFee('Single', true, false);
        System.assertEquals(271000, result2.hostelFee, 'Expected hostelFee to be 271000');

        // Test case 3: Generic setting for non-final year student
        revaSWCustomMetadataController.HostelFeeResponse result3 = revaSWCustomMetadataController.calculateHostelFee('Double', true, false);
        System.assertEquals(200, result3.hostelFee, 'Expected hostelFee to be 200');

        // Test case 4: Non-premium setting for non-final year student
        revaSWCustomMetadataController.HostelFeeResponse result4 = revaSWCustomMetadataController.calculateHostelFee('Double', false, false);
        System.assertEquals(300, result4.hostelFee, 'Expected hostelFee to be 300');
    }

    @isTest
    static void testGetAllRoomPrices() {
        // Create and insert test data for custom setting
        REVA_Hostel_Fees__c testSetting1 = new REVA_Hostel_Fees__c(Name='TestSetting1', Hostel_Room_Fees__c=194000, Occupancy__c='Single');
        REVA_Hostel_Fees__c testSetting2 = new REVA_Hostel_Fees__c(Name='TestSetting2', Hostel_Room_Fees__c=271000, Occupancy__c='Double');
        List<REVA_Hostel_Fees__c> hostelSettings = new List<REVA_Hostel_Fees__c>{testSetting1, testSetting2};

        // Insert test data
        insert hostelSettings;

        // Call the method to test
        List<revaSWCustomMetadataController.RoomPriceResponse> result = revaSWCustomMetadataController.getAllRoomPrices();

        // Verify the result
        System.assertEquals(2, result.size(), 'Expected 2 room prices');

        // Verify the first room price
        System.assertEquals('TestSetting1', result[0].roomType, 'Expected roomType to be TestSetting1');
        System.assertEquals(194000, result[0].price, 'Expected price to be 194000');

        // Verify the second room price
        System.assertEquals('TestSetting2', result[1].roomType, 'Expected roomType to be TestSetting2');
        System.assertEquals(271000, result[1].price, 'Expected price to be 271000');
    }
    
     // Mock custom metadata records for RSW_Manodhaara_CMT__mdt
    @testVisible static List<RSW_Manodhaara_CMT__mdt> mockRSWManodhaaraCMTRecords = new List<RSW_Manodhaara_CMT__mdt>{
        new RSW_Manodhaara_CMT__mdt(
            DeveloperName = 'Test_Info_1',
            MasterLabel = 'Test Info 1'
        ),
        new RSW_Manodhaara_CMT__mdt(
            DeveloperName = 'Test_Info_2',
            MasterLabel = 'Test Info 2'
        )
    };

    // Mock custom metadata records for Reva_Hostel_Setting__mdt
    @testVisible static List<Reva_Hostel_Setting__mdt> mockRevaHostelSettingRecords = new List<Reva_Hostel_Setting__mdt>{
        new Reva_Hostel_Setting__mdt(
            DeveloperName = 'Test_Hostel_1',
            MasterLabel = 'Test Hostel 1',
            Reva_Hostel_Description__c = 'Test Description 1'
        ),
        new Reva_Hostel_Setting__mdt(
            DeveloperName = 'Test_Hostel_2',
            MasterLabel = 'Test Hostel 2',
            Reva_Hostel_Description__c = 'Test Description 2'
        )
    };

    @isTest
    static void testGetAllCustomMetadata() {
        Test.startTest();
        // Call the method
        List<RSW_Manodhaara_CMT__mdt> result = revaSWCustomMetadataController.getAllCustomMetadata();
        Test.stopTest();

        // Assertions
        System.assertEquals(1, result.size(), 'Unexpected number of records returned');
        // Add more assertions as needed to verify the returned data
    }

    @isTest
    static void testGetHostelCustomMetadata() {
        Test.startTest();
        // Call the method
        List<Reva_Hostel_Setting__mdt> result = revaSWCustomMetadataController.getHostelCustomMetadata();
        Test.stopTest();

        // Assertions
        System.assertEquals(1, result.size(), 'Unexpected number of records returned');
        // Add more assertions as needed to verify the returned data
    }
}