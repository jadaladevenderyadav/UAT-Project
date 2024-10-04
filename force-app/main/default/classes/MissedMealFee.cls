public class MissedMealFee implements Database.Batchable<sObject>, Database.Stateful {
   
    public Database.QueryLocator Start(Database.BatchableContext bc) {
        Date tomorrowDate = Date.today().addDays(1);  
        system.debug('tomorrowDate::'+tomorrowDate);
        system.debug('RecordId::'+[SELECT Id,End_Date__c,status__C, End_Date_and_Time__c,Contact__c FROM REVA_Hostel_Leave_Request__c WHERE End_Date__c = :tomorrowDate]);
        // Query leave requests ending tomorrow
        String query = 'SELECT Id,End_Date__c,Status__c, End_Date_and_Time__c,Contact__c ,Contact__r.Email FROM REVA_Hostel_Leave_Request__c WHERE End_Date__c = :tomorrowDate and Status__c =\'Approved\' ';
        
        return Database.getQueryLocator(query);
    }
   
    public void Execute(Database.BatchableContext BC, List<REVA_Hostel_Leave_Request__c> scope) {
        
    }
    
    public void Finish(Database.BatchableContext leadContext) {
        
        
    }
}