global class Fee_ReminderToMentors_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        
        return Database.getQueryLocator([
            SELECT Id, Name, Record_Type_Name__c, hed__WorkEmail__c, Account_Name__c,
            (SELECT Id, Record_Type_Name__c, ContactId FROM Cases)
            FROM Contact 
            WHERE RecordTypeId = :contactRecTypeId AND Account_Name__c != 'REVA Academy for Corporate Excellence'
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> lstCon) {
        try {
            for (Contact professor : lstCon) {
                System.debug('Processing professor: ' + professor.Name);
                
                List<Case> relatedCases = [
                    SELECT Id, ContactId
                    FROM Case
                    WHERE ContactId = :professor.Id
                ];
                
                if (!relatedCases.isEmpty()) {
                    Case professorCase = relatedCases[0];
                    
                    List<CaseTeamMember> caseTeamMembers = [
                        SELECT Id, MemberId, Member.Name, ParentId
                        FROM CaseTeamMember
                        WHERE ParentId = :professorCase.Id
                    ];
                    
                    if (!caseTeamMembers.isEmpty()) {
                        Set<Id> memberIds = new Set<Id>();
                        for (CaseTeamMember ctm : caseTeamMembers) {
                            memberIds.add(ctm.MemberId);
                        }
                        
                        List<Student_Fee__c> fees = [
                            SELECT Id, Name, Due_Date__c, Amount_Pending__c, SRN_Number__c
                            FROM Student_Fee__c
                            WHERE Due_Date__c <=TODAY  AND Amount_Pending__c > 0 AND Contact__c IN :memberIds
                        ];
                        System.debug('Fees: ' + fees);
                        
                        if (!fees.isEmpty()) {
                            Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
                            List<Contact> contactstudentfee = [
                                SELECT Id, Name, SRN_Number__c, hed__WorkEmail__c, Mentor__c, Application_Number__c,
                                (SELECT Id, Name, Due_Date__c, Amount_Pending__c, SRN_Number__c
                                 FROM Student_Fees__r WHERE  Due_Date__c <=TODAY AND Amount_Pending__c > 0 AND Contact__c IN :memberIds)
                                FROM Contact WHERE Student_Status__c = 'Pursuing' AND Id IN :memberIds AND RecordTypeId = :contactRecTypeId
                            ];
                            
                            System.debug('ContactStudentFee: ' + contactstudentfee);
                            
                            List<string> lst_ToEmail = new List<string>();
                            List<Messaging.SingleEmailMessage> lst_Email = new List<Messaging.SingleEmailMessage>();
                            
                            if (professor.hed__WorkEmail__c != null && professor.hed__WorkEmail__c.contains('@')) {
                                lst_ToEmail.add(professor.hed__WorkEmail__c);
                            }
                            
                            List<OrgWideEmailAddress> oweaList = [
                                SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts' LIMIT 1
                            ];
                            
                            if (!oweaList.isEmpty()) {
                                OrgWideEmailAddress owea = oweaList[0];
                                
                                String emailBody = '<p>Dear Mr/ Ms. Mentor ' + professor.Name + ',</p>' +
                                    '<p>This is a reminder about the upcoming Fee Payment deadlines for your mentees.</p>' +
                                    '<table border="1" cellpadding="0" cellspacing="0" width="800px">' +
                                    '<tr>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>SRN Number</b></td>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>Application Number</b></td>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>Student Name</b></td>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>Total Pending Amount</b></td>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>Due Date</b></td>' +
                                    '</tr>';
                                
                                for (Contact mentor : contactstudentfee) {
                                    Decimal totalPendingAmount = 0;
                                    String strDateOfconf = '';
                                    String srnnumber = '';
                                    Date earliestDueDate = null;
                                    
                                    if (mentor.SRN_Number__c != null) {
                                        srnnumber = mentor.SRN_Number__c;
                                    }
                                    
                                    if (!mentor.Student_Fees__r.isEmpty()) {
                                        // Find the earliest due date
                                        
                                        for (Student_Fee__c studentFee : mentor.Student_Fees__r) {
                                            if (earliestDueDate == null || studentFee.Due_Date__c < earliestDueDate) {
                                                earliestDueDate = studentFee.Due_Date__c;
                                            }
                                            totalPendingAmount += studentFee.Amount_Pending__c;
                                        }
                                        
                                        // Format the earliest due date
                                        strDateOfconf = earliestDueDate != null ? DateTime.newInstance(earliestDueDate.year(), earliestDueDate.month(), earliestDueDate.day()).format('dd/MM/yyyy') : '';
                                        System.debug('Earliest Due Date: ' + strDateOfconf);
                                    }                            
                                    if (totalPendingAmount > 0) {
                                        emailBody += '<tr>' +
                                            '<td style="padding: 5px;text-align: center;">' + srnnumber + '</td>' +
                                            '<td style="padding: 5px;text-align: center;">' + mentor.Application_Number__c + '</td>' +
                                            '<td style="padding: 5px;text-align: center;">' + mentor.Name + '</td>' +
                                            '<td style="padding: 5px; text-align: center;">' + totalPendingAmount + '</td>' +
                                            '<td style="padding: 5px;text-align: center;">' + strDateOfconf + '</td>' +
                                            '</tr>';
                                    }
                                }
                                
                                emailBody += '</table>' +
                                    '<p>Please ensure your mentees are aware of the upcoming deadlines and take the necessary steps for fee payment.</p>' +
                                    '<p>Thank you for your attention to this matter.</p>' +
                                    '<p><b>Note:</b> In case the mentee has paid the fee and is not updated in the Student Portal, please ask the mentee to reach out to the Accounts Department, 1st Floor, Admin Block.</p>' +
                                    '<p>The mentee will not be allowed to write IA if the outstanding is not cleared.</p>' +
                                    '<p>Sincerely,<br>Office of Finance and Accounts,<br>REVA University</p>';
                                
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.setToAddresses(lst_ToEmail);
                                email.setSubject('Fee Payment Reminder For Your Mentees');
                                email.setHtmlBody(emailBody);
                                
                                // Set the OrgWideEmailAddress
                                email.setOrgWideEmailAddressId(owea.Id);
                                
                                lst_Email.add(email);
                            }
                            
                            // Send emails
                            Messaging.sendEmail(lst_Email);
                        }
                    }
                }
            }
        } catch (Exception e) {
            // Log the exception or take appropriate action
            System.debug('Error in execute method: ' + e.getMessage());
            System.debug('Error in execute getcause method: ' + e.getCause());
            System.debug('Error in execute getLineNumber method: ' + e.getLineNumber());
            System.debug('Error in execute getStackTraceString method: ' + e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Implement the finish logic if needed
    }
}