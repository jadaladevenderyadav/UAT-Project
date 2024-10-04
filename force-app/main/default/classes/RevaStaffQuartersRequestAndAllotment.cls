public without sharing class RevaStaffQuartersRequestAndAllotment {
    public static final Set<String> staffReqCompleted = new Set<String>{'Room Allotted', 'Vacation Initiated'};
        @AuraEnabled
        public static Map<String, String> quarterRequestProcess(String roomType,Date joiningDate) {
            Map<String, String> retMap = new Map<String, String>();
            try {
                // Check if there are available quarters of the specified type
                List<Staff_Quarters_Room__c> quartersAvl = availableQuarters(roomType);
                if (quartersAvl.isEmpty()) {
                    retMap.put('isError', 'true');
                    retMap.put('errorMessage', 'No Staff Quarters Available.');
                    return retMap;
                }
                // Create the quarters request without checking for existing requests
                String userType = getUserType();
                Staff_Quarters_Request__c objReq = createQuartersReq(Userinfo.getUserId(), roomType, userType, joiningDate);
                retMap.put('isSuccess', 'true');
                retMap.put('quartersReq', JSON.serialize(objReq));
                retMap.put('successMessage', 'Request for Quarters successfully submitted.');
            } catch (Exception ex) {
                retMap.put('isError', 'true');
                retMap.put('errorMessage', 'An error occurred while processing the request.');
            }
            return retMap;
        }
     
    public static List<Staff_Quarters_Room__c> availableQuarters(String roomType) {
        system.debug('roomType==>'+roomType);
        List<Staff_Quarters_Room__c> quartersAvl = new List<Staff_Quarters_Room__c>();
        try {
            if (String.isNotBlank(roomType)) {
                quartersAvl = [SELECT Id FROM Staff_Quarters_Room__c WHERE Type__c =: roomType];
                system.debug('quartersAvl==>'+quartersAvl);
            } else {
                quartersAvl = [SELECT Id FROM Staff_Quarters_Room__c];
            }
        } catch (Exception ex) {
            // Log or handle the exception
            System.debug('Exception in availableQuarters: ' + ex.getMessage());
        }
        return quartersAvl;
    }
    /* public static List<Staff_Quarters_Room__c> availableQuarters(String roomType) {
List<Staff_Quarters_Room__c> quartersAvl = new List<Staff_Quarters_Room__c >();
try {
quartersAvl = [SELECT Id FROM Staff_Quarters_Room__c WHERE Type__c =: roomType];
} catch (Exception ex) {

}
return quartersAvl;
}*/
    public static String getUserType() {
        String profileName;
        List<User> userList = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        if (!userList.isEmpty()) {
            profileName = userList[0].Profile.Name;
        } else {
            // Handle the situation where the user doesn't have a profile
            return 'Unknown';
        }
        
        if ('Professor'.equals(profileName)) {
            return 'TeachingStaff';
        } else if ('Non Teaching Profile'.equals(profileName)) {
            return 'NonTeachingStaff';
        } else if ('School Director'.equals(profileName)) {
            return 'SchoolDirector';
        } else {
            return 'Unknown';
   		 }
    }
    /* public static String getUserType() {
String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

if ('Professor'.equals(profileName)) {
return 'TeachingStaff';
} else if ('Non Teaching Profile'.equals(profileName)) {
return 'NonTeachingStaff';
} else {
return 'Unknown';
}
}*/
    @AuraEnabled
    public static Staff_Quarters_Request__c fetchExistingQuartersReq(Id userId) {
        Staff_Quarters_Request__c  quartersReq;
        try {
            quartersReq = [SELECT Id, Name, Status__c, Type__c, Room_Request_For__c, (SELECT Id, Initiated_Date__c, Status__c FROM Staff_Quarter_Vacation_Requests__r ORDER BY Initiated_Date__c DESC LIMIT 1) FROM Staff_Quarters_Request__c WHERE Room_Request_For__c  =: userId ORDER BY CreatedDate DESC LIMIT 1];
        } catch (Exception ex) {
            
        }
        return quartersReq;
    }
    @AuraEnabled
    public static Staff_Quarters_Request__c fetchExistingQuartersDetails(Id userId) {
        Staff_Quarters_Request__c  quartersReq;
        try {
            quartersReq = [SELECT Id, Name, Status__c, Type__c, Room_Request_For__c FROM Staff_Quarters_Request__c WHERE Room_Request_For__c  =: userId ORDER BY CreatedDate DESC LIMIT 1];
        } catch (Exception ex) {
            
        }
        return quartersReq;
    }
    public static Staff_Quarters_Request__c createQuartersReq(Id userId, String roomType, String userType,Date joiningDate) {
        Staff_Quarters_Request__c quarterReq = fetchExistingQuartersReq(userId);
        // if(quarterReq == null){
        Staff_Quarters_Request__c objReq = new Staff_Quarters_Request__c(Room_Request_For__c = userId, Type__c = roomType, Quarters_Request_Type__c = userType, Staff_Quarters_Joining_Date__c = joiningDate);
        insert objReq;
        return objReq;
        // }else{
        //    return quarterReq;
        //}
    }
    @AuraEnabled
    public static Map<String, String> initiateVacation(Id userId) {
        Map<String, String> retMap = new Map<String, String>();
        try {
            Staff_Quarters_Request__c quartersReq = fetchExistingQuartersReq(Userinfo.getUserId());
            if (quartersReq != null) {
                Staff_Quarter_Vacation_Request__c vacReq;
                vacReq = fetchExistVacationReq(quartersReq.Id);
                if (vacReq != null) {
                    vacReq.Initiated_Date__c = Date.today();
                    vacReq.Status__c = 'Initiated';
                } else {
                    vacReq = new Staff_Quarter_Vacation_Request__c(Staff_Quarters_Request__c  = quartersReq.Id, Initiated_Date__c  = Date.today());
                }
                insert vacReq;
                quartersReq.Status__c = 'Vacation Initiated';
                update quartersReq;
                retMap.put('isSuccess', 'true');
                retMap.put('successMessage', 'Staff Vacation Initiated');
            }
        } catch (Exception ex) {
            retMap.put('isError', 'true');
            retMap.put('errorMessage', 'Staff Vacation Initiation Failed. Try again');
        }
        return retMap;
    }
    public static Staff_Quarter_Vacation_Request__c fetchExistVacationReq(Id staffQuarterId) {
        Staff_Quarter_Vacation_Request__c vacReq;
        try {
            vacReq = [SELECT Id, Status__c FROM Staff_Quarter_Vacation_Request__c WHERE Staff_Quarters_Request__c =: staffQuarterId ORDER BY Initiated_Date__c DESC LIMIT 1];
        } catch (Exception ex) {
            
        }
        return vacReq;
    }
    @AuraEnabled
    public static Map<String, String> fetchInitialInfo(Id userId) {
        Map<String, String> retMap = new Map<String, String>();
        try {
            Staff_Quarters_Request__c quartersReq = fetchExistingQuartersReq(Userinfo.getUserId());
            if (quartersReq != null && quartersReq.Status__c != null) {
                if (quartersReq.Status__c == 'Request Submitted' || quartersReq.Status__c == 'Booked') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'You have already applied for staff quarters. Please wait for the required approvals to get processed');                    
                } else if (quartersReq.Status__c == 'Room Allotted') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'You already have room allotted for you. Initiate vacation process if you want to vacate');    
                } else if (quartersReq.Status__c == 'Approved') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'Quarter request already approved. Wait for room to get allotted');  
                } else if (quartersReq.Status__c == 'Rejected') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'Quarter request already rejected. Create new quarter request');  
                } else if (quartersReq.Status__c == 'Vacation Initiated') {
                    if (quartersReq.Staff_Quarter_Vacation_Requests__r != null && !quartersReq.Staff_Quarter_Vacation_Requests__r.isEmpty()) {
                        Staff_Quarter_Vacation_Request__c vacReq = quartersReq.Staff_Quarter_Vacation_Requests__r.get(0);
                        if (vacReq.Status__c != null && vacReq.Status__c == 'Initiated') {
                            retMap.put('isWarning', 'true');
                            retMap.put('warningMessage', 'Quarter request vacation initiated. Complete it first'); 
                        } else if (vacReq.Status__c != null && vacReq.Status__c == 'Completed') {
                            retMap.put('isWarning', 'true');
                            retMap.put('warningMessage', 'Quarter request vacation initiated. Complete it first'); 
                        }
                    }
                } else if (quartersReq.Status__c == 'Vacation Completed') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'You have vacated a room recently. Book a new one'); 
                }
            }
        } catch (Exception ex) {
            retMap.put('isError', 'true');
            retMap.put('errorMessage', 'Staff Vacation Initiation Failed. Try again');
        }
        
        return retMap;
    }
    @AuraEnabled
    public static list<Staff_Quarters_Request__c> fetchExistingQuartersUserDetails(String roomType) {
        list<Staff_Quarters_Request__c>  UserquartersReq;
        try {
            UserquartersReq = [SELECT Id, Name, Status__c, Type__c, Room_Request_For__c FROM Staff_Quarters_Request__c WHERE Type__c =: roomType];
        } catch (Exception ex) {
            
        }
        return UserquartersReq;
    }
}