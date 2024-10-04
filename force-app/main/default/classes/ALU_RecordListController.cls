/*created date: Jan 23rd, 2024
 * created By : Venugopal
*/

public class ALU_RecordListController {
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getCaseList(string caseStatus) {
        Id userId = UserInfo.getUserId();
        system.debug('case status-->'+caseStatus);
        string status = caseStatus;
        return [select id ,CaseNumber, Contact.Name,Contact_Name__c, Subject, Status from case where Status =:status AND OwnerId = :userId ]; //AND OwnerId = :userId
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Alumni_Activities__c> getAlumniActivities(string fileterByRecordType) {
        
        Id userId = UserInfo.getUserId();
        string recTypeName = fileterByRecordType;
        return [select id,Name, Contact_Name__c,Total_Experience_In_Years__c,Current_CTC_In_Lakhs__c, Blog_Name__c, Blog_Link__c,
                	   Record_Type_Name__c,Owner.Name ,OwnerId,Achiever__c, Achievement__c, Details__c,Company_Name__c, Designation__c,
                       Status__c 
                from Alumni_Activities__c  
                WHERE Record_Type_Name__c =: recTypeName AND OwnerId = :userId]; // AND  OwnerId = :userId 
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AlumniAchievementsWrapper> getAlumniAchievements(string fileterByRecordType) {
        List<AlumniAchievementsWrapper> acwrprList = new List<AlumniAchievementsWrapper>();
        Id userId = UserInfo.getUserId();
        string recTypeName = fileterByRecordType;
        system.debug('recTypeName from class----->'+recTypeName);
        List<Alumni_Activities__c> achievementsList = [select Id,Name,Record_Type_Name__c,OwnerId,Achiever__c, Achievement__c, Details__c from Alumni_Activities__c  WHERE Record_Type_Name__c =: recTypeName AND  OwnerId = :userId ]; // 
        system.debug('achievementsList from class----->'+achievementsList);
        if(!achievementsList.isEmpty()){
            for(Alumni_Activities__c achievmnt : achievementsList) {
                AlumniAchievementsWrapper aaw = new AlumniAchievementsWrapper();
                aaw.Id = achievmnt.Id;
                aaw.Name = achievmnt.Name;
                aaw.Achiever = achievmnt.Achiever__c;
                aaw.Achievement = achievmnt.Achievement__c;
                if(achievmnt.Details__c != null && achievmnt.Details__c != ''){
                aaw.Details = removeHTMLTags(achievmnt.Details__c);  
                }
                
                acwrprList.add(aaw);
            }
        }
        system.debug('acwrprList---->'+acwrprList);
        return acwrprList;
    }
    
    public class AlumniAchievementsWrapper{
        @AuraEnabled public Id Id {get;set;}
        @AuraEnabled public string Name {get;set;}
        @AuraEnabled public string Achiever {get;set;}
        @AuraEnabled public string Achievement {get;set;}
        @AuraEnabled public string Details {get;set;}
        @AuraEnabled public Id OwnerId {get;set;}
    }
    
    
    public static String removeHTMLTags(String input) {
        // Regular expression to remove HTML tags
        String regex = '<[^>]+>';
        // Replace HTML tags with an empty string
        String plainText = input.replaceAll(regex, '');
        // Replace multiple spaces with a single space
        plainText = plainText.replaceAll('\\s+', ' ');
        
        return plainText.trim();
    }

    
    @AuraEnabled(cacheable=true)
    public static List<EventRegistrationsWrapper> getEventRegistrations(Id userId){
        
        List<EventRegistrationsWrapper> evtRegWrapperList = new List<EventRegistrationsWrapper>();
        System.debug('userId--->' + userId);
        Id usrId = userId;
        
        List<Alumni_Event_Registrations__c> eventRegistrations = [
            SELECT Id, Name, Event__c, Registration_Date_Time__c, Event_Attended__c, OwnerId
            FROM Alumni_Event_Registrations__c
            WHERE OwnerId = :usrId
        ];
        
        // Format the date time field
        for (Alumni_Event_Registrations__c registration : eventRegistrations) {
            EventRegistrationsWrapper evWrap = new EventRegistrationsWrapper();
            evWrap.Id = registration.Id;
            evWrap.Name =  registration.Name;
            evWrap.Event = registration.Event__c;
            
            evWrap.EventAttended = registration.Event_Attended__c;
            evWrap.OwnerId = registration.OwnerId;
            
            if (registration.Registration_Date_Time__c != null) {
                
                DateTime dt = registration.Registration_Date_Time__c;
                evWrap.RegistrationDateTime = dt.format('DD/MM/YYYY hh:mm:ss a');
                
            }
            evtRegWrapperList.add(evWrap);
            
        }
        system.debug('evtRegWrapperList--->'+evtRegWrapperList);
        
        return evtRegWrapperList;
        
    }
    
    public class EventRegistrationsWrapper{
        @AuraEnabled public Id Id {get;set;}
        @AuraEnabled public string Name {get;set;}
        @AuraEnabled public string Event {get;set;}
        @AuraEnabled public string RegistrationDateTime {get;set;}
        @AuraEnabled public string EventAttended {get;set;}
        @AuraEnabled public Id OwnerId {get;set;}
    }
    
    @AuraEnabled
    public static Id createAchievements(AchievementsDetailsWrapper achmntDetails){
        system.debug('achmntDetails--->'+achmntDetails);
        Id insertedRecordId;
        Id uploadedFileId;
        AchievementsDetailsWrapper adw = achmntDetails;
        
        List<Alumni_Activities__c> acheivementsToInsert = new List<Alumni_Activities__c>();
        
        //get Achievements Record type
        Id achievementRecTypeId = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByDeveloperName().get('Achievements').getRecordTypeId();
        
        Alumni_Activities__c achvmnt = new Alumni_Activities__c();
        achvmnt.RecordTypeId = achievementRecTypeId;
        achvmnt.Achievement__c = adw.achievement;
        achvmnt.Date__c = adw.dateVal;
        achvmnt.Organisation__c = adw.organization;
        achvmnt.Designation__c = adw.designation;
        achvmnt.Image__c = adw.image;
        achvmnt.Details__c = adw.description;
        achvmnt.Contact__c = [Select Id,ContactId from User where Id =: adw.userId].ContactId;
        acheivementsToInsert.add(achvmnt);
        system.debug('acheivementsToInsert---->'+acheivementsToInsert);
        
        if(!acheivementsToInsert.isEmpty()){
            try{
                insert acheivementsToInsert; 
                insertedRecordId = acheivementsToInsert[0].Id;
                system.debug('acheivementsToInsertedddddd---->'+acheivementsToInsert[0].Id);
                if(insertedRecordId != null && adw.file != null){
                    
                    uploadedFileId = adw.file;
                    tagFileTocreatedAchievement(uploadedFileId, insertedRecordId); 
                }
            }Catch(exception e){
                system.debug('error---->'+e); 
            }
            
        }
        return insertedRecordId;  
    }
    
    public static void tagFileTocreatedAchievement(Id contDocId, Id recordId){
        
        system.debug('contDocId------>'+contDocId+'=========rec id--->'+recordId);
        List<ContentDocumentLink> conLinkListToInsert = new List<ContentDocumentLink>();
        List<ContentDocumentLink> conLinkList;
        
        // Create a new ContentDocumentLink record
        ContentDocumentLink newLink = new ContentDocumentLink();
        newLink.ContentDocumentId = contDocId;
        newLink.LinkedEntityId = recordId;
        newLink.ShareType = 'V'; 
        conLinkListToInsert.add(newLink);
        
        if(!conLinkListToInsert.isEmpty()){
            // Insert the ContentDocumentLink record
            insert conLinkListToInsert;
            system.debug('conLinkListToInsert------>'+conLinkListToInsert); 
        }
        
        
    }
    
    public class AchievementsDetailsWrapper{
        @AuraEnabled public Id userId {get;set;}  
        @AuraEnabled public string achievement {get;set;}  
        @AuraEnabled public date dateVal {get;set;}  
        @AuraEnabled public string organization {get;set;}  
        @AuraEnabled public string designation {get;set;}  
        @AuraEnabled public string image {get;set;}  
        @AuraEnabled public string description {get;set;}  
        @AuraEnabled public Id file {get;set;}  
    }
    
}