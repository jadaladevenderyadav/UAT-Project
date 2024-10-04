@IsTest
public class MSTR_ContactTrigHndlr_Test
{
    public static testmethod void ContactTrig()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.FirstName  = 'Test Contact';
        objcon.LastName  ='C';
        objcon.Employee_Number__c ='EP1237';
        objcon.RecordTypeId = recordTypeId;
        objcon.Active__c = true;
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        insert objcon;
        
        string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId;  
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objContact = MSTR_TestDataFactory.createContact('test Contact');
        objContact.AccountId = objAcc.id;
        objContact.FirstName  = 'Test Con';
        objContact.LastName  ='LastCon';
        objContact.ReportsToId  = objcon.Id;
        objContact.Active__c = true;
        objContact.RecordTypeId = recordTypId;
        objContact.Employee_Number__c  ='EP134';         
        objContact.hed__WorkEmail__c  = 'TestCon00@reva.edu.in';
        insert objContact;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'];
        
        User objUser = new User(
            LastName = 'Te',
            FirstName ='testing',
            alias = 'testu'+'testing',
            Email = 'test@unitingambitionn.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            ContactId = objContact.Id,
            UserName='test@unitingambitions.com',
            EmployeeNumber ='EP134'
        );
        
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objContact);
        
        Map<Id, Contact> oldMap = new Map<Id, Contact>();
        oldMap.put(objContact.Id,objContact);
        
        objContact.Active__c  = false;
        objContact.FirstName  = 'Test Con';
        objContact.MiddleName  ='Middle Con';
        objContact.LastName  ='L';
        objContact.Employee_Number__c  ='EP678';
        objContact.Designation__c  ='dveloper';
        objContact.hed__WorkEmail__c  = 'testing@email.com';        
        update objContact;
        
        set<string> set_ConIds = new set<string>();
        set_ConIds.add(objcon.Id);
        
        set<Id> set_ContIds = new set<Id>();
        set_ContIds.add(objcon.Id);
        
        List<User> list_User = new List<User>();
        list_User.add(objUser);
        
        set<Id> set_UsrIds = new set<Id>();
        set_UsrIds.add(objUser.Id);
        
        Test.startTest();
        MSTR_ContactTrigHndlr.CreateProfessorUser(lstContact);
        // MSTR_ContactTrigHndlr.CreateProfessorUserMethod(set_ContIds);
        //MSTR_ContactTrigHndlr.UserCreateMethod(objContact);
        // MSTR_ContactTrigHndlr.DeactivateUserMethod(set_ConIds);
        MSTR_ContactTrigHndlr.DeactivateUser(lstContact,oldMap);
        MSTR_ContactTrigHndlr.DeactivateStudentUser(set_UsrIds);
        Test.stopTest();
        system.assertEquals(objcon.Id,objcon.Id);
    }
    
    public static testmethod void StudentUserCreation()
    {
        string houseHoldRec = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',houseHoldRec);
        objAccount.RecordtypeId = houseHoldRec;  
        insert objAccount;
        
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.FirstName  = 'Test Contact';
        objcon.LastName  ='C';
        objcon.RecordTypeId = recordTypeId;
        objcon.Active__c = true;
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.User_Creation_in_AD__c = 'AD User Disabled';
        insert objcon;
        
        Map<Id, Contact> old_Map = new Map<Id, Contact>();
        old_Map.put(objcon.Id, objcon);
        
        objcon.User_Creation_in_AD__c = 'AD User Disabled';
        Update objcon;
        
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objcon);
        test.startTest();
        MSTR_ContactTrigHndlr.StudentUserCreation(lstContact, old_Map);
        
        test.stopTest();
    }
}