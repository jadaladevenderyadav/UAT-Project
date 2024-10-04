@isTest
public class rve_IAExamApprovalTest {
    @testSetup
    static void setup() {
        // Create test data
        
        // Create a School (Account)
        Account school = new Account(Name = 'Test School', School_Head__c = UserInfo.getUserId());
        insert school;
        
        // Create a Program Batch
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name = 'Test Batch');
        insert programBatch;
        
        // Create Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'User' + i,
                Active__c = true,
                Checking_Eligibility_for_Exam__c = 'InEligible',
                AccountId = school.Id,
                Program_Batch__c = programBatch.Id,
                SRN_Number__c = 'SRN' + i
            ));
        }
        insert contacts;
    }
    
    @isTest
    static void testGetContacts() {
        // Execute the method to be tested
        Test.startTest();
        Map<String, Object> results = rve_IAExamApproval.getContacts();
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, results);
        //System.assertEquals(5, results.size());
      /*  for (Contact con : results) {
            System.assertEquals('InEligible', con.Checking_Eligibility_for_Exam__c);
            System.assertEquals(true, con.Active__c);
            System.assertEquals(UserInfo.getUserId(), con.Account.School_Head__c);
        }*/
    }
    
    @isTest
    static void testUpdateContacts() {
        // Retrieve contacts to update
        List<Contact> contactsToUpdate = [SELECT Id, SRN_Number__c, Name, Checking_Eligibility_for_Exam__c, Program_Batch__r.Name
                                          FROM Contact WHERE Active__c = true AND Checking_Eligibility_for_Exam__c = 'InEligible'];
        
        // Update field values
        for (Contact con : contactsToUpdate) {
            con.Checking_Eligibility_for_Exam__c = 'Eligible';
        }
        
        // Execute the method to be tested
        Test.startTest();
        rve_IAExamApproval.updateContacts(contactsToUpdate);
        Test.stopTest();
        
        // Verify the updates
        List<Contact> updatedContacts = [SELECT Id, Checking_Eligibility_for_Exam__c
                                         FROM Contact WHERE Id IN :contactsToUpdate];
        for (Contact con : updatedContacts) {
            System.assertEquals('Eligible', con.Checking_Eligibility_for_Exam__c);
        }
    }
}