public without sharing class FEE_StudentPayment_Ctrl 
{
    @AuraEnabled
    public static ContentVersion savePdfAsFile(String recordId) {
        try{
        System.debug('recordId=> '+recordId);
        // Generate the Visualforce page as a PDF
        PageReference pdfPage = Page.FEE_FeeReceipt;
        pdfPage.getParameters().put('id', recordId); // Pass the record ID to the VF page
        pdfPage.setRedirect(false);
        
        // Get the PDF content as a Blob (binary data)
        Blob pdfBlob = pdfPage.getContentAsPDF();
        
        // Create a new ContentVersion record to store the PDF in Salesforce Files
        ContentVersion file = new ContentVersion();
        file.Title = 'FeeReceipt_' + recordId; // Name of the file
        file.PathOnClient = '/FeeReceipt.pdf'; // File extension
        file.VersionData = pdfBlob; // Set the Blob data
        file.FirstPublishLocationId = recordId; // Link the file to the related record (Account, Contact, etc.)
        
        // Insert the file record into Salesforce
        insert file;
        System.debug('file=> '+file);
        return file;
        }
        catch(Exception e)
        {
            System.debug('Line=> '+e.getLineNumber()+' Message=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     // Method to delete a file after download
        @AuraEnabled
    public static void deleteFile(String contentDocumentId) {
        try {
            // Query for all ContentVersion records related to the ContentDocument
            List<ContentDocument> contentVersions = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
            
            // Delete all associated ContentVersion records
            if(!contentVersions.isEmpty())
            {
              delete contentVersions[0];
            }
            
            // Finally, delete the ContentDocument record
            ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];
            delete contentDocument;
            
            System.debug('File successfully deleted');
        } catch (Exception e) {
            System.debug('Error deleting file: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static StudentFeeWrapper DisplayStudentFeeRecords()
    {
        StudentFeeWrapper stuWrap = new StudentFeeWrapper();
        user usr = new user();
        usr =[select id,Name,ContactId from User where id=:userinfo.getUserId()];
        if(usr.ContactId != null)
        {            
            for(Student_Fee__c objStuFee : [select id,Name,Fee_Year__c,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Application_Number__c,Contact__r.Split_Booking_Fee__c,
                                            Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                            Course_Name_Course_Code__c,Program_Enrollment__c,Description__c,Due_Date__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,
                                            Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,
                                            Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c,
                                            (SELECT Id, Name, Student_Payment__r.Amount__c,Student_Payment__r.Split_Booking_Fee__c,Student_Payment__r.Partial_Booking_Fee__c,Student_Payment__r.Pending_Booking_Fee_FF__c,Student_Payment__r.Pending_Booking_Fee__c,Student_Payment__r.Payment_Status__c,Student_Payment__r.Split_Validation__c FROM Student_Fee_Payments__r where Student_Payment__r.Payment_Status__c != 'Success')
                                            from Student_Fee__c where Contact__c =: usr.ContactId order by Due_Date__c asc]) 
            {
                CheckboxWrapper checkWrap = new CheckboxWrapper();
                if(objStuFee.Name != null)
                    stuWrap.objStuname =objStuFee.Name;
                if(objStuFee.Contact__r.Application_Number__c != null)
                    stuWrap.objAppNumber=objStuFee.Contact__r.Application_Number__c;
                if(objStuFee.Contact__r.SRN_Number__c != null)
                    stuWrap.objSrnNumber=objStuFee.Contact__r.SRN_Number__c; 
                
                stuWrap.TotalAmount = stuWrap.TotalAmount + objStuFee.Amount__c;
                stuWrap.TotalPendingAmount = stuWrap.TotalPendingAmount + objStuFee.Amount_Pending__c;
                stuWrap.TotalPaidAmount = stuWrap.TotalPaidAmount + objStuFee.Amount_Paid__c;
                
                if(objStuFee.Amount_Pending__c != null && objStuFee.Amount_Pending__c > 0)
                {
                    checkWrap.ObjStuFeeDeatils = objStuFee;                    
                    stuWrap.lst_CheckboxWrap.add(checkWrap);
                }
                if(objStuFee.Amount_Pending__c == 0)
                {
                    stuWrap.lst_StuPaidDetails.add(objStuFee);
                }
            }
            for(Student_Payment__c objStuPay : [select Id,Name,Amount__c,Contact__c,Description__c,Fee_Type__c,Mode_of_Payment__c,Offline_Receipt_Number__c,Online_Receipt_Number1__c,
                                                Payment_Date_Time__c,Payment_Link_Id__c,Payment_Url__c,Payment_Gateway__c,Program_Enrollment__c,Razorpay_Signature__c,Payment_Status__c,
                                                Transaction_ID__c,Transaction_Status__c 
                                                from Student_Payment__c where Payment_Status__c !=: 'Payment Link Created' AND Contact__c =: usr.ContactId Order by Createddate DESC]) 
            {
                stuWrap.lst_StuPaymentDetails.add(objStuPay);
            }
        }
        return stuWrap;
    } 
    @AuraEnabled //Single record validation
    public static ErrorWrapper ValidationDate(Id strSelid,date selduedate,string Conid)
    {
        system.debug('====strSelid==='+strSelid);
        ErrorWrapper errWrap = new ErrorWrapper();
        if(selduedate != null)
        {
            string selFeetype;
            boolean isLateFee = false;
            for(Student_Fee__c objStuFee : [select id,Name,Fee_Type__c,Contact__c,Due_Date__c,Parent_Student_Fee__c
                                            from Student_Fee__c where id =: strSelid and Contact__c =: Conid])
            {  
                if(objStuFee.Fee_Type__c !=  null)
                {
                    selFeetype = objStuFee.Fee_Type__c;
                }
                if(string.isNotBlank(objStuFee.Parent_Student_Fee__c)){
                    isLateFee = true;
                }
            }
            
            set<string> set_FeeType = new set<string>();
            set_FeeType.add('Tuition Fee');
            set_FeeType.add('University Fee');
            set_FeeType.add('Penalty Fee');
            if(!string.isBlank(selFeetype) && (selFeetype == 'Tuition Fee'))
            {                 
                for(Student_Fee__c objStuFee : [select id,Name,Fee_Type__c,Contact__c,Due_Date__c
                                                from Student_Fee__c where Due_Date__c <=: selduedate and Contact__c =: Conid 
                                                and Amount_Pending__c != null and Amount_Pending__c > 0 and Fee_Type__c =: 'University Fee' ])
                {                     
                    errWrap.DateError='Fee for Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made';                    
                }
                
                Boolean hasPenaltyFee = false;
                for (Student_Fee__c objStuFee : [SELECT Id, Name, Fee_Type__c, Contact__c, Due_Date__c
                                                 FROM Student_Fee__c WHERE Due_Date__c <= :selduedate AND Contact__c = :Conid AND Amount_Pending__c != null 
                                                 AND Amount_Pending__c > 0 AND Fee_Type__c = 'Penalty Fee']) {
                                                     hasPenaltyFee = true;
                                                     errWrap.DateError = 'You have Penalty Fee So that you can'+'\''+'t made with Single Payment Go with PAY Multiples';
                                                     return errWrap;
                                                 }
            }
            else if(!string.isBlank(selFeetype) && (selFeetype == 'Tuition Fee'))
            {                 
                for(Student_Fee__c objStuFee : [select id,Name,Fee_Type__c,Contact__c,Due_Date__c
                                                from Student_Fee__c where Due_Date__c <=: selduedate and Contact__c =: Conid 
                                                and Amount_Pending__c != null and Amount_Pending__c > 0  and Fee_Type__c =: 'University Fee'])
                {                     
                    if(objStuFee.Fee_Type__c == 'University Fee')
                        errWrap.DateError='Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made';                    
                    //else if(objStuFee.Fee_Type__c == 'Tuition Fee')
                    //   errWrap.DateError='Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made';                    
                    
                }
                
            } 
            else if(!string.isBlank(selFeetype) && (selFeetype == 'University Fee'))
            {
                
                for(Student_Fee__c objStuFee : [select id,Name,Fee_Type__c,Contact__c,Due_Date__c
                                                from Student_Fee__c where Due_Date__c <: selduedate and Contact__c =: Conid 
                                                and Amount_Pending__c != null and Amount_Pending__c > 0  ])
                {                     
                    if(objStuFee.Fee_Type__c == 'University Fee')
                        errWrap.DateError='Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made';                    
                    else if(objStuFee.Fee_Type__c == 'Tuition Fee')
                        errWrap.DateError='Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made'; 
                    
                }
                Boolean hasPenaltyFee = false;
                for (Student_Fee__c objStuFee : [SELECT Id, Name, Fee_Type__c, Contact__c, Due_Date__c
                                                 FROM Student_Fee__c WHERE Due_Date__c >= :selduedate AND Contact__c = :Conid AND Amount_Pending__c != null 
                                                 AND Amount_Pending__c > 0 AND Fee_Type__c = 'Penalty Fee']) {
                                                     hasPenaltyFee = true;
                                                     errWrap.DateError = 'You have Penalty Fee So that you can'+'\''+'t made with Single Payment Go with PAY Multiples';
                                                     return errWrap;
                                                 }
            } else if (selFeetype == 'Penalty Fee') {
                for (Student_Fee__c objStuFee : [SELECT Id, Name, Fee_Type__c, Contact__c, Due_Date__c
                                                 FROM Student_Fee__c WHERE Contact__c = :Conid AND Fee_Type__c = 'Penalty Fee'
                                                 AND Amount_Pending__c > 0]) {
                                                     errWrap.DateError = 'You cannot pay Penalty Fee in Single Payment Go with PAY Multiples';
                                                     return errWrap;
                                                 }
            }
        }
        return errWrap;
    } 
    @AuraEnabled
    public static StudentFeeRecWrapper FetchFeeRecords(Id strSelid)
    {
        StudentFeeRecWrapper stuWrap = new StudentFeeRecWrapper();
        user usr = new user();
        usr =[select id,Name,ContactId from User where id=:userinfo.getUserId()];
        if(usr.ContactId != null)
        {   
            for(Student_Fee__c objStuFee : [select id,Name,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Split_Booking_Fee__c,Contact__r.Application_Number__c,
                                            Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                            Course_Name_Course_Code__c,Description__c,Due_Date__c,Program_Enrollment__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,Premium_Room__c,
                                            Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,
                                            Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c,
                                            (SELECT Id, Name, Student_Payment__r.Amount__c,Student_Payment__r.Split_Booking_Fee__c,Student_Payment__r.Partial_Booking_Fee__c,Student_Payment__r.Pending_Booking_Fee_FF__c,Student_Payment__r.Pending_Booking_Fee__c,Student_Payment__r.Payment_Status__c,Student_Payment__r.Split_Validation__c FROM Student_Fee_Payments__r where Student_Payment__r.Payment_Status__c != 'Success')
                                            from Student_Fee__c where id=:strSelid and  Contact__c =: usr.ContactId order by Due_Date__c asc])
            {
                system.debug(objStuFee.Fee_Type__c+' ,'+objStuFee.Fee_Payment_Criteria__r.Fee_Type__c);
                if(objStuFee.Fee_Type__c == objStuFee.Fee_Payment_Criteria__r.Fee_Type__c)
                {
                    
                    // Hostel Related     
                    if (objStuFee.Fee_Type__c=='Hostel Fee'){
                        if (objStuFee.Payment_Type__c == 'Full Payment') {
                            // When Payment_Type__c is 'Full payment'
                            stuWrap.NoOfInstallments = 1;
                        } else {
                            // For other cases
                            if( objStuFee.Paid_Installments__c ==0){
                                stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c;
                            }else{
                                stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c+1;
                            }
                            
                        }
                        
                        if(objStuFee.Number_of_Installments__c  != null && objStuFee.Paid_Installments__c != null){
                            stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c+1;
                        }
                    }
                    
                    
                    
                    stuWrap.StuFeeType = objStuFee.Fee_Type__c;
                    if (objStuFee.Fee_Type__c!='Hostel Fee'){
                        if(objStuFee.Number_of_Installments__c  != null && objStuFee.Paid_Installments__c != null)
                            
                            stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c;
                    }
                    stuWrap.PendingAmount = objStuFee.Amount_Pending__c;
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Full Payment')  stuWrap.lst_StuFeePayment.add(objStuFee);
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Partial Payment') stuWrap.lst_StuFeePayment.add(objStuFee);
                    
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('RazorPay','RazorPay');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Paytm__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('PayTM','PayTM');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('EazyPay','EazyPay');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('BillDesk','BillDesk');
                    }
                }            
            }
        }
        system.debug(stuWrap);
        return stuWrap; 
    }@AuraEnabled
    public static Student_Fee__c getPenaltyFeeForContact(Id contactId) {
        // Query to fetch penalty fee records for the given contact ID
        List<Student_Fee__c> penaltyFees = [
            SELECT Id, Fee_Year__c 
            FROM Student_Fee__c 
            WHERE Contact__c = :contactId 
              AND Fee_Type__c = 'Penalty Fee' AND Amount_Pending__c > 0 LIMIT 1
        ];
        
        // Return the list of penalty fee records
       return (penaltyFees.size() > 0) ? penaltyFees[0] : null;
    }   
    @AuraEnabled
    public static StudentFeeRecWrapper MultiStduentFeeRecords(list<Student_Fee__c> lst_StuIds)
    {
        //system.debug('===lst_StuIds==='+lst_StuIds);
        StudentFeeRecWrapper stuWrap = new StudentFeeRecWrapper();
        boolean razorpay = true;
        boolean billdesk = true;
        boolean paytm = true;
        boolean EazyPay = true;
       
        for(Student_Fee__c objstufee : lst_StuIds)
        {
            if(objstufee.Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c == null && billdesk==true)
            {
                billdesk = false;
            }
            if(objstufee.Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c == null && EazyPay==true)
            {
                EazyPay = false;
            }
            if(objstufee.Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c == null && razorpay==true)
            {
                razorpay = false;
            }
            if(objstufee.Fee_Payment_Criteria__r.Merchant_ID_Paytm__c == null && paytm==true)
            {
                paytm = false;
            }
            system.debug('objstufee1==>'+objstufee);
            system.debug('objstufee2==>'+objstufee.Student_Fee_Payments__r);
            stuWrap.lst_StuFeePayment.add(objstufee);
         
        }
       
        if(razorpay == true)
            stuWrap.map_PaymentGateway.put('RazorPay','RazorPay');
        if(paytm == true)
            stuWrap.map_PaymentGateway.put('PayTM','PayTM');
        if(EazyPay == true)
            stuWrap.map_PaymentGateway.put('EazyPay','EazyPay');
        if(billdesk == true)
            stuWrap.map_PaymentGateway.put('BillDesk','BillDesk');        
        
        stuWrap.Errmsg = 'Success';
        if(stuWrap.map_PaymentGateway.values().size() ==0)
        {
            stuWrap.Errmsg = 'Failure';
        }
        return stuWrap; 
    }
@AuraEnabled
    public static ErrorWrapper ValidateMultiPayments(list<Student_Fee__c> lst_StuIds)
    {
        ErrorWrapper errWrap = new ErrorWrapper();
        set<string> set_feetype = new set<string>();
        set<date> set_dates = new set<date>();
        date seldate;
        set<id> set_conid = new set<id>();
        List<Date> lst_Date = new List<Date>();
        
        Integer totalRemainingInstallments = 0;
        for(Student_Fee__c objstufee : lst_StuIds)
        {
            if(objstufee.Fee_Type__c != null  && objstufee.Contact__c != null)
            {
                //set_feetype.add(objstufee.Fee_Type__c);
                if(objstufee.Due_Date__c != null)
                {
                    set_dates.add(objstufee.Due_Date__c);
                    lst_Date.add(objstufee.Due_Date__c);
                    seldate = objstufee.Due_Date__c;
                    set_conid.add(objstufee.Contact__c);
                } 
            }
             
        }
        
        set_feetype.add('University Fee');
        set_feetype.add('Tuition Fee');
         
        map<date,Student_Fee__c> map_StudFee = new map<date,Student_Fee__c>();
        if(set_feetype.size()>0 && set_dates.size()>0)
        {
            Date maxDate;
            if(lst_Date.size() > 0)
            {
                lst_Date.sort();
                maxDate = lst_Date[lst_Date.size()-1];
            }
             
            integer countFee = 0;
            for(Student_Fee__c objStuFee : [select id,Name,Fee_Type__c,Contact__c,Due_Date__c from Student_Fee__c 
                                            where Due_Date__c <=: maxDate
                                          //  and Fee_Type__c in: set_feetype  
                                            and Contact__c in: set_conid 
                                            and Amount_Pending__c != null and Amount_Pending__c>0])
            {                 
                countFee = countFee + 1;
                map_StudFee.put(objStuFee.Due_Date__c,objStuFee);
            }             
            for(Student_Fee__c dt : lst_StuIds)
            {                 
                if(map_StudFee.size() > 0)
                {                                 
                   if(!map_StudFee.ContainsKey(dt.Due_Date__c) )
                   {
                       errWrap.DateError = 'Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made'; 
                   }
                }
            }                         
            
            if(map_StudFee.size() > lst_StuIds.size())
            {
                errWrap.DateError = 'Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made'; 
            }
        }
        return errWrap;
}@AuraEnabled
public static rezorpayResponseCall razorPayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType)
{
    string Name = '';
    decimal totAmt = PartialAmount;
    string email = '';
    string mobile = '';
    string discription = '';
    string contactId = '';
    string ProgEnrollId='';
    string RefId = Utility.generateRandomNumber();
    system.debug('RefId==>'+RefId);
    list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
    //  map<string,string> mapStuFee = new map<string,string>();
    
    for(Student_Fee__c fee : lst_StuFeeDeatils)
    {
        //totAmt = totAmt + fee.Amount_Pending__c;
        Name = fee.Contact__r.Name;
        email = fee.Contact__r.Email;
        mobile = fee.Contact__r.MobilePhone;
       // mobile = '9573248467';
        system.debug('mobile==>'+mobile);
        discription = discription + fee.Fee_Type__c+',';
        contactId = fee.Contact__c;
        ProgEnrollId = fee.Program_Enrollment__c;         
        //    mapStuFee.put(fee.Fee_Type__c,fee.Id);
    }
    Student_Payment__c objStuFeePay = new Student_Payment__c();
    objStuFeePay.Amount__c = totAmt;
    objStuFeePay.Contact__c = contactId;
    objStuFeePay.Fee_Type__c = discription; 
    objStuFeePay.Mode_of_Payment__c = 'Online';
    //objStuFeePay.Payment_Date_Time__c = system.now();
    //objStuFeePay.Payment_Date_Time__c = system.now().addHours(5).addMinutes(30);
    objStuFeePay.Reference_Id__c = RefId;
    objStuFeePay.Program_Enrollment__c = ProgEnrollId;
    lstStuPayment.add(objStuFeePay);
    
    rezorpayResponseCall reswrap = new rezorpayResponseCall();
    
    if(lstStuPayment.size() > 0){
        
        razorPayRequestCall rq = new razorPayRequestCall();
        string amt = string.valueof(totAmt.round(System.RoundingMode.HALF_DOWN));
        amt = amt + '00';
        system.debug('amt==>'+amt);
        rq.ramount = decimal.valueof(amt);
        rq.rcurrency = 'INR';
        rq.accept_partial = false;
        //rq.first_min_partial_amount = 100;
        rq.expire_by = 1786948311;
        rq.reference_id = RefId;
        //  rq.reference_id = 'Ref-0002';
        rq.description = discription;
        rq.reminder_enable = true;
        rq.callback_url = Razorpay_Details__c.getValues('CallbackUrl').Value__c;
        rq.callback_method = 'get';
        
        customerWrp cw = new customerWrp();
        cw.name = Name;
        cw.contact = Mobile;
        cw.email = email;
        rq.customer = cw;
        
        notifyWrp nw = new notifyWrp();
        nw.sms = true;
        nw.email=true;
        rq.notify = nw;
        
        notesWrp nt = new notesWrp();
        nt.paymentType = 'FeePayment';
        nt.reference_id = RefId;
        rq.notes = nt;
        
        string jsonbody = json.serialize(rq);
        jsonbody = jsonbody.replace('"rcurrency"', '"currency"');
        jsonbody = jsonbody.replace('"ramount"', '"amount"'); 
         system.debug('jsonbody==>'+jsonbody);
        string endpoint = Razorpay_Details__c.getValues('Razorpay Endpoint').Value__c; 
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json'); 
        req.setBody(jsonbody);
        //System.debug('+++++++++++++'+jsonbody);
        String username = Razorpay_Details__c.getValues('UserName').Value__c;
        String password = Razorpay_Details__c.getValues('Password').Value__c;
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);                 
        Http http = new Http();
        
        HTTPResponse res = http.send(req);
        String resBody = res.getBody();
        System.debug('++++reqBody++++++++'+ req );
        System.debug('++++resBody++++++++'+res.getBody());
        system.debug('====status code===='+res.getStatusCode());
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_StudentPayment_Ctrl';
        dblog.Method_Name__c = 'razorPayGenratePaymentLink';
        dblog.Processing_API_Name__c = 'RazorPay';            
        dblog.Request__c = req.getBody();
        dblog.Response__c = res.getBody();
        dblog.User_Id__c = UserInfo.getUserId();
        
        if(res.getStatusCode() == 200)
        {                      
            reswrap =  (rezorpayResponseCall)System.JSON.deserialize(resBody, rezorpayResponseCall.class);
            reswrap.statusCode = res.getStatusCode();              
            
            list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
            // for(Student_Payment__c sp : lstStuPayment){
            objStuFeePay.Payment_Link_Id__c = reswrap.id;
            objStuFeePay.Payment_Url__c = reswrap.short_url;
            objStuFeePay.Payment_Status__c = 'Payment Link Created';
            //}
            insert objStuFeePay;
            for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();   
                if(feeType == 'single'){                 
                    sfp.Amount__c = totAmt;
                }
                else{
                    sfp.Amount__c = objstuFee.Amount_Pending__c;
                }
                sfp.Mode_of_Payment__c = 'Online';
                sfp.Payment_Link_Id__c = reswrap.id;
                sfp.Student_Fee__c =  objstuFee.id;   //mapStuFee.get(objstuFee.Fee_Type__c);
                sfp.Student_Payment__c = objStuFeePay.id;
                sfp.Line_Item_Payment_Gateway__c = 'Razorpay';
                sfp.Reference_Id__c = RefId;
                lstSfp.add(sfp);
            }
            //system.debug('==lstStuPayment==='+lstStuPayment);
            insert lstSfp;
            // system.debug('===after insert==='+lstSfp);
            dblog.Status__c = 'Success';
        }
        else{
            reswrap.statusCode = res.getStatusCode();
            dblog.Status__c = 'Failure';
        }
        insert dblog;
    }
    // system.debug('===reswrap==='+reswrap);
    return reswrap;
}    

@AuraEnabled
public static rezorpayResponseCall BillDeskPayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType,string stuFeePayRecId)
{
    rezorpayResponseCall reswrap = new rezorpayResponseCall();
    string Name = '';
    decimal totAmt = PartialAmount;
    string email = '';
    string mobile = '';
    string mobilevalue='';
    string contactId = '';
    string studentUniqueId = '';
    string ProgEnrollId='';
    string discription = '';
    string RefId = Utility.generateRandomNumber();
    list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        System.debug('studentDetails1==>'+lst_StuFeeDeatils);
		Set<Id> stuFeeIdSet = new Set<Id>();
    for(Student_Fee__c fee : lst_StuFeeDeatils)
    {
        stuFeeIdSet.add(fee.Id);
        Name = fee.Contact__r.Name;
        if(string.isNotBlank(fee.Contact__r.Email)){
            email = fee.Contact__r.Email;
        }
        else{
            email = 'NA';
        }
        if(string.isNotBlank(fee.Contact__r.MobilePhone)){
            mobile = fee.Contact__r.MobilePhone;
        }
        else{
            mobile = 'NA';
        }
        mobilevalue=mobile.remove('+').remove('-');
        contactId = fee.Contact__c;
        ProgEnrollId = fee.Program_Enrollment__c;  
        discription = discription + fee.Fee_Type__c;    
        studentUniqueId = fee.Contact__r.Application_Number__c;  
        if(string.isNotBlank(studentUniqueId)){ 
            studentUniqueId = studentUniqueId.replaceAll('[^a-zA-Z0-9\\s+]', '');
        }
        else{
            studentUniqueId = 'NA';
        }
    }
    Student_Payment__c objStuFeePay = new Student_Payment__c();
            objStuFeePay.Amount__c = totAmt;
            system.debug('objStuFeePay.Amount__c**********'+objStuFeePay.Amount__c);
            objStuFeePay.Contact__c = contactId;
            objStuFeePay.Fee_Type__c = discription; 
            //  objStuFeePay.Mode_of_Payment__c = 'Online';
            objStuFeePay.Reference_Id__c = RefId;
            objStuFeePay.Program_Enrollment__c = ProgEnrollId;
            lstStuPayment.add(objStuFeePay);
    system.debug('size===>'+lst_StuFeeDeatils.size());
    if(lstStuPayment.size() > 0){
        string str = '<TXNDATA><TXNSUMMARY><REQID>PGECOM201</REQID><PGMERCID>'+Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'</PGMERCID>';
        str += '<RECORDS>'+lst_StuFeeDeatils.size()+'</RECORDS>';
        str += '<PGCUSTOMERID>'+RefId+'</PGCUSTOMERID>';
        str += '<AMOUNT>'+totAmt+'.00</AMOUNT>';
        dateTime dt = system.now();
        string strDt =string.valueof(dt);
        String newStrDt = strDt.replaceAll('[^0-9]', '');
        str += '<TXNDATE>'+newStrDt+'</TXNDATE></TXNSUMMARY>';
        
        integer count = 1;
        //system.debug('++++++++'+feeType);
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            str += '<RECORD ID="'+count+'"><MERCID>'+Billdesk_Merchant_Details__c.getValues(fee.Fee_Type__c).MerchantId__c+'</MERCID>';
            String amountToDisplay = (fee.Amount_Pending__c == Math.floor(fee.Amount_Pending__c)) 
                              ? String.valueOf(fee.Amount_Pending__c.intValue()) 
                              : String.valueOf(fee.Amount_Pending__c.setScale(2));
            if(feeType == 'single'){
                str += '<AMOUNT>'+totAmt+'.00</AMOUNT>';
            }else{
                str += '<AMOUNT>'+fee.Amount_Pending__c+'.00</AMOUNT>';
            }
            str += '<CUSTOMERID>'+RefId+count+'</CUSTOMERID>';
            str += '<ADDITIONALINFO1>'+Name+'</ADDITIONALINFO1>';
            str += '<ADDITIONALINFO2>'+email+'</ADDITIONALINFO2>';
            str += '<ADDITIONALINFO3>'+mobilevalue+'</ADDITIONALINFO3>';
            str += '<ADDITIONALINFO4>'+RefId+'</ADDITIONALINFO4>';
            str += '<ADDITIONALINFO5>'+fee.id+'</ADDITIONALINFO5>';
            str += '<ADDITIONALINFO6>'+studentUniqueId+'</ADDITIONALINFO6>';
            str += '<ADDITIONALINFO7>'+fee.Fee_Type__c+'</ADDITIONALINFO7>';
            str += '<FILLER1>NA</FILLER1>';
            str += '<FILLER2>NA</FILLER2>';
            str += '<FILLER3>NA</FILLER3>';
            str += '</RECORD>';
            count = count+1;
        }
        str += '</TXNDATA>';
        
        String gencheckSum = calculateCheckSum(str);
        gencheckSum = gencheckSum.toUppercase();
        string mainStr = '<?xml version="1.0" encoding="UTF-8"?><REQUEST>'+str;
        mainStr += '<CHECKSUM>'+gencheckSum+'</CHECKSUM></REQUEST>';
        system.debug('mainStr642'+mainStr);
        
        string endPoint = Billdesk_Merchant_Details__c.getValues('PaymentLink').MerchantId__c;
        Http http1 = new Http();
        HttpRequest httpReq1 = new HttpRequest();
        HttpResponse httpRes1 = new HttpResponse();
        httpReq1.setEndpoint(endPoint);
        System.debug('EndPoint-->> '+endPoint);
        httpReq1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        string payload = 'msg='+mainStr;
        System.debug('Stage1'+payload);
        httpReq1.setbody(payload);
        httpReq1.setMethod('POST');
        httpReq1.setTimeout(120000);
        httpRes1 = http1.send(httpReq1);
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_StudentPayment_Ctrl';
        dblog.Method_Name__c = 'BillDeskPayGenratePaymentLink';
        dblog.Processing_API_Name__c = 'BillDesk';            
        dblog.Request__c = httpReq1.getBody();
        dblog.Response__c = httpRes1.getBody();
        dblog.User_Id__c = UserInfo.getUserId();
        
        string statusCode;
        if(httpRes1.getStatusCode() == 200){
            string httpreq = httpReq1.getBody();
            string strXml = httpRes1.getBody();
            system.debug('httpreq-->>>>'+httpreq);
            System.debug('strXml-->>>> '+strXml);
            Dom.Document doc = new Dom.Document();  
            doc.load(strXml);
            Dom.XMLNode rootElement = doc.getRootElement();
            
            for(Dom.XMLNode child1 : rootElement.getChildElements())
            {
                 system.debug('child1'+child1);
                for(Dom.XMLNode child2 : child1.getChildElements())
                {   system.debug('child2'+child2);
                    if(child2.getName() == 'TXNSUMMARY'){   
                        for(Dom.XMLNode child3 : child2.getChildElements()){
                            system.debug('Child3Elements===>'+child3);
                            if(child3.getName() == 'STATUSCODE'){
                                system.debug('getNme===>'+child3.getName()+child3.getText());
                                statusCode = child3.getText();
                            }    
                        }    
                    }
                }
            }
        }
        else{
            reswrap.statusCode = httpRes1.getStatusCode();
        }
        
        if(statusCode == '0'){
            string baseReq = Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'|'+RefId+'|NA|'+totAmt+'.00|NA|NA|NA|INR|NA|R|'+Billdesk_Merchant_Details__c.getValues('SecurityId').MerchantId__c+'|NA|NA|F|';
            string midReq = Name+'|'+email+'|'+mobilevalue+'|'+RefId+'|'+studentUniqueId+'|NA|NA|';
            string returnUrl = Billdesk_Merchant_Details__c.getValues('CallbackUrl').MerchantId__c;
            System.debug('Stage2 '+baseReq);
            string checkSum =  baseReq+midReq+returnUrl;           
            String genertedcheckSum = calculateCheckSum(checkSum);
            genertedcheckSum = genertedcheckSum.toUppercase();
            checkSum = checkSum+'|'+genertedcheckSum;
            // system.debug('checkSum===>'+checkSum);
            
            string ep = Billdesk_Merchant_Details__c.getValues('PaymentEndPoint').MerchantId__c+checkSum;
            reswrap.short_url = ep;
            reswrap.statusCode = 200; 
            Student_Payment__c objStuFeePay1 = new Student_Payment__c();
            Student_Payment__c checkForSplitObject = checkForSplitPayment(stuFeeIdSet , totAmt);
            system.debug('checkForSplitObject*************'+checkForSplitObject);
            if( checkForSplitObject!=null && !String.isEmpty(checkForSplitObject.Id)){
                Student_Payment__c objStuFe = new Student_Payment__c();
                objStuFe.Reference_Id__c = RefId;
                objStuFe.Billdesk_Url__c = ep;
                objStuFe.Contact__c = contactId;
                objStuFe.Payment_Status__c = 'Payment Link Created';
                objStuFe.Payment_Gateway__c = 'Billdesk';
                objStuFe.Mode_of_Payment__c = 'Online';
                objStuFe.Id = checkForSplitObject.Id;
                //AddedbyRajashekarAug012024
                if(objStuFe.Program_Enrollment__c == null || objStuFe.Program_Enrollment__c == ''){
                    objStuFe.Program_Enrollment__c = ProgEnrollId;
                }
                //endshere
                update objStuFe;             
                system.debug('update ObjectFeePay1**********'+objStuFe);
            }else{
                
                objStuFeePay1.Reference_Id__c = RefId;
                objStuFeePay1.Amount__c = totAmt;
                objStuFeePay1.Billdesk_Url__c = ep;
                objStuFeePay1.Contact__c = contactId;
                objStuFeePay1.Payment_Status__c = 'Payment Link Created';
                objStuFeePay1.Payment_Gateway__c = 'Billdesk';
                objStuFeePay1.Mode_of_Payment__c = 'Online';
                objStuFeePay1.Fee_Type__c = discription; 
                objStuFeePay1.Program_Enrollment__c = ProgEnrollId;
                insert objStuFeePay1;
                system.debug('Insert ObjectFeePay1**********'+objStuFeePay);
            }
            
                        
            //  system.debug('==stu payment id==='+objStuFeePay.id);
            //AddedByRajashekar30july24
            list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
            
            if(stuFeePayRecId != null && stuFeePayRecId != ''){
                Student_Fee_Payment__c sfpRec = [select id,Name from Student_Fee_Payment__c where id=:stuFeePayRecId];
                for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                    if(feeType == 'single'){
                        sfpRec.Amount__c = totAmt;
                    }
                    else{
                        sfpRec.Amount__c = objstuFee.Amount_Pending__c;
                    }
                    sfpRec.Mode_of_Payment__c = 'Online';
                    sfpRec.Reference_Id__c = RefId;
                   /* sfp.Student_Fee__c =  objstuFee.id; 
                    if(checkForSplitObject != null && !String.isEmpty(checkForSplitObject.Id)){
                        sfp.Student_Payment__c = checkForSplitObject.Id;
                    }else{
                        sfp.Student_Payment__c = objStuFeePay1.id;
                    }*/
                    sfpRec.Line_Item_Payment_Gateway__c = 'Billdesk';                   
                } 
                update sfpRec;
               //Endshere30july2024
            }else{
                
            for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                if(feeType == 'single'){
                    sfp.Amount__c = totAmt;
                }
                else{
                    sfp.Amount__c = objstuFee.Amount_Pending__c;
                }
                sfp.Mode_of_Payment__c = 'Online';
                sfp.Reference_Id__c = RefId;
                sfp.Student_Fee__c =  objstuFee.id; 
                if(checkForSplitObject != null && !String.isEmpty(checkForSplitObject.Id)){
                    sfp.Student_Payment__c = checkForSplitObject.Id;
                }else{
                    sfp.Student_Payment__c = objStuFeePay1.id;
                }
                sfp.Line_Item_Payment_Gateway__c = 'Billdesk';                   
                lstSfp.add(sfp);
              }     
          }
            
            if(lstSfp.size() > 0){
                /*********changed on 2907 hostel********/
                insert lstSfp;
               // upsert lstSfp;
                set<Id> studentPaymentId = new Set<Id>();
       			set<Id> studentFeeId = new Set<Id>();
                for(Student_Fee_Payment__c eStr : lstSfp){
                    if(!String.isEmpty(eStr.Student_Payment__c)){
                        studentPaymentId.add(eStr.Student_Payment__c);
                    }
                    if(!String.isEmpty(eStr.Student_Fee__c)){
                        studentFeeId.add(eStr.Student_Fee__c);
                    }
                }
                list<Student_Fee_Payment__c> deleteNotTransctionList = [SELECT ID FROM Student_Fee_Payment__c 
                                                        WHERE  SF_Transaction_ID__c = NULL  
                                                        AND Student_Fee__c IN : studentFeeId  AND Line_Item_Payment_Status__c = 'Success'];
                system.debug('deleteNotTransctionList@@@@@@@@@@@@@@@@@'+deleteNotTransctionList);
                 if(!deleteNotTransctionList.isEmpty()){
                      // delete deleteNotTransctionList;
                 }
            }
            dblog.Status__c = 'Success';
            dblog.Data_Received__c = ep;
        }
        else{
            reswrap.statusCode = integer.valueof(statusCode);
            dblog.Status__c = 'Failure';
        }
        insert dblog;
     }
    return reswrap;
}    

