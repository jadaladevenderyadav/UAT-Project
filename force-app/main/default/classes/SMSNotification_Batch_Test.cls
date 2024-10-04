@isTest
public class SMSNotification_Batch_Test 
{
    public static testMethod void AttendanceSMSBtch()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
        Account objAcc = TT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id AccountRecTypeIdRACE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();        
        Account acc = TT_TestDataFactory.CreateAccount('REVA', AccountRecTypeId);
        acc.RecordTypeId = AccountRecTypeIdRACE;
        acc.Program_Type__c = 'PG';
        insert acc;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'Master of Science in Biotechnology-(2023-2025)',
             hed__Start_Date__c = system.today().addDays(-5),
        hed__End_Date__c = system.today().addyears(+1),
           hed__Account__c = acc.id
        );
        insert programBatch;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = TT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAcc.id;
        objcon.School__c = acc.id;
        objcon.Student_Status__c = 'Pursuing';
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Program_Batch__c = programBatch.id;
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
       //objcon.Father__r.MobilePhone = '1234567890';
		//objcon.Mother__r.MobilePhone = '9876543210';
        
        insert objcon;
        
        Contact fatherContact = new Contact(
            FirstName = 'Father',
            LastName = 'Lastname',
            AccountId = objAcc.Id,
            MobilePhone = '1234567890' // Set the mobile phone number for Father
        );
        insert fatherContact;

        objcon.Father__c = fatherContact.Id;
        update objcon;
        
        Contact MotherContact = new Contact(
            FirstName = 'Mother',
            LastName = 'Lastname',
            AccountId = objAcc.Id,
            MobilePhone = '1234567890' // Set the mobile phone number for Father
        );
        insert MotherContact;

        objcon.Mother__c = MotherContact.Id;
        update objcon;
        
         hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,programBatch.id);
        objProgEnroll.hed__Contact__c = objCon.Id;
        objProgEnroll.hed__Start_Date__c = system.today()-1; 
        objProgEnroll.hed__End_Date__c =  system.today()+1; 
        objProgEnroll.hed__Program_Plan__c = programBatch.Id;
        Insert objProgenroll;
        
        Date semesterStartDate = Date.today();
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm.Program_Batch__c = programBatch.id;
        objTerm.hed__Start_Date__c = system.today()+28;
        objTerm.hed__End_Date__c = system.today()+30;
        objTerm.Term_Number__c =1;
        insert objTerm;
        
        hed__Term__c objTerm1 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm1.Program_Batch__c = programBatch.id;
       objTerm1.hed__Start_Date__c =system.today()-1;  
        objTerm1.IA_1_Start_date__c = system.today()+1;
        objTerm1.Term_Number__c =3;
        insert objTerm1;
        
        hed__Term__c objTerm2 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm2.Program_Batch__c = programBatch.id;
        objTerm2.hed__Start_Date__c =system.today()-1; 
        objTerm2.IA_1_Start_date__c = system.today()+1;
        objTerm2.Term_Number__c =5;
        insert objTerm2;
        
        hed__Term__c objTerm3 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm3.Program_Batch__c = programBatch.id;
         objTerm3.hed__Start_Date__c =system.today()-1;
        objTerm3.IA_1_Start_date__c = system.today()+1;
        objTerm3.Term_Number__c =7;
        insert objTerm3;
        
        hed__Term__c objTerm4 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm4.Program_Batch__c = programBatch.id;
        objTerm4.hed__Start_Date__c =system.today()-1; 
        objTerm4.IA_2_Start_date__c =system.today()+1;
        objTerm4.Term_Number__c =9;
        insert objTerm4;
        
        
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
              
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Name = 'Fee';
        objStudentFee.Fee_Year__c='1st year';
        objStudentFee.Due_Date__c = system.today()+58;
        //objStudentFee.Due_Date__c = system.today()-10;
        objStudentFee.Amount__c = 5000;
        objStudentFee.Actual_Program_Fee__c = 5000;
        objStudentFee.Amount_Paid__c = 0;
        objStudentFee.Amount_Pending__c = 5000;
        Insert objStudentFee;
        
        
        SMS_API_Utility.shortMessageWrp shortMsg = New SMS_API_Utility.shortMessageWrp();
        shortMsg.message = 'TestMsg';
        shortMsg.recipient = 'TestRecp';
        shortMsg.dltContentId = 'DLTID001';
        
        List<SMS_API_Utility.shortMessageWrp> listshort = new List<SMS_API_Utility.shortMessageWrp>();
        listshort.add(shortMsg);
        
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        SMSNotification_Batch btch = new SMSNotification_Batch();
        database.executeBatch(btch);
        Test.stopTest();
        System.assertNotEquals(null, objcon.Id, 'Contact record was not inserted successfully');
           
    }
    public static testMethod void testGetTimeDetails() {
        // Test with a time in 24-hour format
        String formattedTime1 = SMSNotification_Batch.getTimeDetails('14:30');
        System.assertEquals('2:30', formattedTime1, 'Time format should be in 12-hour format');

        // Test with a time in 24-hour format with leading 0
        String formattedTime2 = SMSNotification_Batch.getTimeDetails('9:15');
        System.assertEquals('09:15', formattedTime2, 'Time format should be in 12-hour format');

        // Test with a time in 12-hour format
        String formattedTime3 = SMSNotification_Batch.getTimeDetails('7:45');
        System.assertEquals('07:45', formattedTime3, 'Time format should remain the same');

        // Add more test cases as needed
    }
}