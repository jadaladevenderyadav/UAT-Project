public class ASM_IAMarksEntry {
    @AuraEnabled
    public static dataWpr fetchData(String prfConId, String iaType){
        dataWpr dWpr = new dataWpr();
        hed__Course_Enrollment__c prfCon = [SELECT Id,hed__Course_Offering__c,Section__c,Section__r.Name,
                                            hed__Course_Offering__r.hed__Course__r.Name,
                                            hed__Course_Offering__r.hed__Course__c,External_Id__c,
                                            hed__Course_Offering__r.hed__Course__r.Seminar_Maximum_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Quiz_Maximum_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Theory_Maximum_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Analysis_and_Synthesis_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Literature_Survey_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Ethical_Attitude_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Independent_Learning_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Oral_Presentation_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Report_Writing_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Continuous_Learning_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Selection_of_Topic_Max_marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Knowledge_of_Exercise_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Execution_of_Exercise_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Description_of_Experiment_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Viva_Voce_Practical_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Punctuality_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Results_Max_Marks__c,
                                            hed__Course_Offering__r.hed__Course__r.Maximum_Internal_Marks__c,
                                            Course_Offering_Section_ID__c
                                            FROM hed__Course_Enrollment__c WHERE Id =: prfConId];
        dWpr.mainCrsConn = prfCon;
        dWpr.list_marksWpr = new List<marksWpr>();
        Set<Id> set_CConIds = new Set<Id>();
        for(hed__Course_Enrollment__c con : [SELECT Id,Name,hed__Contact__c,hed__Contact__r.Name,hed__Course_Offering__c,
                                             Course_Offering_Section_ID__c,
                                             hed__Contact__r.SRN_Number__c,hed__Program_Enrollment__r.Semester__c,
                                             hed__Course_Offering__r.hed__Course__c,External_Id__c,
                                             hed__Course_Offering__r.hed__Course__r.Seminar_Maximum_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Quiz_Maximum_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Theory_Maximum_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Analysis_and_Synthesis_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Literature_Survey_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Ethical_Attitude_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Independent_Learning_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Oral_Presentation_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Report_Writing_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Continuous_Learning_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Selection_of_Topic_Max_marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Knowledge_of_Exercise_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Execution_of_Exercise_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Description_of_Experiment_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Viva_Voce_Practical_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Punctuality_Max_Marks__c,
                                             hed__Course_Offering__r.hed__Course__r.Results_Max_Marks__c
                                             FROM hed__Course_Enrollment__c WHERE 
                                             hed__Course_Offering__c =: prfCon.hed__Course_Offering__c
                                             AND Section__c =: prfCon.Section__c 
                                             AND RecordType.Name = 'Student' ORDER BY hed__Contact__r.SRN_Number__c ASC])
        {
            marksWpr mWpr = new marksWpr();
            mWpr.crsConn = con;
            String extId = con.External_Id__c+'_'+iaType;             
            mWpr.iaMark = new IA_Marks__c(Course_Connection__c=con.Id,Course_Offering__c=con.Course_Offering_Section_ID__c,External_ID__c=extId,IA_Type__c=iaType,Semester__c=con.hed__Program_Enrollment__r.Semester__c,Faculty_Course_Connection__c=prfCon.Id,ownerid=userinfo.getUserId());
             
            dWpr.list_marksWpr.add(mWpr);
            set_CConIds.add(con.Id);
        }
        Map<Id,IA_Marks__c> map_IaMarks = new Map<Id,IA_Marks__c>();
        for(IA_Marks__c iam : [SELECT Id,Theory_Secured_Marks__c,Seminar_Secured_Marks__c,Quiz_Secured_marks__c,
                               Analysis_and_Synthesis_Secured_Marks__c,Continuous_Learning_Secured_Marks__c,
                               Ethical_Attitude_Secured_Marks__c,Independent_Learning_Secured_Marks__c,
                               Literature_Survey_Secured_Marks__c,Selection_of_Topic_Secured_Marks__c,
                               Oral_Presentation_Secured_Marks__c,Report_Writing_Secured_Marks__c,
                               Knowledge_of_Exercise_Secured_Marks__c,Execution_of_Exercise_Secured_Marks__c,
                               Description_of_Experiment_Secured_Mark__c,Viva_Voce_Practical_Secured_Marks__c,
                               Punctuality_Secured_Marks__c,Results_Secured_Marks__c,Faculty_Course_Connection__c,
                               Course_Connection__c, Course_Offering__c FROM IA_Marks__c 
                               WHERE Course_Connection__c IN: set_CConIds AND IA_Type__c =: iaType])
        {
            iam.OwnerId = Userinfo.getUserId();
            iam.Faculty_Course_Connection__c = prfConId;
            map_IaMarks.put(iam.Course_Connection__c,iam);
        }
        if(!map_IaMarks.isEmpty()){
            for(marksWpr mWpr : dWpr.list_marksWpr){
                if(map_IaMarks.get(mWpr.crsConn.Id) != null){
                    mWpr.iaMark = map_IaMarks.get(mWpr.crsConn.Id);
                }
            }
        }
        return dWpr;
    }
    
    @AuraEnabled
    public static void saveData(List<IA_Marks__c> list_IaMarks)
    {        
        set<Id> set_CourseConnectIds = new set<Id>();
        set<Id> set_ContactIds = new set<Id>();
        set<Id> set_MntrIds = new set<Id>();
        set<string> set_EmplyNum = new set<string>();
        set<Id> set_MenteeIds = new set<Id>();
        Id mntRecTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('Mentee').getRecordTypeId();
        List<IA_Marks__Share> list_ShareIAMarks = new List<IA_Marks__Share>();
        
        try{
            Upsert list_IaMarks;
            
            if(!list_IaMarks.IsEmpty())
            {
                for(IA_Marks__c objIAMarks : list_IaMarks)
                {
                    if(objIAMarks.Course_Connection__c != null)
                    {
                        set_CourseConnectIds.add(objIAMarks.Course_Connection__c);
                    }
                }                
                
                for(hed__Course_Enrollment__c objCourseConnection : [select Id,Name,hed__Contact__c from hed__Course_Enrollment__c where Id IN : set_CourseConnectIds])
                {
                    set_ContactIds.add(objCourseConnection.hed__Contact__c);
                }                
                for(Case objCase : [select Id,ContactId,RecordTypeId,Mentor__c from Case where RecordTypeId =: mntRecTypeId and ContactId IN: set_ContactIds ])        {
                    if(string.IsNotBlank(objCase.Mentor__c))  set_MntrIds.add(objCase.Mentor__c);  
                }                
                for(Contact objCon : [select Id,Name,Employee_Number__c from Contact where Id In :set_MntrIds]) {
                    if(string.IsNotBlank(objCon.Employee_Number__c)) set_EmplyNum.add(objCon.Employee_Number__c);   
                }                
                for(User objUsrMentor: [select Id,Name,EmployeeNumber from User where IsActive = True AND EmployeeNumber IN: set_EmplyNum]) {
                    set_MenteeIds.add(objUsrMentor.Id);  
                }               
              //  system.debug('====set_MenteeIds'+set_MenteeIds);
                if(set_MenteeIds.size() > 0)
                {
                    for(IA_Marks__c objIAMarksshr : list_IaMarks)
                    {
                        for(Id strId : set_MenteeIds)
                        {
                            if(objIAMarksshr.OwnerId != strId)
                            {
                                IA_Marks__Share objShrMrks = new IA_Marks__Share();
                                objShrMrks.ParentId = objIAMarksshr.Id;
                                objShrMrks.UserOrGroupId = strId;
                                objShrMrks.AccessLevel = 'Edit';
                                list_ShareIAMarks.add(objShrMrks);
                            }
                        }
                    } 
                }
                
                if(!list_ShareIAMarks.IsEmpty())
                {
                    try { 
                         if(!Test.isRunningTest())  insert list_ShareIAMarks;                   
                    }
                    catch(exception e) {
                        system.debug('====>>>'+e.getMessage()+'. At: '+e.getStackTraceString());
                        throw new AuraHandledException(e.getMessage()+'. At: '+e.getStackTraceString());
                    }
                }                
            }
        }catch(exception e){
            system.debug('====>>>'+e.getMessage()+'. At: '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'. At: '+e.getStackTraceString());
        }
    }
    public class dataWpr{
        @AuraEnabled public hed__Course_Enrollment__c mainCrsConn{get;set;}
        @AuraEnabled public List<marksWpr> list_marksWpr{get;set;}
    }
    
    public class marksWpr{
        @AuraEnabled public hed__Course_Enrollment__c crsConn{get;set;}
        @AuraEnabled public IA_Marks__c iaMark{get;set;}
        @AuraEnabled public Decimal total{get;set;}
    }
}