/*********************************************
* TThis class to generate Json for Student Subject Data
* And it'll send the same to Logisys API
* It's called from:
* ********************************************/
public class ASM_StdSubjectAPI {
    @future(callout=true)
    public static void sendStdSubject_future(Set<Id> set_CConIds, String reqType){
        Debug_Log__c dLog = sendStdSubject(set_CConIds,reqType);
        Insert dLog;
    }
    
    public static Debug_Log__c sendStdSubject(Set<Id> set_CConIds, String reqType){
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_StdSubjectAPI';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Student Subject Data to Logisys';
        dLog.Object_Name__c = 'hed__Course_Enrollment__c';
        dLog.No_of_Records__c = set_CConIds.size();
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        
        try{
            Map<String,hed__Course_Enrollment__c> map_CCons = new Map<String,hed__Course_Enrollment__c>();
            List<reqWpr> list_reqWpr = new List<reqWpr>();
            for(hed__Course_Enrollment__c con : [SELECT Id,SRN_Number__c,Program_Code__c,Program__c,Course_Code__c,
                                                 Section__c,Section__r.hed__Parent_Term__c,Section__r.hed__Parent_Term__r.Name,
                                                 hed__Contact__r.Program_Batch__r.Program_Batch_Name__c, 
                                                 Section__r.hed__Parent_Term__r.Term_Number__c,School__c, Semester_Number__c,
                                                 hed__Course_Offering__c,hed__Course_Offering__r.hed__Course__r.Name
                                                 FROM hed__Course_Enrollment__c WHERE Id IN: set_CConIds])
            {
                map_CCons.put(con.Id,con);
                reqWpr rWp = new reqWpr();
                rWp.regno = String.isNotBlank(con.SRN_Number__c) ? con.SRN_Number__c : '';
                rWp.degcode = String.isNotBlank(con.hed__Contact__r.Program_Batch__r.Program_Batch_Name__c) ? con.hed__Contact__r.Program_Batch__r.Program_Batch_Name__c : '';
                rWp.degname = String.isNotBlank(con.Program__c) ? con.Program__c : '';
                rWp.sem = (con.Section__c != null && con.Semester_Number__c != null) ? String.valueof(con.Semester_Number__c) : '';
                rWp.subcode = String.isNotBlank(con.Course_Code__c) ? con.Course_Code__c : '';
                rWp.subname = (con.hed__Course_Offering__c != null) ? con.hed__Course_Offering__r.hed__Course__r.Name : '';
                rWp.rtype = reqType;
                rWp.collname = con.School__c;
                rWp.collcode = con.School__c;
                rWp.logisysextid = con.Id;
                list_reqWpr.add(rWp);   
            }
            
            String jsonBody = json.serialize(list_reqWpr);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
            
            //Map Http Request
            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_StdSubjectAPI',jsonBody);
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            
            String response = hRsp+' ::: '+hRsp.getBody();
            dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
            if(hRsp.getStatusCode() == 200){
                String resBody = hRsp.getBody();
                rspWpr rsp = (rspWpr) Json.deserialize(resBody, rspWpr.class);
                if(reqType == 'I' || reqType == 'D'){
                    for(resdata rwp : rsp.data.resdata){
                        if(map_CCons.get(rwp.logisysextid) != null){
                            map_CCons.get(rwp.logisysextid).Logisys_Integration__c = (rwp.status == 'T') ? 'Yes' : 'No';
                        }
                    }
                    Update map_CCons.values();
                }
                dLog.Status__c = rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
            }
        }catch(exception e){
            System.debug('@@==>> Exception: '+e.getMessage()+'. At: '+e.getStackTraceString());
            dLog.Error_Message__c = e.getMessage()+'. At: '+e.getStackTraceString();
        }
        return dLog;
    }
    
    public class reqWpr{
        public String regno;
        public String degcode;
        public String degname;
        public String sem;
        public String subcode;
        public String subname;
        public String rtype;
        public String collcode;
        public String collname;
        public String logisysextid;
    }
    
    public class rspWpr{
        public String status;
        public dataWpr data;
        public Integer error_code;
    }
    
    public class resdata{
        public String status{get;set;}
        public String msg{get;set;}
        public String logisysextid{get;set;}
    }
    public class dataWpr{
        public list<resdata> resdata{get;set;}
    }
}