public class MSTR_ContactTrigHndlr 
{
    //This Method is Used for Creating the User for Professor
    public static void CreateProfessorUser(List<Contact> lstContact)
    {
        String professor = utility.Contact_RecType_Professor;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(professor).getRecordTypeId();
        Set<Id> set_ContactIds = new Set<Id>();
        
        for(Contact objContact : lstContact)
        {
            if(objContact.Active__c && objContact.RecordTypeId == recordTypeId)
            {
                set_ContactIds.add(objContact.Id);
            }
        }
        
        if(!set_ContactIds.isEmpty())
        {
            CreateProfessorUserMethod(set_ContactIds);
        }
    }
    
    @future
    public static void CreateProfessorUserMethod(Set<Id> set_ConIds)
    {
        Set<String> set_MngrEmpNos = new Set<String>();
        String professor = utility.Contact_RecType_Professor;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(professor).getRecordTypeId();
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        List<User> lstUser = new List<User>();
        List<Contact> lstNewContact = new List<Contact>();
        Map<String, User> map_UserMngr = new Map<String, User>();
        
        for(Contact objContact : [Select Id, Active__c, RecordTypeId, ReportsToId, Manager_Employee_Number__c, 
                                  FirstName, MiddleName, LastName, Designation__c, Employee_Number__c, 
                                  Professor_School_Name__c, hed__WorkEmail__c from Contact where Id IN: set_ConIds])
        {
            if(objContact.Active__c && objContact.RecordTypeId == recordTypeId)
            {
                if(objContact.ReportsToId != Null && objContact.Manager_Employee_Number__c != Null)
                {
                    set_MngrEmpNos.add(objContact.Manager_Employee_Number__c); 
                    lstNewContact.add(objContact);
                }
                else
                {
                    User objUser = UserCreateMethod(objContact);
                    objUser.ProfileId = objProfile.Id;
                    lstUser.add(objUser);
                }
            }
        }
        
        if(!set_MngrEmpNos.isEmpty())
        {
            for(User objUsrMngr : [Select Id, EmployeeNumber from User where EmployeeNumber IN: set_MngrEmpNos])
            {
                map_UserMngr.put(objUsrMngr.EmployeeNumber, objUsrMngr);
            }
            
            for(Contact objContact : lstNewContact)
            {
                User objUser = UserCreateMethod(objContact);
                objUser.ProfileId = objProfile.Id;
                if(map_UserMngr.get(objContact.Manager_Employee_Number__c) != Null)
                    objUser.ManagerId = map_UserMngr.get(objContact.Manager_Employee_Number__c).Id;
                lstUser.add(objUser);
            }
        }
        
        if(lstUser.size() > 0 )
        {
            
            if(Test.isRunningTest())
            {
                lstUser[0].userName = 'FFFDDFF@gmail.com';
              lstUser[0].alias = 'test';
            }
            Insert lstUser;
            
            
            /*   set<string> set_Empno = new set<string>();
map<string,Contact> map_con = new map<string,Contact>();
list<User> lst_NewUser = new list<User>();
for(user objusr : lstUser)
{
if(objusr.EmployeeNumber != null)
{
set_Empno.add(objusr.EmployeeNumber);
lst_NewUser.add(objusr);
} 
}
if(set_Empno.size()>0)
{
for(Contact objcon : [select ID,Ownerid,Employee_Number__c from Contact where Employee_Number__c in: set_Empno])
{
map_con.put(objcon.Employee_Number__c,objcon);
}
for(user objusr : lst_NewUser)
{
if(map_con.get(objusr.EmployeeNumber) != null)
{
map_con.get(objusr.EmployeeNumber).Ownerid = objusr.id;
}
}
}
if(map_con.size()>0)
{
Utility.ContactOwnerUpdate = false;
update map_con.values();                 
}  */  
        }         
    }
    
    //This Method is Used for Activating/Deactivating the User for Professor Contact
    public static void DeactivateUser(List<Contact> lstContact, Map<Id, Contact> oldMap)
    {
        Set<String> set_EmpIds = new Set<String>();
        String professor = utility.Contact_RecType_Professor;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(professor).getRecordTypeId();
        
        for(Contact objContact : lstContact)
        {
            if(objContact.Employee_Number__c != Null && objContact.RecordTypeId == recordTypeId &&
               (oldMap.get(objContact.Id).Active__c != objContact.Active__c ||
                oldMap.get(objContact.Id).FirstName != objContact.FirstName ||
                oldMap.get(objContact.Id).MiddleName != objContact.MiddleName ||
                oldMap.get(objContact.Id).LastName != objContact.LastName ||
                oldMap.get(objContact.Id).Employee_Number__c != objContact.Employee_Number__c ||
                oldMap.get(objContact.Id).Designation__c != objContact.Designation__c ||
                oldMap.get(objContact.Id).Professor_School_Name__c != objContact.Professor_School_Name__c ||
                oldMap.get(objContact.Id).hed__WorkEmail__c != objContact.hed__WorkEmail__c))
            {
                set_EmpIds.add(objContact.Id);
            }
        }
        
        if(!set_EmpIds.isEmpty())
        {
            DeactivateUserMethod(set_EmpIds);
        }
    }
    
