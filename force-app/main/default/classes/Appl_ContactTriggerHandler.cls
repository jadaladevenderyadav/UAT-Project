public without sharing class Appl_ContactTriggerHandler {
    
    public static final string APPL_RT_NAME = 'Applicant';
    
    public static void applicantUserCreation(List<Contact> contactsList, Map<Id,Contact> oldMap){
        List<Contact> conRec = new List<Contact>();
        Set<Id> contactIds = new Set<Id>();
        set<Id> batchContactIds = new Set<Id>();
        for (Contact c : contactsList){
            if (c.Record_Type_Name__c == 'Applicant' &&
                oldMap.get(c.id).Application_Fee_Paid__c != c.Application_Fee_Paid__c &&
                c.Application_Fee_Paid__c == true){
                    if (!System.isBatch()){ //Future methods cannot be called from batch
                        contactIds.add(c.Id);
                    }
                    else
                    {
                        batchContactIds.add(c.Id);
                    }
                }
        }
        
        
        /* Custom Metadata can be used to configure Test_Mode to avoid user creation during testing other features. */
        if(!contactIds.isEmpty() || !batchContactIds.isEmpty()){
            try{
                if(!contactIds.isEmpty()){
                    createApplicantUser(contactIds);
                }
                else if(!batchContactIds.isEmpty()){
                    conRec = [select id, Application_Fee_Paid__C,Record_Type_Name__c,MobilePhone,Country_Code__c,Application_Number__C from contact where Id IN : batchContactIds];
                    System.enqueueJob(new QueueableSendApplicationNumberSMS(conRec));
                    
                }
                
            }
            catch (Exception e){
                System.debug('Exception Error:'+ e);
            }
        }
    }
    
    @future
    public static void createApplicantUser(Set<Id> contactIds){
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = : 'Applicant Profile'].Id;
        Organization orgDetails = [Select Name, IsSandbox from Organization Limit 1];
        
        List<User> usersToBeCreated = new List<User>();
        List<User> users = [Select Id, ContactId from User Where ContactId In : contactIds];
        
        if(users.size() == 0){ //All contacts do not have user records
            for(List<Contact> contacts : [Select Id, FirstName, MiddleName, LastName, Email, Application_Number__c, Nick_Name__c,
                                          Record_Type_Name__c, Application_Fee_Paid__c, MobilePhone from Contact
                                          Where Id in : contactIds]){
                                              
                                              for(Contact c :contacts){
                                                  usersToBeCreated.add(setUserInfo(c, profileId, orgDetails));  
                                              }                                   
                                          }
        }else{ //Few contacts have user records. Creates for those who doesnt have user records.
            Map<Id,User> contactIdUserMap = new Map<Id,USer>();
            
            for(User u : users){
                contactIdUserMap.put(u.ContactId, u);
            }
            
            for(Contact c : [Select Id, FirstName, MiddleName, LastName, Email, Application_Number__c, Nick_Name__c,
                             Record_Type_Name__c, Application_Fee_Paid__c, MobilePhone from Contact
                             Where Id in : contactIds]){
                                 if(!contactIdUserMap.keySet().contains(c.Id)){
                                     usersToBeCreated.add(setUserInfo(c, profileId, orgDetails));
                                 }
                             }
        }
        if(!Test.isRunningTest()){
            system.debug('the user >>'+JSON.serializePretty(usersToBeCreated));
            insert usersToBeCreated;
        }
    }
    
    
    private static User setUserInfo(Contact c, String profileId, Organization orgDetails){
        
        User applUser = new User();
        String userFullName = c.FirstName + c.LastName;
        
        applUser.FirstName = c.FirstName;
        applUser.MiddleName = c.MiddleName;
        applUser.LastName = c.LastName;
        applUser.ContactId = c.Id;
        applUser.ProfileId = profileId;
        applUser.Email = c.Email;
        applUser.MobilePhone = c.MobilePhone;
        applUser.TimeZoneSidKey = 'Asia/Kolkata'; // CAN BE SET ALSO BASED ON THE COUNTRY OF THE CONTACT
        applUser.LanguageLocaleKey = 'en_US';
        applUser.EmailEncodingKey = 'UTF-8';
        applUser.LocaleSidKey = 'en_IN';
        applUser.IsActive = true;
        applUser.CommunityNickname = c.Nick_Name__c + System.currentTimeMillis();
        applUser.FederationIdentifier = c.Email;
        applUser.UserPreferencesDisableMessageEmail = true;
        
        
        if(userFullName.length() > 8){
            applUser.alias = userFullName.substring(0,8);
        }
        else {
            applUser.alias = userFullName;
        }
        
        if(orgDetails.IsSandbox){
            applUser.Username = c.Application_Number__c+ '@' + 'reva.edu.in.' + orgDetails.Name.deleteWhiteSpace();
        }else{
            applUser.Username = c.Application_Number__c+ '@' + 'reva.edu.in';
        }
        
        return applUser;
    }
    
    public static void updateContactSource(Map<Id,Contact> oldContactMap, List<Contact> newContacts){
        
        for(Contact eachContact : newContacts){

            if(eachContact.Record_Type_Name__C == APPL_RT_NAME){
                // Making sure that the update is from the sync -- D0nt pass utmsource in the flow. (not for creatio nor for update)
                if (eachContact.pi__last_activity__c != oldContactMap.get(eachContact.Id).pi__last_activity__c) {

 
                    if ((eachContact.utm_source__c == '' || eachContact.utm_source__c == null) 
                            && eachContact.pi__first_touch_url__c !='' && (oldContactMap.get(eachContact.Id).pi__first_touch_url__c == '' || oldContactMap.get(eachContact.Id).pi__first_touch_url__c == null)) {
                        eachContact.utm_source__c = 'Organic';
                    }
                    else if ((eachContact.utm_source__c == '' || eachContact.utm_source__c == null) 
                            && eachContact.pi__first_touch_url__c == '' && (oldContactMap.get(eachContact.Id).pi__first_touch_url__c == '' || oldContactMap.get(eachContact.Id).pi__first_touch_url__c == null)) {
                        eachContact.utm_source__c = 'Direct';
                    }
                    if (oldContactMap.get(eachContact.Id).utm_source__c != eachContact.utm_source__c) {
                        PardotSourceUtility.setSourcesOnContact(eachContact, oldContactMap.get(eachContact.Id)); 
                    }
                     
               }
            }

            
         
     }
    }
}