@AuraEnabled
public static rezorpayResponseCall easypayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType)
{
    rezorpayResponseCall reswrap = new rezorpayResponseCall();
    string Name = '';
    decimal totAmt = PartialAmount;
    string email = '';
    string mobile = '';
    string contactId = '';
    string ProgEnrollId='';
    string discription = '';
    string RefId = Utility.generateRandomNumber();
    list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
    string baseUrl = EasyPay_Details__c.getValues('EndPoint').Value__c+'merchantid='+EasyPay_Details__c.getValues('ICID').Value__c+'&mandatory fields=';
    
    for(Student_Fee__c fee : lst_StuFeeDeatils)
    {
        Name = fee.Contact__r.Name;
        email = fee.Contact__r.Email;
        mobile = fee.Contact__r.MobilePhone;
        contactId = fee.Contact__c;
        ProgEnrollId = fee.Program_Enrollment__c;  
        discription = discription + fee.Fee_Type__c+',';       
    }
    
    Student_Payment__c objStuFeePay = new Student_Payment__c();
    objStuFeePay.Amount__c = totAmt;
    objStuFeePay.Contact__c = contactId;
    objStuFeePay.Fee_Type__c = discription; 
    objStuFeePay.Reference_Id__c = RefId;
    objStuFeePay.Program_Enrollment__c = ProgEnrollId;
    lstStuPayment.add(objStuFeePay);
    
    if(lstStuPayment.size() > 0){
        
        string para1 = RefId+'|'+EasyPay_Details__c.getValues('Submerchantid').Value__c+'|'+PartialAmount;
        para1 += '|'+Name+'|'+email+'|'+mobile+'|'+RefId;  
        
        string plainUrl = baseUrl + para1 + '&optional fields=xyz|xyz&returnurl='+EasyPay_Details__c.getValues('CallbackUrl').Value__c;
        plainUrl += '&Reference No='+RefId+'&submerchantid='+EasyPay_Details__c.getValues('Submerchantid').Value__c;
        plainUrl += '&transaction amount='+string.valueof(PartialAmount)+'&paymode=9';
        system.debug('PlainUrl+++++++'+plainUrl); 
        string str;
        if(!test.isRunningTest()){
            str = calculateAes(para1);
            
            str += '&optional fields='+calculateAes('xyz|xyz');
            str += '&returnurl='+calculateAes(EasyPay_Details__c.getValues('CallbackUrl').Value__c)+'&Reference No='+calculateAes(RefId)+'&submerchantid=';
            str += calculateAes(EasyPay_Details__c.getValues('Submerchantid').Value__c)+'&transaction amount='+calculateAes(string.valueof(PartialAmount))+'&paymode='+calculateAes('9');
        }
        else{
            str = 'test';
        }
        system.debug('++++++++'+str);
        baseUrl = baseUrl + str;
        system.debug('++++++++'+baseUrl);
        /* 
Debug_Log__c dblog = new Debug_Log__c();
dblog.Class_Name__c = 'FEE_StudentPayment_Ctrl';
dblog.Method_Name__c = 'easypayGenratePaymentLink';
dblog.Processing_API_Name__c = 'EasyPay';            
dblog.Request__c = httpReq1.getBody();
dblog.Response__c = httpRes1.getBody();
dblog.User_Id__c = UserInfo.getUserId();
*/
        
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Billdesk_Url__c = baseUrl;
        objStuFeePay.Payment_Status__c = 'Payment Link Created';
        objStuFeePay.Payment_Gateway__c = 'Eazypay';
        objStuFeePay.Mode_of_Payment__c = 'Online';
        insert objStuFeePay;
        
        list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
        for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
            Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
            if(feeType == 'single'){
                sfp.Amount__c = totAmt;
            }
            else{
                sfp.Amount__c = objstuFee.Amount_Pending__c;
            }
            sfp.Mode_of_Payment__c = 'Online';
            sfp.Reference_Id__c = RefId;
            sfp.Student_Fee__c =  objstuFee.id;                       
            sfp.Student_Payment__c = objStuFeePay.id;
            sfp.Line_Item_Payment_Gateway__c = 'Eazypay';                   
            lstSfp.add(sfp);
        }           
        if(lstSfp.size() > 0){
            insert lstSfp;
        }
        reswrap.short_url = baseUrl;
        reswrap.statusCode = 200;
        
    }
    else{
        reswrap.statusCode = 101;
        // dblog.Status__c = 'Failure';
    }
    system.debug('+++++++++++'+reswrap);
    return reswrap;
}


