public class PAFPaymentSendEmails {

  
    public static String ApplicantName;
    public static String ApplicantNumber;
    public static String PhoneNumber;
    Public static string ApplicantOwnerName;
    Public static string ApplicantOwnerMobile;
   
    public static void sendDirectPaymentLinkEmail(Map<Id,Map<String,String>> conEmailSourceMap){
        List<Contact> conList = [Select id, name, Email FROM Contact WHERE id =: conEmailSourceMap.keySet()];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 

        for(Contact con : conList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            List<String> sendTo = new List<String>();
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('REVA - Admission Payment Link');
            String body='' ;
        
            body = 'Dear '+ con.Name + ',<br/>';
            body += '<br/> Kindly make a payment of Rs. ' + (conEmailSourceMap.get(con.Id)).get('Amount') + ' to confirm you Provisional Admission Online at ' + (conEmailSourceMap.get(con.Id)).get('URL') + '.<br/>';
            body += '<br/> In case of any confusion, kindly connect with your admission counsellor '+ (conEmailSourceMap.get(con.Id)).get('CounsellorName') + ' on ' + (conEmailSourceMap.get(con.Id)).get('CounsellorMobileNo') +'<br/>';
            body += '<br/> Regards, <br/> Office of Admissions <br/> REVA University';
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails); 
        }
    }
      public static void sendConfirmEmail(Map<Id,Map<String,String>> ConfirmconEmailSourceMap){
        List<Contact> conList = [Select id, name, Email FROM Contact WHERE id =: ConfirmconEmailSourceMap.keySet()];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 

        for(Contact con : conList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            List<String> sendTo = new List<String>();
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('REVA - Fee Payment Confirmation');
            String body='' ;
        
            body = 'Dear '+ con.Name + ',<br/>';
            body += '<br/> We have received your Provisional Admission Fee of Rs. ' + (ConfirmconEmailSourceMap.get(con.Id)).get('TotalFee')+ '.<br/>';
            body += '<br/> For any futher clarity, connect with your admission counselor '+ (ConfirmconEmailSourceMap.get(con.Id)).get('CounsellorName') + ' on ' + (ConfirmconEmailSourceMap.get(con.Id)).get('CounsellorMobileNo') +'<br/>';
            body += '<br/> Regards, <br/> REVA University';
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails); 
        }
    }
     public static void sendRejectionEmail(Map<Id,Map<String,String>> RejectconEmailSourceMap){
        List<Contact> conList = [Select id, name, Email FROM Contact WHERE id =: RejectconEmailSourceMap.keySet()];
         system.debug('conList::'+conList);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 

        for(Contact con : conList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            List<String> sendTo = new List<String>();
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('REVA - Payment Status');
            String body='' ;
        
            body = 'Dear '+ con.Name + ',<br/>';
            body += '<br/> We regret to inform you that the ' + (RejectconEmailSourceMap.get(con.Id)).get('ModeofPayment') + ' payment associated with Application No:' + (RejectconEmailSourceMap.get(con.Id)).get('Applicationno') + ', amounting to ' + (RejectconEmailSourceMap.get(con.Id)).get('Amount') +  ', was rejected at ' + (RejectconEmailSourceMap.get(con.Id)).get('Dateandtime') +  '.';
            body += ' Please contact your admission counselor for further guidance on the necessary procedure to resolve this issue.<br/>';
            body += ' <br/> Thank you for your attention to this matter.<br/>';
            body += '<br/> Regards, <br/> REVA University';
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails); 
        }
    }
     
    
    
    public static void WhatstappNotificationCounselor(List<Contact> conRecs,Set<Id> stuPaySet, String whatsappTemplateName){
        System.debug('Hellooooooooo:::::');
       Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        Map<Id,Map<String,String>> RejectconEmailSourceMapOwner = new Map<Id,Map<String,String>>();
        notification1.templateId = whatsappTemplateName;
         Map<String,String> RejectEmailSourceMapOwner = new Map<String,String>();  
        // Fetch keys from custom metadata based on templateId
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        List<Student_payment__c> stuPayList=[SELECT Id, Name,Payment_Mode_Type__c, Amount__c, Contact__c, Billdesk_Url__c, payment_status__c FROM Student_payment__c WHERE Contact__c =:conRecs and id =: stuPaySet ORDER BY CreatedDate Desc];
        Map<Id,Decimal> conStuPayAmount = new Map<Id,Decimal>();
        Map<Id,Id> conStuPayIdMap = new Map<Id,Id>();
        Map<Id,string> conStuPayModeMap = new Map<Id,string>();
        for(Student_payment__c stupay : stuPayList){
            conStuPayAmount.put(stupay.Contact__c,stupay.Amount__c);
            conStuPayIdMap.put(stupay.Contact__c,stupay.Id);
            conStuPayModeMap.put(stupay.Contact__c,stupay.Payment_Mode_Type__c);
        }
        
       
          for( contact stu : conRecs ){
               notification1.params = new Map<String, String>();
               //Map<String,String> CounselorMobile = new Map<String,String>();
              Map<String,String> CounselorName = new Map<String,String>(); 
               for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
               String[] keys = metadata.Template_Field__c.split(',');
                   
              if(metadata.Template_ID__c == 'payment_reject_counselor') {
                   for (String key : keys) {
                       if (key == 'CounselorName') {
                                notification1.params.put(key, stu.Owner.Name);
                                RejectEmailSourceMapOwner.put(key, stu.Owner.Name);
                            }else if (key == 'modeofpayment') {
                            notification1.params.put(key.trim(), String.valueOf(conStuPayModeMap.get(stu.Id)));
                            RejectEmailSourceMapOwner.put(key.trim(), String.valueOf(conStuPayModeMap.get(stu.Id)));
                            } else if (key == 'Applictionno') {
                            notification1.params.put(key.trim(), stu.Application_Number__c);
                            RejectEmailSourceMapOwner.put(key.trim(), stu.Application_Number__c);
                            } 
                             else if (key == 'ApplicantName') {
                                notification1.params.put(key, stu.Name); 
                                  RejectEmailSourceMapOwner.put(key, stu.Name);
                            } else if (key == 'Amount') {
                                notification1.params.put(key.trim(), String.valueOf(conStuPayAmount.get(stu.Id))); //PAF amount entered by the counselor
                                RejectEmailSourceMapOwner.put(key.trim(), String.valueOf(conStuPayAmount.get(stu.Id)));
                            }
                            else if (key == 'DateandTime') {         
                                  DateTime currentDateTime = System.now();
                                String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                                 notification1.params.put(key.trim(), formattedDateTime); 
                                RejectEmailSourceMapOwner.put(key.trim(), formattedDateTime);
                        } 
                
            }
              }
            
               }
                if(RejectEmailSourceMapOwner.size() > 0){
                    RejectconEmailSourceMapOwner.put(stu.Id,RejectEmailSourceMapOwner);
                }
                
               List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                   if(stu.owner.mobilephone !=null){
                        String plusRemoved = stu.owner.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                       system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                   }       
        }
         if(RejectconEmailSourceMapOwner.size() > 0){
              //if AddedbyRajashekar as recursion is happening when batch class is run
             if(RecursiveTriggerHandler.isEmail)
             {
                 RecursiveTriggerHandler.isEmail = false;
                 sendRejectionEmailOwner(RejectconEmailSourceMapOwner);
             }
        }
       // if Added by Rajashekar  as recursion is happening when batch class is run
        if(!system.isbatch()){
             System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
        }
    }
    
    
 public static void sendRejectionEmailOwner(Map<Id,Map<String,String>> RejectconEmailSourceMapOwner){
        List<Contact> conList = [Select id, name,owner.Name,owner.Email, Email FROM Contact WHERE id =: RejectconEmailSourceMapOwner.keySet()];
         system.debug('conList::'+conList);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts']; 

        for(Contact con : conList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            List<String> sendTo = new List<String>();
            sendTo.add(con.owner.Email);
            mail.setToAddresses(sendTo);
            mail.setSubject('REVA - Payment Status');
            String body='' ;
        
            body = 'Dear '+ con.owner.Name + ',<br/>';
            body += '<br/> We regret to inform you that the ' + (RejectconEmailSourceMapOwner.get(con.Id)).get('modeofpayment') + ' payment associated with Application No:' + (RejectconEmailSourceMapOwner.get(con.Id)).get('Applictionno') + ','  + (RejectconEmailSourceMapOwner.get(con.Id)).get('ApplicantName') +', amounting to ' + (RejectconEmailSourceMapOwner.get(con.Id)).get('Amount') +  ', was rejected at ' + (RejectconEmailSourceMapOwner.get(con.Id)).get('DateandTime') +  '.<br/>';
            body += '<br/> Regards, <br/> REVA University';
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails); 
        }
    }
   
 
