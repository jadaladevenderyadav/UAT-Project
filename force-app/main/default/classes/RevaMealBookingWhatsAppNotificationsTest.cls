@istest
public class RevaMealBookingWhatsAppNotificationsTest {
    Public class RestMock implements HttpCalloutMock {
       public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }  
     Public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String fullJson = '{"unicode":"False","sender":"REVAUN","message":{"text":"Dear Applicant\r\n\r\nMake a payment of Rs. 8000.00 to confirm your Provisional Admission at https:/\r\neva-university--couat1908.sandbox.my.site.com/Admissions/s/payment-page?contactId=0030T00000VQx7FQAT&isPAF=true&stupayid=a1P0T000001WIxSUAW.\r\nIn case of confusion connect with your admission counsellor.\r\n\r\nRegards\r\nREVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
        HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
        return res;
    }
   }
@isTest
static void testSendMealBookingWhatsAppNotification() {
    Test.setMock(HttpCalloutMock.class, new RestMock());
    // Create test data
    DateTime now = DateTime.now();
    Time currentTime = Time.newInstance(now.hour(), now.minute(), now.second(), 0);  
    Time endTime = Time.newInstance(now.hour() + 1, now.minute(), now.second(), 0);  // Set end time to one hour later
    DateTime tomorrow = now.addDays(1);
    
    Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(Type__c = 'Snacks', Start_Time__c = currentTime, End_Time__c = endTime);
    insert testMenu;
    
    Contact testContact = new Contact(LastName = 'Test Contact', MobilePhone = '1234567890', Email = 'test@example.com');
    insert testContact;
    
    Reva_Meal_Booking__c testBooking1 = new Reva_Meal_Booking__c(
        Reva_Meal_Booking_Status__c = 'Booked',
        Reva_Meal_Booking_Date__c = tomorrow.date(),  // Use tomorrow's date
        Booking_For__c = testContact.Id,
        Reva_Mess_Menu__c = testMenu.Id
    );
    insert testBooking1;
    
    Reva_Meal_Booking__c testBooking2 = new Reva_Meal_Booking__c(
        Reva_Meal_Booking_Status__c = 'Missed Meal',
        Reva_Meal_Booking_Date__c = tomorrow.date(),  // Use tomorrow's date
        Booking_For__c = testContact.Id,
        Reva_Mess_Menu__c = testMenu.Id
    );
    insert testBooking2;
    
    Case cs = new Case();
    cs.ContactId = testContact.Id;
    cs.Hostel_Category__c = 'Maintenance';
    cs.Hostel_Sub_Category__c = 'Electrical';    
    cs.Description__c = 'issue';
    cs.Status = 'New';
    insert cs;
    
    Reva_Hostel_Request__c revahostel = new Reva_Hostel_Request__c();
    revahostel.Hostel_Room_Request_For__c = testContact.Id;
    revahostel.Type__c = '1';
    insert revahostel;
    
   // Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();
    // Call the method to be tested
    List<Id> mealBookingIds = new List<Id>{testBooking1.Id, testBooking2.Id};
    List<String> recordIds = new List<String>();
    recordIds.add(revahostel.Id);
    RevaMealBookingWhatsAppNotifications.sendMealBookingWhatsAppNotification(mealBookingIds);
    // RoomAllocationWhatsAppNotifications.sendRoomAllotedWhatsAppNotification(recordIds);
    RevaMealBookingSMSNotifications.sendMealBookingSMSNotification(mealBookingIds);
    Test.stopTest();
}

}