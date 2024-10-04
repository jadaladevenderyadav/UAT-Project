@IsTest
public class UpdateTotalAmountInPenaltyFeeBatchTest {

    static testMethod void testBatchExecution() {
         string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for(Integer i = 0; i < 5; i++) {
            fees.add(new Student_Fee__c(
                Name = 'Hostel Late Fee Payment',
                Fee_Type__c = 'Hostel Fee',
                contact__c=objCon.id,
                Number_of_Installments__c = 1,
                Paid_Installments__c = 0,
                Amount_Pending__c = 3000,
                Amount__c =3000
            ));
        }
        insert fees;

        // Start the batch job
        Test.startTest();
        UpdateTotalAmountInPenaltyFeeBatch batchJob = new UpdateTotalAmountInPenaltyFeeBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();
}
    
     @isTest
    static void testSchedulerExecution() {
        // Instantiate the scheduler class
        UpdateTotalAmountInPenaltyFeeScheduler scheduler = new UpdateTotalAmountInPenaltyFeeScheduler();
        
        Test.startTest();
        // Call the execute method to simulate the scheduler
        scheduler.execute(null);
        Test.stopTest();

        
    }
}