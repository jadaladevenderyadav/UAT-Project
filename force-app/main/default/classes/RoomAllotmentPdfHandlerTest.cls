@isTest
private class RoomAllotmentPdfHandlerTest {
    @isTest
    static void testConstructor() {
        // Create test data
        Date testDate = Date.today();
        String dateParam = String.valueOf(testDate);
        String TimeParam = '11:00:00:000';
        Test.setCurrentPageReference(new PageReference(''));
        ApexPages.currentPage().getParameters().put('DatePass', dateParam);
        ApexPages.currentPage().getParameters().put('TimePass', TimeParam);
        
        Profile p = [Select Id from profile where name = 'Professor'];
        
         User u = new User(
         FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(), // unique username
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        
        );
        
        insert u;
        // Create test records
        Account acc = new Account(Name = 'Test School',Examination_Vertical_Head__c = u.Id);
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestIAProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        hed__Term__c Semester = new hed__Term__c(
            Name = 'TestSemester',
            hed__Account__c = acc.Id,
            hed__Start_Date__c = System.today(),
            hed__End_Date__c = System.today(),
            Term_Number__c = 1,
            Program_Batch__c = ProgramBatch.Id
        );
        
        insert Semester;
        
        RecordType ExamNotificationRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Rve_Exam_Notification__c' and DeveloperName='hed_IA_Notification'];
        
        Rve_Exam_Notification__c TestNotification = new Rve_Exam_Notification__c();
        TestNotification.Name = 'TestExamNotification';
        TestNotification.rve_Exam_Start_Date__c = System.Today();
        TestNotification.Rve_Publish__c = true;
        TestNotification.hed_Program_Batch__c = ProgramBatch.Id;
        TestNotification.hed_IA_Type__c = 'IA 1';
        TestNotification.RecordTypeId = ExamNotificationRecordType.Id;
        TestNotification.Rve_Semester__c = Semester.Id;
        insert TestNotification;
        
        System.debug('ExamNotification=> '+TestNotification);
        
        hed__Course__c Course = new hed__Course__c(
            Name = 'Test Course',
            hed__Account__c = acc.Id
        );
        
        insert Course;
        
        hed_Time_Table_Line_Item__c TimeTableItem = new hed_Time_Table_Line_Item__c();
        TimeTableItem.Name = 'TestTimeTable';
        TimeTableItem.Reva_Exam_Notification__c = TestNotification.Id;
        TimeTableItem.hed_Date__c = System.today();
        TimeTableItem.hed_Start_Time__c = Time.newInstance(11, 0, 0, 0);
        TimeTableItem.hed_End_Time__c = Time.newInstance(12, 0, 0, 0);
        TimeTableItem.Course__c = Course.Id;

        insert TimeTableItem;
        
        System.debug('TimeTableItem=> '+TimeTableItem);
        
        hed__Facility__c Facility = new hed__Facility__c(
            Name = 'Test Facility',
            hed__Capacity__c = 50,
            Facility_Booked__c = false,
            Room_Name__c = 'TESLA LAB',
            Room__c = '301',
            Floor__c = '1st floor',
            Block__c = 'C.V. Raman Block',
            IA_Type__c = 'IA 1',
            hed__Account__c = acc.Id
        );
        insert Facility;
        
        IA_Seating_Room_Allotment__c SeatingRoom = new IA_Seating_Room_Allotment__c(
            Name = Facility.Room__c,
            Facility_Type__c = Facility.Id,
            Capacity__c = Facility.hed__Capacity__c,
            IA_Type__c = Facility.IA_Type__c,
            School__c = acc.Id,
            Room__c = Facility.Room__c,
            Active__c = true,
            rve_Date_of_Exam__c = Date.today(),
            rveShift__c = 'Morning',
            Exam_Time__c = Time.NewInstance(11, 0, 0, 0),
            End_Time__c = Time.NewInstance(12, 0, 0, 0),
            Alloted_Students__c = 'SA001,SA002',
            InEligible_SRN__c = 'SA003,SA004',
            Course_Name__c = 'Electronic Circuit',
            Exam_Name__c = TestNotification.Name,
            Assigned_Program_Batches__c = ProgramBatch.Id,
            Total_Students__c = 4
        ); 
        
        insert SeatingRoom;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            SRN_Number__c = 'SA001',
            Program_Batch__c = ProgramBatch.Id
        );
        insert testContact;
        
        Contact testContact2 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact2',
            SRN_Number__c = 'SA003',
            Program_Batch__c = ProgramBatch.Id
        );
        insert testContact2;
    
        System.runas(u){
        // Call constructor
        Test.startTest();
        RoomAllotmentPdfHandler handler = new RoomAllotmentPdfHandler(new ApexPages.StandardController(new IA_Seating_Room_Allotment__c()));
        Test.stopTest();
        
        }
    }

    @isTest
    static void testCheckEvenOdd() {
        // Test the checkEvenOdd method
        System.assertEquals('Odd', RoomAllotmentPdfHandler.checkEvenOdd(1));
        System.assertEquals('Even', RoomAllotmentPdfHandler.checkEvenOdd(2));
        System.assertEquals('Odd', RoomAllotmentPdfHandler.checkEvenOdd(3));
        System.assertEquals('Even', RoomAllotmentPdfHandler.checkEvenOdd(4));
    }
}