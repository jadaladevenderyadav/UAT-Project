@isTest
public class UpdatePAFPaidDateTest {

    @isTest
    static void testPAFPaidDateUpdate() {
        // Create test records with Provisional_Admission_Fee_Paid__c unchecked
        List<hed__Application__c> testRecords = new List<hed__Application__c>();
        for(Integer i = 0; i < 5; i++) {
            hed__Application__c app = new hed__Application__c(Application_Number__c = 'Test Application ' + i,
                                                              Provisional_Admission_Fee_Paid__c = false);
            testRecords.add(app);
        }
        insert testRecords;

        // Update some records to set Provisional_Admission_Fee_Paid__c to true
        List<hed__Application__c> recordsToUpdate = [SELECT Id, Provisional_Admission_Fee_Paid__c FROM hed__Application__c WHERE Application_Number__c LIKE 'Test Application%'];
        for(hed__Application__c record : recordsToUpdate) {
            record.Provisional_Admission_Fee_Paid__c = true;
        }
        update recordsToUpdate;

        // Verify that PAF_Paid_Date__c is updated for records where Provisional_Admission_Fee_Paid__c is true
        List<hed__Application__c> updatedRecords = [SELECT Id, PAF_Paid_Date__c FROM hed__Application__c WHERE Id IN :recordsToUpdate];
        for(hed__Application__c record : updatedRecords) {
            System.assertEquals(System.today(), record.PAF_Paid_Date__c, 'PAF_Paid_Date__c should be updated with current date');
        }

        // Test scenario where Provisional_Admission_Fee_Paid__c is already true
        hed__Application__c appWithFeePaid = [SELECT Id, Provisional_Admission_Fee_Paid__c FROM hed__Application__c WHERE Provisional_Admission_Fee_Paid__c = true LIMIT 1];
        appWithFeePaid.Provisional_Admission_Fee_Paid__c = true; // No change, already true
        update appWithFeePaid;
        System.assertEquals(null, appWithFeePaid.PAF_Paid_Date__c, 'PAF_Paid_Date__c should not be updated');
    }
}