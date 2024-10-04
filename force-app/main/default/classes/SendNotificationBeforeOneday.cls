public class SendNotificationBeforeOneday implements Database.Batchable<sObject>, Database.Stateful {
/*
SendNotificationBeforeOnedaySCH sch = new SendNotificationBeforeOnedaySCH();
System.schedule('Hostel Leave Request Batch Schedule - I', '0 00 * * * ? ' , sch);
System.schedule('Hostel Leave Request Batch Schedule - II', '0 15 * * * ? ' , sch);
System.schedule('Hostel Leave Request Batch Schedule - III', '0 30 * * * ? ' , sch);
System.schedule('Hostel Leave Request Batch Schedule - IV', '0 45 * * * ? ' , sch);
*/
    public Database.QueryLocator Start(Database.BatchableContext bc) {
        Date tomorrowDate = Date.today().addDays(1);  
        system.debug('tomorrowDate::'+tomorrowDate);
        system.debug('RecordId::'+[SELECT Id,End_Date__c,status__C, End_Date_and_Time__c,Contact__c FROM REVA_Hostel_Leave_Request__c WHERE End_Date__c = :tomorrowDate]);
        // Query leave requests ending tomorrow
        String query = 'SELECT Id,End_Date__c,Status__c, End_Date_and_Time__c,Contact__c ,Contact__r.Email FROM REVA_Hostel_Leave_Request__c WHERE End_Date__c = :tomorrowDate and Status__c =\'Approved\' ';
        
        return Database.getQueryLocator(query);
    }
   
    public void Execute(Database.BatchableContext BC, List<REVA_Hostel_Leave_Request__c> scope) {
         DateTime now = DateTime.now();
         Id templateId = '00X1e000000SeQeEAK';
         List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
         for (REVA_Hostel_Leave_Request__c record : scope) {
             system.debug('now.hour()::'+now.hour());
              system.debug('now.minute()::'+now.minute());
         if (record.End_Date_and_Time__c != null && record.End_Date_and_Time__c.hour() == now.hour() && record.End_Date_and_Time__c.minute() == now.minute()) {
              system.debug('Hello');
             // Create an email
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setTargetObjectId(record.Contact__c);
             mail.setWhatId(record.Id); 
             mail.setTemplateId(templateId);
             mail.setSaveAsActivity(false); //
             // mail.setSubject('Hostel Leave Request Reminder');
             //mail.setPlainTextBody('This is a reminder that your hostel leave request is ending soon.');
             emails.add(mail);
            }
         }
        
        // Send all emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public void Finish(Database.BatchableContext leadContext) {
        
        
    }
}