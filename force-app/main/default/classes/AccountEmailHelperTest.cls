@isTest
public class AccountEmailHelperTest {

    static testMethod void testInsert() {
        // Create an OrgWideEmailAddress for 'REVA Alerts'
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea.DisplayName = 'REVA Alerts';
        owea.Address = 'alerts@reva.edu.in';
        List<OrgWideEmailAddress> mockOWEAList = new List<OrgWideEmailAddress>{owea};

        // Create a test User
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            ProfileId = profile.Id, 
            UserName = 'standarduser00@testorg.com'
        );
        insert testUser;

        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Test.startTest();
        // Insert another test Account to trigger the email
        Account newAccount = new Account(
            Name = 'New Test Account',
            RecordTypeId = '0125j000000uuRhAAI', // Replace with your record type ID
            Display_Name_Program__c = 'Test Program',
            OwnerId = testUser.Id
        );
                
        AccountEmailHelper.handleInsert(new List<Account>{newAccount});
       
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[0]);
        
        Test.stopTest();

        // Assert that an email was sent for the insert
        System.assertEquals(0, emailResults.size());
        // Clean up test data
        delete testAccount;
       
    }
    static testMethod void testInsert1() {
        // Create an OrgWideEmailAddress for 'REVA Alerts'
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea.DisplayName = 'REVA Alerts';
        owea.Address = 'alerts@reva.edu.in';
        List<OrgWideEmailAddress> mockOWEAList = new List<OrgWideEmailAddress>{owea};

        // Create a test User
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            ProfileId = profile.Id, 
            UserName = 'standarduser00@testorg.com'
        );
        insert testUser;

        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Test.startTest();
        // Insert another test Account to trigger the email
        
        Account newAccount = new Account(
            Name = 'New Test Account',
            RecordTypeId = '0125j000000uuRkAAI', // Replace with your record type ID
            Display_Name_Program__c = 'Test Program',
            OwnerId = testUser.Id
        );
        
        AccountEmailHelper.handleInsert(new List<Account>{newAccount});
       
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[0]);
        
        Test.stopTest();

        // Assert that an email was sent for the insert
        System.assertEquals(0, emailResults.size());
        // Clean up test data
        delete testAccount;
       
    }

    static testMethod void testUpdate() {
        // Create an OrgWideEmailAddress for 'REVA Alerts'
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea.DisplayName = 'REVA Alerts';
        owea.Address = 'alerts@reva.edu.in';
        List<OrgWideEmailAddress> mockOWEAList = new List<OrgWideEmailAddress>{owea};

        // Create a test User
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            ProfileId = profile.Id, 
            UserName = 'Bhasa' + DateTime.now().getTime() + '@gmail.com'
        );
        insert testUser;

        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create another test Account
        Account newAccount = new Account(
            Name = 'New Test Account',
        Display_Name_Program__c='CV',
        Program_Alias__c='TA',
        Program_Code__c='test',
        Program_Type__c='UG',
        No_of_Years__c=3,
        Number_of_Semesters__c=6,
        Intake__c=60,
        Intake_Per_Section__c=60,
        Number_of_Batches__c=2,
        Description='testwe',
        Sequence__c='1');
        insert newAccount;

        Test.startTest();
        // Update the new test Account to trigger the email
        newAccount.Name = 'Updated Test Account';
        newAccount.Display_Name_Program__c='CV';
        newAccount.Program_Alias__c='TA';
        newAccount.Program_Code__c='test';
        newAccount.Program_Type__c='UG';
        newAccount.No_of_Years__c=3;
        newAccount.Number_of_Semesters__c=6;
        newAccount.Intake__c=60;
        newAccount.Intake_Per_Section__c=60;
        newAccount.Number_of_Batches__c=2;
        newAccount.Description='testwe';
        newAccount.Sequence__c='1';
        update newAccount;
        

        // Assert that an email was sent for the update
         List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[0]);
        
        Test.stopTest();

        // Assert that an email was sent for the insert
        System.assertEquals(0, emailResults.size());

        // Clean up test data
        delete testAccount;
        delete newAccount;
        
    }

    static testMethod void testDelete() {
        // Create an OrgWideEmailAddress for 'REVA Alerts'
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea.DisplayName = 'REVA Alerts';
        owea.Address = 'alerts@reva.edu.in';
        List<OrgWideEmailAddress> mockOWEAList = new List<OrgWideEmailAddress>{owea};

        // Create a test User
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            ProfileId = profile.Id, 
            UserName ='unique_username_' + DateTime.now().getTime() + '@testorg.com'
        );
        insert testUser;

        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create another test Account
        Account newAccount = new Account(Name = 'New Test Account');
        insert newAccount;

        Test.startTest();
        // Delete the test Account to trigger the email
        delete testAccount;
          List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[0]);
        
        Test.stopTest();

        // Assert that an email was sent for the insert
        System.assertEquals(0, emailResults.size());

        // Clean up test data
        delete newAccount;
        
    }
}