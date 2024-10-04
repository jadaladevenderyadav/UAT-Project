public class RevaHostelLeaveRequestController {
    
    @AuraEnabled(cacheable = true)
    public static List<REVA_Hostel_Leave_Request__c> getHostelLeaverequests(){
        
        User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        system.debug('currentUser:'+currentUser);  
        Id contactId2 = currentUser.ContactId;
        system.debug('contactId===>'+contactId2);
        
        
        if (currentUser.ContactId == null) {
            return new List<REVA_Hostel_Leave_Request__c>();
        }
        
        
        Id contactId = currentUser.ContactId;
        system.debug('currentUser:'+contactId); 
        
        return [SELECT Id, Name, Contact__c, End_Date_and_Time__c, 
                Start_Date_and_Time__c, Note_to_the_approver__c, Reason_For_Leave__c,Total_Leaves_in_Days__c, 
                Visiting_address__c, Status__c 
                FROM REVA_Hostel_Leave_Request__c 
                WHERE Contact__c = :contactId];
        
        
    }
 
    
    @AuraEnabled
    public static void saveLeaveRequest(Map<String, Object> requestDetails) {
    
        Id contactId;
        if(Test.isRunningTest()){
            contactId = (String) requestDetails.get('contactid');
            system.debug('contactIdTest===>'+contactId);
        }else{
            User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            contactId = currentUser.ContactId;
            system.debug('contactId===>'+contactId);
        }
       
       
        Reva_Hostel_Request__c RHR=[SELECT id, Warden__c FROM Reva_Hostel_Request__c where Hostel_Room_Request_For__c =: contactId] ;
        DateTime staticDateTime = DateTime.newInstance(2024, 5, 21, 12, 0, 0);
        REVA_Hostel_Leave_Request__c leaveRequest = new REVA_Hostel_Leave_Request__c();
        leaveRequest.Contact__c =contactId;
        leaveRequest.Reason_For_Leave__c = (String) requestDetails.get('ReasonLeave');
        leaveRequest.Note_to_the_approver__c = (String) requestDetails.get('NoteApprover');
        leaveRequest.Status__c='Leave Requested';
        leaveRequest.Visiting_address__c=(String) requestDetails.get('VisitingAddress');
        leaveRequest.Warden__c = RHR.Warden__c;
        // Parse and convert the date-time strings to Datetime objects
        String startDateString = (String) requestDetails.get('StartDate');
        String endDateString = (String) requestDetails.get('EndDate');
        
        Datetime startDate = parseIsoDatetime(startDateString);
        Datetime endDate = parseIsoDatetime(endDateString);
        
        leaveRequest.Start_Date_and_Time__c = startDate;
        leaveRequest.End_Date_and_Time__c = endDate;
        
        insert leaveRequest;
        
        String fileName = (String) requestDetails.get('FileName');
        if (!String.isBlank(fileName)) {
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode((String) requestDetails.get('FileContent'));
            insert contentVersion;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
            cdl.LinkedEntityId = leaveRequest.Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }

    }
    
    
    private static Datetime parseIsoDatetime(String isoDateTimeStr) {
        try {
            // Split the date and time parts
            String[] dateTimeParts = isoDateTimeStr.replace('Z', '').split('T');
            String datePart = dateTimeParts[0];
            String timePart = dateTimeParts[1];
            
            // Split the date into year, month, day
            String[] dateComponents = datePart.split('-');
            Integer year = Integer.valueOf(dateComponents[0]);
            Integer month = Integer.valueOf(dateComponents[1]);
            Integer day = Integer.valueOf(dateComponents[2]);
            
            // Split the time into hour, minute, second
            String[] timeComponents = timePart.split(':');
            Integer hour = Integer.valueOf(timeComponents[0]);
            Integer minute = Integer.valueOf(timeComponents[1]);
            Decimal second = Decimal.valueOf(timeComponents[2]);
            
            // Create the Datetime object
            Datetime dateTimeValue = Datetime.newInstanceGmt(year, month, day, hour, minute, second.intValue());
            
            return dateTimeValue;
        } catch (Exception e) {
            throw new AuraHandledException('Invalid date/time format: ' + isoDateTimeStr);
        }
    }
    
    //Update    
    @AuraEnabled
    public static void cancelLeave(String recordId) {
        REVA_Hostel_Leave_Request__c leaveRequest = [SELECT Id FROM REVA_Hostel_Leave_Request__c WHERE Id = :recordId];
        leaveRequest.Status__c = 'Cancelled';
        update leaveRequest;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLeaveRequestWithContact(String recordId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Query the leave request and related contact fields
            REVA_Hostel_Leave_Request__c leaveRequest = [SELECT Id, Status__c, Contact__r.Parent_Name__c, Contact__r.RH_Parent_Phone_Number__c
                                                         FROM REVA_Hostel_Leave_Request__c
                                                         WHERE Id = :recordId LIMIT 1];
            
            // Map the queried fields to a result map
            result.put('Id', leaveRequest.Id);
            result.put('ParentName', leaveRequest.Contact__r.Parent_Name__c);
            result.put('ParentPhoneNumber', leaveRequest.Contact__r.RH_Parent_Phone_Number__c);
            
            // Return the result map
            return result;
        } catch (Exception e) {
            // Handle any exceptions
            throw new AuraHandledException('Error fetching leave request data: ' + e.getMessage());
        }
    }
     
    
      @AuraEnabled(cacheable=true)
    public static REVA_Hostel_Leave_Request__c getRecord(Id recordId) {
        try{
        REVA_Hostel_Leave_Request__c record = [Select Id, Status__c,Check_In__c,Check_Out__c,Contact__r.Name,Contact__r.SRN_Number__c,Contact__r.Phone,
                                               Contact__r.File_Passport_Size_Photo__c,Start_Date_and_Time__c,End_Date_and_Time__c
                                               FROM REVA_Hostel_Leave_Request__c WHERE id =:recordId LIMIT 1];
        return record;
        }catch(exception e){
            return null;
        }
    }
    
     @AuraEnabled
    public static void updateCheckStatus(Id recordId, Boolean status) {
        if (recordId == null) {
            throw new AuraHandledException('Record ID is null'); 
        }
        try {
            
        REVA_Hostel_Leave_Request__c record1 = [Select Id, Status__c,Check_In__c,Check_Out__c,Scan__c,Contact__r.Name,Contact__r.SRN_Number__c,Contact__r.Phone,
                                               Contact__r.File_Passport_Size_Photo__c,Start_Date_and_Time__c,End_Date_and_Time__c
                                               FROM REVA_Hostel_Leave_Request__c WHERE id =:recordId LIMIT 1];
          

            if(record1.Check_Out__c == false ){ 
                  record1.Check_Out__c = status;
                  record1.Status__c = 'Check Out';
            }else{
                if(record1.Check_Out__c == true && record1.Check_In__c == false ){ 
                 record1.Check_In__c = status;
                 record1.Status__c = 'Check In';
              } 
                 }
            update record1;
        
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        }
    } 
    
       @AuraEnabled
    public static Boolean hasStatusUpdated(Id selectedId) {
        try{
        REVA_Hostel_Leave_Request__c record1 = [Select Id, Scan__c,Status__c,Check_In__c,Check_Out__c,Contact__r.Name,Contact__r.SRN_Number__c,Contact__r.Phone,
                                               Contact__r.File_Passport_Size_Photo__c,Start_Date_and_Time__c,End_Date_and_Time__c
                                               FROM REVA_Hostel_Leave_Request__c WHERE id =:selectedId LIMIT 1];
       
            if ((record1.Check_Out__c == true &&  record1.Scan__c == false ) || (record1.Check_In__c == true &&  record1.Scan__c == true)) {
            return true;
        }else{

        return false;
        }
    
    }Catch(Exception e){
          return true;
    }
    }
}