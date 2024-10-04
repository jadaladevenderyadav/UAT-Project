global class UpdateTotalAmountInPenaltyFeeBatch implements Database.Batchable<sObject> {
    
    /*
UpdateTotalAmountInPenaltyFeeScheduler sch = new UpdateTotalAmountInPenaltyFeeScheduler();
System.schedule('Hostel Panality Batch Schedule - I', '0 21 * * * ? ' , sch);
*/
    // Replace 'Student_Fee__c' with your object API name
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query records that you want to update
        String query = 'SELECT Id, Hostel_Late_Fee__c, Amount__c,Amount_Paid__c, Amount_Pending__c FROM Student_Fee__c WHERE Fee_Type__c = \'Hostel Fee\' AND Name = \'Hostel Late Fee Payment\'';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Student_Fee__c> recordsToUpdate = new List<Student_Fee__c>();
        System.debug(scope);
        for (sObject s : scope) {
            Student_Fee__c record = (Student_Fee__c)s;
            System.debug('formula field: '+ record.Hostel_Late_Fee__c);
            // Replace 'Hostel_Late_Fee__c' with your formula field API name
            // Replace 'Amount__c' with the field API name you want to update
            record.Amount__c = record.Hostel_Late_Fee__c;
            record.Amount_Pending__c = record.Hostel_Late_Fee__c  - record.Amount_Paid__c;
            System.debug('amount field: '+ record.Amount__c);
             record.Number_of_Installments__c = 1;
            record.Paid_Installments__c = 0;
            recordsToUpdate.add(record);
        }
        
        // Update the records
        update recordsToUpdate;
    }

    global void finish(Database.BatchableContext BC) {
        // Execute any post-processing logic here
    }
}