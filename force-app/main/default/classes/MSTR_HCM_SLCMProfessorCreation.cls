@RestResource(urlMapping='/ProfessorDetails/*')
global class MSTR_HCM_SLCMProfessorCreation 
{
    @HttpPost
    global static void getProfessorDetails()
    {
        List<responseWrapper> lstRespWrp = new List<responseWrapper>();
        responseWrapper objRespWrp = new responseWrapper();
        RequestWrapper objReqWrp = new RequestWrapper();
        String jsonBody;
        List<Contact> lstContact = new List<Contact>();
        
        //Creating the Debug Log
        Debug_Log__c objDbLog = new Debug_Log__c();
        objDbLog.Processing_API_Name__c = 'Professor API';
        objDbLog.Object_Name__c = 'Contact - Professor';
        objDbLog.Status__c = 'Failure';
        objDbLog.Class_Name__c = 'MSTR_HCM_SLCMProfessorCreation';
        Insert objDbLog;
        
        RestRequest objRestRequest = RestContext.request;
        RestResponse objRestResponse = RestContext.response;
        //Storing the request body into string
        jsonBody = objRestRequest.requestBody.toString().trim();
        try
        {
            if(jsonBody != null)
            {
                // Deserialize the JSON string into RequestWrapper
                objDbLog.Request__c = jsonBody;
                objReqWrp = (RequestWrapper) JSON.deserialize(jsonBody, RequestWrapper.class);
                if(objReqWrp.employeeData.size()>0)
                {
                    String professor = utility.Contact_RecType_Professor;
                    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(professor).getRecordTypeId();
                    for(EmployeeData objEmpData : objReqWrp.employeeData)
                    {
                        Contact objCon = new Contact();
                        objCon.Salutation = String.isNotBlank(objEmpData.Emp_Salutation) ? objEmpData.Emp_Salutation : Null;
                        objCon.FirstName = String.isNotBlank(objEmpData.Emp_FirstName) ? objEmpData.Emp_FirstName : Null;
                        objCon.MiddleName = String.isNotBlank(objEmpData.Emp_MiddleName) ? objEmpData.Emp_MiddleName : Null;
                        objCon.LastName = String.isNotBlank(objEmpData.Emp_LastName) ? objEmpData.Emp_LastName : Null;
                        objCon.Employee_Number__c = String.isNotBlank(objEmpData.Emp_Number) ? objEmpData.Emp_Number : Null;
                        objCon.Account = String.isNotBlank(objEmpData.Emp_Department) ? new Account(SLCM_HCM_ID__c = objEmpData.Emp_Department) : Null; 
                        objCon.ReportsTo = String.isNotBlank(objEmpData.Emp_ReportingMngr) ? new Contact(Employee_Number__c = objEmpData.Emp_ReportingMngr) : Null; 
                        objCon.Employment_Type__c = String.isNotBlank(objEmpData.Emp_EmploymentType) ? objEmpData.Emp_EmploymentType : Null;
                        objCon.Work_Location__c = String.isNotBlank(objEmpData.Emp_WorkLocation) ? objEmpData.Emp_WorkLocation : Null;
                        objCon.Designation__c = String.isNotBlank(objEmpData.Emp_Designation) ? objEmpData.Emp_Designation : Null;
                        objCon.hed__WorkEmail__c = String.isNotBlank(objEmpData.Emp_OfficialEmail) ? objEmpData.Emp_OfficialEmail : Null;
                        objCon.MobilePhone = String.isNotBlank(objEmpData.Emp_Mobile) ? objEmpData.Emp_Mobile : Null;
                        objCon.Email = String.isNotBlank(objEmpData.Emp_PersonalEmail) ? objEmpData.Emp_PersonalEmail : Null;
                        objCon.Date_of_Joining__c = String.isNotBlank(objEmpData.Emp_DateofJoining) ? Date.valueOf(objEmpData.Emp_DateofJoining) : Null;
                        objCon.Birthdate = String.isNotBlank(objEmpData.Emp_RecordDateofBirth) ? Date.valueOf(objEmpData.Emp_RecordDateofBirth) : Null;
                        objCon.Aadhar_Card_Number__c = String.isNotBlank(objEmpData.Emp_AadharCardNumber) ? objEmpData.Emp_AadharCardNumber : Null;
                        objCon.hed__Gender__c = String.isNotBlank(objEmpData.Emp_Gender) ? objEmpData.Emp_Gender : Null;
                        objCon.Blood_Group__c = String.isNotBlank(objEmpData.Emp_BloodGroup) ? objEmpData.Emp_BloodGroup : Null;
                        if(objEmpData.Emp_Active != Null)
                            objCon.Active__c = objEmpData.Emp_Active;
                        objCon.RecordTypeId = recordTypeId;
                        lstContact.add(objCon);
                    }
                    Integer successCount = 0;
                    Integer errorCount = 0;
                    String status = '';
                    List<resultWpr> list_resultWpr = new List<resultWpr>();
                    if(lstContact.size() > 0)
                    {
                        Database.UpsertResult[] result = Database.upsert(lstContact, Contact.Employee_Number__c, false);
                        system.debug('=====>>>'+result);
                        for(Integer i=0;i<result.size();i++)
                        {
                            if(result[i].isSuccess())
                            {
                                successCount++;
                                resultWpr rw = new resultWpr();
                                rw.status = 'Success';
                                rw.empNumber = lstContact[i].Employee_Number__c;
                                rw.error = '';
                                list_resultWpr.add(rw);
                            }
                            else
                            {
                                errorCount++;
                                resultWpr rw = new resultWpr();
                                rw.status = 'Failure';
                                rw.empNumber = lstContact[i].Employee_Number__c;
                                rw.error = result[i].getErrors()[0].getMessage();
                                list_resultWpr.add(rw);
                            }
                        }
                        objrespWrp.result = list_resultWpr;
                        if(successCount == lstContact.size())
                        {
                            status = 'Success';
                        }
                        else if(successCount > 0 && errorCount > 0)
                        {
                            status = 'Partial Success';
                        }
                        else
                        {
                            status = 'Failure';
                        }
                        objrespWrp.status = status;
                        objrespWrp.message = '';
                        objDbLog.Status__c = status;
                    }
                }
                else
                {
                    objrespWrp.Status = 'Failure';
                    objrespWrp.message = 'Error - Professor Data is Empty';
                    objDbLog.Error_Message__c = 'Professor Data is Empty';
                }
            }
            else
            {
                objrespWrp.Status = 'Failure';
                objrespWrp.message = 'Error - Professor Data is Empty';
                objDbLog.Error_Message__c = 'Professor Data is Empty';
            }
            update objDbLog;
        }
        Catch(Exception ex)
        {
            objrespWrp.Status = 'Failure';
            objrespWrp.message = 'Error - '+ex.getMessage();
            objDbLog.Response__c = 'Failure - '+ex.getMessage();
            update objDbLog;
        }
        objRestResponse.addHeader('Content-Type', 'application/json');
        objRestResponse.responseBody = Blob.valueof(Json.serialize(objrespWrp));
    }
    
    global class RequestWrapper
    {
        public List<EmployeeData> employeeData;
    }
    
    global class EmployeeData
    {
        public String Emp_Salutation;
        public String Emp_FirstName;
        public String Emp_MiddleName;
        public String Emp_LastName;
        public String Emp_Number;
        public String Emp_Department;
        public String Emp_ReportingMngr;
        public String Emp_EmploymentType;
        public String Emp_WorkLocation;
        public String Emp_Designation;
        public String Emp_OfficialEmail;
        public String Emp_Mobile;
        public String Emp_PersonalEmail;
        public String Emp_DateofJoining;
        public String Emp_RecordDateofBirth;
        public String Emp_AadharCardNumber;
        public String Emp_Gender;
        public String Emp_BloodGroup;
        public Boolean Emp_Active;
    }

     //Wrapper classes for Response Json
    global class responseWrapper
    {
        public String status;
        public String message;
        public List<resultWpr> result;
    }
    
    public class resultWpr{
        public String status;
        public String empNumber;
        public String error;
    }
    
}