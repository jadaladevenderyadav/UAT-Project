trigger MealBooking on Reva_Meal_Booking__c (before insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            MealBookingHandler.restrictMealBookingOnLeave(trigger.new);
        }
    }

}