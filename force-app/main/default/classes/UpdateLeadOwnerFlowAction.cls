public class UpdateLeadOwnerFlowAction {
    @InvocableMethod(label='Update Lead Owner' description='Batch lead owner update')
    public static void updateLeadOwner(List<BulkLeadUpdateCounselor.UpdateOwnerInput> input) {
        List<Id> recordIds = input[0].recordIds;
        Id newOwnerId = input[0].newOwnerId;
        
        
        BulkLeadUpdateCounselor batch = new BulkLeadUpdateCounselor(recordIds, newOwnerId);
        Database.executeBatch(batch);
    }
}