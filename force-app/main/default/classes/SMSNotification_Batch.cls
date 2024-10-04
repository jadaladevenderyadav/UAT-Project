global class SMSNotification_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        system.debug('RecordType==='+ContactRecTypeId);
        return Database.getQueryLocator([SELECT Id, Name, Active__c, Quota__c, Last_Notification_Date__c, 
                                         ReportsToId, MobilePhone, Father__r.MobilePhone, Mother__r.MobilePhone, 
                                         Program_Batch_Name__c, Program_Batch__r.hed__Start_Date__c, 
                                         Active_Semester__r.hed__Start_Date__c, Active_Semester__r.Term_Number__c
                                         FROM Contact
                                         WHERE Student_Status__c = 'Pursuing'
                                         AND RecordTypeId = :ContactRecTypeId
                                         AND Active_Semester__r.Term_Number__c !=1
                                         AND Program_Type__c != 'Ph.D'
                                         AND School_Name__c NOT IN ('REVA Academy for Corporate Excellence', 'School of Performing Arts and Indic Studies')
                                         AND Program_Batch__r.hed__Start_Date__c != null]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> lstCon) {
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        Date todayDt = System.today();
        Id ConParentTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        Set<Id> set_Reportid = new Set<Id>();
        
        for (Contact con : lstCon) {
            Set<Id> set_BatchIds = new Set<Id>();
            for (hed__Program_Enrollment__c objProgEnroll : [SELECT Id, Active__c, hed__Program_Plan__c, hed__Contact__c 
                                                             FROM hed__Program_Enrollment__c 
                                                             WHERE hed__Contact__c = :con.Id AND Active__c = true]) {
                                                                 set_BatchIds.add(objProgEnroll.hed__Program_Plan__c);
                                                             }
            
            if (!set_BatchIds.isEmpty()) {
                List<hed__Term__c> lst_term = new List<hed__Term__c>();
                for (hed__Term__c objTerm : [SELECT Id, Name, hed__Start_Date__c, Program_Batch__c, Term_Number__c 
                                             FROM hed__Term__c 
                                             WHERE Program_Batch__c IN :set_BatchIds 
                                             AND Term_Number__c IN (3, 5, 7, 9) 
                                             AND hed__Start_Date__c != null]) {
                                                 lst_term.add(objTerm);
                                             }
                
                for (hed__Term__c sem : lst_term) {
                    Date semesterStartDate = sem.hed__Start_Date__c;
                    Date fourWeeksBefore = semesterStartDate.addDays(-28);
                    Date fifteenDaysBefore = semesterStartDate.addDays(-15);
                    Date thirtyDaysAfter = semesterStartDate.addDays(30);
                    Date fortyFiveDaysAfter = semesterStartDate.addDays(45);
                    Date sixtyDaysAfter = semesterStartDate.addDays(60);
                    
                    Boolean sendSMS = false;
                    Boolean sendEmail = false;
                    if (todayDt == fourWeeksBefore || todayDt == fifteenDaysBefore || todayDt == semesterStartDate) {
                        sendSMS = true;
                    } else if (todayDt > semesterStartDate && todayDt <= thirtyDaysAfter && getDayOfWeek(todayDt) == getDayOfWeek(semesterStartDate)) {
                        sendSMS = true;
                    } else if (todayDt > thirtyDaysAfter && todayDt <= fortyFiveDaysAfter && Math.mod(todayDt.daysBetween(thirtyDaysAfter), 3) == 0) {
                        sendSMS = true;
                    } else if (todayDt > fortyFiveDaysAfter && todayDt <= sixtyDaysAfter && Math.mod(todayDt.daysBetween(fortyFiveDaysAfter), 2) == 0) {
                        sendSMS = true;
                    }
                    
                    List<Student_Fee__c> feeList = [SELECT Id, Name, Due_Date__c, Amount__c, Amount_Paid__c, Amount_Pending__c 
                                                    FROM Student_Fee__c 
                                                    WHERE Contact__c = :con.Id 
                                                    AND Amount_Pending__c > 0 
                                                    AND (Due_Date__c <= :semesterStartDate.addDays(30) and Due_Date__c >= :semesterStartDate) 
                                                    AND Fee_Type__c IN ('University Fee','Tuition Fee','Penalty Fee')];
                    
                    if (sendSMS && !feeList.isEmpty()) {
                        set_Reportid.add(con.Id);
                        buildSMSMessages(lstShortMsg, con, feeList);
                    }
                }
            }
        }
        
        System.debug('lstShortMsg size = ' + lstShortMsg.size());
        if (!lstShortMsg.isEmpty()) {
            sendSMS(lstShortMsg);
        }
    }
    private String getDayOfWeek(Date dt) {
        // Convert Date to DateTime to use the format method
        DateTime dtTime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
        return dtTime.format('E'); // Returns day of the week abbreviation (Mon, Tue, etc.)
    }
    private void buildSMSMessages(List<SMS_API_Utility.shortMessageWrp> messages, Contact con, List<Student_Fee__c> feeList) {
        String messageText = 'Dear Student, Your outstanding fees for the current academic year have not been settled. Please make the payment via SLCM to avoid penalties. REVA University';
        
        if (String.isNotBlank(con.MobilePhone)) {
            messages.add(createShortMessage(con.MobilePhone, messageText));
        }
        if (con.Father__r != null && String.isNotBlank(con.Father__r.MobilePhone)) {
            messages.add(createShortMessage(con.Father__r.MobilePhone, messageText));
        }
        if (con.Mother__r != null && String.isNotBlank(con.Mother__r.MobilePhone)) {
            messages.add(createShortMessage(con.Mother__r.MobilePhone, messageText));
        }
    }
    
    private SMS_API_Utility.shortMessageWrp createShortMessage(String mobilePhone, String message) {
        SMS_API_Utility.shortMessageWrp shortMessage = new SMS_API_Utility.shortMessageWrp();
        shortMessage.message = message;
        shortMessage.recipient = '+91' + mobilePhone;
        return shortMessage;
    }
    
    private void sendSMS(List<SMS_API_Utility.shortMessageWrp> messages) {
        HttpRequest request = SMS_API_Utility.SendSMSOneToMany('Penalty SMS', messages);
        
        
    }
    
    global static String getTimeDetails(String timeDetails) {
        String[] outtimesplit = timeDetails.split(':');
        if (Integer.valueOf(outtimesplit[0]) >= 12) {
            Integer outhour = Integer.valueOf(outtimesplit[0]) - 12;
            return String.valueOf(outhour) + ':' + outtimesplit[1];
        } else {
            if (Integer.valueOf(outtimesplit[0]) < 10) {
                return '0' + outtimesplit[0] + ':' + outtimesplit[1];
            } else {
                return outtimesplit[0] + ':' + outtimesplit[1];
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}