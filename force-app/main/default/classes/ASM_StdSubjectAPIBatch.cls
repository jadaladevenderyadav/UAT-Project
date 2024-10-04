global class ASM_StdSubjectAPIBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global Date filterDate;
    global Set<String> set_SemRecordTypes = new Set<String>();
    global ASM_StdSubjectAPIBatch(Date fDate){
        filterDate = fDate;
    }
	global Database.QueryLocator start(Database.BatchableContext BC){
        set_SemRecordTypes.add('Sections');
        set_SemRecordTypes.add('Batches');
        set_SemRecordTypes.add('Group_Allocation');
        return database.getQueryLocator([SELECT Id,Name FROM hed__Term__c WHERE RecordType.DeveloperName IN: set_SemRecordTypes 
                                         AND (hed__Parent_Term__r.IA_1_Start_date__c =: filterDate OR hed__Parent_Term__r.hed__Parent_Term__r.IA_1_Start_date__c =: filterDate)]);
    }
    global void execute(Database.BatchableContext BC, List<hed__Term__c> scope){
        Set<Id> set_CConIds = new Set<Id>();
        for(hed__Course_Enrollment__c con : [SELECT Id FROM hed__Course_Enrollment__c WHERE Section__c =: scope[0].Id AND Logisys_Integration__c != 'Yes' AND RecordType.DeveloperName = 'Student']){
            set_CConIds.add(con.Id);
        }
        if(!set_CConIds.isEmpty()){
            Debug_Log__c dLog = ASM_StdSubjectAPI.sendStdSubject(set_CConIds,'I');
            Insert dLog;
        }
    }
    global void finish(Database.BatchableContext BC){       
    }
}