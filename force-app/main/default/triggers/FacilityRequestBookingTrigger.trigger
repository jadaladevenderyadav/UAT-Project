trigger FacilityRequestBookingTrigger on Facility_Request__c (before insert, before update) {
    if(trigger.isBefore){
            if(trigger.isUpdate){
             Facility_Request_Handler.check(trigger.new,trigger.oldMap);   
        }
    }
    
    if (Trigger.isBefore && (Trigger.isInsert /*|| Trigger.isUpdate*/)) {
        List<Facility_Request__c> newBookings = Trigger.new;
        List<String> errorMessages = new List<String>();
              
        // Check if the facility type is Laboratory or Classroom, then skip validation
        Boolean bypassValidation = false;
        for (Facility_Request__c newBooking : newBookings) {
            if ( newBooking.Is_Elective__c == true) {
                bypassValidation = true;
                break;
            }
        }
        system.debug('bypassValidation ---->'+bypassValidation);
        
        if (!bypassValidation) {
            // Query existing Facility_Request__c records in the database
            system.debug('bypassValidation After ---->'+bypassValidation);
            List<Facility_Request__c> existingBookings = [SELECT Id, Start_Date__c, End_Date__c, Facility_Name__c, Facility_Type__c, Start_Time__c, End_Time__c, Floor__c,Building_Name__c,Room_No__c,Account__c,Is_Elective__c FROM Facility_Request__c ];
            
            
            Set<String> uniqueCombinations = new Set<String>();
            
            for (Facility_Request__c newBooking : newBookings) {
                // for Lab/classroom
                if (newBooking.Is_Elective__c == false && (newBooking.Facility_Type__c == 'Laboratory' || newBooking.Facility_Type__c == 'Classroom')) {
                    // Construct a combination string for comparison
                    String combination = newBooking.Facility_Type__c + '_' + newBooking.Facility_Name__c + '_' + newBooking.Building_Name__c + '_' + newBooking.Floor__c + '_' + newBooking.Room_No__c;
                    system.debug('combination --->' + combination);
                    // Check for duplicate combination
                    if (uniqueCombinations.contains(combination)) {
                        errorMessages.add('Another Facility Record with the same combination already exists.');
                    } else {
                        uniqueCombinations.add(combination);
                        
                        // Flag to track if there's a time conflict
                        boolean hasTimeConflict = false;
                        
                        // Loop through existing records to check for conflicts
                        for (Facility_Request__c existingBooking : existingBookings) {
                            if (existingBooking.Id != null && existingBooking.Id != newBooking.Id) {
                                boolean isFacilityOverlap = existingBooking.Facility_Name__c == newBooking.Facility_Name__c &&
                                    existingBooking.Facility_Type__c == newBooking.Facility_Type__c &&
                                    existingBooking.Floor__c == newBooking.Floor__c &&
                                    existingBooking.Room_No__c == newBooking.Room_No__c &&
                                    existingBooking.Building_Name__c == newBooking.Building_Name__c; // true 
                                    //system.debug('isFacilityOverlap ---->' +isFacilityOverlap);
                                
                                boolean isTimeOverlap = existingBooking.Start_Date__c <= newBooking.End_Date__c &&
                                    existingBooking.End_Date__c >= newBooking.Start_Date__c &&
                                    existingBooking.Start_Time__c <= newBooking.End_Time__c &&
                                    existingBooking.End_Time__c >= newBooking.Start_Time__c; // true
                                    //system.debug('isTimeOverlap ---->' +isTimeOverlap);
                                system.debug('start time'+ newBooking.Start_Time__c);
                                system.debug('end time'+ newBooking.End_Time__c);
                                
                                
                                if((newBooking.End_Time__c == null && newBooking.Start_Time__c == null)){
                                         system.debug('Account gone 12');                               
                                }
                                if (isFacilityOverlap && (String.valueOf(newBooking.End_Time__c) == '00:00:00.000Z' && String.valueOf(newBooking.Start_Time__c) == '00:00:00.000Z')) {
                                    system.debug('Account gone 32');
                                    errorMessages.add('There is a scheduling conflict with an existing booking. Please check for available Laboratory/Classroom.');
                                    break; // No need to check further conflicts for this newBooking
                                } 
                                if (isFacilityOverlap && isTimeOverlap ) {
                                    // hasTimeConflict = true;
                                    errorMessages.add('There is a scheduling conflict with a course offering booking. Please check the time and date slots.');
                                    break; // No need to check further conflicts for this newBooking, but continue checking other existing bookings
                                }
                            }
                        }
                    }
                }
                
                // when exam hall
                if(newBooking.Is_Elective__c == false && newBooking.Facility_Type__c == 'Event Venues'){
                    // Construct a combination string for comparison
                    String combination = newBooking.Start_Date__c + '_' + newBooking.End_Date__c + '_' + newBooking.Facility_Name__c + '_' + newBooking.Facility_Type__c + '_' + newBooking.Facility_Name__c + '_' + newBooking.Start_Time__c + '_' + newBooking.End_Time__c;
                         system.debug('combination --->' + combination);
                    // Check for duplicate combination
                    if (uniqueCombinations.contains(combination)) {
                        errorMessages.add('Another Facility Record with the same combination already exists.');
                    } else {
                        uniqueCombinations.add(combination);
                        
                        // Loop through existing records to check for conflicts
                        for (Facility_Request__c existingBooking : existingBookings) {
                            if(newBooking.Is_Elective__c == false && newBooking.Facility_Type__c == 'Event Venues' ){
                                if (newBooking.Start_Time__c == newBooking.End_Time__c) {
                                    errorMessages.add('Start time and end time cannot be the same');
                                }
                            }
                            
                            if (existingBooking.Id != null &&
                                existingBooking.Id != newBooking.Id &&
                                existingBooking.Facility_Name__c == newBooking.Facility_Name__c &&
                                existingBooking.Facility_Type__c == newBooking.Facility_Type__c &&
                                existingBooking.Floor__c == newBooking.Floor__c &&
                                existingBooking.Room_No__c == newBooking.Room_No__c &&
                                existingBooking.Building_Name__c == newBooking.Building_Name__c &&
                                existingBooking.Start_Date__c <= newBooking.End_Date__c &&
                                existingBooking.End_Date__c >= newBooking.Start_Date__c &&
                                existingBooking.Start_Time__c <= newBooking.End_Time__c &&
                                existingBooking.End_Time__c >= newBooking.Start_Time__c)
                            {                                
                                errorMessages.add('There is a scheduling conflict with an existing booking.');
                                break; // No need to check further conflicts for this newBooking
                            }
                        }
                    }
                }
            }
        }
        
        // Add any additional validation rules here
        
        // Add error messages to the newBooking records
        for (Facility_Request__c newBooking : newBookings) {
            for (String errorMessage : errorMessages) {
                newBooking.addError(errorMessage);
            }
        }
    }
}