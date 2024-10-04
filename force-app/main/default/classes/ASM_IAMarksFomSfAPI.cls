/*********************************************
* TThis class to generate Json for IA Marks Data
* And it'll send the same to Logisys API
* It's called from:
* ********************************************/
public class ASM_IAMarksFomSfAPI {
    @future(callout=true)
    public static void sendIAMarks_future(Set<Id> set_IamIds, String reqType){
        Debug_Log__c dLog = sendIAMarks(set_IamIds,reqType);
        Insert dLog;
    }
    
    public static Debug_Log__c sendIAMarks(Set<Id> set_IamIds, String reqType){
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_IAMarksFomSfAPI';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'IA Marks Data to Logisys';
        dLog.Object_Name__c = 'IA_Marks__c';
        dLog.No_of_Records__c = set_IamIds.size();
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        
        try{
            Map<String,IA_Marks__c> map_IAMarks = new Map<String,IA_Marks__c>();
            Map<Id,Decimal>IAWithCourseConnection = new Map<Id,Decimal>();
            Map<Id, IA_Marks__c> iaMarksByCourseConnection = new Map<Id,IA_Marks__c>();

            List<reqWpr> list_reqWpr = new List<reqWpr>();
            for(IA_Marks__c iam : [SELECT Id,SRN_Number__c,Program_Code__c,Program__c,Course_Code__c,IA_Type__c,Course_Connection__c,
                                   Course_Name__c,Course_Type__c,Semester__r.Program_Batch__r.Program_Batch_Name__c, 
                                   Theory_Secured_Marks__c,Seminar_Secured_Marks__c,Quiz_Secured_marks__c,
                                   Analysis_and_Synthesis_Secured_Marks__c,Continuous_Learning_Secured_Marks__c,
                                   Ethical_Attitude_Secured_Marks__c,Independent_Learning_Secured_Marks__c,
                                   Literature_Survey_Secured_Marks__c,Selection_of_Topic_Secured_Marks__c,
                                   Oral_Presentation_Secured_Marks__c,Report_Writing_Secured_Marks__c,
                                   Knowledge_of_Exercise_Secured_Marks__c,Execution_of_Exercise_Secured_Marks__c,
                                   Description_of_Experiment_Secured_Mark__c,Viva_Voce_Practical_Secured_Marks__c,
                                   Punctuality_Secured_Marks__c,Results_Secured_Marks__c,
                                   School__c,Active_Semester_Number__c FROM IA_Marks__c
 WHERE Id IN: set_IamIds])
            {
                System.debug('IAMarks=> '+iam);
                
                //Theory Fields
                Decimal theoryMarks = iam.Theory_Secured_Marks__c != null ? iam.Theory_Secured_Marks__c : 0;
                Decimal quizMarks = iam.Quiz_Secured_marks__c != null ? iam.Quiz_Secured_marks__c : 0;
                Decimal seminarMarks = iam.Seminar_Secured_Marks__c != null ? iam.Seminar_Secured_Marks__c : 0;
                
                //Practical Fields
                Decimal knowledgeSecuredMarks =iam.Knowledge_of_Exercise_Secured_Marks__c!=null ?iam.Knowledge_of_Exercise_Secured_Marks__c:0;
                Decimal ExerciseSecuredMarks = iam.Execution_of_Exercise_Secured_Marks__c!=null ? iam.Execution_of_Exercise_Secured_Marks__c:0;
                Decimal DescriptionSecuredMarks =iam.Description_of_Experiment_Secured_Mark__c !=null?iam.Description_of_Experiment_Secured_Mark__c:0;
                Decimal VivaSecuredMarks = iam.Viva_Voce_Practical_Secured_Marks__c !=null?iam.Viva_Voce_Practical_Secured_Marks__c:0;
                Decimal PunctualitySecuredMarks = iam.Punctuality_Secured_Marks__c !=null?iam.Punctuality_Secured_Marks__c:0;
                Decimal ResultSecuredMarks = iam.Results_Secured_Marks__c !=null?iam.Results_Secured_Marks__c:0;
                
                //Project Fields
                Decimal TopicSecuredMarks =iam.Selection_of_Topic_Secured_Marks__c!=null ?iam.Selection_of_Topic_Secured_Marks__c:0;
                Decimal AnalysisSecuredMarks = iam.Analysis_and_Synthesis_Secured_Marks__c!=null ? iam.Analysis_and_Synthesis_Secured_Marks__c:0;
                Decimal LiteratureSecuredMarks =iam.Literature_Survey_Secured_Marks__c !=null?iam.Literature_Survey_Secured_Marks__c:0;
                Decimal EthicalSecuredMarks = iam.Ethical_Attitude_Secured_Marks__c !=null?iam.Ethical_Attitude_Secured_Marks__c:0;
                Decimal IndependentSecuredMarks = iam.Independent_Learning_Secured_Marks__c !=null?iam.Independent_Learning_Secured_Marks__c:0;
                Decimal OralSecuredMarks = iam.Oral_Presentation_Secured_Marks__c !=null?iam.Oral_Presentation_Secured_Marks__c:0;
                Decimal ReportSecuredMarks = iam.Report_Writing_Secured_Marks__c !=null?iam.Report_Writing_Secured_Marks__c:0;
                Decimal ContinuousSecuredMarks = iam.Continuous_Learning_Secured_Marks__c !=null?iam.Continuous_Learning_Secured_Marks__c:0;

                
                Decimal IAmarks=0;
                if(iam.Course_Type__c=='Theory'){
                IAmarks = theoryMarks + quizMarks + seminarMarks;
                }
                if(iam.Course_Type__c=='Practical'){
                 IAmarks = knowledgeSecuredMarks+ ExerciseSecuredMarks+ DescriptionSecuredMarks+ VivaSecuredMarks+ PunctualitySecuredMarks +ResultSecuredMarks;  
                }
                if(iam.Course_Type__c=='Project'){
                  IAmarks = TopicSecuredMarks+ AnalysisSecuredMarks+ LiteratureSecuredMarks+ EthicalSecuredMarks+ IndependentSecuredMarks+ OralSecuredMarks+ ReportSecuredMarks+ ContinuousSecuredMarks;  
                }
                
                System.debug('IAmarks=> '+IAmarks);
                
                if (!IAWithCourseConnection.containsKey(iam.Course_Connection__c)) {
                    IAWithCourseConnection.put(iam.Course_Connection__c, IAmarks);
                    iaMarksByCourseConnection.put(iam.Course_Connection__c,iam);
                } else {
                    IAWithCourseConnection.put(iam.Course_Connection__c, IAWithCourseConnection.get(iam.Course_Connection__c) + IAmarks);
                   // iaMarksByCourseConnection.get(iam.Course_Connection__c).add(iam);
                }
                String key = iam.SRN_Number__c+'_'+iam.Course_Code__c+'_'+iam.IA_Type__c;
                iam.Logisys_Integration__c = 'Yes';
                map_IAMarks.put(key,iam);
             
            }
            System.debug('iaMarksByCourseConnection=> '+iaMarksByCourseConnection);
            
             for (Id courseConnId : iaMarksByCourseConnection.keySet()) {
                    IA_Marks__c iam = iaMarksByCourseConnection.get(courseConnId);
                    reqWpr rWpr = new reqWpr();
                    rWpr.regno = String.isNotBlank(iam.SRN_Number__c) ? iam.SRN_Number__c : '';
                    rWpr.degcode = String.isNotBlank(iam.Semester__r.Program_Batch__r.Program_Batch_Name__c) ? iam.Semester__r.Program_Batch__r.Program_Batch_Name__c : '';
                    rWpr.degname = String.isNotBlank(iam.Program__c) ? iam.Program__c : '';
                    rWpr.sem = String.isNotBlank(String.valueOf(iam.Active_Semester_Number__c)) ? String.valueOf(iam.Active_Semester_Number__c) : '';
                    rWpr.collcode = String.isNotBlank(iam.School__c) ? iam.School__c : '';
                    rWpr.subcode = String.isNotBlank(iam.Course_Code__c) ? iam.Course_Code__c : '';
                    rWpr.subname = String.isNotBlank(iam.Course_Name__c) ? iam.Course_Name__c : '';
                    rWpr.rtype = reqType;
                    rWpr.marks = String.valueOf(IAWithCourseConnection.get(courseConnId)/2);

                    list_reqWpr.add(rWpr);
                
            }
            
            String jsonBody = Json.serialize(list_reqWpr);
            System.debug('JsonBody=> '+jsonBody);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
            
            //Map Http Request
            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_IAMarksFomSfAPI',jsonBody);
            
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
                        String key = rwp.regno+'_'+rwp.subcode+'_'+rwp.iatype;
                        //System.debug('key=='+key);
                        //System.debug('map_IAMarks=='+map_IAMarks.get(key));
                        if(rwp.status == 'F' && map_IAMarks.get(key) != null && map_IAMarks.get(key).Logisys_Integration__c == 'Yes'){
                            map_IAMarks.get(key).Logisys_Integration__c = 'No';
                        }
                    }
                    Update map_IAMarks.values();
                }
                dLog.Status__c = rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
            }
        }catch(exception e){
            //System.debug('@@==>> Exception: '+e.getMessage()+'. At: '+e.getStackTraceString());
            dLog.Error_Message__c = e.getMessage()+'. At: '+e.getStackTraceString();
        }
        return dLog;
    }
    
    public static reqWpr mapBaseParams(IA_Marks__c iam, String reqType, String subType, Decimal maxMarks, Decimal secMarks){
        reqWpr rWpr = new reqWpr();
        rWpr.regno = String.isNotBlank(iam.SRN_Number__c) ? iam.SRN_Number__c : '';
        rWpr.degcode = String.isNotBlank(iam.Program_Code__c) ? iam.Program_Code__c : '';
        rWpr.degname = String.isNotBlank(iam.Program__c) ? iam.Program__c : '';
        rWpr.sem = String.isNotBlank(iam.Course_Connection__r.Semester__c) ? iam.Course_Connection__r.Semester__c : '';
        rWpr.subcode = String.isNotBlank(iam.Course_Code__c) ? iam.Course_Code__c : '';
        rWpr.subname = String.isNotBlank(iam.Course_Name__c) ? iam.Course_Name__c : '';
        //rWpr.type = String.isNotBlank(iam.Course_Type__c) ? iam.Course_Type__c : '';
        rWpr.subtype = subType;
      //  rWpr.iatype = String.isNotBlank(iam.IA_Type__c) ? iam.IA_Type__c : '';
        rWpr.rtype = reqType;
        //rWpr.maxmarks = maxMarks;
        //rWpr.secmarks = secMarks;
        return rWpr;
    }
    
    public class reqWpr{
      
        public String subname;
        public String subcode;
        public String sem;
        public String subtype;
        public String degname;
        public String iatype;
        public String degcode;
        public String rtype;
        public String regno;
        public String collcode;
        public String marks;
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