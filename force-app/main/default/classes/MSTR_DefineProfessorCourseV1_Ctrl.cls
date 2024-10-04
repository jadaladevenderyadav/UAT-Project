public with sharing class MSTR_DefineProfessorCourseV1_Ctrl 
{
    @AuraEnabled
    public static SchoolWrapper DisplaySchools()
    {
        SchoolWrapper schWrap = new SchoolWrapper();
        string AccSchoolName;
        User usr =[select Id,Name,ContactId from User where Id =:userinfo.getUserId()];
        if(usr.Id != null)
        {
            for(Contact objCon : [select Id,LastName,OwnerId,Accountid,Account.Name,Account.RecordType.Name,Professor_Across_Schools__c 
                                  from Contact Where OwnerId =: usr.Id and 
                                  Account.RecordType.Name =: Utility.Acc_RecType_University_Department])
            {
                if(objCon.Professor_Across_Schools__c == true)
                {
                    schWrap.ProfSchool = true;
                    schWrap.Map_AccSchool.put(objCon.AccountId,objCon.Account.Name);
                    AccSchoolName = objCon.Account.Name;
                    schWrap.LoginUserAccountName = objCon.Account.Name;
                }
                else
                {
                    schWrap.Map_AccSchool.put(objCon.AccountId,objCon.Account.Name); 
                    schWrap.LoginUserAccountName = objCon.Account.Name;
                }
            }
            if(schWrap.ProfSchool == true)
            {
                list<hed__Course_Offering__c> lst_courseoff = new list<hed__Course_Offering__c>();
                lst_courseoff = [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Course_Across_the_School__c,School__c,School_ID__c,hed__Course__r.Name,Credits__c,hed__Term__c,Offered_By_School__c,Offered_By_School__r.Name,
                                 hed__Term__r.Active__c,Approval_Required_by_School_Head__c from hed__Course_Offering__c where
                                 hed__Term__r.Active__c =:true and hed__Course__r.Course_Across_the_School__c=: true order by Sequence__c];
                for(hed__Course_Offering__c objCourseOff : lst_courseoff )
                { 
                    if(objCourseOff.Offered_By_School__r.Name == AccSchoolName)
                    {
                        schWrap.Map_AccSchool.put(objCourseOff.School_ID__c,objCourseOff.School__c);
                        schWrap.CourseAcross = objCourseOff.hed__Course__r.Course_Across_the_School__c;
                    }
                }
            }
        }
        return schWrap;
    }
    @AuraEnabled
    public static Map<Id,String> DisplayProgram(String AccSchoolId,boolean SelCourseAcross,string LoginAccountName)
    {
        Map<Id,String> Map_AccProgram = new Map<Id,String>();
        SchoolWrapper schWrap = new SchoolWrapper();   
        
        if(SelCourseAcross == true)
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,hed__Course__c,hed__Course__r.Course_Across_the_School__c,hed__Course__r.Name,hed__Term__c,Offered_By_School__c,School_ID__c,
                                                        Offered_By_School__r.Name,hed__Term__r.Active__c,Approval_Required_by_School_Head__c,Program__c,hed__Term__r.Program_Batch__c,
                                                        hed__Term__r.Program_Batch__r.hed__Account__c,hed__Term__r.Program_Batch__r.hed__Account__r.RecordType.Name,hed__Term__r.Program_Batch__r.hed__Account__r.Name
                                                        from hed__Course_Offering__c where Offered_By_School__r.Name =: LoginAccountName and hed__Term__r.Active__c =:true and School_ID__c=:String.valueOf(AccSchoolId).substring(0, 15)
                                                        and hed__Term__r.Program_Batch__r.hed__Account__r.RecordType.Name =: Utility.Acc_RecType_Academic_Program order by Sequence__c])
            {                
                //if(objCourseOff.Offered_By_School__r.Name ==AccSchoolId)
                Map_AccProgram.put(objCourseOff.hed__Term__r.Program_Batch__r.hed__Account__c,objCourseOff.hed__Term__r.Program_Batch__r.hed__Account__r.Name);
            }
        }
        else
        {
            for(Account objAcc : [select Id,Name,RecordType.Name,Parentid,Sequence__c from Account Where 
                                  RecordType.Name = :Utility.Acc_RecType_Academic_Program and Parentid =:AccSchoolId order by Sequence__c]) 
            {
                Map_AccProgram.put(objAcc.Id,objAcc.Name);
            } 
        }
        return Map_AccProgram;
    }
    @AuraEnabled
    public static Map<Id,String> DisplayProgramPlan(string AccProgramId,boolean SelCourseAcross,string LoginAccountName)
    {
        Map<Id,String> Map_AccProgramPlan = new Map<Id,String>();
        set<id> set_progBatchid =new set<id>();
        
        if(SelCourseAcross == true)
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,hed__Course__c,hed__Course__r.Course_Across_the_School__c,hed__Course__r.Name,hed__Term__c,Offered_By_School__c,
                                                        Offered_By_School__r.Name,hed__Term__r.Active__c,Approval_Required_by_School_Head__c,Program__c,hed__Term__r.Program_Batch__c,hed__Term__r.Program_Batch__r.hed__Start_Date__c,
                                                        hed__Term__r.Program_Batch__r.hed__Account__c,hed__Term__r.Program_Batch__r.Name,hed__Term__r.hed__Account__c,Program_batch_ID__c,hed__Term__r.Program_Batch__r.hed__End_Date__c
                                                        from hed__Course_Offering__c where hed__Term__r.Program_Batch__r.hed__Account__c =: AccProgramId and  Offered_By_School__r.Name =:LoginAccountName
                                                        and hed__Term__r.Active__c =:true order by hed__Term__r.Program_Batch__r.hed__Start_Date__c])
            {  
                set_progBatchid.add(objCourseOff.hed__Term__r.Program_Batch__c);
                // Map_AccProgramPlan.put(objCourseOff.hed__Term__r.Program_Batch__c,objCourseOff.hed__Term__r.Program_Batch__r.Name);
            }           
            if(set_progBatchid.size()>0)
            {
                for(hed__Course_Offering__c objCourseOff : [select Id,Name,hed__Course__c,hed__Course__r.Course_Across_the_School__c,hed__Course__r.Name,hed__Term__c,Offered_By_School__c,
                                                            Offered_By_School__r.Name,hed__Term__r.Active__c,Approval_Required_by_School_Head__c,Program__c,hed__Term__r.Program_Batch__c,hed__Term__r.Program_Batch__r.hed__Start_Date__c,
                                                            hed__Term__r.Program_Batch__r.hed__Account__c,hed__Term__r.Program_Batch__r.Name,hed__Term__r.hed__Account__c,Program_batch_ID__c,hed__Term__r.Program_Batch__r.hed__End_Date__c
                                                            from hed__Course_Offering__c where Program_batch_ID__c in: set_progBatchid and
                                                            hed__Term__r.Active__c =:true order by hed__Term__r.Program_Batch__r.hed__Start_Date__c])
                {
                    Map_AccProgramPlan.put(objCourseOff.hed__Term__r.Program_Batch__c,objCourseOff.hed__Term__r.Program_Batch__r.Name);
                }
            }
        }
        else
        {
            for(hed__Program_Plan__c objProgramPlan : [select Id,Name,hed__Account__c,hed__Start_Date__c from hed__Program_Plan__c where 
                                                       hed__Account__c =:AccProgramId and Active__c =: true order by hed__Start_Date__c]) 
            {
                Map_AccProgramPlan.put(objProgramPlan.Id,objProgramPlan.Name);
            }   
        }
        return Map_AccProgramPlan;
    }
    @AuraEnabled
    public static Map<Id,String> DisplayTerm(string AccProgramPlanId,boolean SelCourseAcross,string LoginAccountName)
    {
        Map<Id,String> Map_AccTerm = new Map<Id,String>();
        SchoolWrapper schWrap = new SchoolWrapper();  
        if(SelCourseAcross == true)
        {
            set<id>  set_Termid = new set<id>();
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,hed__Course__c,hed__Course__r.Course_Across_the_School__c,hed__Course__r.Name,hed__Term__c,Offered_By_School__c,hed__Term__r.Name,
                                                        Offered_By_School__r.Name,hed__Term__r.Active__c,Approval_Required_by_School_Head__c,Program__c,hed__Term__r.Program_Batch__c,
                                                        hed__Term__r.Program_Batch__r.hed__Account__c,hed__Term__r.Program_Batch__r.Name,hed__Term__r.RecordType.Name,hed__Term__r.Approval_Status__c
                                                        from hed__Course_Offering__c where hed__Term__r.Program_Batch__c =: AccProgramPlanId and hed__Term__r.RecordType.Name =:Utility.Term_Object_RecType_Term and 
                                                        hed__Term__r.Active__c =:true and hed__Term__r.Approval_Status__c=:'Confirmed' and hed__Course__r.Course_Across_the_School__c =: true
                                                        and Offered_By_School__r.Name =: LoginAccountName order by hed__Term__r.Name])
            {  
                Map_AccTerm.put(objCourseOff.hed__Term__c,objCourseOff.hed__Term__r.Name);
                
            } 
        }
        else
        {
            
            for(hed__Term__c objTerm : [select Id,Name,hed__Account__c,Program_Batch__c,RecordType.Name,Active__c,Approval_Status__c from hed__Term__c where
                                        Program_Batch__c =:AccProgramPlanId and RecordType.Name=:Utility.Term_Object_RecType_Term and Active__c=true and Approval_Status__c=:'Confirmed' order by Name])
            {
                Map_AccTerm.put(objTerm.Id,objTerm.Name);
            }
        }
        return Map_AccTerm;
    }
    
    @AuraEnabled
    public static CourseOfferingWrapper DisplayCourseOfferingRecords(string AccTermId,boolean SelCourseAcross,string LoginAccountName,string AccSchoolId)
    {
        CourseOfferingWrapper WrapCourseOff = new CourseOfferingWrapper(); 
        set<id> set_courseId  = new set<id>();
        set<string> set_accid = new set<string>();
        set<string> set_Category = new set<string>();
        if(AccSchoolId != null)
        {
            for(Account objAcc : [select Id,Name,RecordType.Name,Parentid,Sequence__c,Parent.Name from Account Where 
                                  RecordType.Name = :Utility.Acc_RecType_Academic_Program and Parentid =:AccSchoolId order by Sequence__c]) 
            {
                if(objAcc.Parent.Name == LoginAccountName)
                    set_accid.add(objAcc.Parent.Name);
            }
        }
        list<hed__Course_Offering__c> lst_CourseOffering = new list<hed__Course_Offering__c>();
        map<id,Professor_Student_Course_Preference__c> map_profstudent= new map<id,Professor_Student_Course_Preference__c>();
        User usr =[select Id,Name,ContactId from User where Id =:userinfo.getUserId()];
        if(usr.Id != null)
        {
            Contact objCon =[select Id,OwnerId,Account.RecordType.Name from Contact Where OwnerId =: usr.Id and Account.RecordType.Name =: Utility.Acc_RecType_University_Department];
            
            
            for(Professor_Student_Course_Preference__c objProfStu : [select Id,Name,Contact__c,Course_Offering__c,Preference__c,Professor__c,
                                                                     Professor_Preference__c,Semester__c,Course_Offering__r.Category__c,Course_ID__c 
                                                                     from Professor_Student_Course_Preference__c where Semester__c =:AccTermId 
                                                                     and Course_Offering__c !=: null and Professor__c =: objCon.id])
            {
                if(objProfStu.Course_Offering__c != null)
                {
                    set_courseId.add(objProfStu.Course_Offering__c);
                    map_profstudent.put(objProfStu.Course_Offering__c,objProfStu);
                    WrapCourseOff.ProfessorPreference = objProfStu.Professor_Preference__c;
                    set_Category.add(objProfStu.Course_Offering__r.Category__c+'-'+objProfStu.Course_ID__c);
                }
            }            
        }
        if(set_courseId.size()>0)
        {
            set<string> set_courseIdValid=new  set<string>();
            if(set_accid.size() >0)
            {
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c 
                                                   from hed__Course_Offering__c where hed__Term__c =:AccTermId and Id in: set_courseId  
                                                   and  Offered_By_School__r.Name =: LoginAccountName order by Sequence__c])
                {
                    if(!set_courseIdValid.contains(cour.Course_ID__c))
                    {
                        set_courseIdValid.add(cour.Course_ID__c);
                        lst_CourseOffering.add(cour);
                    }
                }
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c 
                                                   from hed__Course_Offering__c where hed__Term__c =:AccTermId  
                                                   and  Offered_By_School__r.Name =: LoginAccountName and Category__c not in: set_Category
                                                   order by Sequence__c])
                {
                    if(!set_courseIdValid.contains(cour.Course_ID__c))
                    {
                        set_courseIdValid.add(cour.Course_ID__c);
                        lst_CourseOffering.add(cour);
                    }
                }
            }
            else if(SelCourseAcross == true)
            {
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c 
                                                   from hed__Course_Offering__c where hed__Term__c =:AccTermId and Id in: set_courseId  
                                                   and hed__Course__r.Course_Across_the_School__c =: true
                                                   and Offered_By_School__r.Name =: LoginAccountName order by Sequence__c])
                {
                    if(!set_courseIdValid.contains(cour.Course_ID__c))
                    {
                        set_courseIdValid.add(cour.Course_ID__c);
                        lst_CourseOffering.add(cour);
                    }
                }
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c 
                                                   from hed__Course_Offering__c where hed__Term__c =:AccTermId  
                                                   and hed__Course__r.Course_Across_the_School__c =: true and Category__c not in: set_Category
                                                   and Offered_By_School__r.Name =: LoginAccountName order by Sequence__c])
                {
                    if(!set_courseIdValid.contains(cour.Course_ID__c))
                    {
                        set_courseIdValid.add(cour.Course_ID__c);
                        lst_CourseOffering.add(cour);
                    }
                }
            }
            else
            {
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c 
                                                   from hed__Course_Offering__c where hed__Term__c =:AccTermId 
                                                   and Id in: set_courseId  order by Sequence__c])           
                {
                    if(!set_courseIdValid.contains(cour.Course_ID__c))
                    {
                        set_courseIdValid.add(cour.Course_ID__c);
                        lst_CourseOffering.add(cour);
                    }
                }
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c 
                                                   from hed__Course_Offering__c where hed__Term__c =:AccTermId 
                                                   and Category__c not in: set_Category order by Sequence__c])           
                {
                    if(!set_courseIdValid.contains(cour.Course_ID__c))
                    {
                        set_courseIdValid.add(cour.Course_ID__c);
                        lst_CourseOffering.add(cour);
                    }
                }
            }
            for(hed__Course_Offering__c objCourseOff : lst_CourseOffering) 
            {  
                if(objCourseOff.Category__c != null)
                    WrapCourseOff.lst_CourseOffCategory.add(objCourseOff.Category__c);
                if(objCourseOff.hed__Course__r.Course_Across_the_School__c != null)
                    WrapCourseOff.CourseAcross = objCourseOff.hed__Course__r.Course_Across_the_School__c;
                if(objCourseOff.Category__c == 'Hardcore Course') 
                {
                    if(map_profstudent.ContainsKey(objCourseOff.id))
                        objCourseOff.Preference__c = map_profstudent.get(objCourseOff.id).Preference__c;
                    WrapCourseOff.listHardCore.add(objCourseOff);                     
                }   
                if(objCourseOff.Category__c == 'Hardcore Integrated Course') 
                {
                    if(map_profstudent.ContainsKey(objCourseOff.id))
                        objCourseOff.Preference__c = map_profstudent.get(objCourseOff.id).Preference__c;
                    WrapCourseOff.listHcIntegrated.add(objCourseOff); 
                }
                if(objCourseOff.Category__c == 'Practical/Term work')
                {
                    if(map_profstudent.ContainsKey(objCourseOff.id))
                        objCourseOff.Preference__c = map_profstudent.get(objCourseOff.id).Preference__c;
                    WrapCourseOff.listPractical.add(objCourseOff);
                }          
                if(objCourseOff.Category__c == 'Professional Elective') 
                {
                    if(map_profstudent.ContainsKey(objCourseOff.id))
                        objCourseOff.Preference__c = map_profstudent.get(objCourseOff.id).Preference__c; 
                    WrapCourseOff.listProfElective.add(objCourseOff);
                }
                if(objCourseOff.Category__c == 'Open Elective')
                {
                    if(map_profstudent.get(objCourseOff.id) !=null)
                        objCourseOff.Preference__c = map_profstudent.get(objCourseOff.id).Preference__c; 
                    WrapCourseOff.listOpenElective.add(objCourseOff);
                } 
                if(objCourseOff.Category__c == 'Mandatory Course') 
                {
                    if(map_profstudent.ContainsKey(objCourseOff.id)) objCourseOff.Preference__c = map_profstudent.get(objCourseOff.id).Preference__c;
                    WrapCourseOff.listMandatory.add(objCourseOff);                     
                }
                WrapCourseOff.listMainCourse.add(objCourseOff);
            }
        } 
        return WrapCourseOff;
    }
    
    @AuraEnabled
    public static CourseOfferingWrapper DisplayCourseOffering(string AccTermId,boolean SelCourseAcross,string LoginAccountName,string AccSchoolId)
    {
        CourseOfferingWrapper WrapCourseOff = new CourseOfferingWrapper();
        set<string> set_accid = new set<string>();
        set<string> set_courseIdValid=new  set<string>();
        if(AccSchoolId != null)
        {
            for(Account objAcc : [select Id,Name,RecordType.Name,Parentid,Sequence__c,Parent.Name from Account Where 
                                  RecordType.Name = :Utility.Acc_RecType_Academic_Program and Parentid =:AccSchoolId order by Sequence__c]) 
            {
                if(objAcc.Parent.Name == LoginAccountName)
                    set_accid.add(objAcc.Parent.Name);
            }
        }
        if(set_accid.size() >0)
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,Max_Professors_Per_Course__c,
                                                        Min_Professors_Per_Course__c,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c,Offered_By_School__c,Offered_By_School__r.Name,
                                                        hed__Course__r.Course_Across_the_School__c,Course_ID__c 
                                                        from hed__Course_Offering__c where hed__Term__c =:AccTermId 
                                                        and Offered_By_School__r.Name =: LoginAccountName order by Sequence__c])
            {
                if(!set_courseIdValid.contains(objCourseOff.Course_ID__c))
                {
                    set_courseIdValid.add(objCourseOff.Course_ID__c);
                    WrapCourseOff.listMainCourse.add(objCourseOff);
                    if(objCourseOff.Category__c != null)
                        WrapCourseOff.lst_CourseOffCategory.add(objCourseOff.Category__c);
                    //WrapCourseOff.CourseOffCategory = objCourseOff.Category__c;
                    WrapCourseOff.CourseAcross = objCourseOff.hed__Course__r.Course_Across_the_School__c;
                    if(objCourseOff.Category__c == 'Hardcore Course')  WrapCourseOff.listHardCore.add(objCourseOff);                
                    if(objCourseOff.Category__c == 'Hardcore Integrated Course') WrapCourseOff.listHcIntegrated.add(objCourseOff); 
                    if(objCourseOff.Category__c == 'Practical/Term work')  WrapCourseOff.listPractical.add(objCourseOff); 
                    if(objCourseOff.Category__c == 'Professional Elective')  WrapCourseOff.listProfElective.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Open Elective') WrapCourseOff.listOpenElective.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Mandatory Course')  WrapCourseOff.listMandatory.add(objCourseOff); 
                }
            }
        }
        else if(SelCourseAcross == true)
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,Max_Professors_Per_Course__c,
                                                        Min_Professors_Per_Course__c,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c,Offered_By_School__c,Offered_By_School__r.Name,
                                                        hed__Course__r.Course_Across_the_School__c,Course_ID__c 
                                                        from hed__Course_Offering__c where hed__Term__c =:AccTermId 
                                                        and hed__Course__r.Course_Across_the_School__c =: true and Offered_By_School__r.Name =: LoginAccountName order by Sequence__c])
            {
                if(!set_courseIdValid.contains(objCourseOff.Course_ID__c))
                {
                    set_courseIdValid.add(objCourseOff.Course_ID__c);
                    WrapCourseOff.listMainCourse.add(objCourseOff);
                    if(objCourseOff.Category__c != null)
                        WrapCourseOff.lst_CourseOffCategory.add(objCourseOff.Category__c);
                    //WrapCourseOff.CourseOffCategory = objCourseOff.Category__c;
                    WrapCourseOff.CourseAcross = objCourseOff.hed__Course__r.Course_Across_the_School__c;
                    if(objCourseOff.Category__c == 'Hardcore Course')  WrapCourseOff.listHardCore.add(objCourseOff);                
                    if(objCourseOff.Category__c == 'Hardcore Integrated Course') WrapCourseOff.listHcIntegrated.add(objCourseOff); 
                    if(objCourseOff.Category__c == 'Practical/Term work')  WrapCourseOff.listPractical.add(objCourseOff); 
                    if(objCourseOff.Category__c == 'Professional Elective')  WrapCourseOff.listProfElective.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Open Elective') WrapCourseOff.listOpenElective.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Mandatory Course')  WrapCourseOff.listMandatory.add(objCourseOff); 
                }
            }    
        }
        else
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,Max_Professors_Per_Course__c,
                                                        Min_Professors_Per_Course__c,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c,Offered_By_School__c,Offered_By_School__r.Name,
                                                        hed__Course__r.Course_Across_the_School__c,Course_ID__c 
                                                        from hed__Course_Offering__c where hed__Term__c =:AccTermId order by Sequence__c])
            {
                if(!set_courseIdValid.contains(objCourseOff.Course_ID__c))
                {
                    set_courseIdValid.add(objCourseOff.Course_ID__c);
                    WrapCourseOff.listMainCourse.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Hardcore Course')  WrapCourseOff.listHardCore.add(objCourseOff);                
                    if(objCourseOff.Category__c == 'Hardcore Integrated Course') WrapCourseOff.listHcIntegrated.add(objCourseOff); 
                    if(objCourseOff.Category__c == 'Practical/Term work')  WrapCourseOff.listPractical.add(objCourseOff); 
                    if(objCourseOff.Category__c == 'Professional Elective')  WrapCourseOff.listProfElective.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Open Elective') WrapCourseOff.listOpenElective.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Mandatory Course')  WrapCourseOff.listMandatory.add(objCourseOff); 
                }
            }  
        }
        return WrapCourseOff;
    }
    
    @AuraEnabled
    public static ErrorWrapper ValidationPreferences(list<hed__Course_Offering__c> lstHardCourse,list<hed__Course_Offering__c> lstHCIntegrated,
                                                     list<hed__Course_Offering__c> lstPractical,list<hed__Course_Offering__c> lstOpenElective,
                                                     list<hed__Course_Offering__c> lstProfElective,list<hed__Course_Offering__c> lstMandatory,
                                                     list<hed__Course_Offering__c> mainLst,boolean ProfSchool)
    {
        ErrorWrapper WrapErr = new ErrorWrapper();       
        boolean HardCoreMsg = false;
        boolean LabHCoreMsg = false;
        boolean LabPCoreMsg = false;
        
        if(ProfSchool == false)
        {
            for(hed__Course_Offering__c objCourse : lstHardCourse)
            {            
                if(string.IsBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c))
                    {
                        HardCoreMsg = true;
                        LabHCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c); 
                        WrapErr.lst_CourseName.add('Hardcore Course');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstHCIntegrated)
            {            
                if(string.IsBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c))
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Hardcore Integrated Courses');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstPractical)
            {            
                if(string.IsBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c))
                    {
                        HardCoreMsg = true;
                        LabHCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Practical / Term Work');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstOpenElective)
            {            
                if(string.IsNotBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c)) 
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Open Electives');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstProfElective)
            {            
                if(string.IsNotBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c)) 
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Professional Electives');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstMandatory)
            {            
                if(string.IsBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c)) 
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Mandatory Courses');
                    }
                } 
            } 
            if(HardCoreMsg == false)
            {
                WrapErr.HardDupErrmsg = 'Please select atleast one Preference for Practical or HardCore Course';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(LabHCoreMsg == false )
            {
                WrapErr.HardDupErrmsg = 'Please select atleast one Preference for Practical or HardCore Course';
                WrapErr.showsave = true;
                return WrapErr;
            }
            
            for(integer i=0;i<WrapErr.lst_Preference.size();i++)
            {
                string val = WrapErr.lst_Preference[i];
                for(integer j=i+1;j<WrapErr.lst_Preference.size();j++)
                {
                    if(val == WrapErr.lst_Preference[j] && WrapErr.lst_Preference[i] != null && WrapErr.lst_Preference[i] !='')
                    {                       
                        WrapErr.MainErrmsg = 'This Preference - '+WrapErr.lst_Preference[j]+' has already been Chosen for one of the '+WrapErr.lst_CourseName[i] + ' Courses';
                        WrapErr.showsave = true;
                        return WrapErr;
                    }
                }
            }            
        }
        if(ProfSchool == true)
        {
            for(hed__Course_Offering__c objCourse : lstHardCourse)
            {            
                if(string.IsBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c))
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c); 
                        WrapErr.lst_CourseName.add('Hardcore Course');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstHCIntegrated)
            {            
                if(string.IsBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c))
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Hardcore Integrated Courses');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstPractical)
            {            
                if(string.IsBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c))
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Practical / Term Work');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstOpenElective)
            {            
                if(string.IsNotBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c)) 
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Open Electives');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstProfElective)
            {            
                if(string.IsNotBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c)) 
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Professional Electives');
                    }
                } 
            }
            for(hed__Course_Offering__c objCourse : lstMandatory)
            {            
                if(string.IsBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c)) 
                    {
                        HardCoreMsg = true;
                        WrapErr.lst_Preference.add(objCourse.Preference__c);
                        WrapErr.lst_CourseName.add('Mandatory Courses');
                    }
                } 
            } 
            
            
            for(integer i=0;i<WrapErr.lst_Preference.size();i++)
            {
                string val = WrapErr.lst_Preference[i];
                for(integer j=i+1;j<WrapErr.lst_Preference.size();j++)
                {
                    if(val == WrapErr.lst_Preference[j] && WrapErr.lst_Preference[i] != null && WrapErr.lst_Preference[i] !='')
                    {
                        WrapErr.MainErrmsg = 'This Preference - '+WrapErr.lst_Preference[j]+' has already been Chosen for one of the '+WrapErr.lst_CourseName[i] + ' Courses';
                        //'This Preference - '+WrapErr.lst_Preference[j]+' is Already Selected.';
                        WrapErr.showsave = true;
                        return WrapErr;
                    }
                }
            }
            if(HardCoreMsg == false)
            {
                WrapErr.HardDupErrmsg = 'Please select atleast one Preference for Practical or HardCore Course';
                WrapErr.showsave = true;
                return WrapErr;
            }
        }
        
        if(WrapErr.lst_Preference.size() == 2 && (WrapErr.lst_Preference[0] == '3' || WrapErr.lst_Preference[1] == '3'))
        {
            WrapErr.HardDupErrmsg = 'Select the Preference in the order like Preference 1,Preference 2... ';
            WrapErr.showsave = true;
            return WrapErr;
        }
        if(WrapErr.lst_Preference.size() == 1 && (WrapErr.lst_Preference[0] == '2' || WrapErr.lst_Preference[0] == '3'))
        {
            WrapErr.HardDupErrmsg = 'Select the Preference in the order like Preference 1 ';
            WrapErr.showsave = true;
            return WrapErr;
        }
        return WrapErr;
    }
    @AuraEnabled
    public static void CreateProfessorCourseRecords(list<hed__Course_Offering__c> lstHc,list<hed__Course_Offering__c> lstHcIntegrated,
                                                    list<hed__Course_Offering__c> lstPract,list<hed__Course_Offering__c> lstOpenEle,
                                                    list<hed__Course_Offering__c> lstProfel,list<hed__Course_Offering__c> lstMandtry,
                                                    boolean ProfPreference,string AccTermId)
    {   
        set<string> set_hardCourseId = new set<string>();
        set<string> set_hardCourIntegId = new set<string>();
        set<string> set_PracticalId = new set<string>();
        set<string> set_OpeneleId = new set<string>();
        set<string> set_ProfId = new set<string>();
        set<string> set_MandatryId = new set<string>();
        User usr =[select Id,Name,ContactId from User where Id =:userinfo.getUserId()];
        Contact objCon = new Contact();
        if(usr.Id != null)
        {
            objCon =[select Id,LastName,OwnerId,Accountid,Account.Name,Account.RecordType.Name,
                     Professor_Across_Schools__c from Contact Where OwnerId =: usr.Id and 
                     Account.RecordType.Name =: Utility.Acc_RecType_University_Department];
        }
        list<Professor_Student_Course_Preference__c> lst_profstudent = new list<Professor_Student_Course_Preference__c>();
        map<id,Professor_Student_Course_Preference__c> map_HCProfstu = new map<id,Professor_Student_Course_Preference__c>();
        map<id,Professor_Student_Course_Preference__c> map_HIProfstu = new map<id,Professor_Student_Course_Preference__c>();
        map<id,Professor_Student_Course_Preference__c> map_PractProfstu = new map<id,Professor_Student_Course_Preference__c>();
        map<id,Professor_Student_Course_Preference__c> map_OpenProfstu = new map<id,Professor_Student_Course_Preference__c>();
        map<id,Professor_Student_Course_Preference__c> map_Profstudent = new map<id,Professor_Student_Course_Preference__c>();
        map<id,Professor_Student_Course_Preference__c> map_ManstuProf = new map<id,Professor_Student_Course_Preference__c>();
        if(lstHc.size()>0)
        {   
            for(hed__Course_Offering__c objcourse : lstHc)
            {
                //if(objcourse.id != null)  set_hardCourseId.add(objcourse.id);
                if(objcourse.Course_ID__c != null) set_hardCourseId.add(objcourse.Course_ID__c);
            }
        }
        if(lstHcIntegrated.size()>0)
        {
            for(hed__Course_Offering__c objcourse : lstHcIntegrated)
            {
                // if(objcourse.id != null) set_hardCourIntegId.add(objcourse.id);
                if(objcourse.Course_ID__c != null) set_hardCourIntegId.add(objcourse.Course_ID__c);
            }
        }
        if(lstPract.size()>0)
        {
            for(hed__Course_Offering__c objcourse : lstPract)
            {
                //if(objcourse.id != null) set_PracticalId.add(objcourse.id);
                if(objcourse.Course_ID__c != null)  set_PracticalId.add(objcourse.Course_ID__c);
            }
        }
        if(lstOpenEle.size()>0)
        {
            for(hed__Course_Offering__c objcourse : lstOpenEle)
            {
                // if(objcourse.id != null) set_OpeneleId.add(objcourse.id);
                if(objcourse.Course_ID__c != null)  set_OpeneleId.add(objcourse.Course_ID__c);
            }
        }
        if(lstProfel.size()>0)
        {
            for(hed__Course_Offering__c objcourse : lstProfel)
            {
                //if(objcourse.id != null) set_ProfId.add(objcourse.id);
                if(objcourse.Course_ID__c != null) set_ProfId.add(objcourse.Course_ID__c);
            }
        }
        if(lstMandtry.size()>0)
        {
            for(hed__Course_Offering__c objcourse : lstMandtry)
            {
                // if(objcourse.id != null) set_MandatryId.add(objcourse.id);
                if(objcourse.Course_ID__c != null) set_MandatryId.add(objcourse.Course_ID__c);
            }
        }
        list<Professor_Student_Course_Preference__c> lst_profDelete = new list<Professor_Student_Course_Preference__c>();
        if(set_hardCourseId.size()>0)
        {            
            for(Professor_Student_Course_Preference__c objprofstu : [select id,Name,Course_Offering__c,Preference__c,Contact__c,
                                                                     Professor_Preference__c,Semester__c,Course_Offering__r.Course_ID__c  
                                                                     from Professor_Student_Course_Preference__c 
                                                                     where Course_Offering__r.Course_ID__c in : set_hardCourseId  
                                                                     and Professor__c =: objCon.id and Semester__c=:AccTermId])
            {
                map_HCProfstu.put(objprofstu.Course_Offering__c,objprofstu);
                lst_profDelete.add(objprofstu);
            }           
        }
        if(set_hardCourIntegId.size()>0)
        {            
            for(Professor_Student_Course_Preference__c objprofstu : [select id,Name,Course_Offering__c,Preference__c,Contact__c,
                                                                     Professor_Preference__c,Semester__c,Course_Offering__r.Course_ID__c  
                                                                     from Professor_Student_Course_Preference__c
                                                                     where Course_Offering__r.Course_ID__c in : set_hardCourIntegId 
                                                                     and Professor__c =: objCon.id and Semester__c=:AccTermId])
            {
                map_HIProfstu.put(objprofstu.Course_Offering__c,objprofstu);
                lst_profDelete.add(objprofstu);
            }           
        }
       /* if(set_OpeneleId.size()>0)
        {            
            for(Professor_Student_Course_Preference__c objprofstu : [select id,Name,Course_Offering__c,Preference__c,Contact__c,
                                                                     Professor_Preference__c,Semester__c,Course_Offering__r.Course_ID__c 
                                                                     from Professor_Student_Course_Preference__c
                                                                     where Course_Offering__r.Course_ID__c in : set_OpeneleId 
                                                                     and Professor__c =: objCon.id and Semester__c=:AccTermId])
            {
                map_OpenProfstu.put(objprofstu.Course_Offering__c,objprofstu);
                lst_profDelete.add(objprofstu);
            }            
        }*/
        if(set_ProfId.size()>0)
        {            
            for(Professor_Student_Course_Preference__c objprofstu : [select id,Name,Course_Offering__c,Preference__c,Contact__c,
                                                                     Professor_Preference__c,Semester__c,Course_Offering__r.Course_ID__c 
                                                                     from Professor_Student_Course_Preference__c 
                                                                     where Course_Offering__r.Course_ID__c in : set_ProfId 
                                                                     and Professor__c =: objCon.id and Semester__c=:AccTermId])
            {
                map_Profstudent.put(objprofstu.Course_Offering__c,objprofstu);
                lst_profDelete.add(objprofstu);
            }            
        }
        if(set_PracticalId.size()>0)
        {            
            for(Professor_Student_Course_Preference__c objprofstu : [select id,Name,Course_Offering__c,Preference__c,Contact__c,
                                                                     Professor_Preference__c,Semester__c,Course_Offering__r.Course_ID__c 
                                                                     from Professor_Student_Course_Preference__c 
                                                                     where Course_Offering__r.Course_ID__c in : set_PracticalId 
                                                                     and Professor__c =: objCon.id and Semester__c=:AccTermId])
            {
                map_PractProfstu.put(objprofstu.Course_Offering__c,objprofstu);
                lst_profDelete.add(objprofstu);
            }            
        }
        if(set_MandatryId.size()>0)
        {            
            for(Professor_Student_Course_Preference__c objprofstu : [select id,Name,Course_Offering__c,Preference__c,Contact__c,
                                                                     Professor_Preference__c,Semester__c,Course_Offering__r.Course_ID__c 
                                                                     from Professor_Student_Course_Preference__c 
                                                                     where Course_Offering__r.Course_ID__c in : set_MandatryId 
                                                                     and Professor__c =: objCon.id and Semester__c=:AccTermId])
            {
                map_ManstuProf.put(objprofstu.Course_Offering__c,objprofstu);
                lst_profDelete.add(objprofstu);
            }           
        }
        
        if(lstHc.size()>0)
        {   
            set<string> set_courseIdValid=new  set<string>();
            map<string,list<hed__Course_Offering__c>> map_HardCore = new map<string,list<hed__Course_Offering__c>>();
            for(hed__Course_Offering__c objcourse : [select id,Name,Preference__c,hed__Term__c,Course_ID__c,hed__Term__r.RecordType.Name,
                                                     Course_Offering_Active__c,hed__Term__r.Term_Number__c,School__c,Offered_By_School__c
                                                     from hed__Course_Offering__c
                                                     where Course_ID__c in:set_hardCourseId 
                                                     and hed__Term__r.RecordType.Name=:Utility.Term_Object_RecType_Term 
                                                     AND Course_Offering_Active__c =:True 
                                                     AND hed__Term__c =:AccTermId])
            {
                if(map_HardCore.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c) ==null)
                    map_HardCore.put(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c,new list<hed__Course_Offering__c>());
                map_HardCore.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c).add(objcourse);
            }
            for(hed__Course_Offering__c objcourse : lstHc)
            {
                if(objcourse.Preference__c != null && objcourse.Preference__c != '')
                {
                    if(map_HardCore.containskey(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                    {
                        for(hed__Course_Offering__c objHC:map_HardCore.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                        {
                            Professor_Student_Course_Preference__c  objprof = new Professor_Student_Course_Preference__c();
                            objprof.Course_Offering__c = objHC.Id;
                            objprof.Preference__c = objcourse.Preference__c; 
                            objprof.Name = objcourse.Name;
                            objprof.Semester__c= objHC.hed__Term__c;
                            /* if(map_HCProfstu.Containskey(objcourse.Id))
                                {
                                objprof.id = map_HCProfstu.get(objcourse.Id).Id;
                                }*/
                            objprof.Professor_Preference__c = ProfPreference;
                            objprof.Professor__c = objCon.id;                
                            lst_profstudent.add(objprof);
                        }
                    }
                }
            }
        }
        if(lstHcIntegrated.size()>0)
        {
            set<string> set_courseIdValid=new  set<string>();
            map<string,list<hed__Course_Offering__c>> map_HardCoreInte = new map<string,list<hed__Course_Offering__c>>();
            for(hed__Course_Offering__c objcourse : [select id,Name,Preference__c,hed__Term__c,Course_ID__c,hed__Term__r.RecordType.Name,
                                                     Course_Offering_Active__c,hed__Term__r.Term_Number__c,School__c,Offered_By_School__c
                                                     from hed__Course_Offering__c
                                                     where Course_ID__c in:set_hardCourIntegId 
                                                     and hed__Term__r.RecordType.Name=:Utility.Term_Object_RecType_Term 
                                                     AND Course_Offering_Active__c =:True 
                                                     AND hed__Term__c =:AccTermId])
            {
                if(map_HardCoreInte.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c) ==null)
                    map_HardCoreInte.put(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c,new list<hed__Course_Offering__c>());
                map_HardCoreInte.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c).add(objcourse);
            }
            for(hed__Course_Offering__c objcourse : lstHcIntegrated)
            {                
                if(objcourse.Preference__c != null && objcourse.Preference__c != '')
                {
                    if(map_HardCoreInte.containskey(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                    {
                        for(hed__Course_Offering__c objInte:map_HardCoreInte.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                        {
                            Professor_Student_Course_Preference__c  objprof = new Professor_Student_Course_Preference__c();
                            objprof.Course_Offering__c = objInte.Id;
                            objprof.Preference__c = objcourse.Preference__c;
                            objprof.Name = objcourse.Name;
                            objprof.Semester__c= objInte.hed__Term__c;
                            /*if(map_HIProfstu.Containskey(objcourse.Id))
                                {
                                objprof.id = map_HIProfstu.get(objcourse.Id).Id;
                                }*/
                            objprof.Professor__c = objCon.id;
                            objprof.Professor_Preference__c = ProfPreference;
                            lst_profstudent.add(objprof);
                        }
                    }
                }
            }
        }
        
        if(lstPract.size()>0)
        {
            set<string> set_courseIdValid=new  set<string>();
            map<string,list<hed__Course_Offering__c>> map_practical = new map<string,list<hed__Course_Offering__c>>();
            for(hed__Course_Offering__c objcourse : [select id,Name,Preference__c,hed__Term__c,Course_ID__c,hed__Term__r.RecordType.Name,
                                                     Course_Offering_Active__c,hed__Term__r.Term_Number__c,School__c,Offered_By_School__c
                                                     from hed__Course_Offering__c
                                                     where Course_ID__c in:set_PracticalId 
                                                     and hed__Term__r.RecordType.Name=:Utility.Term_Object_RecType_Term 
                                                     AND Course_Offering_Active__c =:True 
                                                     AND hed__Term__c =:AccTermId])
            {
                if(map_practical.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c) ==null)
                    map_practical.put(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c,new list<hed__Course_Offering__c>());
                map_practical.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c).add(objcourse);
            }
            for(hed__Course_Offering__c objcourse : lstPract)
            {               
                if(objcourse.Preference__c != null && objcourse.Preference__c != '')
                {
                    if(map_practical.containskey(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                    {
                        for(hed__Course_Offering__c objPract:map_practical.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                        {                            
                            Professor_Student_Course_Preference__c  objprof = new Professor_Student_Course_Preference__c();
                            objprof.Course_Offering__c = objPract.Id;
                            objprof.Preference__c = objcourse.Preference__c;   
                            objprof.Professor__c = objCon.id;
                            objprof.Name = objcourse.Name;
                            objprof.Semester__c= objPract.hed__Term__c;
                            /* if(map_PractProfstu.Containskey(objcourse.Id))
                                {
                                objprof.id = map_PractProfstu.get(objcourse.Id).Id;
								}*/
                            objprof.Professor_Preference__c = ProfPreference;
                            lst_profstudent.add(objprof);
                        }
                    }
                }
            }
        }
        /*   if(lstOpenEle.size()>0)
            {
            for(hed__Course_Offering__c objcourse : lstOpenEle)
            {                
            if(objcourse.Preference__c != null && objcourse.Preference__c != '')
            {
            Professor_Student_Course_Preference__c  objprof = new Professor_Student_Course_Preference__c();
            objprof.Course_Offering__c = objcourse.Id;
            objprof.Preference__c = objcourse.Preference__c;   
            objprof.Professor__c = objCon.id;
            objprof.Name = objcourse.Name;
            objprof.Semester__c= objcourse.hed__Term__c;
            if(map_OpenProfstu.Containskey(objcourse.Id))
            {
            objprof.id = map_OpenProfstu.get(objcourse.Id).Id;
            }
            objprof.Professor_Preference__c = ProfPreference;
            lst_profstudent.add(objprof);
            }
            }
            }*/
        if(lstProfel.size()>0)
        {
            set<string> set_courseIdValid=new  set<string>();
            map<string,list<hed__Course_Offering__c>> map_Profelective = new map<string,list<hed__Course_Offering__c>>();
            for(hed__Course_Offering__c objcourse : [select id,Name,Preference__c,hed__Term__c,Course_ID__c,hed__Term__r.RecordType.Name,
                                                     Course_Offering_Active__c,hed__Term__r.Term_Number__c,School__c,Offered_By_School__c
                                                     from hed__Course_Offering__c
                                                     where Course_ID__c in:set_ProfId 
                                                     and hed__Term__r.RecordType.Name=:Utility.Term_Object_RecType_Term 
                                                     AND Course_Offering_Active__c =:True 
                                                     AND hed__Term__c =:AccTermId])
            {
                if(map_Profelective.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c) ==null)
                    map_Profelective.put(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c,new list<hed__Course_Offering__c>());
                map_Profelective.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c).add(objcourse);
            }
            for(hed__Course_Offering__c objcourse : lstProfel)
            {                
                if(objcourse.Preference__c != null && objcourse.Preference__c != '')
                {
                    if(map_Profelective.containskey(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                    {
                        for(hed__Course_Offering__c objProfEle:map_Profelective.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                        {
                            Professor_Student_Course_Preference__c  objprof = new Professor_Student_Course_Preference__c();
                            objprof.Course_Offering__c = objProfEle.Id;
                            objprof.Preference__c = objcourse.Preference__c;   
                            objprof.Professor__c = objCon.id;
                            objprof.Name = objcourse.Name;
                            objprof.Semester__c= objProfEle.hed__Term__c;
                            /*  if(map_Profstudent.Containskey(objcourse.Id))
                                {
                                objprof.id = map_Profstudent.get(objcourse.Id).Id;
                                }*/
                            objprof.Professor_Preference__c = ProfPreference;
                            lst_profstudent.add(objprof);
                        }
                    }
                }
            }
        }
        if(lstMandtry.size()>0)
        {
            set<string> set_courseIdValid=new  set<string>();
            map<string,list<hed__Course_Offering__c>> map_Mandatory = new map<string,list<hed__Course_Offering__c>>();
            for(hed__Course_Offering__c objcourse : [select id,Name,Preference__c,hed__Term__c,Course_ID__c,hed__Term__r.RecordType.Name,
                                                     Course_Offering_Active__c,hed__Term__r.Term_Number__c,School__c,Offered_By_School__c
                                                     from hed__Course_Offering__c
                                                     where Course_ID__c in:set_MandatryId 
                                                     and hed__Term__r.RecordType.Name=:Utility.Term_Object_RecType_Term
                                                     AND Course_Offering_Active__c =:True 
                                                     AND hed__Term__c =:AccTermId])
            {
                if(map_Mandatory.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c) ==null)
                    map_Mandatory.put(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c,new list<hed__Course_Offering__c>());
                map_Mandatory.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c).add(objcourse);
            }
            for(hed__Course_Offering__c objcourse : lstMandtry)
            {                
                if(objcourse.Preference__c != null && objcourse.Preference__c != '')
                {
                    if(map_Mandatory.containskey(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                    {
                        for(hed__Course_Offering__c objMand:map_Mandatory.get(objcourse.Course_ID__c+'-'+objcourse.Offered_By_School__c))
                        {
                            Professor_Student_Course_Preference__c  objprof = new Professor_Student_Course_Preference__c();
                            objprof.Course_Offering__c = objMand.Id;
                            objprof.Preference__c = objcourse.Preference__c;   
                            objprof.Professor__c = objCon.id;
                            objprof.Name = objcourse.Name;
                            objprof.Semester__c= objMand.hed__Term__c;
                            /* if(map_ManstuProf.Containskey(objcourse.Id))
                             {
                               objprof.id = map_ManstuProf.get(objcourse.Id).Id;
                             }*/
                            objprof.Professor_Preference__c = ProfPreference;
                            lst_profstudent.add(objprof);
                        }
                    }
                }
            }
        }
        if(lst_profstudent.size()>0)
        {             
            try
            {
                if(lst_profDelete.size()>0)
                {
                    delete lst_profDelete;
                }
                insert lst_profstudent;
            }
            catch(Exception ex)
            {
                system.debug('===Exception==='+ex.getMessage()+ex.getLineNumber());
            }         
        }
    }
    @AuraEnabled
    public static Map<String, String> getPreference() 
    {
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('hed__Course_Offering__c');
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get('Preference__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) 
        {
            mapPickListValues.put(objPickList.getValue(),objPickList.getLabel());
        }       
        return mapPickListValues;
    }
    public class CourseOfferingWrapper
    {
        @AuraEnabled public list<hed__Course_Offering__c> listHardCore {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listOpenElective {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listProfElective {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listPractical {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listHcIntegrated {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listMandatory {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listMainCourse {get;set;}
        @AuraEnabled public Boolean ProfessorPreference {get;set;}   
        @AuraEnabled public list<string> lst_CourseOffCategory{get;set;}
        @AuraEnabled public Boolean CourseAcross{get;set;}
        
        public CourseOfferingWrapper(){
            listHardCore = new list<hed__Course_Offering__c>();
            listOpenElective = new list<hed__Course_Offering__c>(); 
            listProfElective = new list<hed__Course_Offering__c>(); 
            listPractical = new list<hed__Course_Offering__c> ();
            listHcIntegrated = new list<hed__Course_Offering__c>();
            listMandatory = new list<hed__Course_Offering__c>();
            listMainCourse =new list<hed__Course_Offering__c>();
            CourseAcross = false;
            lst_CourseOffCategory = new list<string>();
        }
    }
    public class SchoolWrapper
    {
        @AuraEnabled public Map<Id,String> Map_AccSchool{get;set;}
        @AuraEnabled public boolean ProfSchool {get;set;}
        @AuraEnabled public Boolean CourseAcross{get;set;}
        @AuraEnabled public string CourseOffCategory{get;set;}
        @AuraEnabled public string LoginUserAccountName{get;set;}
        public SchoolWrapper()
        {
            Map_AccSchool = new Map<Id,String>();
            ProfSchool = false;
            CourseAcross = false;
        }    
    }
    public class ErrorWrapper
    {
        @AuraEnabled public string HardDupErrmsg {get;set;}        
        @AuraEnabled public string MainErrmsg {get;set;}        
        @AuraEnabled public boolean showsave {get;set;}
        @AuraEnabled public string ManPrefErrmsg {get;set;}
        @AuraEnabled public list<String> lst_Preference{get;set;}
        @AuraEnabled public list<String> lst_CourseName{get;set;}
        public ErrorWrapper()
        {
            lst_Preference =  new list<String>();
            lst_CourseName = new list<String>();
        }
    }    
}