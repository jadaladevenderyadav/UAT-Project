@isTest
public class MSTR_DefineProfessorCourseV1_Ctrl_Test 
{
    public static testMethod Void ProfessorMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
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
        
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today().adddays(-16); 
        objTerm.hed__End_Date__c =system.today().adddays(16);
        objTerm.Approval_Status__c = 'Confirmed';
        insert objTerm;
        
        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.Course_Across_the_School__c= true;
        objCourse.HardCore_Sub_Type__c ='Theory';
        objCourse.hed__Course_ID__c = '123';
        insert objCourse; 
        
        hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseHI.Category__c = 'Hardcore Integrated Course';
        objCourseHI.hed__Course_ID__c = '1234';
        objCourseHI.Course_Across_the_School__c= true;
        insert objCourseHI; 
        
        hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCoursePW.Category__c = 'Practical/Term Work';
        objCoursePW.hed__Course_ID__c = '12348';
        objCoursePW.Course_Across_the_School__c= true;
        insert objCoursePW; 
        
        hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseMAN.Category__c = 'Mandatory Course';
        objCourseMAN.hed__Course_ID__c = '12347';
        objCourseMAN.Course_Across_the_School__c= true;
        insert objCourseMAN; 
        
        hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseOpen.Category__c = 'Open Elective';
        objCourseOpen.hed__Course_ID__c = '12346';
        objCourseOpen.Course_Across_the_School__c= true;
        insert objCourseOpen;
        
        hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseProf.Category__c = 'Professional Elective';
        objCourseProf.hed__Course_ID__c = '12345';
        objCourseProf.Course_Across_the_School__c= true;
        insert objCourseProf; 
        
        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        objCourseOff1.Active__c = true;
        objCourseOff1.hed__Course__c = objCourse.Id;
        objCourseOff1.hed__Term__c=objTerm.id;
        objCourseOff1.Approval_Required_by_School_Head__c = true;
        objCourseOff1.Offered_By_School__c = objAccount.Id;
        insert objCourseOff1;         
        
        hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOffHC.Category__c = 'Hardcore Course';
        objCourseOffHC.Sequence__c =1;
        objCourseOffHC.Offered_By_School__c = objAccount.Id;
        insert objCourseOffHC;
        
        hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseHI.id);
        objCourseOffHI.Category__c = 'Hardcore Integrated Course';
        objCourseOffHI.Sequence__c =1;
        objCourseOffHI.Offered_By_School__c = objAccount.Id;
        insert objCourseOffHI;
        
        hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);
        objCourseOffPWORK.Category__c = 'Practical/Term Work';
        objCourseOffPWORK.Sequence__c =1;
        objCourseOffPWORK.Offered_By_School__c = objAccount.Id;
        insert objCourseOffPWORK;
        
        hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseMAN.id);
        objCourseOffMandatory.Category__c = 'Mandatory Course';
        objCourseOffMandatory.Sequence__c =1;
        objCourseOffMandatory.Offered_By_School__c = objAccount.Id;
        insert objCourseOffMandatory;
        
        hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseProf.id);
        objCourseOffProfEle.Category__c = 'Professional Elective';
        objCourseOffProfEle.Sequence__c =1;
        objCourseOffProfEle.Offered_By_School__c = objAccount.Id;
        objCourseOffProfEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffProfEle;
        
        hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOffOpenEle.Category__c = 'Open Elective';
        objCourseOffOpenEle.Sequence__c =1;
        objCourseOffOpenEle.Offered_By_School__c = objAccount.Id;
        objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffOpenEle;
        
        Professor_Student_Course_Preference__c objProfStu = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
        objProfStu.Professor__c = objcon.id;
        insert objProfStu;
        
        Professor_Student_Course_Preference__c objProfStuHI = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor StudentHI',objCourseOffHI.id,objTerm.id);
        objProfStuHI.Professor__c = objcon.id;
        insert objProfStuHI;
        
        Professor_Student_Course_Preference__c objProfStuPW = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffPWORK.id,objTerm.id);
        objProfStuPW.Professor__c = objcon.id;
        insert objProfStuPW;
        
        Professor_Student_Course_Preference__c objProfStuM = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffMandatory.id,objTerm.id);
        objProfStuM.Professor__c = objcon.id;
        insert objProfStuM;
        
        Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffOpenEle.id,objTerm.id);
        objProfStuOE.Professor__c = objcon.id;
        insert objProfStuOE;
        
        Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffProfEle.id,objTerm.id);
        objProfStuProf.Professor__c = objcon.id;
        insert objProfStuProf;
        
        hed__Course_Offering__c obh = new hed__Course_Offering__c();
        obh =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
              hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c 
              from  hed__Course_Offering__c where id =: objCourseOffHC.id
              and   Course_ID__c =:objCourse.hed__Course_ID__c limit 1];
        
        hed__Course_Offering__c obh1 = new hed__Course_Offering__c();
        obh1 =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
               hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c 
               from  hed__Course_Offering__c where id =: objCourseOffHI.id
               and   Course_ID__c =:objCourseHI.hed__Course_ID__c limit 1];
        
        hed__Course_Offering__c obh2 = new hed__Course_Offering__c();
        obh2 =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
               hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c 
               from  hed__Course_Offering__c where id =: objCourseOffPWORK.id
               and   Course_ID__c =:objCoursePW.hed__Course_ID__c limit 1];
        
        hed__Course_Offering__c obh3 = new hed__Course_Offering__c();
        obh3 =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
               hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c 
               from  hed__Course_Offering__c where id =: objCourseOffProfEle.id
               and   Course_ID__c =:objCourseProf.hed__Course_ID__c limit 1];
        
        hed__Course_Offering__c obh4 = new hed__Course_Offering__c();
        obh4 =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
               hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c 
               from  hed__Course_Offering__c where id =: objCourseOffMandatory.id
               and   Course_ID__c =:objCourseMAN.hed__Course_ID__c limit 1];
        
        list<hed__Course_Offering__c> lstHardCourse = new list<hed__Course_Offering__c>();
        lstHardCourse.add(obh); //objCourseOffHC
        
        list<hed__Course_Offering__c> lstHCIntegrated = new list<hed__Course_Offering__c>();
        lstHCIntegrated.add(obh1); //objCourseOffHI
        
        list<hed__Course_Offering__c> lstPractical = new list<hed__Course_Offering__c>();
        lstPractical.add(obh2); //objCourseOffPWORK
        
        list<hed__Course_Offering__c> lstProfElective= new list<hed__Course_Offering__c>();
        lstProfElective.add(obh3);//objCourseOffProfEle
        
        list<hed__Course_Offering__c> lstMandatory= new list<hed__Course_Offering__c>();
        lstMandatory.add(obh4);//objCourseOffMandatory
        
        list<hed__Course_Offering__c> lstOpenElective= new list<hed__Course_Offering__c>();
        lstOpenElective.add(objCourseOffOpenEle); 
        
        /* list<hed__Course_Offering__c> lstHardCourse = new list<hed__Course_Offering__c>();
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
lstOpenElective.add(objCourseOffOpenEle); */
        
        test.starttest();
        MSTR_DefineProfessorCourseV1_Ctrl.DisplaySchools();
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayProgram(objAccount.id,true,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayProgram(objAccount.id,false,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayProgramPlan(objAccount1.id,false,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayProgramPlan(objAccount1.id,true,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayTerm(objProgPlan.id,false,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayTerm(objProgPlan.id,true,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOfferingRecords(objTerm.id,true,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOfferingRecords(objTerm.id,false,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOfferingRecords(objTerm.id,true,objAccount.Name,'');
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOfferingRecords(objTerm.id,false,objAccount.Name,'');
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOffering(objTerm.id,true,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOffering(objTerm.id,false,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOffering(objTerm.id,false,objAccount.Name,'');
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOffering(objTerm.id,true,objAccount.Name,'');
        MSTR_DefineProfessorCourseV1_Ctrl.CreateProfessorCourseRecords(lstHardCourse,lstHCIntegrated,lstPractical,lstOpenElective,lstProfElective,lstMandatory,true,objTerm.Id);
        MSTR_DefineProfessorCourseV1_Ctrl.ValidationPreferences(lstHardCourse,lstHCIntegrated,lstPractical,lstOpenElective,lstProfElective,lstMandatory,null,true);
        MSTR_DefineProfessorCourseV1_Ctrl.ValidationPreferences(lstHardCourse,lstHCIntegrated,lstPractical,lstOpenElective,lstProfElective,lstMandatory,null,false);
        MSTR_DefineProfessorCourseV1_Ctrl.getPreference();
        test.stoptest();
        system.assertequals(objCourseOff1.id,objCourseOff1.id);
    }
    public static testMethod Void ValidationsMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.School__c = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';
        objcon.MobilePhone ='8963210547';
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
        
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today().adddays(-16); 
        objTerm.hed__End_Date__c =system.today().adddays(16);
        objTerm.Approval_Status__c = 'Confirmed';
        insert objTerm;
        
        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.HardCore_Sub_Type__c ='Theory';
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
        insert objCourseOff1; 
        
        hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOffHC.Category__c = 'Hardcore Course';
        objCourseOffHC.Sequence__c =1;
        objCourseOffHC.Preference__c ='1';
        insert objCourseOffHC;
        
        hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseHI.id);
        objCourseOffHI.Category__c = 'Hardcore Integrated Course';
        objCourseOffHI.Sequence__c =1;
        objCourseOffHI.Preference__c ='1';
        insert objCourseOffHI;
        
        hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);
        objCourseOffPWORK.Category__c = 'Practical/Term Work';
        objCourseOffPWORK.Sequence__c =1;
        objCourseOffPWORK.Preference__c ='1';
        insert objCourseOffPWORK;
        
        hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseMAN.id);
        objCourseOffMandatory.Category__c = 'Mandatory Course';
        objCourseOffMandatory.Sequence__c =1;
        objCourseOffMandatory.Preference__c ='1';
        insert objCourseOffMandatory;
        
        hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseProf.id);
        objCourseOffProfEle.Category__c = 'Professional Elective';
        objCourseOffProfEle.Sequence__c =1;
        objCourseOffProfEle.Preference__c ='1';
        objCourseOffProfEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffProfEle;
        
        hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOffOpenEle.Category__c = 'Open Elective';
        objCourseOffOpenEle.Sequence__c =1;
        objCourseOffOpenEle.Preference__c ='1';
        objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffOpenEle;
        
        Professor_Student_Course_Preference__c objProfStu = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
        objProfStu.Professor__c = objcon.id;
        insert objProfStu;
        
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
        
        test.starttest();
        MSTR_DefineProfessorCourseV1_Ctrl.DisplaySchools();
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayProgram(objAccount.id,true,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayProgramPlan(objAccount1.id,false,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayTerm(objProgPlan.id,false,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOffering(objTerm.id,true,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.DisplayCourseOffering(objTerm.id,false,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.ValidationPreferences(lstHardCourse,lstHCIntegrated,lstPractical,lstOpenElective,lstProfElective,lstMandatory,null,true);
        test.stoptest();
        system.assertequals(objCourseOff1.id,objCourseOff1.id);       
    }
    public static testMethod Void DisplayEleseMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = false;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        insert objcon;
        
        test.starttest();
        MSTR_DefineProfessorCourseV1_Ctrl.DisplaySchools();
        test.stoptest();
    }
}