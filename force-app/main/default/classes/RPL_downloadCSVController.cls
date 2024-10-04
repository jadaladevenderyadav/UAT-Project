public with sharing class RPL_downloadCSVController {
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> fetchContacts() {
        return [SELECT Id, Name, Email, AccountId FROM Contact LIMIT 2000];
    }
    
}