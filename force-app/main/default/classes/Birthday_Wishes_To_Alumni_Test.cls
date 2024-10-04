@isTest
public class Birthday_Wishes_To_Alumni_Test {

    @isTest
    static void testSendBirthdayWishes() {
        // Create test data
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com',
            Birthdate = Date.today()
        );
        insert testContact;

        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Alumni' LIMIT 1];

        // Assign Alumni record type to the test contact
        testContact.RecordTypeId = rt.Id;
        update testContact;

        Test.startTest();
        // Call the method to send birthday wishes
        Birthday_Wishes_To_Alumni.sendBirthdayWishes();
        Test.stopTest();

        // Verify that an email was sent
        List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>());
        //System.assertEquals(1, sendEmailResults.size(), 'One email should be sent');

        // Verify the email content
        List<EmailMessage> sentEmails = [SELECT Subject, TextBody, ToAddress FROM EmailMessage];
        System.assertEquals(1, sentEmails.size(), 'One email should be captured by EmailMessage object');

        EmailMessage sentEmail = sentEmails[0];
        System.assertEquals('Happy Birthday!', sentEmail.Subject, 'Subject should be "Happy Birthday!"');
        System.assertEquals('test@example.com', sentEmail.ToAddress, 'Email should be sent to the correct address');
        System.assertEquals('REVA UNIVERSITY\nBengaluru, India\n\nDear REVAite,\n\nREVA University and the REVA University Alumni Association extend warm wishes to you on your special day! Happy Birthday!\nMay this year bring you joy, success, and countless memorable moments. Wishing you a fantastic day filled with love and happiness.\n\nBest Wishes,\nTeam REVA University Alumni Association\nwww.reva.edu.in', sentEmail.TextBody, 'Email body should match expected content');
    }
}