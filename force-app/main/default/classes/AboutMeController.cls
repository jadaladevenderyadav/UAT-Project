public without sharing class AboutMeController {
    
    @AuraEnabled(cacheable=true)
    public static Id getUserContactId() {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        return contactId;
    }

    @AuraEnabled
    public static void updateContactDescription(String description) {
        Id contactId = getUserContactId();
        Contact contactRecord = [SELECT Id, Description FROM Contact WHERE Id = :contactId];
        contactRecord.Description = description;
        update contactRecord;
    }
}