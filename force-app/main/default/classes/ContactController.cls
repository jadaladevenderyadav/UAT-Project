public without sharing class ContactController {
       
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactBySRN(String srnNumber, String appNumber) {
        system.debug(srnNumber);
     //   return [SELECT Id, Name, SRN_Number__c, Email FROM Contact WHERE SRN_Number__c = :srnNumber];
     if(srnNumber != ''){
        return [SELECT Id, Student_Full_Name__c, SRN_Number__c, Application_Number__c, School_Name__c, Program_Batch1__c, Personal_Email__c, Phone FROM Contact WHERE Record_Type_Name__c = 'PU Student' AND SRN_Number__c = : srnNumber];
     }
        return [SELECT Id, Student_Full_Name__c, SRN_Number__c, Application_Number__c, School_Name__c, Program_Batch1__c, Personal_Email__c, Phone FROM Contact WHERE Record_Type_Name__c = 'PU Student' AND Application_Number__c =: appNumber];     
        
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getSchoolNames(){
        try {
            List<Account> schoolNameList = [SELECT name FROM Account WHERE name like 'PU%'];
            return schoolNameList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }   

    @AuraEnabled
    public static List<hed__Program_Plan__c> getProgramBatches(String schId){
        try{
            System.debug('program Id : '+schId);
           //  List<Account> listAccountRecordId = [SELECT Id FROM Account WHERE parentid =: schId];
           // System.debug('result  : '+listAccountRecordId);
           // return listAccountRecordId;
            List<hed__Program_Plan__c> programBatchList = [SELECT Id,Name FROM hed__Program_Plan__c WHERE hed__Account__c =: [SELECT Id FROM Account WHERE parentid =: schId]];
            System.debug('result  : '+programBatchList);
            return programBatchList;        

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Access the Country codes 
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        
        // Describe the object to get the field
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        
        // Check if the field is a picklist
        if (fieldResult.getType() == Schema.DisplayType.PICKLIST) {
            // Retrieve picklist values
            List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : entries) {
                picklistValues.add(entry.getLabel());
            }
        }
        
        return picklistValues;
    }


    @AuraEnabled
    public static String insertStudentInfo(String payload){
        String error = 'Success';
        // System.debug('Hello debugger vscode');
    try{           
        ContactInfo payloadObject = (ContactInfo) JSON.deserialize(payload, ContactInfo.class);
        SObject contactInfo = (Sobject) Type.forName('Contact').newInstance();

        contactInfo.put('SRN_Number__c', payloadObject.regSrnNumber);  
        contactInfo.put('Application_Number__c', payloadObject.regApplNumber);         
        contactInfo.put('FirstName', payloadObject.firstName);
        contactInfo.put('LastName', payloadObject.lastName);       

        // contactInfo.put('School_Name__c', payloadObject.schoolName);  // inserts names
        // contactInfo.put('Program_Batch1__c', payloadObject.programBatch);  // inserts names
        contactInfo.put('School__c', payloadObject.schoolName);  // inserts id
        contactInfo.put('Program_Batch__c', payloadObject.programBatch);  // inserts id
        contactInfo.put('Personal_Email__c', payloadObject.email);  
        contactInfo.put('Phone', payloadObject.mobile); // Mobile no not inserting phone no inserting
        // contactInfo.put('Record_Type_Name__c', 'PU Student'); 
        // contactInfo.put('hed__Former_First_Name__c', payloadObject.firstName);
        // contactInfo.put('hed__Former_Last_Name__c', payloadObject.lastName);
        
        insert contactInfo;
        // return true;

        } catch(Exception e) {
            System.debug('Error creating contact: '+e.getMessage());
            error = e.getMessage();
        }
        return error;   
    }

    //********************************************************************* */
    // Method to insert a contact record
    // @AuraEnabled
    // public static void createContact(String firstName, String lastName, String email) {
    //     Contact newContact = new Contact();
    //     newContact.FirstName = firstName;
    //     newContact.LastName = lastName;
    //     newContact.Email = email;
        
    //     try {
    //         insert newContact;
    //     } catch (Exception e) {
    //         // Handle exception
    //         System.debug('Error creating contact: ' + e.getMessage());
    //     }
    // }
    
    //********************************************************************** */

    @AuraEnabled
    public static Boolean checkSRNExists(String srnNumber) {
        // Query to check if a srn with the provided email already exists
        Integer srnCount = [SELECT COUNT() FROM Contact WHERE SRN_Number__c = :srnNumber LIMIT 1];
        // If srnCount is greater than 0, SRN exists; otherwise, it doesn't exist
        return srnCount > 0;
    }    

    @AuraEnabled
    public static String checkContactExists(String srnNumber, String applNumber, String emailValue,String phoneValue) {
        // public static String checkContactExists(String payload) {

            // ContactInfo payloadObject = (ContactInfo) JSON.deserialize(payload, ContactInfo.class);
            // SObject contactInfo = (Sobject) Type.forName('Contact').newInstance();
            String response = '';
            try{
                List<Contact> existingContacts = [SELECT Id, SRN_Number__c, Application_Number__c, Personal_Email__c, Phone FROM Contact WHERE (SRN_Number__c = : srnNumber OR Application_Number__c = : applNumber OR Personal_Email__c = : emailValue OR Phone = : phoneValue) LIMIT 1];
                
                if (!existingContacts.isEmpty()) {
                    Contact existingContact = existingContacts[0];
                    if (existingContact.SRN_Number__c == srnNumber) {
                        // return 'SRN Number';
                        response = response + 'SRN Number,';
                    }  
                    if (existingContact.Application_Number__c == applNumber) {
                        // return 'Application Number';
                        response = response + 'Application Number,';
                    } 
                    if (existingContact.Personal_Email__c == emailValue) {
                        response = response + 'Email Id,';
                    }
                    if (existingContact.Phone == phoneValue) {
                        response = response + 'Phone number';
                    }
                }
                // return null;
                return response;
            }catch(Exception e) {
                System.debug('Exception occured while checking existing contacts: '+e.getMessage());                
            }
            return response;
    }


     //Wrapper Class to represent a ContactInfo Item
    public class ContactInfo {    
        @AuraEnabled
        public String regSrnNumber;    
        @AuraEnabled
        public String regApplNumber;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String schoolName;
        @AuraEnabled
        public String programBatch;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String mobile;
        @AuraEnabled
        public String recordType;
    }
    
}