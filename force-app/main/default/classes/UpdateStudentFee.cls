public with sharing class UpdateStudentFee {
    @InvocableMethod(label='Update Student Fee' description='Batch Student Fee Update')
    public static void updateStuFee(List<BulkStudentFeeUpdate.UpdateStuFeeInput> input) {
        List<Id> recordIds = input[0].recordIds;
        // Id newOwnerId = input[0].newOwnerId;
        
        
        BulkStudentFeeUpdate batch = new BulkStudentFeeUpdate(recordIds);
        Database.executeBatch(batch);
    }
}