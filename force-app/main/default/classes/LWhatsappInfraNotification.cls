public class LWhatsappInfraNotification {

    public class InputParameters {
        @InvocableVariable(required=true)
        public List<String> recordIds;

        @InvocableVariable(required=true)
        public List<String> userIds;
       
        @InvocableVariable(required=true)
        public List<String> UserCheck;
    }
        public static String ApplicantName;
      Public static string ApplicantOwnerName;
    Public static string ApplicantOwnerMobile;
    public static string INFRACategory;
    public static string Facility;
    Public static String PhoneNumbersms;

    
    
    @InvocableMethod(label='L Users Notifications')
    public static void processContacts(List<InputParameters> inputs) {
        List<Id> LUserId =inputs[0].userIds ;
        List<string> checkuser =inputs[0].UserCheck;
        system.debug('checkuser[0]:'+checkuser[0]);
        if(LUserId != Null &&  checkuser[0] != Null ){
            makeCalloutAsync(inputs[0].recordIds,LUserId,checkuser[0]);
            if(checkuser[0] == 'L1'){
                L1UserMethod(inputs[0].recordIds, 'infrastructure_support_l1_',LUserId );
                 system.debug('checkuser##############:'+checkuser);
            }   if(checkuser[0] == 'L2'){
                L1UserMethod(inputs[0].recordIds, 'infrastructure_support_l2_updated',LUserId );
                 system.debug('checkuser##################:'+checkuser);
            }  if(checkuser[0] == 'L3'){
                L1UserMethod(inputs[0].recordIds, 'infrastructure_support_l3_copy',LUserId );
                system.debug('checkuser###################:'+checkuser);
            } if(checkuser[0] == 'L4'){
                L1UserMethod(inputs[0].recordIds, 'infrastructure_support_l4',LUserId );
            }  
        }
    }
    
    @Future(callout=true)
    public static void L1UserMethod(List<string> recordIds, String whatsappTemplateName , list<Id> userId ) {
        List<Domain> domainList = [
            SELECT Id, DomainType, Domain, HttpsOption 
            FROM Domain 
            WHERE HttpsOption = 'CommunityAlt'
        ];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        
        Case caseRecord = [
            SELECT id, OwnerId,CreatedDate, CaseNumber, Description, INFRA_Category__c, INFRA_Sub_Category__c,Facility__c,Facility__r.Name

            FROM Case 
            WHERE id = :recordIds 
            LIMIT 1
        ];
        String formattedCreatedDate = caseRecord.CreatedDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
    
        List<User> caseOwnerList = [SELECT Id,Name, Phone FROM User WHERE (contactId =:userId or id =:userId ) LIMIT 1];
        
        for (User caseOwner : caseOwnerList) {
            Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            notification.templateId = whatsappTemplateName;
            notification.params = new Map<String, String>();
            
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :notification.templateId
            ];
            
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                
                for (String key : keys) {
                    if (metadata.Template_ID__c == 'infrastructure_support_l1_') {
                        if (key == 'L1_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Raised_by') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_date') {
                            notification.params.put(key, formattedCreatedDate);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.INFRA_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.INFRA_Sub_Category__c);
                        } else if (key == 'facility') {
                            notification.params.put(key, caseRecord.Facility__r.Name);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), Label.NonTeachingFacultyURL);
                        }
                    }else if (metadata.Template_ID__c == 'infrastructure_support_l2_updated') {
                        if (key == 'L2_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        }  else if (key == 'Raised_by') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_date') {
                            notification.params.put(key, formattedCreatedDate);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                           
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.INFRA_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.INFRA_Sub_Category__c);
                        } else if (key == 'facility') {
                            notification.params.put(key, caseRecord.Facility__r.Name);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), Label.NonTeachingFacultyURL);
                        }
                    }else if (metadata.Template_ID__c == 'infrastructure_support_l3_copy') {
                        if (key == 'L3_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        }  else if (key == 'Raised_by') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_date') {
                            notification.params.put(key, formattedCreatedDate);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.INFRA_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.INFRA_Sub_Category__c);
                        } else if (key == 'facility') {
                            notification.params.put(key, caseRecord.Facility__r.Name);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), Label.NonTeachingFacultyURL);
                        }
                    }
                    
                }
                
                List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                    
                    if (caseOwner.Phone != null) {
                        String plusRemoved = caseOwner.Phone.replace('+', '');
                        String correctedWhatsappNumber = plusRemoved.replace('-', '');
                        
                        if (!phoneNumbersToNotifications.containsKey(correctedWhatsappNumber)) {
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                        }
                       
                    }
            }
  
          
        }
          if (!phoneNumbersToNotifications.isEmpty()) {
                
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                
            }
    }

