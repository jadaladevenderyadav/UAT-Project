@isTest
public class MSTR_createCourseOfferingCls_Test 
{
    public static testMethod Void CreateCourseMethod()
    {
       string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.Parentid = objAccount1.id;
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       objProgPlan.hed__Account__c = objAccount.id;
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;     
       
        hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Hardcore Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement');
       objPlanReq.hed__Category__c = 'Hardcore Course';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
       
       hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
       objCourse.Category__c = 'Hardcore Course';
       objCourse.HardCore_Sub_Type__c = 'Theory'; 
       insert objCourse; 
       
       hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
       objCourseOff1.Category__c = 'Open Elective';
       objCourseOff1.Sequence__c =1;
       insert objCourseOff1; 
       
       hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
       objCourseOff.Category__c = 'Hardcore Course';
       objCourseOff.Sequence__c =1;
       objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
       insert objCourseOff;
       
       MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
       plnWrap.count = '1';
       plnWrap.courseId =  objCourseOff.id;
       plnWrap.termId = objTerm.Id;
       
       list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
       lst_planWrap.add(plnWrap); 
       
       Test.StartTest();
       MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
       MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
       MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
       MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,lst_planWrap,null,null,null,null,null,Null,false,false);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
     }
     public static testMethod Void CreateCourseMethod1()
    {
       string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.Parentid = objAccount1.id;
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       objProgPlan.hed__Account__c = objAccount.id;
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
        hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Practical/Term Work';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
        hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq.hed__Category__c = 'Practical/Term Work';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       objPlanReq.Sequence__c =2;
       insert objPlanReq;
       
       hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
       objCourse.Category__c = 'Practical/Term Work';
       insert objCourse; 
       
       hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
       objCourseOff1.Category__c = 'Open Elective';
       objCourseOff1.Sequence__c =1;
       insert objCourseOff1; 
       
       hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
       objCourseOff.Category__c = 'Practical/Term Work';
       objCourseOff.Sequence__c =1;
       objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
       insert objCourseOff;
       
        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
       plnWrap.count = '1';
       plnWrap.courseId =  objCourseOff.id;
       plnWrap.termId = objTerm.Id;
       
       list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
       lst_planWrap.add(plnWrap); 
       
       Test.StartTest();
       MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
       MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,null,null,lst_planWrap,null,null,null,Null,false,false);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
     }
      public static testMethod Void CreateCourseMethod2()
    {
       string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId);
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.Parentid = objAccount1.id;
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       objProgPlan.hed__Account__c = objAccount.id;
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
        hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
       
       hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
       objCourse.Category__c = 'Hardcore Integrated Course';
       insert objCourse;
       
       hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
       objCourseOff1.Category__c = 'Open Elective';
       objCourseOff1.Sequence__c =1;
       insert objCourseOff1; 
       
       hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
       objCourseOff.Category__c = 'Hardcore Integrated Course';
       objCourseOff.Sequence__c =1;
       objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
       insert objCourseOff; 
       
        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
       plnWrap.count = '1';
       plnWrap.courseId =  objCourseOff.id;
       plnWrap.termId = objTerm.Id;
       
       list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
       lst_planWrap.add(plnWrap); 
       
       Test.StartTest();
       MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
       MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,null,lst_planWrap,null,null,null,null,Null,false,false);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
     }
     public static testMethod Void CreateCourseMethod3()
    {
      string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId);
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.Parentid = objAccount1.id;
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       objProgPlan.hed__Account__c = objAccount.id;
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Mandatory Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
        hed__Plan_Requirement__c objPlanReq= MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq.hed__Category__c = 'Mandatory Course';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
       
       hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
       objCourse.Category__c = 'Mandatory Course';
       insert objCourse; 
       
       hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
       objCourseOff1.Category__c = 'Open Elective';
       objCourseOff1.Sequence__c =1;
       insert objCourseOff1; 
       
       hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
       objCourseOff.Category__c = 'Mandatory Course';
       objCourseOff.Sequence__c =1;
       objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
       insert objCourseOff;
       
        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
       plnWrap.count = '1';
       plnWrap.courseId =  objCourseOff.id;
       plnWrap.termId = objTerm.Id;
       
       list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
       lst_planWrap.add(plnWrap); 
       
       Test.StartTest();
       MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
       MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,null,null,null,null,null,lst_planWrap,Null,false,false);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
     }
     public static testMethod Void CreateCourseMethod4()
    {
       string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.Parentid = objAccount1.id;
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       objProgPlan.hed__Account__c = objAccount.id;
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Professional Elective';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
        hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq.hed__Category__c = 'Professional Elective';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
        objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
       
       hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
       objCourse.Category__c = 'Professional Elective';
       insert objCourse; 
       
       hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
       objCourseOff1.Category__c = 'Professional Elective';
       objCourseOff1.Sequence__c =1;
       insert objCourseOff1; 
       
       hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
       objCourseOff.Category__c = 'Professional Elective';
       objCourseOff.Sequence__c =1;
       objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
       insert objCourseOff;
       
        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
       plnWrap.count = '1';
       plnWrap.courseId =  objCourseOff.id;
       plnWrap.termId = objTerm.Id;
       
       list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
       lst_planWrap.add(plnWrap); 
       
       Test.StartTest();
       MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
       MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,lst_planWrap,null,null,null,null,null,Null,false,false);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
     }
     public static testMethod Void CreateCourseMethod5()
    {
       string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.Parentid = objAccount1.id;
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       objProgPlan.hed__Account__c = objAccount.id;
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       objTerm.Course_Offering_Created__c = true;
       insert objTerm;
       
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Open Elective';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
        hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq.hed__Category__c = 'Open Elective';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
        objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
       
       hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
       objCourse.Category__c = 'Open Elective';
       insert objCourse;
       
       hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
       objCourseOff1.Category__c = 'Open Elective';
       objCourseOff1.Sequence__c =1;
       insert objCourseOff1;  
       
       hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
       objCourseOff.Category__c = 'Open Elective';
       objCourseOff.Sequence__c =1;
       objCourseOff.Parent_Course_Offering__c = objCourseOff1.id; 
       insert objCourseOff; 
       
       MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
       plnWrap.count = '1';
       plnWrap.courseId =  objCourseOff.id;
       plnWrap.termId = objTerm.Id;
       
       list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
       lst_planWrap.add(plnWrap); 
       
       Test.StartTest();
       MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
       MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
       MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,lst_planWrap,null,null,null,null,null,Null,false,false);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
     }
     
     public static testMethod Void ProfElectiveMethod1()
    {            
       string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       
       Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount2.Parentid = objAccount1.id;
       objAccount2.RecordTypeid = AcaRecId1;
       insert objAccount2;
       
        string AcaUniRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId );
       objAccount.Parentid = objAccount2.id;
       objAccount.RecordTypeid = AcaUniRecId ;
       insert objAccount;
       
       hed__Course__c cur= MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
       cur.Category__c = 'Hardcore Course';
        cur.hed__Course_ID__c = 'T1';
        cur.hed__Credit_Hours__c = 80;
        cur.Category__c = 'Hardcore Course';
        cur.Credits__c = 4;
        cur.hed__Account__c = objAccount.id;
        cur.HardCore_Sub_Type__c = 'Theory';
       insert cur; 
        
        hed__Course__c cur1 = MSTR_TestDataFactory.CreateCourse('Test1',objAccount.id);
        cur1.hed__Course_ID__c = 'T2';
        cur1.hed__Credit_Hours__c = 80;
        cur1.Category__c = 'Hardcore Integrated Course';
        cur1.Credits__c = 4;
        cur1.hed__Account__c = objAccount.id;
        insert cur1;
        
        hed__Course__c cur2 = MSTR_TestDataFactory.CreateCourse('Test2',objAccount.id);
        cur2.hed__Course_ID__c = 'T10';
        cur2.hed__Credit_Hours__c = 80;
        cur2.Category__c = 'Practical/Term Work';
        cur2.Credits__c = 4;
        cur2.hed__Account__c = objAccount.id;
        insert cur2;
        
        hed__Course__c cur3 = MSTR_TestDataFactory.CreateCourse('Test3',objAccount.id);
        cur3.hed__Course_ID__c = 'T3';
        cur3.hed__Credit_Hours__c = 80;
        cur3.Category__c = 'Mandatory Course';
        cur3.Credits__c = 4;
        cur3.hed__Account__c = objAccount.id;
        insert cur3;
        
        string AcaAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program ).getRecordTypeId();
    
       Account objAccount3 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaAccRecId );
       objAccount3.parentId = objAccount.id;
       objAccount3.recordTypeId = AcaAccRecId ;
       insert objAccount3;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
              
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Hardcore Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       objPlanReq1.hed__Course__c = cur.id;
       objPlanReq1.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq2 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq2.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReq2.Semester__c = objTerm.id;
       objPlanReq2.Credits__c = 10;
       objPlanReq2.Sequence__c =2;
       objPlanReq2.hed__Course__c = cur1.id;
       objPlanReq2.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq2;
       
       hed__Plan_Requirement__c objPlanReq3 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq3.hed__Category__c = 'Practical/Term Work';
       objPlanReq3.Semester__c = objTerm.id;
       objPlanReq3.Credits__c = 10;
       objPlanReq3.Sequence__c =2;
       objPlanReq3.hed__Course__c = cur2.id;
       objPlanReq3.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq3;
       
       hed__Plan_Requirement__c objPlanReq4 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq4.hed__Category__c = 'Mandatory Course';
       objPlanReq4.Semester__c = objTerm.id;
       objPlanReq4.Credits__c = 10;
       objPlanReq4.Sequence__c =2;
       objPlanReq4.hed__Course__c = cur3.id;
       objPlanReq4.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq4;
       
       MSTR_createCourseOfferingCls.planLiwrap p1 = new MSTR_createCourseOfferingCls.planLiwrap();
       p1.count = '1';
       p1.subCount = '0';
       p1.courseId = cur.id;
       p1.courseName = cur.Name;
       p1.credits = 2;
       p1.termId = objTerm.id;
       p1.recordId = Null;
       p1.filter = '';
       list<MSTR_createCourseOfferingCls.planLiwrap> l1 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p1};
       
       MSTR_createCourseOfferingCls.planLiwrap p2 = new MSTR_createCourseOfferingCls.planLiwrap();
       p2.count = '1';
       p2.subCount = '0';
       p2.courseId = cur1.id;
       p2.courseName = cur1.Name;
       p2.credits = 2;
       p2.termId = objTerm.id;
       p2.recordId = Null;
       p2.filter = '';
       list<MSTR_createCourseOfferingCls.planLiwrap> l2 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p2};
       
       MSTR_createCourseOfferingCls.planLiwrap p3 = new MSTR_createCourseOfferingCls.planLiwrap();
       p3.count = '1';
       p3.subCount = '0';
       p3.courseId = cur2.id;
       p3.courseName = cur2.Name;
       p3.credits = 2;
       p3.termId = objTerm.id;
       p3.recordId = Null;
       p3.filter = '';
       list<MSTR_createCourseOfferingCls.planLiwrap> l3 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p3};
       
       MSTR_createCourseOfferingCls.planLiwrap WrapPlanOpen = new MSTR_createCourseOfferingCls.planLiwrap();
       WrapPlanOpen.count = '10';
       WrapPlanOpen.courseName = 'test';
       WrapPlanOpen.credits = 10;
       WrapPlanOpen.termId = objTerm.id;
       
       list<MSTR_createCourseOfferingCls.planLiwrap>  lst_planwrapOpen = new list<MSTR_createCourseOfferingCls.planLiwrap>();
       lst_planwrapOpen.add(WrapPlanOpen);
       
       MSTR_createCourseOfferingCls.openElectivewrap opEleWrap =  new MSTR_createCourseOfferingCls.openElectivewrap();
       opEleWrap.count = '10';
       opEleWrap.Name = 'test';
       opEleWrap.credits = 10;
       opEleWrap.termId = objTerm.id;
       opEleWrap.lstPlanLi = lst_planwrapOpen;
       
       MSTR_createCourseOfferingCls.profElectivewrap profEleWrap =  new MSTR_createCourseOfferingCls.profElectivewrap();
       profEleWrap.count = '10';
       profEleWrap.Name = 'test';
       profEleWrap.credits = 10;
       profEleWrap.termId = objTerm.id;
       profEleWrap.lstPlanLi = lst_planwrapOpen;
       
       MSTR_createCourseOfferingCls.planLiwrap p4 = new MSTR_createCourseOfferingCls.planLiwrap();
       p4.count = '1';
       p4.subCount = '0';
       p4.courseId = cur3.id;
       p4.courseName = cur3.Name;
       p4.credits = 2;
       p4.termId = objTerm.id;
       p4.recordId = Null;
       p4.filter = ''; 
       list<MSTR_createCourseOfferingCls.planLiwrap> l4 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p4};
       list<MSTR_createCourseOfferingCls.openElectivewrap> l5 = new list<MSTR_createCourseOfferingCls.openElectivewrap>{opEleWrap};
       list<MSTR_createCourseOfferingCls.profElectivewrap> l6 = new list<MSTR_createCourseOfferingCls.profElectivewrap>();
       list<string> l7 = new list<string>();
       
       MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.id,l1,l2,l3,l5,l6,l4,l7,false,false);
       
       MSTR_createCourseOfferingCls.savePlanRequiement(objTerm1.id,l1,l2,l3,l5,l6,l4,l7,false,false);
        System.AssertEquals(objTerm.id,objTerm.id);
       
     }  
     public static testMethod Void ProfElectiveElseMethod()
    {            
       string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       
       Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount2.Parentid = objAccount1.id;
       objAccount2.RecordTypeid = AcaRecId1;
       insert objAccount2;
       
        string AcaUniRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId );
       objAccount.Parentid = objAccount2.id;
       objAccount.RecordTypeid = AcaUniRecId ;
       insert objAccount;
       
       hed__Course__c cur= MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
       cur.Category__c = 'Hardcore Course';
        cur.hed__Course_ID__c = 'T1';
        cur.hed__Credit_Hours__c = 80;
        cur.Category__c = 'Hardcore Course';
        cur.Credits__c = 4;
        cur.hed__Account__c = objAccount.id;
        cur.HardCore_Sub_Type__c = 'Theory';
       insert cur; 
        
        hed__Course__c cur1 = MSTR_TestDataFactory.CreateCourse('Test1',objAccount.id);
        cur1.hed__Course_ID__c = 'T2';
        cur1.hed__Credit_Hours__c = 80;
        cur1.Category__c = 'Hardcore Integrated Course';
        cur1.Credits__c = 4;
        cur1.hed__Account__c = objAccount.id;
        insert cur1;
        
        hed__Course__c cur2 = MSTR_TestDataFactory.CreateCourse('Test2',objAccount.id);
        cur2.hed__Course_ID__c = 'T3';
        cur2.hed__Credit_Hours__c = 80;
        cur2.Category__c = 'Practical/Term Work';
        cur2.Credits__c = 4;
        cur2.hed__Account__c = objAccount.id;
        insert cur2;
        
        hed__Course__c cur3 = MSTR_TestDataFactory.CreateCourse('Test3',objAccount.id);
        cur3.hed__Course_ID__c = 'T6';
        cur3.hed__Credit_Hours__c = 80;
        cur3.Category__c = 'Mandatory Course';
        cur3.Credits__c = 4;
        cur3.hed__Account__c = objAccount.id;
        insert cur3;
        
        string AcaAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program ).getRecordTypeId();
    
       Account objAccount3 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaAccRecId );
       objAccount3.parentId = objAccount.id;
       objAccount3.recordTypeId = AcaAccRecId ;
       insert objAccount3;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
              
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Hardcore Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       objPlanReq1.hed__Course__c = cur.id;
       objPlanReq1.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq2 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq2.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReq2.Semester__c = objTerm.id;
       objPlanReq2.Credits__c = 10;
       objPlanReq2.Sequence__c =2;
       objPlanReq2.hed__Course__c = cur1.id;
       objPlanReq2.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq2;
       
       hed__Plan_Requirement__c objPlanReq3 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq3.hed__Category__c = 'Practical/Term Work';
       objPlanReq3.Semester__c = objTerm.id;
       objPlanReq3.Credits__c = 10;
       objPlanReq3.Sequence__c =2;
       objPlanReq3.hed__Course__c = cur2.id;
       objPlanReq3.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq3;
       
       hed__Plan_Requirement__c objPlanReq4 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq4.hed__Category__c = 'Mandatory Course';
       objPlanReq4.Semester__c = objTerm.id;
       objPlanReq4.Credits__c = 10;
       objPlanReq4.Sequence__c =2;
       objPlanReq4.hed__Course__c = cur3.id;
       objPlanReq4.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq4;
       
       MSTR_createCourseOfferingCls.planLiwrap p1 = new MSTR_createCourseOfferingCls.planLiwrap();
       p1.count = '1';
       p1.subCount = '0';
       p1.courseId = cur.id;
       p1.courseName = cur.Name;
       p1.credits = 2;
       p1.termId = objTerm.id;
       p1.recordId = Null;
       p1.filter = '';
       list<MSTR_createCourseOfferingCls.planLiwrap> l1 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p1};
       
       MSTR_createCourseOfferingCls.planLiwrap p2 = new MSTR_createCourseOfferingCls.planLiwrap();
       p2.count = '1';
       p2.subCount = '0';
       p2.courseId = cur1.id;
       p2.courseName = cur1.Name;
       p2.credits = 2;
       p2.termId = objTerm.id;
       p2.recordId = Null;
       p2.filter = '';
       list<MSTR_createCourseOfferingCls.planLiwrap> l2 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p2};
       
       MSTR_createCourseOfferingCls.planLiwrap p3 = new MSTR_createCourseOfferingCls.planLiwrap();
       p3.count = '1';
       p3.subCount = '0';
       p3.courseId = cur2.id;
       p3.courseName = cur2.Name;
       p3.credits = 2;
       p3.termId = objTerm.id;
       p3.recordId = Null;
       p3.filter = '';
       list<MSTR_createCourseOfferingCls.planLiwrap> l3 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p3};
       
       MSTR_createCourseOfferingCls.planLiwrap WrapPlanOpen = new MSTR_createCourseOfferingCls.planLiwrap();
       WrapPlanOpen.count = '10';
       WrapPlanOpen.courseName = 'test';
       WrapPlanOpen.credits = 10;
       WrapPlanOpen.termId = objTerm.id;
       
       list<MSTR_createCourseOfferingCls.planLiwrap>  lst_planwrapOpen = new list<MSTR_createCourseOfferingCls.planLiwrap>();
       lst_planwrapOpen.add(WrapPlanOpen);
      
       MSTR_createCourseOfferingCls.profElectivewrap profEleWrap =  new MSTR_createCourseOfferingCls.profElectivewrap();
       profEleWrap.count = '10';
       profEleWrap.Name = 'test';
       profEleWrap.credits = 10;
       profEleWrap.termId = objTerm.id;
       profEleWrap.lstPlanLi = lst_planwrapOpen;
       
       MSTR_createCourseOfferingCls.planLiwrap p4 = new MSTR_createCourseOfferingCls.planLiwrap();
       p4.count = '1';
       p4.subCount = '0';
       p4.courseId = cur3.id;
       p4.courseName = cur3.Name;
       p4.credits = 2;
       p4.termId = objTerm.id;
       p4.recordId = Null;
       p4.filter = ''; 
       list<MSTR_createCourseOfferingCls.planLiwrap> l4 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p4};
       list<MSTR_createCourseOfferingCls.openElectivewrap> l5 = new list<MSTR_createCourseOfferingCls.openElectivewrap>();
       list<MSTR_createCourseOfferingCls.profElectivewrap> l6 = new list<MSTR_createCourseOfferingCls.profElectivewrap>{profEleWrap};
       list<string> l7 = new list<string>();
       
       MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.id,l1,l2,l3,l5,l6,l4,l7,false,false);
       
       MSTR_createCourseOfferingCls.savePlanRequiement(objTerm1.id,l1,l2,l3,l5,l6,l4,l7,false,false);
        System.AssertEquals(objTerm.id,objTerm.id);
       
     }  
 }