public class HallTicket_Published_whats_batchQueue implements Queueable, Database.AllowsCallouts {
    private List<Contact> elgcontactList;
    public List<string>ExamName;
    public List<String> Semester;

    // Constructor to accept the list of contacts
    public HallTicket_Published_whats_batchQueue(List<Contact> contacts,List<String>ExamName,List<String>Semester) {
        this.elgcontactList = contacts;
        this.ExamName = ExamName;
        this.Semester= Semester;
    }

    // Execute method
    public void execute(QueueableContext context) {
       // Fetching template details
            String StdelgtemplateId = 'hall_ticket_notification_for_eligible_student';
            String parentelgtemplateId = 'hall_ticket_notification_parents_eligible';            
            
            ////////////////////// Iterate through contacts to create notifications for elgible students/////////////////
            for (Contact con : elgcontactList) {
                system.debug(con.name);
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = StdelgtemplateId;
                notification.params = new Map<String, String>();
                
                // Set dynamic values for each key based on related record
                notification.params.put('studentname', con.Name);
                notification.params.put('examname', String.join(examname, ','));
                
                // Map to store notifications for each contact's phone number
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                
                
                // Add notification to map
                phoneNumbersToNotifications.put(con.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                
                //Send Whatsapp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> '+response);
            }
            
            
            ////////////////////// Iterate through contacts to create notifications for elgible parents/////////////////
            for (Contact con : elgcontactList) {
                system.debug(con.name);
                
                // Determine which parent's contact to use
                String parentContactNumber = '';
                String parentName = '';
                
                if (con.Father_Mobile_Number__c != null) {
                    parentContactNumber = con.Father_Mobile_Number__c;
                    parentName =con.Father_Name__c;
                } else if (con.Mother_Mobile_Number__c != null) {
                    parentContactNumber = con.Mother_Mobile_Number__c;
                    parentName = con.Mother_Name__c;
                } else if (con.Guardian__r.MobilePhone != null) {
                    parentContactNumber = con.Guardian__r.MobilePhone;
                    parentName = con.Guardian__r.Name;
                }
                // Create notifications for parent(s)
                if (parentContactNumber != '') {
                    Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                    notification.templateId = parentelgtemplateId;
                    notification.params = new Map<String, String>();
                    
                    // Set dynamic values for each key based on related record
                    notification.params.put('parentname', parentName);
                    notification.params.put('examname', String.join(examname, ','));
                    notification.params.put('semestername', String.join(semester, ','));
                    
                    // Map to store notifications for each contact's phone number
                    Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                    
                    
                    // Add notification to map
                    phoneNumbersToNotifications.put(parentContactNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                    
                    //Send Whatsapp notifications
                    HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                    System.debug('Response=> '+response);
                    
                }
            }

              List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            List<SMS_API_Utility.shortMessageWrp> messageList1 = new List<SMS_API_Utility.shortMessageWrp>();

        if(!elgcontactList.isEmpty())
            {
                for(Contact con : elgcontactList) {
                    String phoneNumber = con.MobilePhone;            
                    
                    String message = 'Dear '+con.Name+', The Hall Ticket for '+examname[0]+' has been published in your Student Portal.'
                        +'Please login to your Student Portal and download the Hall ticket. REVA University';
                    
                    if(phoneNumber != null && message != null){
                        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                        shrtMessage.dltContentId = '1007254147253479284';
                        shrtMessage.message = message;
                        shrtMessage.recipient = phoneNumber;
                        messageList.add(shrtMessage);
                    }
                    
                    // Ternary operators for parent phone number and name
                    String parentPhoneNumber = con.Father_Mobile_Number__c != null ? con.Father_Mobile_Number__c
                        : con.Mother_Mobile_Number__c != null ? con.Mother_Mobile_Number__c
                            : con.Guardian__r != null ? con.Guardian__r.MobilePhone : null;
                    
                    String parentName = con.Father_Mobile_Number__c != null ? con.Father_Name__c
                        : con.Mother_Mobile_Number__c != null ? con.Mother_Name__c
                            : con.Guardian__r != null ? con.Guardian__r.Name : null;
                    
                    if(parentPhoneNumber != null && parentName != null) {
                        System.debug('Parent phoneNumber => ' + parentPhoneNumber);          
                        
                        String message1 = 'Dear Mr./Ms. ' + parentName + ', This is to inform you that the Hall Ticket for your ward ' + con.Name + ' had been published for ' + con.Active_Semester__r.Name + ' ' + examname[0] + '. REVA University';
                        
                        SMS_API_Utility.shortMessageWrp shrtMessage1 = new SMS_API_Utility.shortMessageWrp();
                        shrtMessage1.dltContentId = '1007449711845627472';
                        shrtMessage1.message = message1;
                        shrtMessage1.recipient = parentPhoneNumber;
                        messageList1.add(shrtMessage1); 
                    }
                }
                
            }

             if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Hall Ticket Notification-Eligible Studen', messageList);
            }
            if(messageList1.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Hall Ticket Notification to Parents', messageList1);
            }

             List<Messaging.SingleEmailMessage> sendemaillist = new List<Messaging.SingleEmailMessage>();
            
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];

            // Iterate through eligible students to create email notifications
            for (Contact conList : elgcontactList) {
                String subject = 'Download your Hall ticket for ' + String.join(examname, ',');
                String body = EmailTemplatesForReva.sendHallTicketEmailtoEligibleStudent7(conList.Name, String.join(examname, ','), 'studentPortalLink');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{conList.Email});
                email.setOrgWideEmailAddressId(owea.Id);
                email.setSubject(subject);
                email.setHtmlBody(body);
                sendemaillist.add(email);
            }
            
            // Iterate through eligible students' parents to create email notifications
            for (Contact conListParent : elgcontactList) {
                // Determine which parent's contact to use
                String parentEmail = '';
                String parentName = '';
                
                if (conListParent.Father_Email_ID__c != null) {
                    parentEmail = conListParent.Father_Email_ID__c;
                    parentName = conListParent.Father_Name__c;
                } else if (conListParent.Mother_Email_ID__c != null) {
                    parentEmail = conListParent.Mother_Email_ID__c;
                    parentName = conListParent.Mother_Name__c;
                } else if (conListParent.Guardian__r.Email != null) {
                    parentEmail = conListParent.Guardian__r.Email;
                    parentName = conListParent.Guardian__r.Name;
                }
                
                // Create notifications for parent(s)
                if (parentEmail != '') {
                    // Create a new email message
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    // Set the recipient email address
                    email.setToAddresses(new String[]{parentEmail});
                    
                    // Set the subject using the provided method
                    String subject = 'Hall ticket Published for ' +  String.join(examname, ',');
                    email.setSubject(subject);
                    
                    // Set the HTML body using the provided method
                    String body = EmailTemplatesForReva.sendHallTicketPublishEmailtoParent8(parentName, String.join(semester, ','), String.join(examname, ','));
                    email.setHtmlBody(body);
                    
                    // Add the created email message to eligibleParentEmails list
                    sendemaillist.add(email);           
                }

                
            }

            Messaging.sendEmail(sendemaillist);
    }
}