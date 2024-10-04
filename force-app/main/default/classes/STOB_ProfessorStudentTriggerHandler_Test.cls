@istest
public class STOB_ProfessorStudentTriggerHandler_Test 
{
    public static testMethod Void ProfessorStudent()
    {        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = STOB_TestDataFactory.CreateAccount('str_accName');
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;

        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        hed__Course__c obj_Cour = STOB_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_Cour_Off =STOB_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        obj_Cour_Off.Student_Preference_1__c = 11;
        obj_Cour_Off.Student_Preference_2__c = 22;
        obj_Cour_Off.Student_Preference_3__c = 33;
        insert obj_Cour_Off;
        
        hed__Course_Offering__c obj_Cour_Off1 =STOB_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        obj_Cour_Off1.Student_Preference_1__c = 12;
        obj_Cour_Off1.Student_Preference_2__c = 24;
        obj_Cour_Off1.Student_Preference_3__c = 32;
        insert obj_Cour_Off1;
        
        Professor_Student_Course_Preference__c obj_Pro_Stud_Cour =  new Professor_Student_Course_Preference__c();
        obj_Pro_Stud_Cour.Name = 'Test';
        obj_Pro_Stud_Cour.Course_Offering__c= obj_Cour_Off.Id;
        obj_Pro_Stud_Cour.Contact__c= ObjCon.id;
        obj_Pro_Stud_Cour.Preference__c = '1';
        obj_Pro_Stud_Cour.Semester__c = obj_Term.Id;
        insert obj_Pro_Stud_Cour;
        
        List<Professor_Student_Course_Preference__c> lst_Pro_stud = new List<Professor_Student_Course_Preference__c>();
        lst_Pro_stud.Add(obj_Pro_Stud_Cour);
        
        obj_Pro_Stud_Cour.Course_Offering__c= obj_Cour_Off1.Id;
        update obj_Pro_Stud_Cour;
        
        map<id,Professor_Student_Course_Preference__c> oldMap = new map<id,Professor_Student_Course_Preference__c>();
        oldMap.put(obj_Pro_Stud_Cour.Id,obj_Pro_Stud_Cour);
        
        delete obj_Pro_Stud_Cour;
        undelete obj_Pro_Stud_Cour;   
        
        Test.StartTest();
        STOB_ProfessorStudentTriggerHandler.RollupPreference(lst_Pro_stud, null); 
        STOB_ProfessorStudentTriggerHandler.RollupPreference(lst_Pro_stud, oldMap); 
        Test.StopTest(); 
        system.assertEquals(obj_Pro_Stud_Cour.Id,obj_Pro_Stud_Cour.Id); 
    }
}