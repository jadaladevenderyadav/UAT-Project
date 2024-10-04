global class RTRStudentTransportConfirmation implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public List<String> recordIds;
    
    global RTRStudentTransportConfirmation(List<String> recordIds) {
        this.recordIds = recordIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator('SELECT Id, Contact__r.Id,contact__r.Name, contact__r.email, Route_Master__r.Name,Route_Pick_Up_Point__r.Name, Contact__r.Application_Number__c, Contact__r.SRN_Number__c, ' +
                                        'Registration_Status__c, Reva_Transport__r.Name, (SELECT Id, Amount__c, Amount_Paid__c, Amount_Pending__c, Due_Date__c FROM Student_Fees__r), Contact__r.Program_Batch__r.Name ' +
                                        'FROM Transport_Registeration__c ' +
                                        'WHERE Registration_Status__c = \'Active\' AND Reva_Transport__r.Active__c = true AND Id IN :recordIds');
    }
    
    global void execute(Database.BatchableContext context, List<Transport_Registeration__c> scope) {
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String stuName; 
        String applicationNumber;
        String SRNNumber;
        String ProgramBatchName;
        String RouteNumber;
        String RoutePickupPoint;
        Decimal amount;
        String dueDate;
        Decimal amountPaid;
        Decimal AmountPending;
        
        for(Transport_Registeration__c trReg : scope) {
            stuName = trReg.Contact__r.name; 
            applicationNumber = trReg.Contact__r.Application_Number__c;
            SRNNumber = trReg.Contact__r.SRN_Number__c;
            ProgramBatchName = trReg.Contact__r.Program_Batch__r.Name;
            RouteNumber = trReg.Route_Master__r.Name;
            RoutePickupPoint = trReg.Route_Pick_Up_Point__r.Name;
            
            for(Student_Fee__c fee : trReg.Student_Fees__r){
                amount = fee.Amount__c;
                Date Datedue = fee.Due_Date__c;
                Datetime rtrDateTime = Datetime.newInstance(Datedue.year(), Datedue.month(), Datedue.day());
                dueDate = rtrDateTime.format('dd/MM/yyyy'); 
                amountPaid = fee.Amount_Paid__c;
                AmountPending = fee.Amount_Pending__c;                
            }            
            
            String Body = 'Dear ' + stuName + ','+ '\n\nGreetings from REVA University.'+ '\n\nWe are pleased to inform you that your Transport Registration for REVA Transport has been successfully processed and approved. ' +
                +  '\nStudent Details:' + '\nApplicationNumber: ' + applicationNumber + '\nSRN: '+ SRNNumber + '\nName: ' + stuName + '\nProgram: ' + ProgramBatchName + '\n\nRegistration Details: '  + '\nRoute Number: ' +RouteNumber +                 
                '\nPickup Point: '+ RoutePickupPoint + '\nTotal Amount: ' + amount + '\nAmount Paid: ' + amountPaid  + '\nAmount Pending: '+ AmountPending + '\nDue Date: '+ dueDate + '\n\nBest Regards,' + '\nTransport Department' + '\nREVA University';  
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Transport Confirmation');
            mail.setplaintextbody(Body);
            mail.setToAddresses(new List<String>{'ankitp@yopmail.com'});
            emailList.add(mail);                       
        }
        
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }	     
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}