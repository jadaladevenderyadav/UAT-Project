public class RevaHostelLeaveRequestTriggerHandler {
    Public static String wardenPhone; 
    Public static String wardenName; 
    Public static String parentPhone;
    Public static String parentName;
    Public static String mentorPhone;
    Public static String mentorName;
    Public static String studentName;
    Public static String studentPhone;
    Public static String formattedStartDate;
    Public static String formattedEndDate;
    Public static String reason;    
    Public static String block;
    Public static String roomNo;
    Public static String CheckOutDate;
    Public static String CheckInDate;
    Public static String CheckOutTime;
    Public static String CheckInTime;

     public static void leaveApprovalNotification(List<REVA_Hostel_Leave_Request__c> LeaveRequests) {
          Id recordIds = LeaveRequests[0].id;
          if(recordIds != null){
               makeLeaveCheckOutCallout(recordIds);
         }
     }
     public static void leaveRequestNotification(List<REVA_Hostel_Leave_Request__c> LeaveRequests) {
        List<Id> RevaLeaveRequests = new List<Id>();
        List<string> checkuser = new List<string>();
         for(REVA_Hostel_Leave_Request__c rvleave: LeaveRequests){
             RevaLeaveRequests.add(rvleave.Id);
         }
         if(RevaLeaveRequests != null){
             makeCalloutAsync(RevaLeaveRequests);
         }
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync( list<Id> RevaLeaveRequests ) {
    
        Set<Id> contactIds = new Set<Id>();
        
        REVA_Hostel_Leave_Request__c RevaLeavereq = [SELECT  id,Name,Status__c,Start_Date_and_Time__c,End_Date_and_Time__c,Reason_For_Leave__c,
                                                     Contact__c,Contact__r.MobilePhone,Contact__r.Name,Contact__r.Mentor__c,Contact__r.Mentor__r.Name 
                                                     From REVA_Hostel_Leave_Request__c WHERE id =: RevaLeaveRequests ];
        contactIds.add(RevaLeavereq.Contact__c);
        
        Reva_Hostel_Request__c request = [SELECT id,warden__r.Phone, Block__c,Status__c, warden__r.Name,Hostel_Room_Request_For__c,Hostel_Room_Request_For__r.Father__r.Name,
                                          Hostel_Room_Request_For__r.Father__r.MobilePhone,Hostel_Room_Request_For__r.Mentor__r.Name,Hostel_Room_Request_For__r.Mentor__r.MobilePhone,
                                          Reva_Hostel_Room__r.Name, Room_Number__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c =: contactIds LIMIT 1];   
       
        if(request.warden__r.Phone != null){
            String plusRemoved = request.warden__r.Phone.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            WardenPhone = correctedWhatsappNumber;
        }
        if(RevaLeavereq.Contact__r.MobilePhone != null){
            String plusRemoved = RevaLeavereq.Contact__r.MobilePhone.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            studentPhone = correctedWhatsappNumber;
        }
        if(request.Hostel_Room_Request_For__r.Mentor__r.MobilePhone != null){
            String plusRemoved = request.Hostel_Room_Request_For__r.Mentor__r.MobilePhone.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            mentorPhone = correctedWhatsappNumber;
        }
        if(request.Hostel_Room_Request_For__r.Father__r.MobilePhone != null){
            String plusRemoved = request.Hostel_Room_Request_For__r.Father__r.MobilePhone.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            parentPhone = correctedWhatsappNumber;
        }   
        
        formattedStartDate = RevaLeavereq.Start_Date_and_Time__c.format('dd-MM-yyyy HH:mm:ss', 'IST');   
        formattedEndDate = RevaLeavereq.End_Date_and_Time__c.format('dd-MM-yyyy HH:mm:ss', 'IST');
        CheckOutDate = RevaLeavereq.Start_Date_and_Time__c.format('dd-MM-yyyy', 'IST');   
        CheckInDate = RevaLeavereq.End_Date_and_Time__c.format('dd-MM-yyyy', 'IST');
        CheckOutTime = RevaLeavereq.Start_Date_and_Time__c.format('HH:mm:ss', 'IST');   
        CheckInTime = RevaLeavereq.End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        studentName = RevaLeavereq.Contact__r.Name;
        mentorName = request.Hostel_Room_Request_For__r.Mentor__r.Name;
        parentName = request.Hostel_Room_Request_For__r.Father__r.Name;
        wardenName = request.warden__r.Name;
        Reason = RevaLeavereq.Reason_For_Leave__c;
        block = request.Block__c;
        roomNo = request.Reva_Hostel_Room__r.Name;
       
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        
        if(RevaLeavereq.Status__c == 'Leave Requested'){
        Parentreg(RevaLeavereq , messageList);
        MentorReg(RevaLeavereq , messageList);
        Wardenreg(RevaLeavereq , messageList);
         
        }
        If(RevaLeavereq.Status__c == 'Approved'){
        StudentApproved(RevaLeavereq , messageList);
        ParentApproved(RevaLeavereq , messageList);
        WardenApproved(RevaLeavereq , messageList);
        MentorApproved(RevaLeavereq , messageList);
        }
        If(RevaLeavereq.Status__c == 'Check Out'){
            CheckOutStudent(RevaLeavereq , messageList);
            ParentCheckOut(RevaLeavereq , messageList);
            MentorCheckOut(RevaLeavereq , messageList);
        }
        If(RevaLeavereq.Status__c == 'Check In'){
            CheckInStudent(RevaLeavereq , messageList);
            ParentCheckIn(RevaLeavereq , messageList);
            MentorCheckIn(RevaLeavereq , messageList);
        }
        if (messageList != null) {
            SMS_API_Utility.SendSMSOneToMany('Leave Request (Parent)', messageList); 
            SMS_API_Utility.SendSMSOneToMany('Leave Request (Warden/Mentor)', messageList);
            SMS_API_Utility.SendSMSOneToMany('Leave Approval (Student)', messageList);
            SMS_API_Utility.SendSMSOneToMany('Leave Approval (Parent)', messageList);
            SMS_API_Utility.SendSMSOneToMany('Leave Approval (Warden/Mentor)', messageList);
            
            SMS_API_Utility.SendSMSOneToMany('Check_Out_Notification_Student', messageList);
            SMS_API_Utility.SendSMSOneToMany('Check_Out_Information_Parent', messageList);
            SMS_API_Utility.SendSMSOneToMany('Check_out_Information_Mentor', messageList); 
            SMS_API_Utility.SendSMSOneToMany('Check_in_Information_Students', messageList);
            SMS_API_Utility.SendSMSOneToMany('Check_in_Information_Parents', messageList);
            SMS_API_Utility.SendSMSOneToMany('Check_in_Confirmation', messageList);
        }       
    }
    
    // Regiester Notification
      public static void Parentreg (REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {
          
        String message = 'Dear ' + parentName + '\n\nWe would like to inform you that your child, ' + studentName + ', has requested leave from the hostel. The details of their leave request are as follows:\n\nLeave start date and time: ' + formattedStartDate + '\nLeave end date:\n' + formattedEndDate + '\nReason for leave: ' + Reason + '\n\nRegards,\nHostel Office,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007782822189483403';
        shrtMessage.message = message;
        shrtMessage.recipient = parentPhone;
        messageList.add(shrtMessage);
    }
      public static void Wardenreg(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {
          
        String message =  'Dear ' + wardenName + '\n\nWe would like to inform you that one of our students, ' + studentName + ', has requested leave from the hostel. The details of their leave request are as follows:\n\nLeave start date and time: ' + formattedStartDate + '\nLeave end date:\n' + formattedEndDate + '\nReason for leave: ' + Reason + '\nBlock name: ' + block + '\nRoom number: ' + roomNo + '\nMobile number: ' + studentPhone + '\n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007961397830328958';
        shrtMessage.message = message;
        shrtMessage.recipient = WardenPhone;
        messageList.add(shrtMessage);
    }
      public static void MentorReg(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {       
        
        String message = 'Dear ' + mentorName + '\n\nWe would like to inform you that one of our students, ' + studentName + ', has requested leave from the hostel. The details of their leave request are as follows:\n\nLeave start date and time: ' + formattedStartDate + '\nLeave end date:\n' + formattedEndDate + '\nReason for leave: ' + Reason + '\nBlock name: ' + block + '\nRoom number: ' + roomNo + '\nMobile number: ' + studentPhone + '\n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007961397830328958';
        shrtMessage.message = message;
        shrtMessage.recipient = mentorPhone;
        messageList.add(shrtMessage);
    }
    
    // Approved Notitfications 
     public static void StudentApproved (REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + studentName + '\n\nYour leave request from the hostel has been approved. The details are as follows:\n\nLeave start date & time: ' + formattedStartDate + '\nLeave end date & time: ' + formattedEndDate + '\nReason for the leave: ' + Reason + '\n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007550489527389803';
        shrtMessage.message = message;
        shrtMessage.recipient = studentPhone;
        messageList.add(shrtMessage);
    }
       public static void ParentApproved (REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + parentName + '\n\nPlease be informed that the leave request for ' + studentName + ' has been approved. The details of this request are as follows:\n\nLeave start date & time: ' + formattedStartDate + '\nLeave end date & time: ' + formattedEndDate + '\nReason for leave: ' + Reason + ' \n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007426602285615563';
        shrtMessage.message = message;
        shrtMessage.recipient = parentPhone;
        messageList.add(shrtMessage);
    }
      public static void WardenApproved(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {    
        
        String message = 'Dear ' + wardenName + '\n\nPlease be informed that the leave request for '+ studentName +' has been approved. The details are as follows:\n\nLeave start date & time: ' + formattedStartDate + '\nLeave end date & time: '+ formattedEndDate +'\nReason for leave: ' + Reason + '\n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007160852002518651';
        shrtMessage.message = message;
        shrtMessage.recipient = WardenPhone;
        messageList.add(shrtMessage);
    }
      public static void MentorApproved(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + mentorName + '\n\nPlease be informed that the leave request for '+ studentName +' has been approved. The details are as follows:\n\nLeave start date & time: ' + formattedStartDate + '\nLeave end date & time: '+ formattedEndDate +'\nReason for leave: ' + Reason + '\n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007160852002518651';
        shrtMessage.message = message;
        shrtMessage.recipient = mentorPhone;
        messageList.add(shrtMessage);
    }

    
    //Check Out Notifications
    public static void CheckOutStudent(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + studentName + ',\nYouve successfully completed the security checkout on '+ CheckOutDate +' at '+CheckOutTime +' for hostel leave. Your checkin is scheduled for ' + CheckInDate + '.\n REVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007305717623200000';
        shrtMessage.message = message;
        shrtMessage.recipient = studentPhone;
        messageList.add(shrtMessage);
    }
      public static void ParentCheckOut(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + parentName + '\nYour Child has completed security check-out on ' + CheckOutDate + ' at '+CheckOutTime+' for hostel leave. Their check-in is scheduled for ' + CheckInDate + '.\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007219312319097098';
        shrtMessage.message = message;
        shrtMessage.recipient = parentPhone;
        messageList.add(shrtMessage);
    }
    
     public static void MentorCheckOut(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + mentorName +',\nYour mentee '+studentName+ ' has completed check-out on '+ CheckOutDate + ' at '+CheckOutTime+' for hostel leave. Check-in is scheduled for ' + CheckInDate + '.\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007655391598157095';
        shrtMessage.message = message;
        shrtMessage.recipient = mentorPhone;
        messageList.add(shrtMessage);
    }

    
    // Check In Notifications
   public static void CheckInStudent(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + studentName + ',\nYou have successfully completed the security check-in on '+ CheckInDate +' at '+CheckInTime +' after your hostel leave.\nRegards,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007958936830396769';
        shrtMessage.message = message;
        shrtMessage.recipient = studentPhone;
        messageList.add(shrtMessage);
    }
    
      public static void ParentCheckIn(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + parentName + ',\nYour child has successfully completed the security check-in on ' + CheckInDate + ' at '+CheckInTime+' after their hostel leave.\nRegards,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007973278865491387';
        shrtMessage.message = message;
        shrtMessage.recipient = parentPhone;
        messageList.add(shrtMessage);
    }
      public static void MentorCheckIn(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + mentorName +',\nYour mentee ' +studentName+' has successfully completed the security check-in on '+ CheckInDate + ' at '+CheckInTime+' after their hostel leave.\nRegards,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007090109464134424';
        shrtMessage.message = message;
        shrtMessage.recipient = mentorPhone;
        messageList.add(shrtMessage);
    }
  
 
    
    public static void makeLeaveCheckOutCallout(Id recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c,Warden__r.LastName,Warden__r.FirstName, LastModifiedDate,End_Date_and_Time__c, Reason_For_Leave__c, Contact__r.Name, Contact__r.MobilePhone,
            Contact__r.Father__r.Name,Contact__r.Father__r.MobilePhone ,Contact__r.SRN_Number__c FROM REVA_Hostel_Leave_Request__c
            WHERE Id =: recordIds
            LIMIT 1
        ];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'hostel_leave_notif_parent';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'hostel_leave_notif_parent') {
                    for (String key : keys) {
                        if (key == 'parent_name') {
                            notification1.params.put(key, stu.Contact__r.Father__r.Name);
                        }else if (key == 'ward_name') {
                            notification1.params.put(key.trim(),stu.Warden__r.LastName +' '+ stu.Warden__r.FirstName );     
                        }else if (key == 'start_date') {
                            notification1.params.put(key.trim(), String.valueof(stu.Start_Date__c));
                        } else if (key == 'end_date') { 
                            notification1.params.put(key.trim(),  String.valueof(stu.End_Date__c));
                        }else if (key == 'SRN_Number') {
                            notification1.params.put(key.trim(), stu.Contact__r.SRN_Number__c);
                        }      
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Contact__r.Father__r.MobilePhone !=null){
                            String plusRemoved = stu.Contact__r.Father__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
}