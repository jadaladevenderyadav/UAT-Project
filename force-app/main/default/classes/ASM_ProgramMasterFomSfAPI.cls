public class ASM_ProgramMasterFomSfAPI {
    
     @InvocableMethod
    public static void sendProgramDetails_future(list<Id> ProgramBatchIds){
        Debug_Log__c dLog = sendProgramDetails(ProgramBatchIds);
        Insert dLog;
    }
    
     public static Debug_Log__c sendProgramDetails(list<Id>ProgramBatchIds){
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_ProgramMasterFomSfAPI';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Program Master Data to Logisys';
        dLog.Object_Name__c = 'hed__Program_Plan__c';
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        try{
            
           System.debug('ProgramBatchIds=> '+ProgramBatchIds);

           List<hed__Program_Plan__c>AllProgramList = [SELECT Id, Name, Program_Batch_Name__c, hed__Account__r.Name,
                                                       (SELECT Id, Term_Number__c FROM Terms__r where Active__c=true) FROM hed__Program_Plan__c WHERE Id IN:ProgramBatchIds];
            
           System.debug('AllProgramList=> '+AllProgramList.size());

           List<hed__Plan_Requirement__c>Syllabuslist = [SELECT id,name,Semester__r.name,Semester__r.Term_Number__c,Semester__r.Program_Batch__r.Program_Batch_Name__c,
           Semester__r.Program_Batch__r.hed__Account__r.name,Semester__c from hed__Plan_Requirement__c  where Semester__r.Active__c
           = true AND Semester__r.Program_Batch__c IN:ProgramBatchIds];

           Map<Id,Integer>SemesterWithSyllabus = new Map<Id,Integer>();

           if(Syllabuslist.size()>0)
           {
            for(hed__Plan_Requirement__c Syllabus : Syllabuslist)
            {
              if(!SemesterWithSyllabus.containskey(Syllabus.Semester__c))
              {
                SemesterWithSyllabus.put(Syllabus.Semester__c,1);
              }
              else{
                SemesterWithSyllabus.put(Syllabus.Semester__c,SemesterWithSyllabus.get(Syllabus.Semester__c)+1);
              }
            }
           }

           System.debug('SemesterWithSyllabus=> '+SemesterWithSyllabus);


           list<reqWpr>Reqlist = new list<reqWpr>();
           if(Syllabuslist.size()>0)
           {
            for(hed__Program_Plan__c ProgramBatch : AllProgramList)
            {
                System.debug('ProgramBatch.Terms__r[0].Id=> '+ProgramBatch.Terms__r[0].Id);
                reqWpr APIBody = new reqWpr();
                APIBody.degcode = ProgramBatch.Program_Batch_Name__c;
                APIBody.degname = ProgramBatch.hed__Account__r.Name;
                APIBody.sem = String.valueOf(ProgramBatch.Terms__r[0].Term_Number__c);
                APIBody.totsub = String.valueOf(SemesterWithSyllabus.get(ProgramBatch.Terms__r[0].Id));
                APIBody.rtype = 'I';
                Reqlist.add(APIBody);
            }
           }

           String JsonBody = JSON.serialize(Reqlist);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);

            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_ProgramMasterFomSfAPI',jsonBody);
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
        public String sem;
        public String degname;
        public String degcode;
        public String rtype;
        public String totsub;
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