public class ASM_CourseMasterFomSfAPI {
    @InvocableMethod
    public static void sendCourseDetails_future(list<Id> semesterIds){
        Debug_Log__c dLog = sendCourseDetails(semesterIds);
        Insert dLog;
    }	
    
    public static Debug_Log__c sendCourseDetails(list<Id>semesterIds){
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_CourseMasterFomSfAPI';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Course Master Data to Logisys';
        dLog.Object_Name__c = 'hed__Course__c';
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        try{
            
            System.debug('semesterIds=> '+semesterIds);
            
            List<hed__Plan_Requirement__c>syllabusList = [SELECT id ,name,hed__Course__r.rve_OldCourseCode__c,Semester__r.Program_Batch__r.Program_Batch_Name__c,
                                                        Semester__r.name,Semester__r.Term_Number__c, hed__Course__r.Name, 
                                                        hed__Course__r.hed__Course_ID__c, hed__Course__r.Credits__c,
                                                        hed__Course__r.L_T_P__c, hed__Course__r.HardCore_Sub_Type__c, 
                                                        hed__Course__r.Theory_Maximum_Marks__c, hed__Course__r.Seminar_Maximum_Marks__c,
                                                        hed__Course__r.Quiz_Maximum_Marks__c, hed__Course__r.Category__c from hed__Plan_Requirement__c  
                                                        WHERE Semester__c IN:semesterIds and hed__Course__c != null ];
            
            System.debug('syllabusList=> '+syllabusList.size());

            
            list<reqWpr>Reqlist = new list<reqWpr>();
            if(Syllabuslist.size()>0)
            {
                for(hed__Plan_Requirement__c slist : syllabusList)
                {
                    
                    reqWpr APIBody = new reqWpr();
                    APIBody.degcode = slist.Semester__r.Program_Batch__r.Program_Batch_Name__c;
                    APIBody.sem = String.valueOf(slist.Semester__r.Term_Number__c);
                    APIBody.subcode =slist.hed__Course__r.hed__Course_ID__c;
                    APIBody.subname =slist.hed__Course__r.Name;
                    APIBody.subshort=slist.hed__Course__r.Name;
                    APIBody.credit=String.valueOf(slist.hed__Course__r.Credits__c);
                    APIBody.ltp= String.valueOf(slist.hed__Course__r.L_T_P__c);
                    APIBody.subtype=slist.hed__Course__r.HardCore_Sub_Type__c;
                    APIBody.iamaxmarks=String.valueOf(slist.hed__Course__r.Theory_Maximum_Marks__c + slist.hed__Course__r.Seminar_Maximum_Marks__c + slist.hed__Course__r.Quiz_Maximum_Marks__c);
                    APIBody.oldsubcode=slist.hed__Course__r.rve_OldCourseCode__c;
                    APIBody.category=slist.hed__Course__r.Category__c;
                    APIBody.rtype = 'I';
                    Reqlist.add(APIBody);
                }
            }
            
            String JsonBody = JSON.serialize(Reqlist);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
            
            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_CourseMasterFomSfAPI',jsonBody);
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            
            String response = hRsp+' ::: '+hRsp.getBody();
            dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
            
            if(hRsp.getStatusCode() == 200){
                String resBody = hRsp.getBody();
                rspWpr rsp = (rspWpr) Json.deserialize(resBody, rspWpr.class);
                
                
                System.debug('ResponseCode=> '+hRsp.getstatuscode());
                System.debug('ResponseBody=> '+hRsp.getBody());
                dLog.Status__c = rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
            }
            
        }
        catch(Exception e)
        {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
        }
        return dLog;
    }
    
    public class reqWpr{
        
        public String degcode;
        public String sem;
        public String subcode;
        public String subname;
        public string subshort;
        public string credit;
        public string ltp;
        public string subtype;
        public string iamaxmarks;
        public string oldsubcode;
        public string category;
        public String rtype;
  
    }
    
    public class rspWpr{
        public String status;
        public dataWpr data;
        public Integer error_code;
    }
    
    public class resdata{
        public String status{get;set;}
        public String msg{get;set;}
        public String regno;
        public String degcode;
        public String subcode;
        public String iatype;
    }
    public class dataWpr{
        public list<resdata> resdata{get;set;}
    }
}