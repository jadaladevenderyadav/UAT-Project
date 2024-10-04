public class rve_IAExamApproval {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getContacts() {
        Map<String, Object> result = new Map<String, Object>();

        List<Contact> contacts = [SELECT Id, SRN_Number__c, Name, Checking_Eligibility_for_Exam__c, Program_Batch__r.Name,
                                  School__r.School_Head__c, School__r.Examination_Vertical_Head__c
                                  FROM Contact 
                                  WHERE Active__c = true 
                                  AND Checking_Eligibility_for_Exam__c = 'InEligible' 
                                  AND (School__r.School_Head__c = :UserInfo.getUserId() 
                                       OR School__r.Examination_Vertical_Head__c = :UserInfo.getUserId()) 
                                  ORDER BY SRN_Number__c];

        Boolean isVerticalHead = false;
        if (!contacts.isEmpty()) {
            isVerticalHead = contacts[0].School__r.Examination_Vertical_Head__c == UserInfo.getUserId();
        }

        result.put('contacts', contacts);
        result.put('isVerticalHead', isVerticalHead);
        system.debug('results>> '+ result);

        return result;
    }

    @AuraEnabled
    public static void updateContacts(List<Contact> contacts) {
        update contacts;
    }
}