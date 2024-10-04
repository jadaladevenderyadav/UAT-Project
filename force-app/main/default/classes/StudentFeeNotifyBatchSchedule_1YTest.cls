@isTest
public class StudentFeeNotifyBatchSchedule_1YTest {
    
    @testSetup
    static void setupTestData() {
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'B. Tech in Computer Science Engineering',
                                Program_Alias__c = 'BT-CS',
                                Program_Code__c = 'CS',
                                Program_Type__c = 'UG',
                                Intake_Per_Section__c = 60
                               ));
        insert accList;
        
        // Create Active Semester
        hed__Term__c term = new hed__Term__c(Name = 'Spring 2024', 
                                             Term_Number__c = 1, 
                                             hed__Start_Date__c = Date.today().addDays(-10),
                                             hed__Account__c = accList[0].Id);
        insert term;
        
        // Create Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(FirstName = 'Test', LastName = 'User' + i, Active_Semester__c = term.Id));
        }
        insert contacts;
        
        // Custom Label Setup
        // Assuming Label.Active_Semester_First_Year is '1'
    }
    
    public testmethod static void testBatchJob() {
        Test.startTest();
        
        // Schedule the batch
        String cronExp = '0 0 0 * * ?';
        String jobName = 'TestStudentFeeNotifyBatchSchedule_1Y'+Integer.valueof((Math.random() * 10000));
        System.schedule(jobName, cronExp, new StudentFeeNotifyBatchSchedule_1Y());
        
        // Run the batch
        Integer batchSize = 200;
        Database.executeBatch(new StudentFeeNotifyBatchSchedule_1Y(), batchSize);
        // Schedule the job
        System.schedule(jobName, cronExp, new StudentFeeNotifyBatchSchedule_1Y());
        
        
        Test.stopTest();
        
        // Verify scheduled jobs
        List<CronTrigger> scheduledJobs = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                           FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        System.assertEquals(1, scheduledJobs.size());
        
        // Verify batch job executed correctly
        System.assertEquals(5, StudentFeeNotifyBatchSchedule_1Y.contIdList.size());
    }
}