@AuraEnabled
public static rezorpayResponseCall PaytmGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType)
{
    rezorpayResponseCall reswrap = new rezorpayResponseCall();
    decimal totAmt = PartialAmount;
    string applicationNo = '';
    string contactId = '';
    string ProgEnrollId='';
    string discription = '';
    string RefId = Utility.generateRandomNumber();  
    
    for(Student_Fee__c fee : lst_StuFeeDeatils)
    {
        applicationNo = fee.Contact__r.Application_Number__c;
        contactId = fee.Contact__c;
        ProgEnrollId = fee.Program_Enrollment__c;  
        discription = discription + fee.Fee_Type__c+','; 
    }
    
    Student_Payment__c objStuFeePay = new Student_Payment__c();
    objStuFeePay.Amount__c = totAmt;
    objStuFeePay.Contact__c = contactId;
    objStuFeePay.Fee_Type__c = discription; 
    objStuFeePay.Reference_Id__c = RefId;
    objStuFeePay.Program_Enrollment__c = ProgEnrollId;
    
    Map<string, string> parammap = new Map<string,string>();
    parammap.put('MID',Paytm_Details__c.getValues('MID').Value__c);
    parammap.put('ORDER_ID',RefId);
    
    paytmMain ptm = new paytmMain();
    ptm.body = new PaytmParamClass();
    ptm.body.requestType = 'Payment';
    ptm.body.mid = Paytm_Details__c.getValues('MID').Value__c;
    ptm.body.orderId = RefId;
    ptm.body.websiteName = 'DEFAULT';
    ptm.body.callbackUrl = Paytm_Details__c.getValues('CallbackUrl').Value__c;
    ptm.body.txnAmount = new paymentDetails();
    ptm.body.txnAmount.value = string.valueof(PartialAmount);
    ptm.body.txnAmount.ccurrency = 'INR';
    ptm.body.userInfo = new UserDetails();
    ptm.body.userInfo.custId = applicationNo;
    
    string jsonStr = JSON.serialize(ptm.body);
    system.debug('jsonStr+++++++++'+jsonStr);
    system.debug('Key+++++++++'+Paytm_Details__c.getValues('Merchant Key').Value__c);
    string checksumstring = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Details__c.getValues('Merchant Key').Value__c, jsonStr);
    system.debug('checksumstring+++++++++'+checksumstring);
    ptm.head = new headDetails();
    ptm.head.signature = checksumstring;
    
    system.debug('Ptm++++++++'+ptm);
    
    string baseUrl = Paytm_Details__c.getValues('Endpoint').Value__c + 'mid=' +Paytm_Details__c.getValues('MID').Value__c+'&' ;
    baseUrl += 'orderId='+RefId;
    
    
    string str = JSON.serialize(ptm);
    system.debug('HttpBody++++++++'+str); 
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(baseUrl);
    req.setHeader('Content-Type','application/json');
    req.setMethod('POST');
    req.setBody(str);
    req.setTimeout(120000);
    HttpResponse res = h.send(req);
    
    system.debug('++++++++'+res); 
    System.debug('++++resBody++++++++'+res.getBody());
    
    Debug_Log__c dblog = new Debug_Log__c();
    dblog.Class_Name__c = 'FEE_StudentPayment_Ctrl';
    dblog.Method_Name__c = 'paytmGenratePaymentLink';
    dblog.Processing_API_Name__c = 'Paytm';            
    dblog.Request__c = req.getBody();
    dblog.Response__c = res.getBody();
    dblog.User_Id__c = UserInfo.getUserId();
    
    
    objStuFeePay.Reference_Id__c = RefId;
    //  objStuFeePay.Billdesk_Url__c = baseUrl;
    objStuFeePay.Payment_Status__c = 'Payment Link Created';
    objStuFeePay.Payment_Gateway__c = 'Paytm';
    objStuFeePay.Mode_of_Payment__c = 'Online';
    insert objStuFeePay;
    
    list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
    for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
        Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
        if(feeType == 'single'){
            sfp.Amount__c = totAmt;
        }
        else{
            sfp.Amount__c = objstuFee.Amount_Pending__c;
        }
        sfp.Mode_of_Payment__c = 'Online';
        sfp.Reference_Id__c = RefId;
        sfp.Student_Fee__c =  objstuFee.id;                       
        sfp.Student_Payment__c = objStuFeePay.id;
        sfp.Line_Item_Payment_Gateway__c = 'Paytm';                   
        lstSfp.add(sfp);
    }           
    if(lstSfp.size() > 0){
        insert lstSfp;
    }
    
    inisaliseResponse response1 = new inisaliseResponse();
    
    if(res.getStatusCode() == 200){
        response1 = (inisaliseResponse)System.JSON.deserialize(res.getBody(), inisaliseResponse.class);
        
        if(response1.body.resultInfo.resultCode == '0000' || response1.body.resultInfo.resultCode == '0002'){
            reswrap.reference_id = response1.body.txnToken;
            reswrap.statusCode = 200;
            reswrap.id = Paytm_Details__c.getValues('MID').Value__c;
            reswrap.status = RefId;
            reswrap.short_url = Paytm_Details__c.getValues('PaymentEndPoint').Value__c +'mid='+Paytm_Details__c.getValues('MID').Value__c+'&orderId='+RefId;
            dblog.Status__c = 'Success';
            
        }
        else{
            reswrap.statusCode = 101;
            dblog.Status__c = 'Failure';
        }
    }
    
    insert dblog;
    return reswrap;
}

