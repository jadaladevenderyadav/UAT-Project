public Without Sharing class RevaHostelRequestController {
    //public  class revaHostelRequestController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentStudentContact() {
        Id studentId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        system.debug('studentId===>'+studentId);
        Contact studentContact = [SELECT Id, FirstName, LastName, Email, hed__WorkEmail__c, Active_Semester__c,
                                  Phone, Birthdate, RH_Current_Pursuing_Year_of_Student__c, Father_Name__c,Is_Final_Year__c,
                                  Father_Mobile_Number__c, MobilePhone, MailingAddress, OtherAddress, Course__c,Primary_Academic_Program__r.Program_Alias__c, 
                                  hed__Gender__c, SRN_Number__c,Program_Batch__c,Program_Batch__r.name,Active_Semester__r.Name, Program_Batch__r.hed__End_Date__c
                                  //(Select Id, Status__c,Reva_Hostel_Room__c FROM Reva_Hostel_Requests__r WHERE Status__c='Approved' AND Reva_Hostel_Room__c != NULL ORDER BY ID DESC Limit 1)
                                  FROM Contact WHERE Id = :studentId];
        
        Map<String, Object> contactDetails = new Map<String, Object>();
        contactDetails.put('Id', studentContact.Id);
        contactDetails.put('FirstName', studentContact.FirstName);
        contactDetails.put('LastName', studentContact.LastName);
        contactDetails.put('Email', studentContact.hed__WorkEmail__c);
        contactDetails.put('MobilePhone', studentContact.MobilePhone);
        contactDetails.put('Birthdate', studentContact.Birthdate);
        contactDetails.put('ParentName', studentContact.Father_Name__c);
        contactDetails.put('ParentContactNumber', studentContact.Father_Mobile_Number__c);
        contactDetails.put('Course', studentContact.Course__c);
        contactDetails.put('OtherAddress', studentContact.OtherAddress);
        contactDetails.put('MailingAddress', studentContact.MailingAddress);
        contactDetails.put('Gender', studentContact.hed__Gender__c);
        contactDetails.put('idCardNumber', studentContact.SRN_Number__c);
        contactDetails.put('CurrentPusuingYear', studentContact.RH_Current_Pursuing_Year_of_Student__c);
        contactDetails.put('StudentBelongsToFinalYear',studentContact.Is_Final_Year__c);
        contactDetails.put('ProgramAlias',studentContact.Primary_Academic_Program__r.Program_Alias__c);
        contactDetails.put('Semester', studentContact.Active_Semester__r.Name);
        contactDetails.put('ProgramBatch', studentContact.Program_Batch__r.Name);
        if(studentContact.Reva_Hostel_Requests__r.size() > 0){
            contactDetails.put('roomAlloted', TRUE);
        }
        else{
            contactDetails.put('roomAlloted', FALSE);
        }
        
        return contactDetails;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentNonTeachingContact() {
        Id userId = UserInfo.getUserId();
        Contact nonTeachingContact = [SELECT Id, FirstName, LastName, Name,Email,Employee_Number__c, MobilePhone,hed__Gender__c,RecordType.Name
                                      FROM Contact 
                                      WHERE Id = :[SELECT ContactId FROM User WHERE Id = :userId].ContactId 
                                      AND RecordType.Name = 'Non Teaching'];
        
        Map<String, Object> contactDetails = new Map<String, Object>();
        contactDetails.put('Id', nonTeachingContact.Id);
        contactDetails.put('FirstName', nonTeachingContact.FirstName);
        contactDetails.put('LastName', nonTeachingContact.LastName);
        contactDetails.put('Email', nonTeachingContact.Email);
        contactDetails.put('MobilePhone', nonTeachingContact.MobilePhone);
        contactDetails.put('employeeNumber', nonTeachingContact.Employee_Number__c);
        contactDetails.put('Gender', nonTeachingContact.hed__Gender__c);
        contactDetails.put('RecordTypeName', nonTeachingContact.RecordType.Name);
        Boolean createHostelRequest = true;
        //contactDetails.put('idCardNumber', nonTeachingContact.SRN_Number__c);
        //contactDetails.put('CurrentPusuingYear', nonTeachingContact.RH_Current_Pursuing_Year_of_Student__c);
        
        return contactDetails;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentTeachingContact() {
        Id userId = UserInfo.getUserId();
        User UserInfo = [SELECt Id, Email FROM User WHERE Id =:userId];
        Contact teachingContact = [SELECT Id, FirstName, LastName, Name,Email, Employee_Number__c ,MobilePhone,hed__Gender__c,RecordType.Name, Birthdate
                                   FROM Contact 
                                   WHERE Email = :USerInfo.Email
                                   AND RecordType.Name = 'Professor'];
        System.debug('contact email id ' + teachingContact.Email);
        System.debug('Contact id' + teachingContact.id);
        
        Map<String, Object> contactDetails = new Map<String, Object>();
        contactDetails.put('Id', teachingContact.Id);
        contactDetails.put('FirstName', teachingContact.FirstName);
        contactDetails.put('LastName', teachingContact.LastName);
        contactDetails.put('Email', teachingContact.Email);
        contactDetails.put('MobilePhone', teachingContact.MobilePhone);
        contactDetails.put('Birthdate', teachingContact.Birthdate);
        contactDetails.put('employeeNumber', teachingContact.Employee_Number__c);
        contactDetails.put('Gender', teachingContact.hed__Gender__c);
        contactDetails.put('RecordTypeName', teachingContact.RecordType.Name);
        Boolean createHostelRequest = true;
        //contactDetails.put('idCardNumber', nonTeachingContact.SRN_Number__c);
        //contactDetails.put('CurrentPusuingYear', nonTeachingContact.RH_Current_Pursuing_Year_of_Student__c);
        
        return contactDetails;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkHostelRequestExists() {
        try {
            // Get the current user's Id
            String userId = UserInfo.getUserId();
            
            // Fetch the user's information
            User userInfo = [SELECT Id, Email FROM User WHERE Id = :userId LIMIT 1];
            
            // Fetch the teaching contact based on the user's email
            Contact teachingContact = [SELECT Id, Email, RecordType.Name
                                       FROM Contact
                                       WHERE Email = :userInfo.Email
                                       LIMIT 1];
            
            // Check if the teaching contact exists
            if (teachingContact != null) {
                // Fetch the hostel request for the teaching contact
                Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :teachingContact.Id LIMIT 1];
                
                // Return true if the hostel request exists for the teaching contact
                return hostelRequest != null;
            } else {
                // Throw a custom exception if the teaching contact is not found
                throw new AuraHandledException('Teaching contact not found for the current user.');
            }
        } catch (Exception ex) {
            // Handle other exceptions and throw an AuraHandledException
            throw new AuraHandledException('Error checking hostel request: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static Map<String, String> hostelDetailsCurrentlyLoggedInUser(){
        try {
            Map<String, String> result = new Map<String, String>();
            result.put('IsHostelRequestAvailable', 'No');
            result.put('RoomNumber', 'N/A');
            List<User> currentlyLoggedInUser = [Select Id, ContactId From User Where Id =: UserInfo.getUserId()];
            if(!currentlyLoggedInUser.isEmpty()){
                List<Contact> currentlyLoggedInContact = [Select Id From Contact Where Id =: currentlyLoggedInUser[0].ContactId];
                if(!currentlyLoggedInContact.isEmpty()){
                    List<Reva_Hostel_Request__c> hostelRequest = [SELECT Id, Status__c, Reva_Hostel_Room__r.Name 
                                                                  FROM Reva_Hostel_Request__c 
                                                                  WHERE Hostel_Room_Request_For__c = :currentlyLoggedInContact[0].Id 
                                                                  AND Status__c = 'Room Allotted' LIMIT 1];
                    
                    String isHostelAvailable = hostelRequest.size() != 0 ? 'Yes' : 'No';
                    String roomNumber = hostelRequest.size() != 0 ? hostelRequest[0].Reva_Hostel_Room__r.Name : 'N/A';
                    result.put('IsHostelRequestAvailable', isHostelAvailable);
                    result.put('RoomNumber', roomNumber);
                    
                }
                
                
            }
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<Reva_Hostel_Request__c> fetchHostelRequestDetails() {
        Id contactId = RevaMealBookingController.fetchContactId();
        List<Reva_Hostel_Request__c> revaHostelRequests = new List<Reva_Hostel_Request__c>();
        try {
            revaHostelRequests = [SELECT Id, Hostel_Room_Request_For__c, Status__c, Type__c,Reva_Hostel_Premium_Room__c, Name, Room_Number__c, Reva_Hostel_Room__c, 
                                  Reva_Hostel_Room__r.Name, Reva_Hostel_Room__r.Dormitory_Type__c, Reva_Hostel_Room__r.Block__c, Reva_Hostel_Room__r.Floor__c                            
                                  FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :contactId];
        } catch (Exception ex) {
            
        } 
        return revaHostelRequests;
    }
    /********************Working one****************************************************/
    /* @AuraEnabled(cacheable=true)
public static List<Reva_Hostel_Request__c> getExistingHostelRequest() {
Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;


return [SELECT Id,Name, Room_Number__c, Type__c,Reva_Hostel_Premium_Room__c,Status__c,Block__c,Reva_Hostel_Room__c
FROM Reva_Hostel_Request__c
WHERE Hostel_Room_Request_For__c = :contactId and Status__c!= 'Rejoin'
//WHERE Hostel_Room_Request_For__c = :contactId
LIMIT 1];            

}*/
    @AuraEnabled(cacheable=true)
    public static List<Reva_Hostel_Request__c> getExistingHostelRequest() {
        // Get the current user's Id and Profile Name
        User currentUser = [SELECT Id, ContactId, Email, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        Id contactId;
        
        // Check if the user has the Student or Non-Teaching Staff profile
        if (currentUser.Profile.Name == 'Student Profile' || currentUser.Profile.Name == 'Non Teaching Profile' || currentUser.Profile.Name =='Student Portal Profile') {
            contactId = currentUser.ContactId;
        } else if (currentUser.Profile.Name == 'Professor') {
            // Fetch the contact based on the email for professor profile
            Contact contact = [SELECT Id FROM Contact WHERE Email = :currentUser.Email LIMIT 1];
            contactId = contact.Id;
        }
        
        // Return the hostel request records
        return [SELECT Id, Name, Room_Number__c, Type__c, Reva_Hostel_Premium_Room__c, Status__c, Block__c, Reva_Hostel_Room__c
                FROM Reva_Hostel_Request__c
                WHERE Hostel_Room_Request_For__c = :contactId AND Status__c != 'Rejoin'
                LIMIT 1];
    }
    
    
    /****************************************************************************/
    
    //Update Record for Rejoin   
    @AuraEnabled
    public static void RejoingRequest(String recordId) {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        Reva_Hostel_Request__c RejoinReq = [SELECT Id,Status__c,Rejoiner__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :contactId and Status__c ='Vacated' ];
        RejoinReq.Status__c = 'Rejoin';
        RejoinReq.Rejoiner__c = true;
        update RejoinReq;
    }
    
    //*********************for alloted hostel request srinivasu veera***************************************//
    @AuraEnabled(cacheable=true)
    public static Reva_Hostel_Request__c getExistingRoomAllotedHostelRequest() {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        Reva_Hostel_Request__c existingRoomAllotedRequest;
        
        try {
            existingRoomAllotedRequest = [SELECT Id,Name, Room_Number__c, Type__c,Reva_Hostel_Premium_Room__c,Status__c,Block__c,Reva_Hostel_Room__c
                                          FROM Reva_Hostel_Request__c
                                          WHERE Hostel_Room_Request_For__c = :contactId AND Status__c='Room Allotted'
                                          LIMIT 1];
            if (existingRoomAllotedRequest == null) {
                // Throw a custom exception if no existing hostel request is found
                throw new AuraHandledException('No existing hostel requests found for the user.');
            }
            
        } catch (Exception ex) {
            // Handle exception if needed
        }
        
        return existingRoomAllotedRequest;
    }
    
    
    
    ///*****************updating Enddate for Non-teachingstaff users for hostel vacating********************////
    /*******************************working one********************************************************/
    /*@AuraEnabled
public static void updateVacationDate(String recordId, Date vacationDate) {
system.debug('record id' + recordId);
system.debug('vacation date'+ vacationDate);
try {

Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;

System.debug('Contact ID: ' + contactId);

Reva_Hostel_Request__c[] hostelRequests = [SELECT Id, RevaHostelVacatingDate__c, Status__c 
FROM Reva_Hostel_Request__c 
WHERE Hostel_Room_Request_For__c = :contactId 
AND Id = :recordId 
LIMIT 1];

if (!hostelRequests.isEmpty()) {
Reva_Hostel_Request__c hostelRequest = hostelRequests[0];

hostelRequest.RevaHostelVacatingDate__c = vacationDate;
hostelRequest.Status__c = 'Vacated';
update hostelRequest;
} else {
throw new AuraHandledException('No hostel request record found for the user with the specified ID.');
}
} catch (Exception e) {
throw new AuraHandledException('Error updating vacation date: ' + e.getMessage());
}
}*/
    
    @AuraEnabled
    public static void updateVacationDate(String recordId, Date vacationDate, String cancellationReason) {
        system.debug('record id' + recordId);
        system.debug('vacation date'+ vacationDate);
        try {
            User currentUser = [SELECT Id, ContactId, Email, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            Id contactId;
            if (currentUser.Profile.Name == 'Non Teaching Profile') {
                contactId = currentUser.ContactId;
            } else if (currentUser.Profile.Name == 'Professor') {
                // Fetch the contact based on the email for professor profile
                Contact contact = [SELECT Id FROM Contact WHERE Email = :currentUser.Email LIMIT 1];
                contactId = contact.Id;
            }
            
            System.debug('Contact ID: ' + contactId);
            
            Reva_Hostel_Request__c[] hostelRequests = [SELECT Id, RevaHostelVacatingDate__c, Status__c 
                                                       FROM Reva_Hostel_Request__c 
                                                       WHERE Hostel_Room_Request_For__c = :contactId 
                                                       AND Id = :recordId 
                                                       LIMIT 1];
            
            if (!hostelRequests.isEmpty()) {
                Reva_Hostel_Request__c hostelRequest = hostelRequests[0];
                
                hostelRequest.RevaHostelVacatingDate__c = vacationDate;
                hostelRequest.Cancellation_Reason__c = cancellationReason;
                hostelRequest.Cancellation_Request_Date__c = System.Today();
                hostelRequest.Vacating_Request__c = 'Vacating Initiated';
                hostelRequest.Status__c = 'Vacating Initiated';
                update hostelRequest;
            } else {
                throw new AuraHandledException('No hostel request record found for the user with the specified ID.');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating vacation date: ' + e.getMessage());
        }
    }
    /***************************************************************************************/
    /********************************************************************/
    @AuraEnabled
    public static void updateStudentVacationDate(String recordId, Date vacationDate){
        system.debug('record id' + recordId);
        system.debug('vacation date'+ vacationDate);
        try {
            // Get the contact ID associated with the logged-in user
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
            
            // Debug log to verify contactId
            System.debug('Contact ID: ' + contactId);
            
            // Query for the hostel request record based on the contact ID
            Reva_Hostel_Request__c[] hostelRequests = [SELECT Id, RevaHostelVacatingDate__c, Status__c 
                                                       FROM Reva_Hostel_Request__c 
                                                       WHERE Hostel_Room_Request_For__c = :contactId 
                                                       AND Id = :recordId 
                                                       LIMIT 1];
            
            // Check if any hostel request records were found
            if (!hostelRequests.isEmpty()) {
                Reva_Hostel_Request__c hostelRequest = hostelRequests[0];
                
                // Update the vacation date field
                hostelRequest.RevaHostelVacatingDate__c = vacationDate;
                hostelRequest.Status__c = 'Vacation Initiated';
                update hostelRequest;
            } else {
                throw new AuraHandledException('No hostel request record found for the user with the specified ID.');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating vacation date: ' + e.getMessage());
        }
    }
    
    
    
    
    
    @AuraEnabled
    public static void updateStudentHostelRequest(Id id, Date programEndDate) {
        system.debug('id'+ id);
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Status__c FROM Reva_Hostel_Request__c WHERE Id = :id];
        system.debug('hostelRequests'+ hostelRequests);
        if (hostelRequests.isEmpty()) {
            throw new AuraHandledException('No hostel request found with the given Id.');
        } else {
            List<Reva_Hostel_Request__c> requestsToUpdate = new List<Reva_Hostel_Request__c>();
            
            for (Reva_Hostel_Request__c hostelRequest : hostelRequests) {
                hostelRequest.Status__c = 'Vacation Initiated';
                hostelRequest.RevaHostelVacatingDate__c = programEndDate;
                requestsToUpdate.add(hostelRequest); 
            }
            update requestsToUpdate; 
        }
    }
    
    
    
    
    
    
    @AuraEnabled(cacheable=true)
    public static Date fetchProgramEndDate() {
        Id studentId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        system.debug('studentId===>' + studentId);
        Contact studentContact = [SELECT Id, Program_Batch__r.hed__End_Date__c
                                  FROM Contact
                                  WHERE Id = :studentId];
        return studentContact.Program_Batch__r.hed__End_Date__c;
    }
    
    
    /*Getting loggedinuser profile*/
    @AuraEnabled
    public static String getLoggedInUserProfile() {
        String userId = UserInfo.getUserId();
        User user = [SELECT Profile.Name FROM User WHERE Id = :userId LIMIT 1];
        return user.Profile.Name;
    }
    
    @AuraEnabled(cacheable=true)
    Public Static hed__Application__c ProvisionalFeePaid(){
        User userId = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        hed__Application__c appli=[SELECT id, Name,hed__Applicant__c,Provisional_Admission_Fee_Paid__c FROM hed__Application__c Where hed__Applicant__c = :userId.ContactId AND Provisional_Admission_Fee_Paid__c = false];
        return appli;
    }
    
    
    
    @AuraEnabled
    public static void createStudentHostelAttachment(Id requestId) {
        System.debug('Request ID: ' + requestId);
        Reva_Hostel_Request__c[] StudentVacationRequests = [SELECT Id, Name FROM Reva_Hostel_Request__c WHERE Id = :requestId LIMIT 1];
        if (!StudentVacationRequests.isEmpty()) {
            Reva_Hostel_Request__c StudentVacationRequest = StudentVacationRequests[0];
            PageReference pdfPages = Page.StudentVactionNOC;
            system.debug('StudentVactionNOC:' +pdfPages);
            pdfPages.getParameters().put('Id', StudentVacationRequest.Id);
            Blob pdfBlobs;
            
            if (pdfPages != null) {
                pdfBlobs = pdfPages.getContent();
                System.debug('Entered if block:' + pdfBlobs);
            } else {
                pdfBlobs = Blob.valueOf('Test');
                System.debug('Entered else block');
            }
            Blob myBlob = pdfBlobs; // blob variable
            String blobString = EncodingUtil.base64Encode(myBlob);
            System.debug('Blob Data: ' + blobString);
            // Create a new Attachment record and associate it with the StudentVacationRequest record
            Attachment attachment = new Attachment();
            attachment.ParentId = StudentVacationRequest.Id;
            attachment.Body = pdfBlobs;
            attachment.Name = 'HostelVacationNOC.pdf';
            attachment.ContentType = 'application/pdf';
            insert attachment;
            
            // Fetch the user to whom you want to send the email
            User recipient = [SELECT Id, Email, Name FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name = 'Warden') LIMIT 1];//[SELECT Id, Email FROM User WHERE Name = 'Warden user' LIMIT 1];
            System.debug('recepiet: '+ recipient);
            System.debug('user email: '+ recipient.Email);
            
            // Create a new email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(recipient.Email != null){
                email.setToAddresses(new List<String>{recipient.Email});
            }else{
                email.setToAddresses(new List<String>{'vamshi.udutha@cloudodyssey.co'});
            }
            
            email.setSubject('Student Hostel Vacation NOC');
            email.setPlainTextBody('Please find attached No Objection Certificate');
            
            // Attach the PDF to the email
            Messaging.EmailFileAttachment attachmentToEmail = new Messaging.EmailFileAttachment();
            attachmentToEmail.setFileName('HostelVacationNOC.pdf');
            attachmentToEmail.setBody(pdfBlobs);
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachmentToEmail});
            
            // Send the email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            
        } else {
            // Handle the case where no records are found for the given requestId
            System.debug('No matching records found for the provided requestId.');
        }
    }
    
    /******************************Newly added by Veera for the filtering the MealBooking in NonTeachingstaff site*************************************************/
   @AuraEnabled
    public static Boolean hasExistingHostelRequest() {
    try {
        User currentUser = [SELECT Id, ContactId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        Id contactId;
        
        if (currentUser.Profile.Name == 'Non Teaching Profile' && currentUser.ContactId != null) {
            contactId = currentUser.ContactId;
        } else {
            return false;
        }
        
        List<Reva_Hostel_Request__c> existingRequests = [ 
            SELECT Id 
            FROM Reva_Hostel_Request__c 
            WHERE Hostel_Room_Request_For__c = :contactId AND Status__c != 'Rejoin'
            LIMIT 1
        ];
        
        return !existingRequests.isEmpty();
        
    } catch (Exception e) {
        System.debug('Error in hasExistingHostelRequest: ' + e.getMessage());
        return false;
    }
}

    /*********************************************************************************/
    
}