public with sharing class StudAttendanceUpdate {
	
    @AuraEnabled(cacheable=true)
    public static List<hed__Attendance_Event__c> searchAttendanceRecords(List<String> srns, Date searchDate) {
      /*  if (String.isBlank(srn) || searchDate == null) {
            throw new AuraHandledException('SRN and Date cannot be blank.');
        } */
        System.debug('APEX SRNS :'+srns+' Date :'+searchDate);
        if (srns == null || srns.isEmpty() || searchDate == null) {
        	throw new AuraHandledException('SRNs and Date cannot be blank.');
    	}
     /*   
        // Trim whitespace from each SRN
        List<String> trimmedSrns = new List<String>();
        for (String s : srns) {
            if (!String.isBlank(s)) {
                trimmedSrns.add(s.trim());
            }
        }
    
        // Ensure we only query with non-empty SRNs
        if (trimmedSrns.isEmpty()) {
            throw new AuraHandledException('No valid SRNs provided.');
        }
        */
        
     /*   return [
            SELECT Id, SRN__c, hed__Contact__r.Name, Course_Offering_Section__c, Slot__c,hed__Attendance_Type__c, hed__Reason__c,
			Course_Offering_Schedule_Date__c,Course_Offering_Schedule__r.hed__Start_Time__c,Course_Offering_Schedule__r.hed__End_Time__c,Course_Offering_From_Schedule__c
            FROM hed__Attendance_Event__c    
            WHERE hed__Attendance_Type__c = 'Absent'  
            AND SRN__c = :srn 
            AND Course_Offering_Schedule_Date__c = :searchDate              
        ]; */
        
            List<hed__Attendance_Event__c> records = [
            SELECT Id, SRN__c, hed__Contact__r.Name, Course_Offering_Section__c, Slot__c,hed__Attendance_Type__c, hed__Reason__c,
			Course_Offering_Schedule_Date__c,Course_Offering_Schedule__r.hed__Start_Time__c,Course_Offering_Schedule__r.hed__End_Time__c,Course_Offering_From_Schedule__c
            FROM hed__Attendance_Event__c
            WHERE hed__Attendance_Type__c = 'Absent' and Course_Offering_Schedule_Date__c = 2023-11-20 LIMIT 100];
        
        	// WHERE hed__Attendance_Type__c = 'Absent'
        	// AND Course_Offering_Schedule_Date__c = :searchDate
        	// AND SRN__c = :srns
    		// This will return an empty list if no records match
    		System.debug('APEX length :'+records.size());
            return records; 
    }
    // WHERE hed__Attendance_Type__c = 'Absent' and Course_Offering_Schedule_Date__c = 2023-11-20 LIMIT 100
    // WHERE Course_Offering_Schedule_Date__c=2023-11-20 AND SRN__c = 'R23EJ088' AND Slot__c = '8'
/*
    @AuraEnabled
    public static void updateAttendanceRecords(List<hed__Attendance_Event__c> recordsToUpdate) {
        if (recordsToUpdate != null && !recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    } */
    
    @AuraEnabled
    public static void updateAttendanceRecords(List<hed__Attendance_Event__c> recordsToUpdate) {
        update recordsToUpdate;
    }
}