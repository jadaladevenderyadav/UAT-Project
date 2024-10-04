@isTest
public class STOB_TestDataFactory_Test
{
    public static testMethod Void testDataMethod()
    {
        Account objAccount = STOB_TestDataFactory.CreateAccount('Test Account');
        insert objAccount;
        Contact objCon = STOB_TestDataFactory.createContact('Test Contact');
        insert objcon;
        System.debug('objcon=> '+objcon.Id);
        hed__Education_History__c objEdhis = STOB_TestDataFactory.createEducationHistory(objCon.Id);
        insert objEdhis;
        System.debug('objEdhis=> '+objEdhis);
        hed__Program_Plan__c  objProgPlan =  STOB_TestDataFactory.createProgramPlan('Test Program Plan');
        insert objProgPlan;
        System.debug('objProgPlan=> '+objProgPlan);
        hed__Program_Enrollment__c objProgEroll = STOB_TestDataFactory.createprogramEnrollment(objProgPlan.Id);
        objProgEroll.hed__Contact__c = objcon.Id;
        insert objProgEroll;
        System.debug('objProgEroll=> '+objProgEroll);
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
        hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        insert objTerm;
        System.debug('objTerm=> '+objTerm);
        hed__Course__c objcourse = STOB_TestDataFactory.CreateCourse('test course',objAccount.id);
        insert objcourse;
        System.debug('objcourse=> '+objcourse);
        hed__Course_Offering__c objCourseOff = STOB_TestDataFactory.createCourseOffering('Test CourseOffering',objTerm.id,objcourse.id);
        insert objCourseOff;
        System.debug('objCourseOff=> '+objCourseOff);
       // Professor_Student_Course_Preference__c  objProfcourse = STOB_TestDataFactory.CreateProfessorStudent('Test Professor',objCourseOff.Id,objTerm.Id);
    }

}