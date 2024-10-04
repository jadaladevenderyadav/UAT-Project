public class MealBookingHandler {
    public static void restrictMealBookingOnLeave(List<Reva_Meal_Booking__c> MealBookings){
        List<Id> contactIds = new List<Id>();
        List<Id> messMenuIds = new List<Id>();
        
        for(Reva_Meal_Booking__c MealBooking : MealBookings){
            contactIds.add(MealBooking.Booking_For__c);
            messMenuIds.add(MealBooking.Reva_Mess_Menu__c);
        }
        
        Map<Id, Contact> studentLeaveRequests = new Map<Id, Contact>([
            SELECT Id,
                   (SELECT Id, Status__c, Start_Date_and_Time__c, End_Date_and_Time__c, CreatedDate 
                      FROM REVA_Hostel_Leave_Requests__r 
                     WHERE Status__c = 'Approved' 
                  ORDER BY CreatedDate LIMIT 1) 
              FROM Contact 
             WHERE Id IN :contactIds
        ]);
        
        Map<Id, Reva_Mess_Menu__c> messMenus = new Map<Id, Reva_Mess_Menu__c>([
            SELECT Id, Start_Time__c, End_Time__c 
              FROM Reva_Mess_Menu__c 
             WHERE Id IN :messMenuIds
        ]);
     
        for(Reva_Meal_Booking__c MealBooking : MealBookings){
            Contact student = studentLeaveRequests.get(MealBooking.Booking_For__c);
            if(student != null && !student.REVA_Hostel_Leave_Requests__r.isEmpty()){
                List<REVA_Hostel_Leave_Request__c> hostelLeaveRequests = student.REVA_Hostel_Leave_Requests__r;
                REVA_Hostel_Leave_Request__c hostelLeaveRequest = hostelLeaveRequests[0];

                Reva_Mess_Menu__c messMenuForCurrentMeal = messMenus.get(MealBooking.Reva_Mess_Menu__c);
                if(messMenuForCurrentMeal != null){
                    Time mealEndTime = messMenuForCurrentMeal.End_Time__c;
                    DateTime leaveStartTime = hostelLeaveRequest.Start_Date_and_Time__c;
                    DateTime leaveEndTime = hostelLeaveRequest.End_Date_and_Time__c;
                    Date mealBookingDate = MealBooking.Reva_Meal_Booking_Date__c;
                    DateTime mealBookingEndDateTime = DateTime.newInstance(mealBookingDate.year(), mealBookingDate.month(), mealBookingDate.day(), 
                                                                        mealEndTime.hour(), mealEndTime.minute(), mealEndTime.second());
                 //   if(mealBookingEndDateTime >= leaveStartTime && mealBookingEndDateTime <= leaveEndTime){
                   //     MealBooking.addError('Meals cannot be booked during the leave period.');
                    //}
                }
            }
        }
    }
}
/*** existing one*****/
/*public class MealBookingHandler {
    public static void restrictMealBookingOnLeave(list<Reva_Meal_Booking__c> MealBookings){
        
        list<id> contactIds = new list<id>();
        list<id> messMenu = new list<id>();
        
        for(Reva_Meal_Booking__c MealBooking : MealBookings){
            system.debug('MealBooking');
            system.debug(MealBooking);
            
            contactIds.add(MealBooking.Booking_For__c);
            messMenu.add(MealBooking.Reva_Mess_Menu__c);
         
        }
        
        map<id, contact> studentLeaveRequests = new map<id, contact>([select id,(select id,Status__c, Start_Date_and_Time__c, End_Date_and_Time__c, CreatedDate 
                                                                                from REVA_Hostel_Leave_Requests__r where Status__c = 'Approved' Order By CreatedDate limit 1 ) 
                                                                      			from Contact where id IN :contactIds]);
        
        system.debug(studentLeaveRequests.keySet());
        
     
        
                
        
        
        map<id, Reva_Mess_Menu__c> messMenus = new map<id, Reva_Mess_Menu__c>([select id, Start_Time__c, End_Time__c from Reva_Mess_Menu__c Where ID in :messMenu]);
        
        system.debug(messMenus);
        
        
        
        
         for(Reva_Meal_Booking__c MealBooking : MealBookings){
            Contact student = studentLeaveRequests.get(MealBooking.Booking_For__c);
             if(student.REVA_Hostel_Leave_Requests__r != null){
                 system.debug('inside if');
                 system.debug(student.REVA_Hostel_Leave_Requests__r);
                 list<REVA_Hostel_Leave_Request__c> HostelLeaveRequest = student.REVA_Hostel_Leave_Requests__r;
                 DateTime leaveStartTime = HostelLeaveRequest[0].Start_Date_and_Time__c;
                 DateTime leaveEndTime = HostelLeaveRequest[0].End_Date_and_Time__c;
                 
               
				 Reva_Mess_Menu__c messMenuForCurrentMeal = messMenus.get(MealBooking.Reva_Mess_Menu__c);
                 Time mealEndTime = messMenuForCurrentMeal.End_Time__c;
                 Date mealBookingDate = MealBooking.Reva_Meal_Booking_Date__c;
                 Datetime mealBookingEndDateTime = Datetime.newInstance(mealBookingDate.year(), mealBookingDate.month(), mealBookingDate.day(), 
                                            mealEndTime.hour(), mealEndTime.minute(), mealEndTime.second());
                 
                 if(mealBookingEndDateTime >= leaveStartTime && mealBookingEndDateTime <= leaveEndTime){
                     MealBooking.addError('Meals Cannot be booked during leave period');
                     
                 }

             }
             
//              MealBooking.addError('Meals Cannot be booked during leave period');
            
         
        }
        
        
    }

}
**/