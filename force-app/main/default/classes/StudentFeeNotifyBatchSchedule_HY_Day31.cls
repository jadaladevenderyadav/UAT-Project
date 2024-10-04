global class StudentFeeNotifyBatchSchedule_HY_Day31 implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    
    global Date currentDate, dt;
    global String CronExp, CronExp1, CronExp2, CronExp3, CronExp4, CronExp5, CronExp6, CronExp7,
        CronExp8, CronExp9, CronExp10, CronExp11, CronExp12, CronExp13, CronExp14, CronExp15, CronExp16, CronExp17,
        jobName, jobName1, jobName2, jobName3, jobName4, jobName5, jobName6, jobName7, jobName8, jobName9, jobName10,
        jobName11, jobName12, jobName13, jobName14, jobName15, jobName16, jobName17;
    
    global List<String> contIdList = new List<String>();
    global Set<String> semProgramBatch = new Set<String>();    
    global List<String> contactRecordIds { get; set; }
    
    global StudentFeeNotifyBatchSchedule_HY_Day31(){}
    
    global StudentFeeNotifyBatchSchedule_HY_Day31(List<String> contactIds){
        this.contactRecordIds = contactIds;
    }
    
    String studentRecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Student').getRecordTypeId();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, hed__Start_Date__c, Program_Batch__c,'
                                       +' Term_Number__c, Days_Remaining_To_Start__c'
                                       +' FROM hed__term__c '
                                       +' WHERE hed__Start_Date__c != null'
                                       +' AND hed__Start_Date__c = THIS_YEAR'
                                       +' AND (Term_Number__c = 3 OR Term_Number__c = 5 OR Term_Number__c = 7)';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<hed__term__c> semesters) {
        
        System.debug('execute method ' + semesters);
        for(hed__term__c sem : semesters){
            semProgramBatch.add(sem.Program_Batch__c);
        }
        String contactQuery = 'SELECT Id, Name, Program_Batch__c'
            +' FROM Contact'
            +' WHERE Program_Batch__c != null AND Program_Batch__c IN : semProgramBatch'
            +' AND RecordTypeId =: studentRecordTypeID AND Active__c = true'
            +' AND Student_Status__c = \'Pursuing\'';
        
        List<Contact> contactList = Database.query(contactQuery);
        System.debug('contactList=> ' + contactList);
        System.debug('contactList SIZE=> ' + contactList.size());
        
        for(Contact cSem : contactList){
            currentDate = Date.Today();
            for(hed__term__c sem : semesters){
                contIdList.add(cSem.Id);
                
                if(sem.hed__Start_Date__c == currentDate){
                    CronExp = '0 40 19 ' + currentDate.day() + ' ' + currentDate.month() + ' ? ' + currentDate.year();
                    jobName = 'First Fee Reminder For Higher Years'+ ' # ' + system.now();
                }
                
                //if(!Test.isRunningTest()){
                    if(math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) <= 30 && 
                       currentDate > sem.hed__Start_Date__c ){
                           dt = sem.hed__Start_Date__c.adddays(8);
                           CronExp1 = '0 30 9 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName1 = 'Fee Reminder for Day-8 1-30_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(15);
                           CronExp2 = '0 35 9  ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName2 = 'Fee Reminder for Day-15 1-30_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(22);
                           CronExp3 = '0 40 9 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName3 = 'Fee Reminder for Day-22 1-30_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(29);
                           CronExp4 = '0 45 9 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName4 = 'Fee Reminder for Day-29 1-30_High_Yr'+ ' # ' + system.now();
                       }   
                    
                    if(math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) > 30 &&
                       math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) <= 45){
                           dt = sem.hed__Start_Date__c.adddays(31);
                           CronExp5 = '0 50 9 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName5 = 'Fee Reminder for Day-31 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(34);
                           CronExp6 = '0 55 9  ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
                           jobName6 = 'Fee Reminder for Day-34 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(37);
                           CronExp7 = '0 0 10 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName7 = 'Fee Reminder for Day-37 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(40);
                           CronExp8 = '0 5 10  ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName8 = 'Fee Reminder for Day-40 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(43);
                           CronExp9 = '0 10 10  ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName9 = 'Fee Reminder for Day-43 31-45_High_Yr'+ ' # ' + system.now();
                       }
                    
                    if(math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) > 45 &&
                       math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) <= 60){
                           dt = sem.hed__Start_Date__c.adddays(46);
                           CronExp10 = '0 15 10 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();  
                           jobName10 = 'Fee Reminder for Day-46 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(48);
                           CronExp11 = '0 20 10 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName11 = 'Fee Reminder for Day-48 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(50);
                           CronExp12 = '0 25 10 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName12 = 'Fee Reminder for Day-50 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(52);
                           CronExp13 = '0 30 10 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
                           jobName13 = 'Fee Reminder for Day-52 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(54);
                           CronExp14 = '0 35 10 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName14 = 'Fee Reminder for Day-54 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(56);
                           CronExp15 = '0 40 10 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName15 = 'Fee Reminder for Day-56 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(58);
                           CronExp16 = '0 45 10 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName16 = 'Fee Reminder for Day-58 31-45_High_Yr'+ ' # ' + system.now();
                           
                           dt = sem.hed__Start_Date__c.adddays(60);
                           CronExp17 = '0 50 10 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                           jobName17 = 'Fee Reminder for Day-60 31-45_High_Yr'+ ' # ' + system.now();
                       }
               // }
            }
        }
        
       // if(!Test.isRunningTest()){
            if(CronExp != null)
            System.schedule(jobName, CronExp, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp1 != null)
            System.schedule(jobName1, CronExp1, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp2 != null)
            System.schedule(jobName2, CronExp2, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp3 != null)
            System.schedule(jobName3, CronExp3, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp4 != null)
            System.schedule(jobName4, CronExp4, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp5 != null)
            System.schedule(jobName5, CronExp5, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp6 != null) 
            System.schedule(jobName6, CronExp6, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp7 != null)
            System.schedule(jobName7, CronExp7, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp8 != null)
            System.schedule(jobName8, CronExp8, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp9 != null)
            System.schedule(jobName9, CronExp9, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp10 != null)
            System.schedule(jobName10, CronExp10, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp11 != null)
            System.schedule(jobName11, CronExp11, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp12 != null)
            System.schedule(jobName12, CronExp12, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp13 != null)
            System.schedule(jobName13, CronExp13, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp14 != null)
            System.schedule(jobName14, CronExp14, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp15 != null)
            System.schedule(jobName15, CronExp15, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp16 != null)
            System.schedule(jobName16, CronExp16, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        if(CronExp17 != null)
            System.schedule(jobName17, CronExp17, new StudentFeeNotifyBatchSchedule_HY_Day31(contIdList));
        //}
    }
    
    global void finish(Database.BatchableContext bc) {}  
    
    public void execute(SchedulableContext SC){
        if(!Test.isRunningTest()){
            Database.executeBatch(new StudentFeeNotifyBatchSchedule_HY_Day31());        
            Database.executeBatch(new StudentFeeNotificationBatch(contactRecordIds)); 
        }
    }
}