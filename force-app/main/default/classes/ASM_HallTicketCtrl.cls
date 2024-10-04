public without sharing class ASM_HallTicketCtrl {
    
    @AuraEnabled(cacheable=true)
    public static List<contact> searchStudents(String searchTerm) {
        
        List<contact> conlst=[SELECT Id, Name FROM contact WHERE (Name LIKE :('%' +searchTerm + '%') OR SRN_Number__c = :searchTerm) AND Active__c=true];
        return conlst;
    }
    @AuraEnabled
    public static string updateContact(String conId, string comments,string approvalType) {
        Contact con = new contact();
        con.Id = conId;
        con.Description=comments;
        con.Exam_Approval__c=true;
        con.Date_of_Approval__c=Date.valueof(DateTime.now());
        update con;
        return 'sucess';
    }
    @AuraEnabled
    public static wrapperClass GetStudentDetails()
    {
        String usrId=userinfo.getUserId();
        decimal Eligibility_Percent = decimal.Valueof(System.Label.ASM_AttendancePercentage);
        wrapperClass objWrapper = new wrapperClass();        
        user usr =[select id,Name,ContactId from User where Id =:usrId]; //
        objWrapper.EnableHallTicket = false;
        List<StudentFee> lst_StuFee = new List<StudentFee>();
        
        string ContactId;
        Contact objcon = new Contact();
        objcon =[select Id,Name,SRN_Number__c,Total_average_current_sem_attendance__c,Recordtype.Name,ReportsToId,Exam_Approval__c,Date_of_Approval__c,Active_Section__c,
                 Active_Semester__r.IA_1_End_date__c,Active_Semester__r.IA_2_End_date__c,Active_Semester__r.IA_1_Start_date__c,Active_Semester__r.IA_2_Start_date__c
                 from Contact where id=: usr.ContactId];

        objwrapper.SRNNumber = objcon.SRN_Number__c;
        if(objcon.Recordtype.Name == utility.Contact_RecType_Student) ContactId =objcon.id;
        else if(objcon.Recordtype.Name == utility.Contact_RecType_Parent) ContactId =objcon.ReportsToId;
        system.debug('objcon-->'+objcon);
        system.debug('ContactId-->>'+ContactId);
        
        Map<Integer, String> semesterToYearMap = new Map<Integer, String>{
            1 => '1st year',
                2 => '1st year',
                3 => '2nd year',
                4 => '2nd year',
                5 => '3rd year',
                6 => '3rd year',
                7 => '4th year',
                8 => '4th year'
                };
                    
                   
        try
        {
            for(Student_Fee__c objFee : [select Id,Name,Fee_Year__c,Contact__c,Contact__r.Total_average_current_sem_attendance__c,Amount_Pending__c,Due_Date__c,Contact__r.Active_Semester__r.Term_Number__c from Student_Fee__c where Contact__c =: ContactId
                                        ])
            {
                System.debug('objFee=> '+objFee);
                Boolean allPendingAmountsZero = true;
                // Check if any of the student fees records have pending amount greater than zero
                if(objFee.Fee_Year__c == semesterToYearMap.get(Integer.valueof(objFee.Contact__r.Active_Semester__r.Term_Number__c)))
                {
                    System.debug('Inside first if=> ');
                    if (Integer.valueOf(objFee.Amount_Pending__c) > 0) {
                        allPendingAmountsZero = false;
                        objWrapper.EnableHallTicket = false;
                        StudentFee objStuFee = new StudentFee();
                        objStuFee.FeeName = objFee.Name;
                        objStuFee.PendingAmount = objFee.Amount_Pending__c;
                        objStuFee.DueDate = objFee.Due_Date__c;
                        lst_StuFee.add(objStuFee);
                        
                        System.debug('Inside second if');
                        break;
                    }
                    else{
                            if(objfee.Contact__r.Total_average_current_sem_attendance__c>=75)
                                {
                                    System.debug('Inside Attendance');
                                    objWrapper.EnableHallTicket = true;                                   
                            }
                        }
                }
                
            }
        }
        catch(exception ex)
        {
            system.debug('Line=> '+ex.getLineNumber()+' Exception=> '+ex.getMessage());
        }
       
        system.debug('objWrapper.EnableHallTicket'+objWrapper.EnableHallTicket);
        system.debug('test 116'+objcon.Exam_Approval__c);
        system.debug('test117'+objcon.Date_of_Approval__c);
        System.debug('IA1STArtDate=>'+objcon.Active_Semester__r.IA_1_Start_date__c);
        System.debug('IA1Condition=> '+objcon.Active_Semester__r.IA_1_End_date__c);
        Date Filterdate = System.today().adddays(Integer.valueOf(System.label.HallTicketScheduleTime));
        If(objcon.Exam_Approval__c == true){
               objWrapper.EnableHallTicket = true;
           }
        system.debug('objWrapper'+objWrapper);
        return objWrapper;
    }
    @AuraEnabled
    public static errorWrap DowloadHallTicket(string StudentSRN)
    {
        errorWrap objError = new errorWrap();
        //StudentSRN = 'R80SA321';
        JsonSRN objJson = new JsonSRN();
        objJson.regno = StudentSRN;
        String jsonBody = Json.serialize(objJson);
        
        
        //Map Http Request
        HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_HallTicketCtrl',jsonBody);
        
        //Send Request
        Http http = new Http();
        HttpResponse hRsp = http.send(hReq);
        System.debug('Response=> '+hRsp);
        string hallTicketURL;
        if(hRsp.getStatusCode() == 200)
        {                        
            responseWrap objWrap = (responseWrap) Json.deserialize(hRsp.getBody(), responseWrap.class);             
            if(objWrap.data.url != null && objWrap.status != 'Failure')
            {
                objError.url = objWrap.data.url;
                return objError;                
            }    
            else
            {
                objError.error = 'error';
                objError.message = objWrap.data.msg;
                return objError;
            }
        }
        else
        {
            objError.error = 'error';
            objError.message = 'Please try after some time';
            return objError;
            
        }
    }
    
    public class JsonSRN
    {
        public string regno;
    }
    
    public class wrapperClass
    {
        @AuraEnabled public string SRNNumber {get;set;}
        @AuraEnabled public boolean EnableHallTicket {get;set;}
        @AuraEnabled public List<StudentFee> StudentFee {get;set;}
        
    }
    public class StudentFee
    {
        @AuraEnabled  public string FeeName {get;set;}
        @AuraEnabled  public decimal PendingAmount {get;set;}
        @AuraEnabled  public Date DueDate {get;set;}
    }
    
    public class responseWrap 
    {
        @AuraEnabled  public Integer error_code {get;set;}
        @AuraEnabled  public String status {get;set;}
        @AuraEnabled  public Data data {get;set;}
    }    
    public class Data 
    {
        @AuraEnabled  public String regno {get;set;}
        @AuraEnabled  public String url {get;set;}
        @AuraEnabled  public String msg {get;set;}
    }
    
    public class errorWrap
    {
        @AuraEnabled  public String error {get;set;}
        @AuraEnabled  public String message {get;set;}
        @AuraEnabled  public String url {get;set;}
    }
}