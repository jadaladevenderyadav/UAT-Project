public class RevaMealBookingSMSNotifications {
    // Invocable method to send SMS notification for meal bookings
    @InvocableMethod(label='Send Meal Booking SMS Notification' description='Send SMS notification for meal bookings')
    public static void sendMealBookingSMSNotification(List<Id> mealBookingIds) {
        List<Reva_Meal_Booking__c> mealBookings = [SELECT Id, Reva_Meal_Booking_Status__c, Type_of_meal__c, Reva_Meal_Booking_Date__c, Booking_For__r.MobilePhone, Booking_For__r.Name, Booking_For_User__r.Name FROM Reva_Meal_Booking__c WHERE Id IN :mealBookingIds];
        
        // Separate meal bookings by status
        List<Reva_Meal_Booking__c> bookedMealBookings = new List<Reva_Meal_Booking__c>();
        List<Reva_Meal_Booking__c> missedMealBookings = new List<Reva_Meal_Booking__c>();
        
        for (Reva_Meal_Booking__c mealBooking : mealBookings) {
            if (mealBooking.Reva_Meal_Booking_Status__c.equalsIgnoreCase('Booked')) {
                bookedMealBookings.add(mealBooking);
            } else if (mealBooking.Reva_Meal_Booking_Status__c.equalsIgnoreCase('Missed Meal')) {
                missedMealBookings.add(mealBooking);
            }
        }
        
        // Send SMS notifications for booked meal bookings
        sendBookedMealNotifications(bookedMealBookings);
        
        // Send SMS notifications for missed meal bookings
        sendMissedMealNotifications(missedMealBookings);
    }
    
    // Method to send SMS notification for booked meal bookings
    private static void sendBookedMealNotifications(List<Reva_Meal_Booking__c> bookedMealBookings) {
        Map<String, String> studentMessages = new Map<String, String>();
        
        for (Reva_Meal_Booking__c mealBooking : bookedMealBookings) {
            String studentPhone ;
             if(mealBooking.Booking_For__r.MobilePhone != null){
                    String plusRemoved = mealBooking.Booking_For__r.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    studentPhone = correctedWhatsappNumber;
                }
                  
            String messageBody = generateBookedMessage(mealBooking);
            
            // Add message to the map
            studentMessages.put(studentPhone, messageBody);
        }
        
        // Send SMS asynchronously for booked meals
        if (!studentMessages.isEmpty()) {
            System.debug('Sending SMS for booked meals: Messages=' + studentMessages);
            Rpl_UtilityClass.sendSMSAsync('Meal Notification (Student)', studentMessages);
        }
    }
    
    // Method to send SMS notification for missed meal bookings
    // @InvocableMethod(label='Send  Missed Meal SMS Notification' description='Send SMS notification for Missed meal')
    
    private static void sendMissedMealNotifications(List<Reva_Meal_Booking__c> missedMealBookings) {
        Map<String, String> studentMessages = new Map<String, String>();
        
        for (Reva_Meal_Booking__c mealBooking : missedMealBookings) {
            String studentPhone ;
            if(mealBooking.Booking_For__r.MobilePhone != null){
                    String plusRemoved = mealBooking.Booking_For__r.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    studentPhone = correctedWhatsappNumber;
                }
            String messageBody = generateMissedMessage(mealBooking);
            
            // Add message to the map
            studentMessages.put(studentPhone, messageBody);
        }
        
        // Send SMS asynchronously for missed meals
        if (!studentMessages.isEmpty()) {
            System.debug('Sending SMS for missed meals: Messages=' + studentMessages);
            Rpl_UtilityClass.sendSMSAsync('Meal Missed Notification (Student)', studentMessages);
        }
    }
    
    // Method to generate message for booked meal status
    private static String generateBookedMessage(Reva_Meal_Booking__c mealBooking) {
        String mealType = mealBooking.Type_of_meal__c;
        Date bookingDate = mealBooking.Reva_Meal_Booking_Date__c;
        System.debug('bookingDate: '+ bookingDate);
        DateTime bookingDateTime = DateTime.newInstance(bookingDate.year(), bookingDate.month(), bookingDate.day());
        String formattedDate = bookingDateTime.format('dd-MM-yyyy');
        String Name;
        if(mealBooking.Booking_For__c!= null){
            Name = mealBooking.Booking_For__r.Name;
            System.debug('booked for contact');
        }if(mealBooking.Booking_For_User__c!= null){
            Name = mealBooking.Booking_For_User__r.Name;
            System.debug('booked for user'); 
        }
        System.debug('Name: '+ Name);
        
        return 'Dear ' + Name + ',\n\nWe are pleased to inform you that your meal has been booked successfully.\n\nDetails:\nMeal booked: ' + mealType + '\nBooking date: ' + formattedDate + '\n\nRegards,\nHostel office\nREVA University';
    }
    
    // Method to generate message for missed meal status
    private static String generateMissedMessage(Reva_Meal_Booking__c mealBooking) {
        String mealType = mealBooking.Type_of_meal__c;
        Date bookingDate = mealBooking.Reva_Meal_Booking_Date__c;
        DateTime bookingDateTime = DateTime.newInstance(bookingDate.year(), bookingDate.month(), bookingDate.day());
        String formattedDate = bookingDateTime.format('dd-MM-yyyy');
        Id studentRecordId = mealBooking.Booking_For__c;
        String Name;
        if(mealBooking.Booking_For__c!= null){
            Name = mealBooking.Booking_For__r.Name;
        }if(mealBooking.Booking_For_User__c!= null){
            Name = mealBooking.Booking_For_User__r.Name;
        }
        List<Reva_Meal_Booking__c> missedMealBookings = [SELECT id, Reva_Meal_Booking_Status__c, Booking_For__c FROM Reva_Meal_Booking__c WHERE Reva_Meal_Booking_Status__c = 'Missed Meal' AND Booking_For__c =: studentRecordId];
        Integer noOfMissedMeals = missedMealBookings.size();
        System.debug('no of missed meals: '+ noOfMissedMeals);
        return 'Dear ' + Name + ',\n\nThis is to inform you that you have missed receiving the meal that you had booked. Please be informed that your meal booking option will be disabled if you miss receiving 10 meals.\n\nDetails:\nMeal type: ' + mealType + '\nBooked date: ' + formattedDate + '\nNo of meals missed: ' + noOfMissedMeals + '\n\nRegards,\nHostel office\nREVA University';
    }
}