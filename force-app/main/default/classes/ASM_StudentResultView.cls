public class ASM_StudentResultView {
    @AuraEnabled
    public static DataWrapper fetchData(String summaryId) {
        // Fetch the current user's contact and fee status
        User currentUser = [SELECT Id, ContactId, Contact.Active_Semester__c, Contact.Active_Semester__r.Name, 
                            Contact.Student_Fee__r.Amount_Pending__c 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId()];
        System.debug('Current User: ' + currentUser);
        System.debug('Contact ID: ' + currentUser.ContactId);
        DataWrapper dataWrapper = new DataWrapper();
        String contactId = currentUser.ContactId;
        System.debug('Contact ID for query: ' + contactId);
        if (contactId != null) {
            // Fetch the contact record along with related student fee records
            Contact contactRecord = [SELECT Id, Name, RecordType.Name, Active_Semester__c, Active_Semester__r.Name, 
                                     Current_Year__c, ReportsToId, ReportsTo.Active_Semester__r.Name,
                                     (SELECT Id, Name, Fee_Year__c, Pending_Amount__c 
                                      FROM Student_Fees__r) 
                                     FROM Contact 
                                     WHERE Id = :contactId 
                                     LIMIT 1];
            // Check if the fee is pending for the current year
            if (contactRecord.Student_Fees__r != null && !contactRecord.Student_Fees__r.isEmpty()) {
                Student_Fee__c studentFee = contactRecord.Student_Fees__r[0];
                if (studentFee.Fee_Year__c == contactRecord.Current_Year__c && studentFee.Pending_Amount__c != 0) {
                    System.debug('Pending fee found for the current year. No results will be returned.');
                    return new DataWrapper(); // Return an empty wrapper if the fee is pending
                }
            }
            // Fetch the summary record
            dataWrapper.summaryRec = [SELECT Id, Remarks__c, CGPA__c, SGPA__c, Passing_Criteria__c, Examination_Month_Year__c 
                                      FROM hed__Term_Grade__c 
                                      WHERE Id = :summaryId];
            System.debug('Summary Record: ' + JSON.serialize(dataWrapper.summaryRec));
            // Fetch the list of results
            dataWrapper.list_Results = [SELECT Id, Secured_External_Marks__c, Secured_Internal_Marks__c, Examination_Month_Year__c, 
                                        Recent_Result_Updated_Date__c, hed__Result__c, No_of_Credits__c, Course__r.hed__Course_ID__c, 
                                        Maximum_Marks_Course_Level__c, Total_Secured_Marks_Course_Level__c, Grade_Points__c, 
                                        Grade__c, Credit_Points__c, CGPA__c, Course__c, Course__r.Name, 
                                        Course__r.Course_Type_Logisys__c, Course__r.Total_Maximum_Marks_IA_External__c, 
                                        Total_Secured_Marks_Course__c 
                                        FROM hed__Term_Grade__c 
                                        WHERE Result_Summary__c = :summaryId 
                                        ORDER BY Course__r.Course_Type_Logisys__c DESC];
            System.debug('List of Results: ' + JSON.serialize(dataWrapper.list_Results));
            return dataWrapper;
        }
        return dataWrapper; 
    }
    public class DataWrapper {
        @AuraEnabled public hed__Term_Grade__c summaryRec { get; set; }
        @AuraEnabled public List<hed__Term_Grade__c> list_Results { get; set; }
    }
}