public static string calculateCheckSum(string mainStr){
    String testKey = Billdesk_Merchant_Details__c.getValues('Checksum').MerchantId__c;
    String algorithmName = 'hmacSHA256';
    Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(mainStr) , Blob.valueOf(testKey));
    //system.debug('++++'+hmacData);
    return EncodingUtil.convertToHEX(hmacData);
    
}

public static string calculateAes(string mainStr){
    /*String Key = EasyPay_Details__c.getValues('AES key').Value__c;
functions.Function accountFunction = functions.Function.get(label.FEE_Easypay_Function_Name);
functions.FunctionInvocation invocation = accountFunction.invoke('{ "input" : "' +mainStr +'", "key" : "'+ key + '"}');
Map<String, Object> mp_out = (Map<String, Object>) JSON.deserializeUntyped(invocation.getResponse()) ;
System.debug('Got response ' + mp_out);
string decode  = String.valueof(mp_out.get('encodedStr')).unescapeHtml4();
return decode;     */
    return '';
}

@AuraEnabled
public static string singleRecordCheckLateFee(string feeId){
    
    Student_Fee__c objStuFee = [select id,Fee_Type__c,Parent_Student_Fee__c,Amount_Pending__c,Contact__c FROM Student_Fee__c WHERE id =: feeId];
    
    string sfId = '';
    if(string.isBlank(objStuFee.Parent_Student_Fee__c)){
        for(Student_Fee__c objSf : [select id,Parent_Student_Fee__c FROM Student_Fee__c WHERE Parent_Student_Fee__c =: objStuFee.id AND 
                                    Fee_Type__c =: objStuFee.Fee_Type__c AND Amount_Pending__c >: 0 AND Contact__c =: objStuFee.Contact__c]){
                                        sfId = objSf.id;
                                    }
    }
    else{
        //  sfId = objStuFee.Parent_Student_Fee__c;
    }
    
    string errorMsg = 'Success';
    if(string.isNotBlank(sfId)){
        errorMsg = 'Late Fee is Pending';
    }                
    return errorMsg;
}

