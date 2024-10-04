public class AccountEmailHelper {
    private static List<String> recipientEmails = new List<String>{
        'jyotiranjan.panda@reva.edu.in',
        'harshitha.bg@reva.edu.in',
        'rashmi.n@reva.edu.in',
        'shinil.tp@reva.edu.in',
        'velpulagunavardan.reddy@reva.edu.in',
        'harsh.joshi@reva.edu.in',
         'nagineni.chaithanya@reva.edu.in'
            };
                public static void handleInsert(List<Account> newAccounts) {
                    
                    
                    if (!newAccounts.isEmpty()) {
                        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
                        
                        for (String recipientEmail : recipientEmails) {
                            for (Account newAccount : newAccounts) {
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.setToAddresses(new String[]{recipientEmail}); // Replace with your recipient's email address
                                email.setSubject('New Account Created');
                                
                                
                                Boolean sendEmail = false;
                                if (   newAccount.RecordTypeId == '0125j000000uuRhAAI' ||
                                    newAccount.RecordTypeId == '0125j000000uuRkAAI' ||
                                    newAccount.RecordTypeId == '0125j000000uuRnAAI'
                                   ) {
                                       sendEmail = true;
                                   }
                                if (sendEmail) {
                                    String parentNameNew = getParentName(newAccount.ParentId);
                                    String createdBy;
                                    if (newAccount.CreatedById != null) {
                                        User creator = [SELECT Name FROM User WHERE Id = :newAccount.CreatedById LIMIT 1];
                                        createdBy = creator.Name;
                                    } else {
                                        createdBy = 'Unknown'; // or another default value
                                    }
                                    String body = 'Dear Team, Account created by: ' + createdBy + '<br/>'+'<br/>';
                                    if(newAccount.RecordTypeId == '0125j000000uuRhAAI'){
                                        body += 'Account ID: ' + newAccount.Id + '<br/>';
                                        body += 'Account Name: ' + newAccount.Name + '<br/>';
                                        body += 'Display Name (Program): ' + newAccount.Display_Name_Program__c + '<br/>';
                                        String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :newAccount.RecordTypeId].Name;
                                        body += 'Record Type: ' + recordTypeName + '<br/>';
                                        body += 'Program Alias: ' + newAccount.Program_Alias__c + '<br/>'; 
                                        body += 'Program code: ' + newAccount.Program_Code__c + '<br/>';
                                        body += 'Program Type: ' + newAccount.Program_Type__c + '<br/>';
                                        body += 'No of Years: ' + newAccount.No_of_Years__c + '<br/>';
                                        body += 'Number of Semesters: ' + newAccount.Number_of_Semesters__c + '<br/>';
                                        body += 'ParentId: ' + parentNameNew + '<br/>';
                                        body += 'Intake: ' + newAccount.Intake__c + '<br/>';
                                        body += 'Intake Per Section: ' + newAccount.Intake_Per_Section__c + '<br/>';
                                        body += 'Number of Batches: ' + newAccount.Number_of_Batches__c + '<br/>';
                                        body += 'Description: ' + newAccount.Description + '<br/>';
                                    } else if(newAccount.RecordTypeId =='0125j000000uuRkAAI'){
                                        body += 'Account ID: ' + newAccount.Id + '<br/>';
                                        body += 'Account Name: ' + newAccount.Name + '<br/>';
                                        String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :newAccount.RecordTypeId].Name;
                                        body += 'Record Type: ' + recordTypeName + '<br/>';
                                        body += 'ParentId: ' + parentNameNew + '<br/>';
                                        body += 'Sequence: ' + newAccount.Sequence__c + '<br/>';
                                    }else if(newAccount.RecordTypeId =='0125j000000uuRnAAI'){
                                        body += 'Account ID: ' + newAccount.Id + '<br/>';
                                        body += 'Account Name: ' + newAccount.Name + '<br/>';
                                        String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :newAccount.RecordTypeId].Name;
                                        body += 'Record Type: ' + recordTypeName + '<br/>';
                                        body += 'ParentId: ' + parentNameNew + '<br/>';
                                        body += 'Sequence: ' + newAccount.Sequence__c + '<br/>';
                                        body += 'School Head: ' + newAccount.School_Head__c + '<br/>';
                                        body += 'Vertical Head: ' + newAccount.Vertical_Head__c + '<br/>';
                                        body += 'SLCM - HCM ID: ' + newAccount.SLCM_HCM_ID__c + '<br/>';
                                    }
                                    email.setHtmlBody(body);
                                    if (owea.size() > 0) {
                                        email.setOrgWideEmailAddressId(owea[0].Id);
                                    }
                                    emails.add(email);
                                }
                            }
                        }
                        if (!emails.isEmpty()) {
                            Messaging.sendEmail(emails);
                        }
                    }
                }
    /*
    public static void handleUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        // Your update logic here
        
        if (!newAccounts.isEmpty()) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
            
            for (String recipientEmail : recipientEmails) {
                for (Account newAccount : newAccounts) {
                    Account oldAccount = oldAccountMap.get(newAccount.Id);
                    if (isRecordTypeSupported(newAccount.RecordTypeId)) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] {recipientEmail}); // Replace with your recipient's email address
                        email.setSubject('Account Updated');
                        String parentNameOld = getParentName(oldAccount.ParentId);
                        String parentNameNew = getParentName(newAccount.ParentId);
                        String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :newAccount.RecordTypeId].Name;
                        String oldrecordTypeName = [SELECT Name FROM RecordType WHERE Id = :oldAccount.RecordTypeId].Name;
                        String lastModifiedByName = [SELECT Name FROM User WHERE Id = :newAccount.LastModifiedById].Name;
                        String currentDateTime = DateTime.now().format('MM/dd/yyyy HH:mm:ss', 'Asia/Kolkata'); 
                        String body = 'Dear Team, Account modified by: ' + lastModifiedByName +' (Date and Time: '+currentDateTime+ ')<br/>'+'<br/>';
                        body += 'Account ID: ' + newAccount.Id + '<br/>';
                        body += 'Account Name: ' + newAccount.Name + '<br/>'+'<br/>';
                        if (parentNameOld != parentNameNew) {
                            body += 'Parent Name changed to ' + parentNameNew +' (old value: '+parentNameOld+ ')<br/>';
                        }
                        if (oldrecordTypeName != recordTypeName) {
                            body += 'RecordTypeName changed to ' + recordTypeName +' (old value: '+oldrecordTypeName+ ')<br/>';
                        }
                        if (oldAccount.Name != newAccount.Name) {
                            body += 'Name changed to ' +newAccount.Name +' (old value: '+oldAccount.Name+ ')<br/>';
                        }
                        if (oldAccount.Display_Name_Program__c != newAccount.Display_Name_Program__c) {
                            body += 'Display Name Program changed to ' + newAccount.Display_Name_Program__c +' (old value: '+oldAccount.Display_Name_Program__c+ ')<br/>';
                        }
                        
                        if (oldAccount.Program_Alias__c != newAccount.Program_Alias__c) {
                            body += 'Program Alias changed to ' +newAccount.Program_Alias__c +' (old value: '+oldAccount.Program_Alias__c+ ')<br/>';
                        }
                        if (oldAccount.Program_Code__c != newAccount.Program_Code__c) {
                            body += 'Program Code changed to ' + newAccount.Program_Code__c +' (old value: '+oldAccount.Program_Code__c+ ')<br/>';
                        }
                        if (oldAccount.Program_Type__c != newAccount.Program_Type__c) {
                            body += 'Program Type changed to ' + newAccount.Program_Type__c +' (old value: '+oldAccount.Program_Type__c+ ')<br/>';
                        }
                        if (oldAccount.No_of_Years__c != newAccount.No_of_Years__c) {
                            body += 'No of Years changed to ' + newAccount.No_of_Years__c +' (old value: '+oldAccount.No_of_Years__c+ ')<br/>';
                        }
                        if (oldAccount.Number_of_Semesters__c != newAccount.Number_of_Semesters__c) {
                            body += 'Number of Semesters changed to ' + newAccount.Number_of_Semesters__c +' (old value: '+oldAccount.Number_of_Semesters__c+ ')<br/>';
                        }
                        
                        if (oldAccount.Intake__c != newAccount.Intake__c) {
                            body += 'Intake changed to ' + newAccount.Intake__c +' (old value: '+oldAccount.Intake__c+ ')<br/>';
                        }
                        if (oldAccount.Intake_Per_Section__c != newAccount.Intake_Per_Section__c) {
                            body += 'Intake Per Section changed to ' + newAccount.Intake_Per_Section__c +' (old value: '+oldAccount.Intake_Per_Section__c+ ')<br/>';
                        }
                        if (oldAccount.Number_of_Batches__c != newAccount.Number_of_Batches__c) {
                            body += 'Number of Batches changed to ' + newAccount.Number_of_Batches__c +' (old value: '+oldAccount.Number_of_Batches__c+ ')<br/>';
                        }
                        if (oldAccount.Description != newAccount.Description) {
                            body += 'Description changed to ' + newAccount.Description +' (old value: '+oldAccount.Description+ ')<br/>';
                        }
                        if (oldAccount.Sequence__c != newAccount.Sequence__c) {
                            body += 'Sequence changed to ' + newAccount.Sequence__c +' (old value: '+oldAccount.Sequence__c+ ')<br/>';
                        }
                        if (oldAccount.School_Head__c != newAccount.School_Head__c) {
                            body += 'School Head changed to ' + newAccount.School_Head__c +' (old value: '+oldAccount.School_Head__c+ ')<br/>';
                        }
                        if (oldAccount.Vertical_Head__c != newAccount.Vertical_Head__c) {
                            body += 'Vertical Head changed to ' + newAccount.Vertical_Head__c +' (old value: '+oldAccount.Vertical_Head__c+ ')<br/>';
                        }
                        if (oldAccount.SLCM_HCM_ID__c != newAccount.SLCM_HCM_ID__c) {
                            body += 'SLCM HCM ID changed to ' + newAccount.SLCM_HCM_ID__c +' (old value: '+oldAccount.SLCM_HCM_ID__c+ ')<br/>';
                        }
                        
                        email.setHtmlBody(body);
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea[0].Id);
                        }
                        emails.add(email);
                    }
                }
            }
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }
    
    public static void handleDelete(List<Account> deletedAccounts) {
        // Your delete logic here
        
        if (!deletedAccounts.isEmpty()) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
            
            for (String recipientEmail : recipientEmails) {
                for (Account deletedAccount : deletedAccounts) {
                    if (isRecordTypeSupported(deletedAccount.RecordTypeId)) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] {recipientEmail}); // Replace with your recipient's email address
                        email.setSubject('Account Deleted');
                        String deletedBy = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()].Name;
                        String currentDateTime = DateTime.now().format('MM/dd/yyyy HH:mm:ss', 'Asia/Kolkata');
                        String body = 'Dear Team, Account deleted by: ' + deletedBy +' (Date and Time: '+currentDateTime+ ')<br/>'+'<br/>';
                        body += 'Account ID: ' + deletedAccount.Id + '<br/>';
                        body += 'Account Name: ' + deletedAccount.Name + '<br/>';
                        email.setHtmlBody(body);
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea[0].Id);
                        }
                        emails.add(email);
                    }
                }
            }
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }
    private static Boolean isRecordTypeSupported(Id recordTypeId) {
        // Add the Ids of the supported Record Types here
        Set<Id> supportedRecordTypes = new Set<Id>{
            '0125j000000uuRhAAI',
                '0125j000000uuRkAAI',
                '0125j000000uuRnAAI'
                };
                    return supportedRecordTypes.contains(recordTypeId);
    }*/
    public static String getParentName(Id parentId) {
        String parentName = '';
        if (parentId != null) {
            List<Account> parentAccounts = [SELECT Name FROM Account WHERE Id = :parentId LIMIT 1];
            if (!parentAccounts.isEmpty()) {
                parentName = parentAccounts[0].Name;
            }
        }
        return parentName;
    }
}