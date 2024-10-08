public class ApplicantProvisionalAdmissionFeeReceipt {
    public Student_Payment__c studentPayment {get;set;}
    public list<Student_Fee_Payment__c> studentFeePayments {get;set;}
    public Decimal total {get;set;}
    public string receiptNo {get;set;}
    public string totalInWords {get;set;}
    public string feeYear {get;set;}
    public string chequeNumber {get;set;}
    public string paymentStatus{get; set;}
    
     public ApplicantProvisionalAdmissionFeeReceipt(ApexPages.StandardController controller){
        try
        {
            studentPayment = new Student_Payment__c();
            studentFeePayments = new list<Student_Fee_Payment__c>();
            total = 0;
            string studentPaymentId = Apexpages.currentPage().getParameters().get('id');
           
            for(Student_Payment__c objstu : [Select Id, Name, Online_Receipt_Number1__c, Offline_Receipt_Number__c, Mode_of_Payment__c , Contact__r.Name, Contact__r.Primary_Academic_Program__r.name, Payment_Date_Time__c,
                                             Contact__r.Application_Number__c, Payment_Gateway__c, Payment_Mode_Type__c, Transaction_ID__c, Payment_Status__c, Receipt_Generated_by__c, Receipt_Generated_on__c
                                             from Student_Payment__c where id = : studentPaymentId]){
                                                 studentPayment = objstu;
                                    }
           
            if(studentPayment.Online_Receipt_Number1__c != null){
                receiptNo = studentPayment.Online_Receipt_Number1__c;
            }
            else{
                receiptNo = studentPayment.Offline_Receipt_Number__c; 
            }
            for(Student_Fee_Payment__c objstudentFeePayments:[Select Id, Name, Amount__c, Student_Fee__r.name, Student_Fee__r.Fee_Year__c,Student_Fee__r.Provisional_Admission_Fee__c from Student_Fee_Payment__c 
                                                              where Student_Payment__c = : studentPaymentId]){
                                                                  
                                                                  studentFeePayments.add(objstudentFeePayments);
                                                                  
                                                                  if(objstudentFeePayments.Amount__c != null)
                                                                      total = total + objstudentFeePayments.Amount__c;
                                                              }
            
            Student_Fee_Payment__c sf = [Select Id, Name, Amount__c, Student_Fee__r.name,Student_Fee__r.Fee_Year__c,Cheque_DD_Number__c from Student_Fee_Payment__c 
                                         where Student_Payment__c = : studentPaymentId
                                         limit 1];
           
            feeYear = sf.Student_Fee__r.Fee_Year__c;
            chequeNumber = sf.Cheque_DD_Number__c ;
            paymentStatus = 'Success';
            
            NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
            totalInWords = cls.convert(integer.valueOf(total));
        }catch(exception ex){
            
        }
    }
}