@AuraEnabled
public static list<string> multiRecordCheckLateFee(string feeId){
    list<string> lstIds = new list<string>();
    Student_Fee__c objStuFee = [select id,Parent_Student_Fee__c,Contact__c FROM Student_Fee__c WHERE id =: feeId];
    
    string sfId = '';
    if(string.isBlank(objStuFee.Parent_Student_Fee__c)){
        for(Student_Fee__c objSf : [select id,Parent_Student_Fee__c FROM Student_Fee__c WHERE Parent_Student_Fee__c =: objStuFee.id 
                                    AND Amount_Pending__c >: 0 AND Contact__c =: objStuFee.Contact__c]){
                                        lstIds.add(objSf.id);
                                    }
    }
    else{
        lstIds.add(objStuFee.Parent_Student_Fee__c);
    }
    
    return lstIds;
}
   
/***********************New Implementation*******************************/
    public static Student_Payment__c checkForSplitPayment(Set<Id> stuFeeIdSet, Decimal Amount){
    if(!stuFeeIdSet.isEmpty()){
        list<Student_Fee_Payment__c> studFeePayList = [SELECT Id, Name, Student_Payment__c, 
                                                       Student_Payment__r.Amount__c,
                                                       Student_Payment__r.Split_Booking_Fee__c,
                                                       Student_Payment__r.Partial_Booking_Fee__c,
                                                       Student_Payment__r.Pending_Booking_Fee_FF__c 
                                                       FROM Student_Fee_Payment__c 
                                                       WHERE Student_Fee__c IN : stuFeeIdSet 
                                                       AND Student_Payment__r.Amount__c =: Amount AND Student_Payment__r.Payment_Status__c != 'Success'];
        
        system.debug('inside the checkForSplitPayment_studFeePayList**************'+studFeePayList);
        set<Id> studPaymentIdSet = new set<Id>();
        for(Student_Fee_Payment__c stdFee : studFeePayList){
            if(stdFee.Student_Payment__r.Split_Booking_Fee__c == true){
                if(!String.isEmpty(stdFee.Student_Payment__c)){
                    studPaymentIdSet.add(stdFee.Student_Payment__c);
                }    
            }
        }
        
        if(!studPaymentIdSet.isEmpty()){
           Student_Payment__c studPaymentList = [SELECT ID, Amount__c, Contact__c, Fee_Type__c,Reference_Id__c, Program_Enrollment__c  
                                                       FROM Student_Payment__c 
                                                       WHERE ID IN : studPaymentIdSet lIMIT 1];
         return studPaymentList;
        }    
    }
    return null;
}
/********************************************************/
    
    
    
