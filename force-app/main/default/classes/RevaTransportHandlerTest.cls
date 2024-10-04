@isTest
private class RevaTransportHandlerTest {

    @isTest
    static void testRevaTransportRegPage() {
                Id StudentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();

        Contact cons = new Contact(FirstName= 'test name',
                                  LastName='Name',
                                 // Active_Semester__c = sem.Id,
                                  Application_Number__c = '1223467',
                                  Select_Category__c ='	Karnataka',
                                  //Father_Name__c= 'rahul',
                                  recordTypeId=StudentRecordTypeId,
                                  Mother_Name__c='sobha',
                                  Email='testuser@example12.com'                                
                                 );
              
        insert cons; 
       // Contact obj2=testDataFactory.createContact();
        Profile p = [SELECT Id, profile.Name FROM Profile WHERE Name='Student Portal Profile'];
        User testUser = new User(
            contactId = cons.Id,
            ProfileId = p.Id,
            LastName = 'TestLastName1',
            FirstName = 'TestFirstName1',
            Email = 'testuser@example12.com',
            UserName = 'testuser@example12.com',
            Alias = 'testuse',
            CommunityNickname = 'testuser1234',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        hed__Term__c sem =testDataFactory.createSemester();
        Id UniversityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        system.runAs(testUser){
        
           // RTR_Route_Master__c obj1 = testDataFactory.createRouteMaster();
           // Transport_Registeration__c obj3 = testDataFactory.createTransport();
           Transport_Registeration__c tt=new Transport_Registeration__c();
            tt.Contact__c=cons.id;
            insert tt;
           
            Test.startTest();
            Transport_Registeration__c result = RevaTransportHandler.revaTransportRegPage();
            RevaTransportHandler.ContactDetails();
               
        Test.stopTest();
        System.assertNotEquals(null, result);
        }
    }

    @isTest
    static void testRevaTransportPortal() {
        // Call the RevaTransportHandler method
        Test.startTest();
        List<Reva_Transport__c> result = RevaTransportHandler.revaTransportPortal();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
}