@Future(callout=true)
    public static void makeCalloutAsync( List<string> recordIds, list<Id> userId, String checkUser ) {
        system.debug('caseRecord==rec>'+recordIds);
        system.debug('caseRecord==user>'+userId);
        system.debug('caseRecord==cuser>'+checkUser);
        system.debug('caseRecord==cr>'+[SELECT id, CaseNumber, INFRA_Category__c, Status, Description, Facility__c FROM Case
                           WHERE id = :recordIds 
                           LIMIT 1
                          ]);
        Case caseRecord = [SELECT id,CaseNumber, INFRA_Category__c, Status, Description, Facility__r.Name,createdDate,Owner.Name, SRN_Number__c,CreatedBy.Name FROM Case
                           WHERE id = :recordIds 
                           LIMIT 1
                          ];  
       
        String formattedCreatedDate = caseRecord.createdDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
        Contact contactRecord = [
            SELECT id, Name, SRN_Number__c 
            FROM Contact 
            WHERE SRN_Number__c = :caseRecord.SRN_Number__c 
            LIMIT 1
        ];
        

        List<User> caseOwnerList = [SELECT Id,Name, Phone FROM User WHERE (contactId =:userId or id =:userId ) ];
        
        ApplicantName = caseRecord.CreatedBy.Name;
        ApplicantOwnerMobile = caseOwnerList[0].Phone;
        ApplicantOwnerName = caseRecord.Owner.Name;
        Facility = caseRecord.Facility__r.Name;
        INFRACategory = caseRecord.INFRA_Category__c;
        
        if(ApplicantOwnerMobile != null){
            String plusRemoved = ApplicantOwnerMobile.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            PhoneNumbersms = correctedWhatsappNumber;
        }
        if (caseRecord != Null) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            system.debug('Hello'+checkUser);
            
            if(checkUser == 'L1'){
                SmsApplicantl1(caseRecord , messageList);
                if (!messageList.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('Support_Request', messageList); 
                    system.debug('Hello');
                }
            }else if(checkUser == 'L2' || checkUser == 'L3' ||checkUser == 'L4'){   
                system.debug('Hello'+checkUser);
                SmsApplicantL2(caseRecord , messageList);
                if (!messageList.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('Support_Request_Escalated_L2', messageList);  
                    system.debug('HelloL2');
                }
            }
            
        }
    }
    
    public static void SmsApplicantL1(Case stuPaySet, List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        
        String message = 'Dear' + ApplicantOwnerName + ',\n New support request has been received from ' + ApplicantName + ' at ' + Facility +'. The category is ' + INFRACategory + '. \nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007750857858490000';
        shrtMessage.message = message;
        shrtMessage.recipient = PhoneNumbersms;
        messageList.add(shrtMessage);
    }
    public static void SmsApplicantL2(Case stuPaySet, List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        String message = 'Dear '+ ApplicantOwnerName +', \nSupport request from '+ ApplicantName + ' at '+ Facility +' has not been resolved. Hence it is escalated to you. \nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007162440757080887';
        shrtMessage.message = message;
        shrtMessage.recipient = PhoneNumbersms;
        messageList.add(shrtMessage);
    } 
    
    }