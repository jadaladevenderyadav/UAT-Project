public class RHStudentFeePaymentReceiptQueueable implements Queueable, Database.AllowsCallouts {
    private Id paymentId;
    private Id userId;

    public RHStudentFeePaymentReceiptQueueable(Id paymentId, Id userId) {
        this.paymentId = paymentId;
        this.userId = userId;
    }

    public void execute(QueueableContext context) {
        User originalUser = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(originalUser) {
            RHStudentFeePaymentReceiptPDFGenerator.generateReceiptPDF(paymentId);
        }
    }
}