public without sharing class Rve_ViewHallTicketController {
   
    @AuraEnabled public boolean EnableHallTicket {get;set;}

    @AuraEnabled
    public static String getPdfFileAsBase64String(String StudentSRN) {
        String base64Pdf;
        if (!Test.isRunningTest()) {
            PageReference pdfPage = Page.HallTicketPDF;
            Blob pdfBlob = pdfPage.getContent();
            base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        } else {
            base64Pdf = StudentSRN;
        }
        return base64Pdf;
    }

    @AuraEnabled
    public static Rve_Exam_Notification__c getExamNotification(String recType) {
        try {
            List<Rve_Exam_Notification__c> examNotifications = new List<Rve_Exam_Notification__c>();
            List<User> lUsers = [SELECT Id, Contact.Id FROM User WHERE Id = :UserInfo.getUserId() AND ContactId != NULL];

            if (!lUsers.isEmpty()) {
                Contact currentStudent = [SELECT Id, Name, Program_Batch__c, Active_Semester__c 
                                          FROM Contact 
                                          WHERE Id = :lUsers[0].ContactId LIMIT 1];
				system.debug('current student'+currentStudent);

                Id recordTypeId = Schema.SObjectType.Rve_Exam_Notification__c
                                  .getRecordTypeInfosByDeveloperName()
                                  .get(recType == 'hed_Semester_Notification' ? 'hed_Semester_Notification' : 'hed_IA_Notification')
                                  .getRecordTypeId();
               				 system.debug('the recordtype is ##'+recordTypeId);
                
                if (recType == 'hed_Semester_Notification') {
                    examNotifications = [SELECT Id, Name, Rve_Publish__c, Rve_Semester__c, rve_Exam_Start_Date__c, hed_IA_Type__c, RecordType.DeveloperName 
                                         FROM Rve_Exam_Notification__c 
                                         WHERE Rve_Publish__c = true 
                                         AND Rve_Semester__c = :currentStudent.Active_Semester__c];
                } else If (recType == 'hed_IA_Notification') {
                    examNotifications = [SELECT Id, Name, Rve_Publish__c, Rve_Semester__c, rve_Exam_Start_Date__c, hed_IA_Type__c, RecordType.DeveloperName 
                                         FROM Rve_Exam_Notification__c 
                                         WHERE Rve_Publish__c = true 
                                         AND hed_Program_Batch__c = :currentStudent.Program_Batch__c];
                    system.debug('examnotifications upon data'+examNotifications);
                }           
            
            }

            return examNotifications.isEmpty() ? null : examNotifications[0];

        } catch (Exception e) {
            System.debug('Line: ' + e.getLineNumber() + ' Exception: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    
     // Method to check if hall ticket download is enabled based on custom label
    @AuraEnabled
    public static Boolean isHallTicketDownloadEnabled() {
        try {
            List<User> lUsers = [SELECT Id, Contact.Id FROM User WHERE Id = :UserInfo.getUserId() AND ContactId != NULL];

            if (!lUsers.isEmpty()) {
                Contact currentStudent = [SELECT Id, Program_Batch__c FROM Contact WHERE Id = :lUsers[0].ContactId LIMIT 1];
                system.debug('currentStudent: ' + currentStudent);

                List<Rve_Exam_Notification__c> examNotifications = [SELECT rve_Exam_Start_Date__c 
                                                                    FROM Rve_Exam_Notification__c 
                                                                    WHERE Rve_Publish__c = true 
                                                                    AND hed_Program_Batch__c = :currentStudent.Program_Batch__c LIMIT 1];
                system.debug('Exam notifications based on student data: ' + examNotifications);

                if (!examNotifications.isEmpty()) {
                    Date examStartDate = examNotifications[0].rve_Exam_Start_Date__c;
                    Date hallTicketDownloadStartTime = examStartDate.addDays(-2); 
                   // Date hallTicketDownloadStartTime = examStartDate.addDays(-Integer.valueOf(Label.Hall_tickets_IAScheduleTime));
                    system.debug('Hall ticket download start time: ' + hallTicketDownloadStartTime);
                    system.debug('Exam start date: ' + examStartDate);
                    // If current date is after or on hall ticket download start time, enable the download button
                    if (Date.today() >= hallTicketDownloadStartTime) {
                        return true; 
                    } else {
                        return false; 
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception in isHallTicketDownloadEnabled: ' + e.getMessage() + ' at line number: ' + e.getLineNumber());
            return false; 
        }
        return false;
    }    
}