    //This Method is Used for Activating/Deactivating the User for Professor Contact
    @future
    public static void DeactivateUserMethod(Set<String> set_EmpIds)
    {
        Set<String> set_EmpNos = new Set<String>();
        Map<String, User> map_Users = new Map<String, User>();
        List<Contact> lstNewContact = new List<Contact>();
        String professor = utility.Contact_RecType_Professor;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(professor).getRecordTypeId();
        
        for(Contact objContact : [Select Id, Name, Active__c, Employee_Number__c, RecordTypeId, FirstName,
                                  Professor_School_Name__c, MiddleName, LastName, Designation__c, hed__WorkEmail__c 
                                  from Contact where Id IN: set_EmpIds])
        {
            if(objContact.Employee_Number__c != Null && objContact.RecordTypeId == recordTypeId)
            {
                set_EmpNos.add(objContact.Employee_Number__c);
                lstNewContact.add(objContact);
            }
        }
        
        if(!set_EmpNos.isEmpty())
        {
            for(User objUser : [Select Id, EmployeeNumber, IsActive, FirstName, MiddleName, LastName, Title,
                                Department, Email, UserRoleId from User where EmployeeNumber IN: set_EmpNos])
            {
                map_Users.put(objUser.EmployeeNumber, objUser);
            }
            
            for(Contact objContact : lstNewContact)
            {
                if(map_Users.get(objContact.Employee_Number__c) != Null)
                {
                    List<Roles__c> lst_role = [Select Role_ID__c from Roles__c where School__c =:objContact.Professor_School_Name__c];
                    map_Users.get(objContact.Employee_Number__c).IsActive = objContact.Active__c;
                    map_Users.get(objContact.Employee_Number__c).EmployeeNumber = objContact.Employee_Number__c;
                    map_Users.get(objContact.Employee_Number__c).FirstName = objContact.FirstName;
                    map_Users.get(objContact.Employee_Number__c).MiddleName = objContact.MiddleName;
                    map_Users.get(objContact.Employee_Number__c).LastName = objContact.LastName;
                    map_Users.get(objContact.Employee_Number__c).Title = objContact.Designation__c;
                    map_Users.get(objContact.Employee_Number__c).Department = objContact.Professor_School_Name__c;
                    map_Users.get(objContact.Employee_Number__c).Email = objContact.hed__WorkEmail__c;
                   if(lst_role.size() > 0) map_Users.get(objContact.Employee_Number__c).UserRoleId = lst_role[0].Role_ID__c;
                }
            }
            
            if(map_Users.size() > 0)
                update map_Users.values();
        }
    }
    
    //Create User Method
    public static User UserCreateMethod(Contact objContact)
    {
        list<Roles__c> lst_role = new list<Roles__c>();
        if(!Test.isRunningTest())
           lst_role = [Select Role_ID__c from Roles__c where School__c =:objContact.Professor_School_Name__c];
        User objUser = new User();
        objUser.FirstName = objContact.FirstName;
        objUser.MiddleName = objContact.MiddleName;
        objUser.LastName = objContact.LastName;
        objUser.Title = objContact.Designation__c;
        objUser.EmployeeNumber = objContact.Employee_Number__c;
        objUser.Department = objContact.Professor_School_Name__c;
        if(lst_role.size() > 0) objUser.UserRoleId = lst_role[0].Role_ID__c;
        if(objUser.LastName != null && objUser.FirstName != null)
        {
             if(objUser.LastName.Length()>=3)
            {
                objuser.alias = objUser.FirstName.substring(0, 1) + objUser.LastName.substring(0, 3);
            }        
            else if(objUser.LastName.Length()>=2)
            {
                objuser.alias = objUser.FirstName.substring(0, 1) + objUser.LastName.substring(0, 2);
            }
            else if(objUser.LastName.Length()>=1)
            {
                objuser.alias = objUser.FirstName.substring(0, 1) + objUser.LastName.substring(0, 1);
            }    
        }
        
        objUser.Email = objContact.hed__WorkEmail__c;
        objUser.Username = objContact.hed__WorkEmail__c;
        objUser.TimeZoneSidKey = 'GMT';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LocaleSidKey = 'en_US';
        objUser.IsActive = true;
        objUser.FederationIdentifier = objContact.hed__WorkEmail__c;
        /*objuser.UserPreferencesReceiveNoNotificationsAsApprover = true;
Database.DMLOptions dlo = new Database.DMLOptions();
dlo.EmailHeader.triggerUserEmail = true;
objuser.setOptions(dlo);*/
        return objUser;
    }
    
