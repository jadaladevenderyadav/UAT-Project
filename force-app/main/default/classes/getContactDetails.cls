public class getContactDetails {

     @AuraEnabled(cacheable=true)
    public static contact ContactDetails(){
        Id userId = UserInfo.getUserId();
        System.debug('Loggedin User Id---->>> '+userId);

        User userInfos = [SELECT Id, contactId, FirstName, LastName From User WHERE Id=:userId];
        System.debug('ContactId of logged in User---->>> '+userInfos.contactId);

        Contact conDetails = [SELECT Id, Name, FirstName, LastName, Record_Type_Name__c, Program_Batch__r.Name,Active_Semester__r.Name, RH_Current_Pursuing_Year_of_Student__c From Contact Where Id=:userInfos.contactId LIMIT 1];
        System.debug('conDetails=> '+conDetails);
        return conDetails;
        
    }
}