@Future(callout=true)
public static void makeCalloutAsync( Set<Id> stuPaySet) {
    List<Student_payment__c> stuPayList = [SELECT Id, Name, Mode_of_Payment__c,Payment_Mode_Type__c, Amount__c, Contact__r.Owner.Name, Contact__r.Owner.mobilephone,Contact__c,contact__r.Name,Contact__r.Application_Number__c,Contact__r.MobilePhone, Billdesk_Url__c, payment_status__c FROM Student_payment__c WHERE Id IN :stuPaySet ORDER BY CreatedDate DESC];
    System.debug('stuPayList::'+stuPayList);
    for(Student_payment__c sp:stuPayList){
      ApplicantName = sp.contact__r.Name;
      ApplicantNumber = sp.Contact__r.Application_Number__c;
      ApplicantOwnerName = sp.Contact__r.owner.Name;
        if(sp.Contact__r.mobilephone != null){
         String plusRemoved = sp.Contact__r.MobilePhone.replace('+', '');
          String correctedWhatsappNumber = plusRemoved.replace('-', '');
            PhoneNumber = correctedWhatsappNumber;
        }
        if(sp.Contact__r.Owner.mobilephone != null){
            String plusRemoved = sp.Contact__r.Owner.MobilePhone.replace('+', '');
          String correctedWhatsappNumber = plusRemoved.replace('-', '');
             ApplicantOwnerMobile= correctedWhatsappNumber;
        }
    if (!stuPayList.isEmpty()) {
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>(); // Define messageList here
        for (Student_payment__c trReg : stuPayList) {
            // Determine which method to call based on TemplateName__c value
            if (trReg.payment_status__c == 'Failed') {
                System.debug('Rejected');
                RejectedSmsApplicant(trReg, messageList);
                RejectedSmsOwner(trReg, messageList);
            }
          /*  if (trReg.payment_status__c == 'Pending') {
                
                LinkSmsApplicant(trReg, messageList);
                SMS_API_Utility.SendSMSOneToMany('Admission_Payment_Link', messageList);
                ConfirmSmsApplicant(trReg, messageList);
                SMS_API_Utility.SendSMSOneToMany('Partial_Payment_Confirmation', messageList);
            }*/
        }
        if (!messageList.isEmpty()) {
          SMS_API_Utility.SendSMSOneToMany('Payment_Rejection_Applicant', messageList);
          SMS_API_Utility.SendSMSOneToMany('Payment_Rejection_Counsellor', messageList);
            
        }
    } else {
        System.debug('No related records found for the provided IDs');
    }
}
}
  
  public static void RejectedSmsApplicant(Student_payment__c stuPaySet, List<SMS_API_Utility.shortMessageWrp> messageList) {
            
    String ApplicantName = ApplicantName;       
    String ModeofPayment = stuPaySet.Payment_Mode_Type__c;
    String ApplicationNo=ApplicantNumber;
    Decimal Amountrejected=stuPaySet.Amount__C;
    Datetime DateandTime = system.now();
    string phnNumber=PhoneNumber;
    String message = 'Dear ' + ApplicantName +  ',\n\nWe regret to inform you that the ' + ModeofPayment + ' payment vide App No ' + ApplicationNo + ', of Rs. ' + Amountrejected + ' , was rejected today at ' + DateandTime + '.\n\nPlease contact your admission counselor for further guidance to resolve this issue.\n\nRegards\nREVA University';
 
    // Assuming you have a method to send SMS and you pass the message and phone number
    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
    shrtMessage.dltContentId = '1007237864665829023';
    shrtMessage.message = message;
    shrtMessage.recipient = phnNumber;
    messageList.add(shrtMessage);
}
    
    public static void RejectedSmsOwner(Student_payment__c stuPaySet, List<SMS_API_Utility.shortMessageWrp> messageList) {
      
    String ApplicantName = ApplicantName;       
    String ModeofPayment = stuPaySet.Payment_Mode_Type__c;
    String ApplicationNo=ApplicantNumber;
    Decimal Amountrejected=stuPaySet.Amount__C;
    Datetime DateandTime = system.now();
    string phnNumber=ApplicantOwnerMobile;
    String message = 'Dear ' + ApplicantOwnerName +  ',\n\nYou are being informed that a ' + ModeofPayment + ' payment vide App No ' + ApplicationNo + ' ' + ApplicantName + ', of Rs. ' + Amountrejected + ' , was rejected on ' + DateandTime + '.\n\nRegards\nREVA University';
 
    // Assuming you have a method to send SMS and you pass the message and phone number
    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
    shrtMessage.dltContentId = '1007175550024129634';
    shrtMessage.message = message;
    shrtMessage.recipient = phnNumber;
    messageList.add(shrtMessage);
}
   
 
}