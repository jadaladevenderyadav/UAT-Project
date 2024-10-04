@isTest
public class RHStudentFeePaymentReceipt {
    
  /*  private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }  
    */
     @isTest
    static void testGenerateReceiptPDFAsync() {
        Contact father = new Contact(
            LastName = 'Test Father',
            Email = 'father@example.com'
        );
        insert father;

        // Create a Contact record for the mother
        Contact mother = new Contact(
            LastName = 'Test Mother',
            Email = 'mother@example.com'
        );
        insert mother;

        // Create a Contact record for the student
        Contact student = new Contact(
            LastName = 'Test Student',
            Email = 'student@example.com',
            Father__c = father.Id,
            Mother__c = mother.Id
        );
        insert student;

        

        Student_Fee__c studentFee = new Student_Fee__c(
            Contact__c = student.Id,
            Payment_Type__c = 'Full Payment'
        );
        insert studentFee;

        Student_Fee_Payment__c payment = new Student_Fee_Payment__c(
            Student_Fee__c = studentFee.Id,
            Amount__c = 100.0,
            Transaction_Date_Time__c = Datetime.now()
        );
        insert payment;

        Test.startTest();
        RHStudentFeePaymentReceiptPDFGenerator.generateReceiptPDFAsync(payment.Id);

        Test.stopTest();

        // Verify that the Attachment is created
        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :payment.Id];
        System.assertEquals(1, attachments.size(), 'Attachment should be created');
        System.assert(attachments[0].Name.startsWith('PaymentReceipt_'), 'Attachment name should start with "PaymentReceipt_"');

        // Verify that ContentVersion is created
        List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion WHERE Title = :('PaymentReceipt_' + payment.Transaction_Date_Time__c.format('yyyyMMdd_HHmmss') + '.pdf')];
        System.assertEquals(1, contentVersions.size(), 'ContentVersion should be created');

        // Verify that email messages are sent
        // For testing purposes, you might want to check the email queue or mock the email sending logic
        // This part is usually more complex and may require a custom solution or additional test setup
    }
}