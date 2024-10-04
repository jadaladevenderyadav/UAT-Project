public class QueueableStudentFeeBalanceUpdate  implements System.Queueable , Database.AllowsCallouts {
    Set<Id> stuFeeSet = new Set<Id>();

    public QueueableStudentFeeBalanceUpdate (Set<Id> stufeeSet){
        stuFeeSet = stufeeSet;
    } 
    
    public void execute(QueueableContext context){
        List<Student_Fee_Payment__c> stuFeePayList = [SELECT Id, Name, Amount__c, Line_Item_Payment_Status__c, Student_Payment__c, Mode_of_Payment__c, SF_Transaction_ID__c, Student_Fee__c, Transaction_Status__c FROM Student_Fee_Payment__c WHERE Student_Fee__c =: stuFeeSet];
        FEE_StudentFeePaymentTriggerHandler.RollupAmount(stuFeePayList,Null);
    }
}