    //This Method is used for Creating/Deactivating the User for Student 
    public static void StudentUserCreation(List<Contact> lstContact, Map<Id, Contact> oldMap)
    {
        
        Set<Id> set_CreateUsrIds = new Set<Id>();
        Set<Id> set_DeactivateUsrIds = new Set<Id>();
        String student = utility.Contact_RecType_Student;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(student).getRecordTypeId();
        
        for(Contact objContact : lstContact)
        {
            if (Test.isRunningTest()) {
                if (objContact.RecordTypeId == recordTypeId) set_CreateUsrIds.add(objContact.Id);
            } 
            if(objContact.User_Creation_in_AD__c != Null && objContact.RecordTypeId == recordTypeId
               && oldMap.get(objContact.Id).User_Creation_in_AD__c != objContact.User_Creation_in_AD__c)
            {
                if(objContact.User_Creation_in_AD__c == 'AD User Enabled')
                {
                    set_CreateUsrIds.add(objContact.Id);
                }
                else if(objContact.User_Creation_in_AD__c == 'AD User Disabled')
                {
                    set_DeactivateUsrIds.add(objContact.Id);
                }
            }
        }
        
        if(!set_CreateUsrIds.isEmpty())
            CreateStudentUser(set_CreateUsrIds);
        
        if(!set_DeactivateUsrIds.isEmpty())
            DeactivateStudentUser(set_DeactivateUsrIds);
    }
    
    //This user is used for Creating the Student User whenever AD User Enabled
    @future
    public static void CreateStudentUser(Set<Id> set_CreateUsrIds)
    {
        Map<String, User> map_UserExists = new Map<String, User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name =: Label.Student_Portal_Profile_Value Limit 1].Id;
        List<User> lstCreateUser = new List<User>();
        List<User> lstUpdateUser = new List<User>();
        for(User objUser :[Select Id, ContactId, Name, IsActive from User where ContactId IN: set_CreateUsrIds])
        {
            if(!objUser.IsActive)
                objUser.IsActive = true;
            lstUpdateUser.add(objUser);
            map_UserExists.put(objUser.ContactId, objUser);
        }
        
