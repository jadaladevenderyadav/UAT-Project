public class Facility_Request_Handler {
    
    
    public static void check(list<Facility_Request__c> newList,map<id,Facility_Request__c> oldMap){
        Boolean bypassValidation = false;
        List<String> errorMessages = new List<String>();
        for (Facility_Request__c newBooking : newList) {
            if ( newBooking.Is_Elective__c == true) {
                bypassValidation = true;
                break;
            }
        }
        system.debug('bypassValidation ---> '+bypassValidation);
        if (!bypassValidation) {
            // Query existing Facility_Request__c records in the database
            system.debug('bypassValidation After ---->'+bypassValidation);
            
            List<Facility_Request__c> existingBookings = [SELECT Id, Start_Date__c, End_Date__c, Facility_Name__c, Facility_Type__c, Start_Time__c, End_Time__c, Floor__c,Building_Name__c,Room_No__c,Account__c,Is_Elective__c FROM Facility_Request__c ];
            
            system.debug('bypassValidation ---> '+existingBookings);
            Set<String> uniqueCombinations = new Set<String>();
            
            if(!oldMap.isEmpty()){
                for(Facility_Request__c newBooking : newList) {
                    
                    // for Lab/classroom
                    if (newBooking.Is_Elective__c == false && (newBooking.Facility_Type__c == 'Laboratory' || newBooking.Facility_Type__c == 'Classroom')) {
                        // Construct a combination string for comparison
                        String combination = newBooking.Facility_Type__c + '_' + newBooking.Facility_Name__c + '_' + newBooking.Building_Name__c + '_' + newBooking.Floor__c + '_' + newBooking.Room_No__c;
                        system.debug('combination --->' + combination);
                        // Check for duplicate combination
                        // 
                        if(newBooking.Facility_Type__c != oldMap.get(newBooking.id).Facility_Type__c 
                           && newBooking.Building_Name__c != oldMap.get(newBooking.Id).Building_Name__c 
                           && newBooking.Floor__c != oldMap.get(newBooking.Id).Floor__c
                           && newBooking.Room_No__c != oldMap.get(newBooking.Id).Room_No__c
                           && newBooking.Facility_Name__c != oldMap.get(newBooking.Id).Facility_Name__c){
                               
                           }else{
                               newBooking.Building_Name__c.addError('Another Facility Record with the same combination already exists.');  
                           }
                    }}
            }
        }}}