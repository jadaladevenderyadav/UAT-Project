public class BulkStudentFeeUpdate implements Database.Batchable<Student_Fee__c> { //, Database.Stateful
    public List<Id> recordIds;
    public List<Student_Fee__c> query =new List<Student_Fee__c>();
    // public Id newOwnerId;
    // List<Lead> leadsToUpdate = new List<Lead>();
    List<Student_Fee__c> stuFeeListUpdate = new List<Student_Fee__c>();

    public BulkStudentFeeUpdate(List<Id> recordIds) {
        this.recordIds = recordIds;
        // this.newOwnerId = newOwnerId;
    }

    public Iterable<Student_Fee__c> start(Database.BatchableContext context) {
        query = [SELECT Id, Name, Actual_Program_Fee__c, Amount_Paid__c, Amount_Pending__c, Calculated_Total_Amount__c, Calculated_Amount_Pending__c, Contact__c FROM Student_Fee__c WHERE Id IN :recordIds];
        return query;
    }

    public void execute(Database.BatchableContext context, List<Student_Fee__c> scope) {
        for (Student_Fee__c stufee : scope) {
            // lead.OwnerId = newOwnerId;
            stufee.Amount_Pending__c = stufee.Calculated_Amount_Pending__c;
            stufee.Amount__c = stufee.Calculated_Total_Amount__c;
            stuFeeListUpdate.add(stufee);
        }
        if(stuFeeListUpdate.size() > 0){
            update stuFeeListUpdate;
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('student fee batch apex has been finished');
    }

    public class UpdateStuFeeInput {
        @InvocableVariable(required=true)
        public List<Id> recordIds;
    }
}