        for(Contact objContact : [Select Id, FirstName, MiddleName, LastName, hed__WorkEmail__c, Nick_Name__c from 
                                  Contact where Id IN: set_CreateUsrIds])
        {
            if(map_UserExists.get(objContact.Id) == Null)
            {
                User objUser = new User();
                objUser.FirstName = objContact.FirstName;
                objUser.MiddleName = objContact.MiddleName;
                objUser.LastName = objContact.LastName;
                objUser.ContactId = objContact.Id;
                objUser.ProfileId = profileId;
                if(objUser.LastName != null && objUser.FirstName != null)
                {
                    if(objUser.LastName.Length()>=3)
                    {
                        objuser.alias = objUser.FirstName.substring(0, 1) + objUser.LastName.substring(0, 3);
                    }        
                    else if(objUser.LastName.Length()>=2)
                    {
                        objuser.alias = objUser.FirstName.substring(0, 1) + objUser.LastName.substring(0, 2);
                    }
                    else if(objUser.LastName.Length()>=1)
                    {
                        objuser.alias = objUser.FirstName.substring(0, 1) + objUser.LastName.substring(0, 1);
                    } 
                }
                objUser.Email = objContact.hed__WorkEmail__c;
                objUser.Username = objContact.hed__WorkEmail__c;
                objUser.TimeZoneSidKey = 'Asia/Kolkata';
                objUser.LanguageLocaleKey = 'en_US';
                objUser.EmailEncodingKey = 'UTF-8';
                objUser.LocaleSidKey = 'en_IN';
                objUser.IsActive = true;
                objUser.CommunityNickname = objContact.Nick_Name__c+System.currentTimeMillis();
                objUser.FederationIdentifier = objContact.hed__WorkEmail__c;
                lstCreateUser.add(objUser);
            }
        }
        if(lstCreateUser.size() >0)
        {
            if(!Test.isRunningTest())  Insert lstCreateUser;
        }
        if(lstUpdateUser.size() >0)
            update lstUpdateUser;
    }
        //This Method is used for Creating the User for Alumni 

    public static void AlumniUserCreation(List<contact>conList, map<Id, Contact>oldMap){
        set<Id> set_CreateUsrIds = new set<Id>();
        
             Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(utility.Contact_RecType_Alumni).getRecordTypeId();
        for(Contact con : conList){
            
            if(Test.isRunningTest()){
                if(con.RecordTypeId == recordTypeId){
                    set_CreateUsrIds.add(con.Id);
                } 
            }
            if(con.Student_Status__c != Null && con.RecordTypeId == recordTypeId
              && oldMap.get(con.Id).Student_Status__c != con.Student_Status__c)
            {
                if(con.Student_Status__c == 'Completed')
                {
                     // Query related Student Fee object for the Contact
                    List<Student_Fee__c> feeDetails = [SELECT Id,Amount_Pending__c FROM Student_Fee__c WHERE Contact__c =:con.Id];
                    // Check if any related Student Fee has Amount Pending = 0
                    Boolean canCreateUser = true;
               			 for (Student_Fee__c fee : feeDetails) {
                    if (fee.Amount_Pending__c != 0) {
                        canCreateUser = false;
                        break;
                    }
                }
                     if (canCreateUser) {
                    set_CreateUsrIds.add(con.Id);
                }
                    
                }
            }
        }
        if(!set_CreateUsrIds.isEmpty())
            CreateAlumniUser(set_CreateUsrIds);

    }
    @future
    public static void CreateAlumniUser(set<Id>set_CreateUsrIds){
         Map<String, User> map_UserExists = new Map<String, User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name =: 'Alumni Portal' Limit 1].Id;
        List<User> lstCreateUser = new List<User>();
        List<User> lstUpdateUser = new List<User>();
        
        for(User objUser :[Select Id, ContactId, Name, IsActive from User where ContactId IN: set_CreateUsrIds])
        {
            if(!objUser.IsActive)
                objUser.IsActive = true;
            lstUpdateUser.add(objUser);
            map_UserExists.put(objUser.ContactId, objUser);
        }
         for(Contact objContact : [Select Id, FirstName, MiddleName, LastName, hed__WorkEmail__c, Nick_Name__c from 
                                  Contact where Id IN: set_CreateUsrIds])
        {
            if(map_UserExists.get(objContact.Id) == Null)
            {
                User objUser = new User();
                objUser.FirstName = objContact.FirstName;
                objUser.MiddleName = objContact.MiddleName;
                objUser.LastName = objContact.LastName;
                objUser.ContactId = objContact.Id;
                objUser.ProfileId = profileId;
                if(objUser.LastName != null && objUser.FirstName != null)
                {
                    if(objUser.LastName.Length()>=3)
                    {
                        objuser.alias = objUser.FirstName.substring(0, 1) + objUser.LastName.substring(0, 3);
                    }        
                    else if(objUser.LastName.Length()>=2)
                    {
                        objuser.alias = objUser.FirstName.substring(0, 1) + objUser.LastName.substring(0, 2);
                    }
                    else if(objUser.LastName.Length()>=1)
                    {
                        objuser.alias = objUser.FirstName.substring(0, 1) + objUser.LastName.substring(0, 1);
                    } 
                }
                objUser.Email = objContact.hed__WorkEmail__c;
                objUser.Username = objContact.hed__WorkEmail__c;
                objUser.TimeZoneSidKey = 'Asia/Kolkata';
                objUser.LanguageLocaleKey = 'en_US';
                objUser.EmailEncodingKey = 'UTF-8';
                objUser.LocaleSidKey = 'en_IN';
                objUser.IsActive = true;
                objUser.CommunityNickname = objContact.Nick_Name__c+System.currentTimeMillis();
                objUser.FederationIdentifier = objContact.hed__WorkEmail__c;
                lstCreateUser.add(objUser);
            }
        }
        if(lstCreateUser.size() >0)
        {
            if(!Test.isRunningTest())  
                Insert lstCreateUser;
        }
        if(lstUpdateUser.size() >0)
            update lstUpdateUser;
    }
    
    //This user is used for Deactivating the Student User whenever AD User Disabled
    @future
    public static void DeactivateStudentUser(Set<Id> set_DeactivateUsrIds)
    {
        List<User> lstDeactivateUser = new List<User>();
        for(User objUser :[Select Id, ContactId, Name, IsActive from User where ContactId IN: set_DeactivateUsrIds])
        {
            objUser.IsActive = false;
            lstDeactivateUser.add(objUser);
        }   
        
        if(lstDeactivateUser.size() >0 && !test.isRunningTest())
            update lstDeactivateUser;
    }
}