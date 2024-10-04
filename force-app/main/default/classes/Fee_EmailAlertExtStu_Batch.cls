global class Fee_EmailAlertExtStu_Batch implements Database.Batchable<sObject> {

    global database.QueryLocator start(Database.BatchableContext bc) {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        System.debug('Start method executed');
        
        return DataBase.getQueryLocator([
            Select id, Name, Active__c, SRN_Number__c, School_Name__c, Program_Type__c, Quota__c, Program_Batch__c, 
                   ReportsToid, Personal_Email__c, Father_Email_ID__c, Mother_Email_ID__c, Email, Program_Batch_Name__c, 
                   Program_Batch__r.hed__Start_Date__c, hed__WorkEmail__c, school__c
            FROM Contact 
            WHERE Student_Status__c = 'Pursuing' 
              AND School_Name__c != 'REVA Academy for Corporate Excellence' 
              AND Program_Type__c != 'Ph.D' 
              AND RecordTypeId = :ContactRecTypeId
        ]);
    }

    global void execute(Database.BatchableContext Bc, List<Contact> lstCon) {           
        for(Contact con : lstCon) {
            List<String> lst_ToEmail = new List<String>();
            List<Messaging.SingleEmailMessage> lst_Email = new List<Messaging.SingleEmailMessage>();
            String programBatchName = con.Program_Batch_Name__c;

            String imageUrl = 'https://reva-university.my.salesforce.com/servlet/servlet.ImageServer?id=015J4000001H82O&oid=00D5j000008ej8d&lastMod=1718889650000';

            // Email body with image
            String textBody = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' +
                '<html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head>' +
                '<body>' +
                '<img src="' + imageUrl + '" alt="REVA University" style="width: 100%; max-width: 800px; height: auto; display: block; margin: 0 auto;">' +
                '</body></html>';

            if(con.hed__WorkEmail__c != null) lst_ToEmail.add(con.hed__WorkEmail__c);

            OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            if(lst_ToEmail.size() > 0) email.setToAddresses(lst_ToEmail);                    

            email.setSubject('Manodhaara is now live on our Student Portal'); 
            email.setHtmlBody(textBody);

            // Query the document for attachment
            List<ContentVersion> contentVersions = [SELECT Title, Id, PathOnClient, FileType, VersionData 
                                                    FROM ContentVersion 
                                                    WHERE Title = 'Manodhaara - Student User Manual 200624'
                                                    LIMIT 1];

            if (contentVersions.size() > 0) {
                ContentVersion contentVersion = contentVersions[0];
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(contentVersion.Title + '.' + contentVersion.FileType);
                attachment.setBody(contentVersion.VersionData);
                attachment.setContentType('application/pdf');
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            }

            lst_Email.add(email);
            if(lst_Email.size() > 0 && lst_ToEmail.size() > 0) {
                Messaging.sendEmail(lst_Email);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        //BatchClass_Utility.sendBatchClassFailureMail('Fee Module', bc.getJobId(), 'Fee Due Date', 'Student Fees');
    }
}