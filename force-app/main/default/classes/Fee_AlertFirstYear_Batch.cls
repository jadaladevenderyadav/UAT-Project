global class Fee_AlertFirstYear_Batch implements Database.Batchable<sObject> 
{
    global database.QueryLocator start(Database.BatchableContext bc)
    {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        date todayDt = system.today();
        integer yr = Integer.Valueof( system.Label.Due_Date_Email_Alert_Year_Filter);
        System.debug('Start method executed');
          Integer currentYear = System.Today().year();
        String Startyear ='%('+ currentYear + '%'; 
        String Endyear ='%' + currentYear +')%';
       system.debug('Startyear==='+Startyear); 
        system.debug('Endyear==='+Endyear); 
        
        return DataBase.getQueryLocator([Select id,Name,Active__c,Quota__c,School_Name__c,ReportsToid,Personal_Email__c,Father_Email_ID__c,Mother_Email_ID__c,Email,Program_Batch_Name__c,Program_Batch__r.hed__Start_Date__c,hed__WorkEmail__c,Active_Semester__r.hed__Start_Date__c
                                        
                                         FROM Contact where Student_Status__c =: 'Pursuing' and RecordTypeId=:ContactRecTypeId and Program_Type__c !='Ph.D' and School_Name__c NOT IN ('REVA Academy for Corporate Excellence','School of Performing Arts and Indic Studies') AND 
                                          ((NOT Program_Batch_Name__c LIKE :Startyear) AND (NOT Program_Batch_Name__c LIKE :Endyear)) 
                                          AND id =:'0035j00000RviuzAAB' and
                                         Program_Batch__r.hed__Start_Date__c != null and CALENDAR_YEAR(Program_Batch__r.hed__Start_Date__c) !=: yr]);
    }
    global void execute(Database.BatchableContext Bc,List<Contact> lstCon)
    {           
        for(Contact con : lstCon)
        {    
            
                Id ConParentTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
                string strDateOfconf; 
                set<id> set_Reportid = new set<id>();
                list<string> lst_CCEmail = new list<string>();
                list<string> lst_ToEmail = new list<string>();
                List<Messaging.SingleEmailMessage> lst_Email = new List<Messaging.SingleEmailMessage>();
                String programBatchName = con.Program_Batch_Name__c;
                
                string TextBody='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head><body>'+
                    'Dear '+Con.Name+','+'<br>'+
                    '<p>Please be informed that the Fee Policy of the university has been revised. Attached to this email is the updatd fee policy for your reference.<p>';
                    
                set_Reportid.add(con.id);
                System.debug('111111');
               
               if(con.hed__WorkEmail__c != null) lst_ToEmail.add(con.hed__WorkEmail__c);
                
               
                
                Textbody = Textbody +'<br>'+'Sincerely,'+'<br>'+'Registrar Office,'+'<br>'+'REVA University</p>'+
                    '</body></html>';
                if(set_Reportid.size()>0)
                {     
                    for(Contact objcon : [Select Id,Name,Email,ReportsToid from contact where ReportsToid in:set_Reportid and RecordTypeId=:ConParentTypeId])
                    {
                        if(objcon.Email != null) lst_CCEmail.add(objcon.Email);                
                    }
                }
                OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'REVA Alerts'];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
                if ( owea.size() > 0 ) 
                {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                
                email.setSubject('Revised Fee Policy'); 
                email.setHtmlBody(TextBody);
                
                String pdfContent = '%PDF-1.4\n1 0 obj\n<< /Title (Sample PDF) >>\nendobj\n'; // Sample PDF content
        
        // Convert the string content to Blob
        Blob pdfBlob = Blob.valueOf(pdfContent);
                
		Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        
                contentversion cversion = [SELECT title,ID, PathOnClient, FileType, versiondata FROM contentversion where title ='Notification - Tuition & University Fee payment 2024-2025'];
		blob WOCFbody = cversion.versiondata;
                attachment.setFileName('Notification - Tuition & University Fee payment 2024-2025'+'.'+cversion.FileType); // Set the file name
                System.debug('filetype=='+cversion.FileType+'body=='+cversion.versiondata);
        attachment.setBody(WOCFbody); // Set the file content
        //attachment.setContentType('application/pdf'); // Set the file type
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                
                lst_Email.add(email);
                if(lst_Email.size()> 0 && lst_ToEmail.size() > 0 )
                {
                    email.setToAddresses(lst_ToEmail);
                	email.setCcAddresses(lst_CCEmail);
                    Messaging.sendEmail(lst_Email);
                }
            }
        }
      
    global void finish(DataBase.BatchableContext bc)
    {
        //BatchClass_Utility.sendBatchClassFailureMail('Fee Module', bc.getJobId(), 'Fee Due Date','Student Fees');
    }
}