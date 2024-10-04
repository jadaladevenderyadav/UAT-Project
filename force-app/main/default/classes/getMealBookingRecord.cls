public class getMealBookingRecord {
   
    @AuraEnabled(cacheable=true)
    public static Reva_Meal_Booking__c getRecord(Id recordId) {
        Reva_Meal_Booking__c record = [Select Id, Reva_Meal_Booking_Status__c,
        Booking_For__r.Name, Booking_For__r.SRN_Number__c, Booking_For__r.Phone, Booking_For__r.File_Passport_Size_Photo__c
        FROM Reva_Meal_Booking__c WHERE id =:recordId LIMIT 1];
        return record;
    }

   

}