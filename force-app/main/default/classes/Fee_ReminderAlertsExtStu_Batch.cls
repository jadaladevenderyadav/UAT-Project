global class Fee_ReminderAlertsExtStu_Batch implements Database.Batchable<sObject> 
{
    global database.QueryLocator start(Database.BatchableContext bc)
    {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        date todayDt = system.today();
        integer yr = Integer.Valueof( system.Label.Due_Date_Email_Alert_Year_Filter);
        System.debug('Start method executed');
       
        Integer currentYear = System.Today().year();
        String year ='%(' + currentYear + '%'; 
       system.debug('year==='+year);        
        return DataBase.getQueryLocator([Select id,Name,Active__c,SRN_Number__c,School_Name__c,Program_Type__c,Quota__c,Program_Batch__c,ReportsToid,Personal_Email__c,Father_Email_ID__c,Mother_Email_ID__c,Email,Program_Batch_Name__c,Program_Batch__r.hed__Start_Date__c,hed__WorkEmail__c
                                         FROM Contact where Student_Status__c =: 'Pursuing' and School_Name__c !='REVA Academy for Corporate Excellence' and Program_Type__c != 'Ph.D' AND Program_Batch_Name__c Like '%-2024)%'
                                          and RecordTypeId=:ContactRecTypeId
                                         and id =:'0035j00000PuFlYAAV'
                                         and Program_Batch__r.hed__Start_Date__c != null]);
          
    }
     global void execute(Database.BatchableContext Bc,List<Contact> lstCon)
    {           
        for(Contact con : lstCon)
        {    
            system.debug('contactlist==='+con);
                string strDateOfconf; 
               list<string> lst_ToEmail = new list<string>();
                List<Messaging.SingleEmailMessage> lst_Email = new List<Messaging.SingleEmailMessage>();
                String programBatchName = con.Program_Batch_Name__c;
                //String session = '';
                string TextBody='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head><body>'+
                'Dear '+Con.Name+','+
                '<p>As per our records, you have not yet collected the original certificates submitted at the time of admission.  Please collect your documents by <b>31st July, 2024</b> during office hours.</p>'+
                'For any clarifications, feel free to contact: 9844298109 / 8050741523.'+'<br>'+
                '</p>'+
                'Registrar’s Office'+'<br>'+
                'REVA University'+
                '</body></html>';

                if (con.hed__WorkEmail__c != null && con.hed__WorkEmail__c != '') {
                         lst_ToEmail.add(con.hed__WorkEmail__c);
                   }
                
                OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'REVA Alerts'];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
                if ( owea.size() > 0 ) 
                {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                
                if(lst_ToEmail.size()>0) email.SetToAddresses(lst_ToEmail);                    
                
                
                email.setSubject('Collection of Original documents'); 
                email.setHtmlBody(TextBody);
                lst_Email.add(email);
                if(lst_Email.size()> 0 && lst_ToEmail.size() > 0 )
                {
                    Messaging.sendEmail(lst_Email);
                }
            }
        }
   
    global void finish(DataBase.BatchableContext bc)
    {
        //BatchClass_Utility.sendBatchClassFailureMail('Fee Module', bc.getJobId(), 'Fee Due Date','Student Fees');
    }
}