/***********************AddedbyRajashekarAug272024*******************************/      
@Auraenabled
  public static string getLoggedInUserProfile(){
      Id currentUserId = UserInfo.getUserId();
      User currentUser = [SELECT Profile.Name FROM User WHERE Id = :currentUserId LIMIT 1];
      String profileName = currentUser.Profile.Name;
      System.debug('CurrentUserProfileName==>: ' + profileName);
      return profileName;
   }    
/****************************Ends here*****************************************/


public class StudentFeeWrapper
{
    @AuraEnabled public list<CheckboxWrapper> lst_CheckboxWrap {get;set;}
    @AuraEnabled public list<Student_Fee__c> lst_StuPaidDetails {get;set;}
    @AuraEnabled public list<Student_Payment__c> lst_StuPaymentDetails {get;set;}
    @AuraEnabled public string objStuname {get;set;}
    @AuraEnabled public string objAppNumber {get;set;}
    @AuraEnabled public string objSrnNumber {get;set;}
    @AuraEnabled public decimal TotalAmount {get;set;}
    @AuraEnabled public decimal TotalPendingAmount {get;set;}
    @AuraEnabled public decimal TotalPaidAmount {get;set;}
    
    public StudentFeeWrapper()
    {
        lst_StuPaidDetails = new list<Student_Fee__c>();
        lst_StuPaymentDetails = new list<Student_Payment__c>();
        lst_CheckboxWrap = new list<CheckboxWrapper>();
        TotalAmount = 0;
        TotalPendingAmount = 0;
        TotalPaidAmount = 0;
    }
} 
public class StudentFeeRecWrapper
{
    @AuraEnabled public list<Student_Fee__c> lst_StuFeePayment {get;set;}
    @AuraEnabled public string StuFeeType {get;set;}
    @AuraEnabled public Decimal NoOfInstallments {get;set;}
    @AuraEnabled public Decimal PendingAmount {get;set;}
    @AuraEnabled public Map<string,string> map_PaymentGateway {get;set;}
    @AuraEnabled public string Errmsg {get;set;}
    public StudentFeeRecWrapper()
    {
        lst_StuFeePayment = new list<Student_Fee__c>();
        map_PaymentGateway = new map<string,string>();
    }
}
public class CheckboxWrapper
{
    @AuraEnabled public Student_Fee__c ObjStuFeeDeatils {get;set;}
    @AuraEnabled public boolean isChecked {get;set;}
    public CheckboxWrapper()
    {
        ObjStuFeeDeatils = new Student_Fee__c();
        isChecked = false;
    }    
}
public class ErrorWrapper
{
    @AuraEnabled public string DateError {get;set;}
    @AuraEnabled public Integer NoOfInstallments {get;set;}
}  
public class razorPayRequestCall{
    @AuraEnabled public decimal ramount {get;set;}
    @AuraEnabled public string rcurrency {get;set;}
    @AuraEnabled public boolean accept_partial {get;set;}
    //@AuraEnabled public decimal first_min_partial_amount {get;set;}
    @AuraEnabled public decimal expire_by {get;set;}
    @AuraEnabled public string reference_id {get;set;}
    @AuraEnabled public string description {get;set;}
    @AuraEnabled public boolean reminder_enable {get;set;}
    @AuraEnabled public string callback_url {get;set;}
    @AuraEnabled public string callback_method {get;set;}
    @AuraEnabled public customerWrp customer {get;set;}
    @AuraEnabled public notifyWrp notify {get;set;}
    @AuraEnabled public notesWrp notes {get;set;}
}
public class customerWrp{
    @AuraEnabled public string name {get;set;}
    @AuraEnabled public string contact {get;set;}
    @AuraEnabled public string email {get;set;}
}
public class notifyWrp{
    @AuraEnabled public boolean sms {get;set;}
    @AuraEnabled public boolean email {get;set;}
}
public class notesWrp{
    @AuraEnabled public string paymentType {get;set;}
    @AuraEnabled public string reference_id{get;set;}
}

