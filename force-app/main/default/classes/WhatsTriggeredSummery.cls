public with sharing class WhatsTriggeredSummery {
    // public WhatsTriggeredSummery() {

    // }

     
        
    // System.debug('Batch1 Record Count:'+[SELECT Id, Name,Mobilephone, CreatedDate,Primary_Academic_Program__r.Name FROM Contact
    //                                           WHERE WhatsApp_Personal_Group__c = 'P' AND Application_Fee_Paid__c = False AND Primary_Academic_Program__c != null AND Record_Type_Name__c = 'Applicant'
    //                                           AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_MONTH(CreatedDate) = 12
    //                                           AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].size());


        @AuraEnabled(cacheable=true)
        public static List<Integer> getWhatsAppTriggerCount(){
            Integer currentYear = Date.today().year();
            String batchYearPrefix = String.valueOf(currentYear);

            List<Integer> batchData = new List<Integer>();
            try {
                Integer batch1Count = [SELECT Id, Name,Mobilephone, CreatedDate,Primary_Academic_Program__r.Name FROM Contact
                WHERE Application_Fee_Paid__c = False AND Primary_Academic_Program__c != null AND Record_Type_Name__c = 'Applicant'
                AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_MONTH(CreatedDate) = 12
                AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].size();

                batchData.add(batch1Count);

                // Integer currentYear = Date.today().year();
                // String batchYearPrefix = String.valueOf(currentYear); 

                Integer batch2Count = [select id, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c from hed__Application__c 
                WHERE hed__Applicant__r.Application_Fee_Paid__c = true and hed__Applicant__r.Admission_Mode__c != null and hed__Applicant__r.Program_Batch__c !=null and hed__Applicant__r.Record_Type_Name__c='Applicant'  and hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+batchYearPrefix+ '%' and hed__Application_Status__c='Started'
                AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_MONTH(CreatedDate) = 12 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].Size();
                 
                batchData.add(batch2Count);

                // Integer currentYear = Date.today().year();
                // String batchYearPrefix = String.valueOf(currentYear); 
                Integer batch3Count = [select id, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c from hed__Application__c 
                                           where hed__Applicant__r.Application_Fee_Paid__c = true and hed__Applicant__r.Admission_Mode__c != null and hed__Applicant__r.Program_Batch__c !=null and hed__Applicant__r.Record_Type_Name__c='Applicant' and hed__Application_Status__c='Incomplete'
                                          AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_MONTH(CreatedDate) = 12 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].size();
           
                
                batchData.add(batch3Count);
                
                return batchData;

            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            }
        }
        
        @AuraEnabled(cacheable=true)
        public static List<AsyncApexJob> getWhatsAppTriggerDate(){
            List<AsyncApexJob> batchCompletedDate = new List<AsyncApexJob>();
            try{
                // This Query returns the completed date of WhatsAppFollowUpBatch1 batch
                AsyncApexJob feeNotPaidBatchDate = [SELECT Id, ApexClass.Name, CompletedDate, Status 
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex' and ApexClass.Name = 'WhatsAppFollowUpBatch1'
                AND Status = 'Completed'
                ORDER BY CompletedDate DESC
                LIMIT 1];
                batchCompletedDate.add(feeNotPaidBatchDate);

                // This Query returns the completed date of WhatsAppFollowUpBatch2 batch
                // AsyncApexJob feePaidStatusStartedDate = [SELECT CompletedDate
                // FROM AsyncApexJob
                // WHERE JobType = 'BatchApex' and ApexClass.Name = 'WhatsAppFollowUpBatch2'
                // AND Status = 'Completed'
                // ORDER BY CompletedDate DESC
                // LIMIT 1];
                // batchCompletedDate.add(feePaidStatusStartedDate);

                // This Query returns the completed date of WhatsAppFollowUpBatch3 batch
                // AsyncApexJob feeNotPaidStatusIncompleteDate = [SELECT CompletedDate
                // FROM AsyncApexJob
                // WHERE JobType = 'BatchApex' and ApexClass.Name = 'WhatsAppFollowUpBatch3'
                // AND Status = 'Completed'
                // ORDER BY CompletedDate DESC
                // LIMIT 1];
                // batchCompletedDate.add(feeNotPaidStatusIncompleteDate);

                return batchCompletedDate;
            }catch (Exception e) {   
                System.debug('Exception occured while executing AsyncApexJob : '+e.getMessage());             
                 throw new AuraHandledException(e.getMessage());
            }
        }
}