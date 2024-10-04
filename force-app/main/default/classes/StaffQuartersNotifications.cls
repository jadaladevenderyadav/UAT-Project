public class StaffQuartersNotifications {
  
    public static String staffName;
    public static String Employcode;
    public static String DptName;
    public static String FloorNo;
    public static String HouseNo;
    public static String Disgnation;
    public static String staffNumber;
    public static String HstOfficeNumber;
    public static String HRNumber;
    public class InputParameters {
        
        @InvocableVariable(required=true)
        public List<String> recordIds;
        
        @InvocableVariable(required=true)
        public String reqperson; 
    }
    
    @InvocableMethod(label='Staff Quarters Notifications')
    public static void processContacts(List<InputParameters> inputs) {
        List<Id> recordId =inputs[0].recordIds ;
        string checkuser =inputs[0].reqperson;
        
        if(recordId != Null &&  checkuser != Null ){
            makeCalloutAsync(recordId,checkuser);
            if(checkuser == 'Booking'){
                StaffBooking(RecordId);
                HostelOffice(RecordId);
                HRBooking(RecordId);
            } 
            if(checkuser == 'Allotment'){
                StaffAllotment(RecordId);
                HostelOfficeAllotment(RecordId);
                HRAllotment(RecordId);
            } 
        }
    }
    
    Public static Void StaffBooking(List<Id> RecordId){
        System.debug('Phone Number -->'+RecordId);
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'staff_quar_req_staff_notif';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'staff_quar_req_staff_notif') {
                    for (String key : keys) {
                        if (key == 'staff_name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Room_Request_For__r.Phone !=null){
                            String plusRemoved = stu.Room_Request_For__r.Phone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }

   Public static Void HostelOffice(List<Id> RecordId){
        System.debug('Phone Number -->'+RecordId);
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'staff_quar_req_hostel_notif';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'staff_quar_req_hostel_notif') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if(key == 'emp_code'){
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if(key == 'dept_name'){
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if(key == 'desig'){
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if(key == 'mob_no'){
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Room_Request_For__r.Phone !=null){
                            String plusRemoved = stu.Room_Request_For__r.Phone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }

   Public static Void HRBooking(List<Id> RecordId){
        System.debug('Phone Number -->'+RecordId);
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'staff_quar_req_hr_notif';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'staff_quar_req_hr_notif') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'emp_code') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'Department_name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'desig') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'Mob_No') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Room_Request_For__r.Phone !=null){
                            String plusRemoved = stu.Room_Request_For__r.Phone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }

 Public static Void StaffAllotment(List<Id> RecordId){
        System.debug('Phone Number -->'+RecordId);
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'staff_quar_alloc_staff_notif';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'staff_quar_alloc_staff_notif') {
                    for (String key : keys) {
                        if (key == 'staff_name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'floor_No') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'House_No') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Room_Request_For__r.Phone !=null){
                            String plusRemoved = stu.Room_Request_For__r.Phone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }

 Public static Void HostelOfficeAllotment(List<Id> RecordId){
        System.debug('Phone Number -->'+RecordId);
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'staff_quar_alloc_hos_notif';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'staff_quar_alloc_hos_notif') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'Staff_Name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'emp_code') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'dept_name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'desig') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'floor_no') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'House_No') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Room_Request_For__r.Phone !=null){
                            String plusRemoved = stu.Room_Request_For__r.Phone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }

 Public static Void HRAllotment(List<Id> RecordId){
        System.debug('Phone Number -->'+RecordId);
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'staff_quar_alloc_hr_notif';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'staff_quar_alloc_hr_notif') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'Staff_Name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'emp_code') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'dept_name') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'Desig') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'floor_no') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }else if (key == 'house_no') {
                            notification1.params.put(key, stu.Room_Request_For__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Room_Request_For__r.Phone !=null){
                            String plusRemoved = stu.Room_Request_For__r.Phone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }


  @Future(callout=true)
    public static void makeCalloutAsync(List<Id> RecordId,String TemplateType) {
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>(); 

       List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Staff_Quarters_Room__r.Name,Room_Request_For__r.Name,
                                                      Staff_Quarters_Room__r.Floor__c,Room_Request_For__r.Phone From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
            for(Staff_Quarters_Request__c Rgus:Revaguestre){
            staffName = Rgus.Room_Request_For__r.Name;
            HouseNo = Rgus.Staff_Quarters_Room__r.Name;
            FloorNo = Rgus.Staff_Quarters_Room__r.Floor__c;
           
            if(Rgus.Room_Request_For__r.Phone != null){
                String plusRemoved = Rgus.Room_Request_For__r.Phone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                staffNumber = correctedWhatsappNumber;
            } 
            /*    if(Rgus.Department_Head__r.MobilePhone != null){
                String plusRemoved = Rgus.Department_Head__r.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                DptHeadNumber = correctedWhatsappNumber;
            } if(Rgus.General_Admin__r.MobilePhone != null){
                String plusRemoved = Rgus.General_Admin__r.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                GeneralAdminNumber = correctedWhatsappNumber;
            }*/
            
            if (!Revaguestre.isEmpty()) {
                if (TemplateType == 'Booking') {
                    StaffBooking(messageList);
                    HostelOfficeBooking(messageList);
                }else if(TemplateType == 'Allotment'){
                    StaffAllotment(messageList);
                    HostelOfficeAllotment(messageList);
                }
                
                if (!messageList.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('Staff_Quarters_Notification', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Staff_Quarters_Notification_Hostel_Offi',messageList);
                    SMS_API_Utility.SendSMSOneToMany('Staff_Quarters_Allotted_Hostel_Office_an', messageList);
                    SMS_API_Utility.SendSMSOneToMany('Quarters_Allocation_Staff',messageList);

                   }
            } else {
                System.debug('No related records found for the provided IDs');
            }
        }
    }
    
    
    public static void StaffBooking( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();
        string phnNumber=staffNumber;
        String message = 'Dear '+staffName+ ',\nYour request for Staff Quarters has been received. We will notify you once it is processed.\nRegards,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007468806114250000';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
  public static void HostelOfficeBooking( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();	
        string phnNumber=staffNumber;
        String message = 'New Staff Quarters request received from '+staffName+ '. Please review the request. Employee Code:'+Employcode+' Designation: '+DptName+' \nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007439185764223757';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
 public static void StaffAllotment( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();	
        string phnNumber=staffNumber;
        String message = 'Dear '+staffName+  '\nYour Quarters is allocated as per your request. Floor No'+Employcode+' House No: '+DptName+'\nRegards,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007430938745779093';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
 public static void HostelOfficeAllotment( List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        Datetime DateandTime = system.now();	
        string phnNumber=staffNumber;
        String message = 'Staff Quarters is allocated to '+staffName+ '#}. Employee Code:'+Employcode+' Designation: '+Disgnation+' Department: '+DptName+' Floor No: '+FloorNo+' House No: '+HouseNo+'\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007430938745779093';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        messageList.add(shrtMessage);
    }
}