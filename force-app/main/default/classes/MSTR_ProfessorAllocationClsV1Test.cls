@isTest
public class MSTR_ProfessorAllocationClsV1Test {
    public static testMethod Void ProfessorMethod(){
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        string poffRtId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        string facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        string groupRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
        string batchId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.recordTypeId = poffRtId;
        objcon.Active__c = true;
        objcon.X1st_Dose_Vaccine_Name__c ='Dose';
        objcon.X2nd_Dose_Vaccine_Name__c = 'Covaxin';
        objcon.X2nd_Dose_Vaccine_Date__c = system.today();
        objcon.X1st_Dose_Vaccine_Date__c = system.today();
        insert objcon;
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account Child',AcaRecId);
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.parentid = objAccount.id;
        insert objAccount1;
        
        hed__Program_Plan__c objProgPlan = MSTR_TestDataFactory.createProgramPlan('test program plan');
        objProgPlan.hed__Account__c = objAccount1.id;
        objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
        objProgPlan.hed__End_Date__c = system.today()+2;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        string sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today().adddays(-16); 
        objTerm.hed__End_Date__c =system.today().adddays(16);
        objTerm.Approval_Status__c = 'Confirmed';
        insert objTerm;
        
        hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,sectionRtId);
        objTerm1.Program_Batch__c  = objProgPlan.id;
        objTerm1.hed__Start_Date__c = system.today().adddays(-16); 
        objTerm1.hed__End_Date__c =system.today().adddays(16);
        objTerm1.hed__Parent_Term__c = objTerm.id;
        objTerm1.Approval_Status__c = 'Confirmed';
        insert objTerm1;
        
        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.Course_Across_the_School__c= true;
        objCourse.HardCore_Sub_Type__c = 'Theory';
        insert objCourse; 
        
        hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseHI.Category__c = 'Hardcore Integrated Course';
        insert objCourseHI; 
        
        hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCoursePW.Category__c = 'Practical/Term Work';
        insert objCoursePW; 
        
        hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseMAN.Category__c = 'Mandatory Course';
        insert objCourseMAN; 
        
        hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseOpen.Category__c = 'Open Elective';
        insert objCourseOpen;
        
        hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseProf.Category__c = 'Professional Elective';
        insert objCourseProf; 
        
        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        objCourseOff1.Active__c = true;
        objCourseOff1.hed__Course__c = objCourse.Id;
        objCourseOff1.hed__Term__c=objTerm.id;
        objCourseOff1.Approval_Required_by_School_Head__c = true;
        objCourseOff1.Offered_By_School__c = objAccount.Id;
        objCourseOff1.Max_Professors_Per_Course__c = 2;
        insert objCourseOff1;         
        
        hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOffHC.Category__c = 'Hardcore Course';
        objCourseOffHC.Sequence__c =1;
        objCourseOffHC.Max_Professors_Per_Course__c = 2;
        insert objCourseOffHC;
        
        hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseHI.id);
        objCourseOffHI.Category__c = 'Hardcore Integrated Course';
        objCourseOffHI.Sequence__c =1;
        objCourseOffHI.Max_Professors_Per_Course__c = 2;
        insert objCourseOffHI;
        
        hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);
        objCourseOffPWORK.Category__c = 'Practical/Term Work';
        objCourseOffPWORK.Sequence__c =1;
        objCourseOffPWORK.Max_Professors_Per_Course__c = 2;
        insert objCourseOffPWORK;
        
        hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseMAN.id);
        objCourseOffMandatory.Category__c = 'Mandatory Course';
        objCourseOffMandatory.Sequence__c =1;
        objCourseOffMandatory.Max_Professors_Per_Course__c = 2;
        insert objCourseOffMandatory;
        
        hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseProf.id);
        objCourseOffProfEle.Category__c = 'Professional Elective';
        objCourseOffProfEle.Sequence__c =1;
        objCourseOffProfEle.Parent_Course_Offering__c = objCourseOff1.id;
        objCourseOffProfEle.Max_Professors_Per_Course__c = 2;
        insert objCourseOffProfEle;
        
        hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOffOpenEle.Category__c = 'Open Elective';
        objCourseOffOpenEle.Sequence__c =1;
        objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff1.id;
        objCourseOffOpenEle.Max_Professors_Per_Course__c = 2;
        insert objCourseOffOpenEle;
        
        hed__Course_Offering__c  objCourseOff2 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm1.id,objCourseOpen.id);
        objCourseOff2.Category__c = 'Open Elective';
        objCourseOff2.Sequence__c =1;
        objCourseOff2.Active__c = true;
        objCourseOff2.hed__Course__c = objCourse.Id;
        objCourseOff2.hed__Term__c=objTerm.id;
        objCourseOff2.Approval_Required_by_School_Head__c = true;
        objCourseOff2.Offered_By_School__c = objAccount.Id;
        insert objCourseOff2; 
        
        
        hed__Course_Offering__c  objCourseOffHC2 = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm1.id,objCourse.id);
        objCourseOffHC2.Category__c = 'Hardcore Course';
        objCourseOffHC2.Sequence__c =1;
        insert objCourseOffHC2;
        
        hed__Course_Offering__c  objCourseOffHI2 = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm1.id,objCourseHI.id);
        objCourseOffHI2.Category__c = 'Hardcore Integrated Course';
        objCourseOffHI2.Sequence__c =1;
        insert objCourseOffHI2;
        
        hed__Course_Offering__c  objCourseOffPWORK2 = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm1.id,objCoursePW.id);
        objCourseOffPWORK2.Category__c = 'Practical/Term Work';
        objCourseOffPWORK2.Sequence__c =1;
        insert objCourseOffPWORK2;
        
        hed__Course_Offering__c  objCourseOffMandatory2 = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm1.id,objCourseMAN.id);
        objCourseOffMandatory2.Category__c = 'Mandatory Course';
        objCourseOffMandatory2.Sequence__c =1;
        insert objCourseOffMandatory2;
        
        hed__Course_Offering__c  objCourseOffProfEle2 = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm1.id,objCourseProf.id);
        objCourseOffProfEle2.Category__c = 'Professional Elective';
        objCourseOffProfEle2.Sequence__c =1;
        objCourseOffProfEle2.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffProfEle2;
        
        hed__Course_Offering__c  objCourseOffOpenEle2 = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm1.id,objCourseOpen.id);
        objCourseOffOpenEle2.Category__c = 'Open Elective';
        objCourseOffOpenEle2.Sequence__c =1;
        objCourseOffOpenEle2.Parent_Course_Offering__c = objCourseOff2.id;
        insert objCourseOffOpenEle2;
        
        
        
        
        Professor_Student_Course_Preference__c objProfStu = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
        objProfStu.Professor__c = objcon.id;
        objProfStu.Preference__c = '1';
        insert objProfStu;
        
        Professor_Student_Course_Preference__c objProfStuHI = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor StudentHI',objCourseOffHI.id,objTerm.id);
        objProfStuHI.Professor__c = objcon.id;
        objProfStuHI.Preference__c = '1';
        insert objProfStuHI;
        
        Professor_Student_Course_Preference__c objProfStuPW = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffPWORK.id,objTerm.id);
        objProfStuPW.Professor__c = objcon.id;
        objProfStuPW.Preference__c = '1';
        insert objProfStuPW;
        
        Professor_Student_Course_Preference__c objProfStuM = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffMandatory.id,objTerm.id);
        objProfStuM.Professor__c = objcon.id;
        objProfStuM.Preference__c = '1';
        insert objProfStuM;
        
        Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffOpenEle.id,objTerm.id);
        objProfStuOE.Professor__c = objcon.id;
        objProfStuOE.Preference__c = '1';
        insert objProfStuOE;
        
        Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffProfEle.id,objTerm.id);
        objProfStuProf.Professor__c = objcon.id;
        objProfStuProf.Preference__c = '1';
        insert objProfStuProf;
        
        list<hed__Course_Offering__c> lstHardCourse = new list<hed__Course_Offering__c>();
        lstHardCourse.add(objCourseOffHC);
        
        list<hed__Course_Offering__c> lstHCIntegrated = new list<hed__Course_Offering__c>();
        lstHCIntegrated.add(objCourseOffHI);
        
        list<hed__Course_Offering__c> lstPractical = new list<hed__Course_Offering__c>();
        lstPractical.add(objCourseOffPWORK);
        
        list<hed__Course_Offering__c> lstProfElective= new list<hed__Course_Offering__c>();
        lstProfElective.add(objCourseOffProfEle);
        
        list<hed__Course_Offering__c> lstMandatory= new list<hed__Course_Offering__c>();
        lstMandatory.add(objCourseOffMandatory);
        
        list<hed__Course_Offering__c> lstOpenElective= new list<hed__Course_Offering__c>();
        lstOpenElective.add(objCourseOffOpenEle); 
        
        hed__Course_Enrollment__c ce = new hed__Course_Enrollment__c();
        ce.hed__Course_Offering__c = objCourseOffHC2.id;
        ce.recordTypeId = facultyRtId;
        ce.hed__Contact__c = objcon.id;
        ce.Section__c = objTerm1.id;
        ce.Order_Count__c = '1';
        insert ce;
        
        hed__Term__c objGrpTerm = new hed__Term__c();
        objGrpTerm.Name = 'test CourseOffering';
        objGrpTerm.hed__Account__c = objAccount.id;
        objGrpTerm.recordTypeId = groupRtId;
        objGrpTerm.Course_Offering__c = objCourseOffProfEle2.id;
        objGrpTerm.hed__Parent_Term__c = objTerm.id;
        objGrpTerm.Group_Number__c = 1;
        insert objGrpTerm;
        
        hed__Term__c objbatchTerm = new hed__Term__c();
        objbatchTerm.Name = 'test CourseOffering';
        objbatchTerm.hed__Account__c = objAccount.id;
        objbatchTerm.recordTypeId = batchId;
        objbatchTerm.hed__Parent_Term__c = objTerm1.id;
        insert objbatchTerm;
        
        test.starttest();
            MSTR_ProfessorAllocationClsV1.getTermDetails(objTerm.id);
            MSTR_ProfessorAllocationClsV1.getProgramPlan(objTerm.id);
            MSTR_ProfessorAllocationClsV1.getPreferencesDetails(objTerm.id,objCourse.id,'Hardcore Course');
            MSTR_ProfessorAllocationClsV1.getprofessorDetails(objTerm.id,objCourse.id,'Hardcore Course');
            MSTR_ProfessorAllocationClsV1.getSectionLst(objTerm.id);
            MSTR_ProfessorAllocationClsV1.getGroupLst(objTerm.id,objCourseProf.id,'Professional Elective');
            MSTR_ProfessorAllocationClsV1.getElectiveDetails(objTerm.id,objCourseProf.id,'Professional Elective');
            
            hed__Course_Enrollment__c ce1 = new hed__Course_Enrollment__c();
            ce1.hed__Course_Offering__c = objCourseOffProfEle.id;
            ce1.recordTypeId = facultyRtId;
            ce1.hed__Contact__c = objcon.id;
            ce1.Section__c = objGrpTerm.id;
            ce1.Order_Count__c = '1';
            insert ce1;
            
            MSTR_ProfessorAllocationClsV1.getprofessorBatchDetails(objTerm.id,objCourseProf.id,'Professional Elective');
            MSTR_ProfessorAllocationClsV1.getprofessorBatchDetails(objTerm.id,objCoursePW.id,'Practical/Term work');
            MSTR_ProfessorAllocationClsV1.getElectiveDetails(objTerm.id,objCourseProf.id,'Professional Elective');
            
            MSTR_ProfessorAllocationClsV1.ProfessorWrap wrp = new MSTR_ProfessorAllocationClsV1.ProfessorWrap();
            wrp.professor = '';
            wrp.professorId = objcon.id;
            wrp.Preference = '1';
            wrp.connectionId = '';
            wrp.section = '';
            wrp.courseOfferingId = objCourseOffHC.id;
            wrp.termId = objTerm.id;
            wrp.isCreated = false;
            wrp.groupId = '';
            wrp.groupName = '';
            
            MSTR_ProfessorAllocationClsV1.ProfessorMainWrap  wrp1 = new MSTR_ProfessorAllocationClsV1.ProfessorMainWrap();
            wrp1.Preferences = '1';
            wrp1.PreferenceCount = 1;
            wrp1.orderCount = '1';
            wrp1.primaryFaculty = objcon.id;
            wrp1.mapProfessor = new map<string,string>();
            wrp1.mapProfessor.put(objcon.id,'proff');
            wrp1.lstPreferences = new list<MSTR_ProfessorAllocationClsV1.ProfessorWrap>();
            wrp1.lstPreferences.add(wrp);
            
            list<MSTR_ProfessorAllocationClsV1.ProfessorMainWrap> lstwrp = new list<MSTR_ProfessorAllocationClsV1.ProfessorMainWrap>{wrp1};
            
            MSTR_ProfessorAllocationClsV1.saveProfessorDetails(objTerm.id,objCourseHI.id,objcon.id,lstwrp,false);
            wrp.isCreated = true;
            wrp.connectionId = ce.id;
            MSTR_ProfessorAllocationClsV1.saveProfessorDetails(objTerm.id,objCourseHI.id,objcon.id,lstwrp,false);
            
            MSTR_ProfessorAllocationClsV1.ProfessorWrap wrp2 = new MSTR_ProfessorAllocationClsV1.ProfessorWrap();
            wrp2.professor = '';
            wrp2.professorId = objcon.id;
            wrp2.Preference = '1';
            wrp2.connectionId = '';
            wrp2.section = '';
            wrp2.courseOfferingId = objCourseOffPWORK2.id;
            wrp2.termId = objTerm.id;
            wrp2.isCreated = false;
            wrp2.groupId = objGrpTerm.id;
            wrp2.groupName = '';
            
            MSTR_ProfessorAllocationClsV1.ProfessorMainWrap mainWrp = new MSTR_ProfessorAllocationClsV1.ProfessorMainWrap();
            mainWrp.Preferences = '1';
            mainWrp.PreferenceCount = 1;
            mainWrp.orderCount = '1';
            mainWrp.primaryFaculty = objcon.id;
            mainWrp.mapProfessor = new map<string,string>();
            mainWrp.mapProfessor.put(objcon.id,'proff');
            mainWrp.lstPreferences = new list<MSTR_ProfessorAllocationClsV1.ProfessorWrap>();
            mainWrp.lstPreferences.add(wrp2);
            
            MSTR_ProfessorAllocationClsV1.groupWrap gwrp = new MSTR_ProfessorAllocationClsV1.groupWrap();
            gwrp.mainProffesors = new list<MSTR_ProfessorAllocationClsV1.ProfessorMainWrap>();
            gwrp.mainProffesors.add(mainWrp);
            list<MSTR_ProfessorAllocationClsV1.groupWrap> lstGwrp = new list<MSTR_ProfessorAllocationClsV1.groupWrap>{gwrp};
            MSTR_ProfessorAllocationClsV1.savePraticalDetails(objTerm.id,objCoursePW.id,objcon.id,lstGwrp,false);
            
            
            MSTR_ProfessorAllocationClsV1.ProfessorWrap wrp3 = new MSTR_ProfessorAllocationClsV1.ProfessorWrap();
            wrp3.professor = '';
            wrp3.professorId = objcon.id;
            wrp3.Preference = '1';
            wrp3.connectionId = '';
            wrp3.section = '';
            wrp3.courseOfferingId = objCourseOffProfEle.id;
            wrp3.termId = objTerm.id;
            wrp3.isCreated = false;
            wrp3.groupId = objGrpTerm.id;
            wrp3.groupName = '';
                        
            MSTR_ProfessorAllocationClsV1.groupElectiveWrp gewrp = new MSTR_ProfessorAllocationClsV1.groupElectiveWrp();
            gewrp.mainProffesors = new list<MSTR_ProfessorAllocationClsV1.ProfessorWrap>();
            gewrp.PreferenceCount = 1;
            gewrp.orderCount = '1';
            gewrp.primaryFaculty = objcon.id;
            gewrp.mainProffesors.add(wrp3);
            list<MSTR_ProfessorAllocationClsV1.groupElectiveWrp> lstGewrp = new list<MSTR_ProfessorAllocationClsV1.groupElectiveWrp>{gewrp};
            MSTR_ProfessorAllocationClsV1.saveProElectiveDetails(objTerm.id,objCourseProf.id,objcon.id,lstGewrp,false);
        test.stopTest();        
    }
}