public class rezorpayResponseCall{
    @AuraEnabled public string id {get;set;}
    @AuraEnabled public string reference_id {get;set;}
    @AuraEnabled public string short_url {get;set;}
    @AuraEnabled public string status  {get;set;}
    @AuraEnabled public integer statusCode  {get;set;}
}

public class paytmMain{
    @AuraEnabled public PaytmParamClass body {get;set;}
    @AuraEnabled public headDetails head {get;set;}
}
public class PaytmParamClass{
    @AuraEnabled public string requestType {get;set;}
    @AuraEnabled public string mid {get;set;}
    @AuraEnabled public string orderId {get;set;}
    @AuraEnabled public string websiteName {get;set;}
    @AuraEnabled public string callbackUrl {get;set;}  
    @AuraEnabled public paymentDetails txnAmount {get;set;}  
    @AuraEnabled public UserDetails userInfo {get;set;}    
    
}

public class paymentDetails{
    @AuraEnabled public string value {get;set;}
    @AuraEnabled public string ccurrency {get;set;}
}

public class UserDetails{
    @AuraEnabled public string custId {get;set;}
}

public class headDetails{
    @AuraEnabled public string signature {get;set;}
}


public class inisaliseResponse{
    @AuraEnabled public resBodyDetails body {get;set;}
    @AuraEnabled public resHeadDetails head {get;set;}
}
public class resHeadDetails{
    @AuraEnabled public string responseTimestamp {get;set;}
    @AuraEnabled public string version {get;set;}
    @AuraEnabled public string signature {get;set;}
}
public class resResultInfoDetails{
    @AuraEnabled public string resultStatus {get;set;}
    @AuraEnabled public string resultCode {get;set;}
    @AuraEnabled public string resultMsg {get;set;}
}
public class resBodyDetails{
    @AuraEnabled public resResultInfoDetails resultInfo {get;set;}
    @AuraEnabled public string txnToken {get;set;}
    @AuraEnabled public boolean isPromoCodeValid {get;set;}
    @AuraEnabled public boolean authenticated {get;set;}
}
}