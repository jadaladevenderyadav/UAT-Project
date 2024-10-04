public without sharing class revaApprovedFacilityController {
    @AuraEnabled
    public static List<String> getFaciltyRequestFields() {
        List<String> fieldNames = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Facility_Request__c.fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
            fieldNames.add(fieldName);
        }
        return fieldNames;
    }
    
    @AuraEnabled
    public static List<Facility_Request__c> getAllTimeSlots(){
        List<Facility_Request__c> allTimeSlots =  [Select Id,End_Time__c,Start_Time__c FROM Facility_Request__c WHERE Start_Date__c >= today];
        System.debug('allTimeSlotsVals---->'+ allTimeSlots);
        return allTimeSlots;        
    }
    
    @AuraEnabled
    public static List<Facility_Request__c> getEventFacilities(){
        List<Facility_Request__c> facilityData =  [SELECT Id, Facility_Type__c FROM Facility_Request__c ];
        // List<hed__Facility__c> facilityData =  [SELECT Id, hed__Facility_Type__c FROM hed__Facility__c WHERE hed__Facility_Type__c IN ('Event venues')];
        System.debug('facilityData---->'+facilityData);
        return facilityData;       
    }
    
    @AuraEnabled
    public static List<Facility_Request__c> getLabFacilities(Id accountId){
        List<Facility_Request__c> facilityData =  [SELECT Id, Facility_Type__c FROM Facility_Request__c WHERE Facility_Type__c IN ('Laboratory' , 'Classroom') ];
        System.debug('facilityData---->'+facilityData);
        return facilityData;       
    } 
    
    @AuraEnabled
    public static List<Facility_Request__c> getFilteredFacilities(Id accountId,String facilityType, String buildingName, String floorNumber,String facilityName) {
        system.debug('facilityType--->'+ facilityType);
        system.debug('buildingName--->' + buildingName);
        system.debug('floorNumber--->'+ floorNumber);
        system.debug('facilityName--->'+ facilityName);
        List<Facility_Request__c> facilityResults = new List<Facility_Request__c>();
        
        if (facilityType != null && buildingName == null && floorNumber == null && facilityName == null ) {
            facilityResults = [SELECT Name, Facility_Name__c, Facility_Type__c, Building_Name__c, Floor__c, Room_No__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, ApprovalStatus__c, RequesterName__c FROM Facility_Request__c WHERE Facility_Type__c = :facilityType ];
        } else if (facilityType != null && buildingName != null && floorNumber == null && facilityName == null ) {
            
            facilityResults = [SELECT Name, Facility_Name__c, Facility_Type__c, Building_Name__c, Floor__c, Room_No__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, ApprovalStatus__c, RequesterName__c FROM Facility_Request__c WHERE Facility_Type__c = :facilityType AND Building_Name__c = :buildingName ];
        } else if (facilityType != null && buildingName != null && floorNumber != null && facilityName == null ) {
            facilityResults = [SELECT Name, Facility_Name__c, Facility_Type__c, Building_Name__c, Floor__c, Room_No__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, ApprovalStatus__c, RequesterName__c FROM Facility_Request__c WHERE Facility_Type__c = :facilityType AND Building_Name__c = :buildingName AND Floor__c = :floorNumber ];
        } else if (facilityType != null && buildingName != null && floorNumber != null && facilityName != null ) {
            facilityResults = [SELECT Id,Name, Facility_Name__c, Facility_Type__c, Building_Name__c, Floor__c, Room_No__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, ApprovalStatus__c, RequesterName__c FROM Facility_Request__c WHERE Facility_Type__c = :facilityType AND Building_Name__c = :buildingName AND Floor__c = :floorNumber AND Room_No__c = :facilityName];
        }        
        System.debug('facilityData---->' + facilityResults);
        return facilityResults;        
    }
    
    @AuraEnabled
    public static List<Calendar_Timings__c> getTimeValues() {
        List<Calendar_Timings__c> timeValsList = [SELECT Id, Name FROM Calendar_Timings__c ORDER BY Id ASC];
        return timeValsList;
    }
    
    @AuraEnabled
    public static List<hed__Course_Offering_Schedule__c> getCourseScedules(Id recordId){
        List<hed__Course_Offering_Schedule__c> courseTimeData =  [SELECT Id, Name ,hed__End_Time__c, hed__Start_Time__c ,hed__Facility__c,Date__c,	hed__Course_Offering__r.Active_Elective_Course__c  FROM hed__Course_Offering_Schedule__c where Id=: recordId];
        System.debug('courseTimeData---->'+courseTimeData);
        return courseTimeData ;
        
    }
    public class FacilityRequestWrapper {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String approvalStatus {get;set;}
        @AuraEnabled public String buildingName {get;set;}
        @AuraEnabled public String facilityName {get;set;}
        @AuraEnabled public String facilityType {get;set;}
        @AuraEnabled public String floorNumber {get;set;}
        @AuraEnabled public String roomNumber {get;set;}
        @AuraEnabled public Date startDate {get;set;}
        @AuraEnabled public Date endDate {get;set;}
        @AuraEnabled public string startTime {get;set;}
        @AuraEnabled public string endTime {get;set;}
        @AuraEnabled public String facilityReason {get;set;}
        @AuraEnabled public String additionalFacility {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Integer capacity {get;set;}
        @AuraEnabled public Boolean IAExamhall {get;set;}
        @AuraEnabled public Boolean facilityElectiveStatus {get;set;}
        
    }
    
    @AuraEnabled
    public static String saveFacilityRequest(String selectedFields, Id courseOfferingId) {
        System.debug('selected items coming from js---->' + selectedFields);
        System.debug('courseOfferingId items coming from js---->' + courseOfferingId);
        String errorMessage = '';
        String accountId;
        String updateAccId;
        
        List<hed__Course_Offering_Schedule__c> courseRequestData = new List<hed__Course_Offering_Schedule__c>();
        List<Facility_Request__c> facilityrequestData = new List<Facility_Request__c>();
        
        if (!courseOfferingId.toString().startsWith('001')) {
            hed__Course_Offering_Schedule__c data = [SELECT Id, SchoolName__c FROM hed__Course_Offering_Schedule__c WHERE Id =: courseOfferingId];
            accountId = data.SchoolName__c;
            updateAccId = data.SchoolName__c;
        } else {
            accountId = courseOfferingId;
        }
        
        FacilityRequestWrapper facilityWrappers = (FacilityRequestWrapper) JSON.deserialize(selectedFields, FacilityRequestWrapper.class);
        
        Time startTimeValue = Time.newInstance(0, 0, 0, 0);
        Time endTimeValue = Time.newInstance(0, 0, 0, 0);
        
        if (facilityWrappers != null) {
            if (facilityWrappers.startTime != null && facilityWrappers.startTime != '') {
                List<String> startTimeComponents = facilityWrappers.startTime.split(':|\\s');
                Integer starthour = Integer.valueOf(startTimeComponents[0]);
                Integer startMinute = Integer.valueOf(startTimeComponents[1]);
                startTimeValue = Time.newInstance(starthour, startMinute, 0, 0);
            }
            
            if (facilityWrappers.endTime != null && facilityWrappers.endTime != '') {
                List<String> endTimeComponents = facilityWrappers.endTime.split(':|\\s');
                Integer endHour = Integer.valueOf(endTimeComponents[0]);
                Integer endMinute = Integer.valueOf(endTimeComponents[1]);
                endTimeValue = Time.newInstance(endHour, endMinute, 0, 0);
            }
            
            Facility_Request__c part = new Facility_Request__c();
            part.Id=facilityWrappers.id;
            part.ApprovalStatus__c=facilityWrappers.approvalStatus;
            part.Building_Name__c = facilityWrappers.buildingName;
            part.Name = facilityWrappers.facilityName;
            part.Facility_Name__c = facilityWrappers.facilityName;
            part.Facility_Type__c = facilityWrappers.facilityType;
            part.Floor__c = facilityWrappers.floorNumber;
            part.Room_No__c = facilityWrappers.roomNumber;
            part.Reason_of_Booking__c = facilityWrappers.facilityReason;
            part.Additional_Amenities_Required__c = facilityWrappers.additionalFacility;
            part.Start_Date__c = facilityWrappers.startDate;
            part.End_Date__c = facilityWrappers.endDate;
            part.Start_Time__c = startTimeValue;
            part.End_Time__c = endTimeValue;
            part.Description__c = facilityWrappers.description;
            part.Capacity__c = facilityWrappers.capacity;
            part.IA_Exam_Hall__c = facilityWrappers.IAExamhall;
            system.debug('facilityElectiveStatus --->' + facilityWrappers.facilityElectiveStatus);
            part.Is_Elective__c =facilityWrappers.facilityElectiveStatus;
            // part.Account__c = accountId;
            
            try {
                system.debug('parts --->' + part);
                if(facilityWrappers.approvalStatus == 'Approved'){
                    update part;
                    System.debug('accountId --->' + accountId);
                    System.debug('updateAccId ---> '+ updateAccId);
                    System.debug('courseOfferingId ---> '+ courseOfferingId);
                    if (courseOfferingId != null && part.Facility_Type__c != 'Event Venues' && part.Facility_Type__c != 'IA Exam Hall') {
                        hed__Course_Offering_Schedule__c courseOfferingData = [SELECT Id, Facility_Request__c, Name FROM hed__Course_Offering_Schedule__c WHERE Id =: courseOfferingId];
                        courseOfferingData.Facility_Request__c = part.Id;
                        update courseOfferingData;
                    }
                    return 'Success';
                }else{
                    system.debug('before ---->');
                    if (courseOfferingId != null && part.Facility_Type__c != 'Event Venues' && part.Facility_Type__c != 'IA Exam Hall') {
                        hed__Course_Offering_Schedule__c courseOfferingData = [SELECT Id, Facility_Request__c FROM hed__Course_Offering_Schedule__c WHERE Id = :courseOfferingId];
                        courseOfferingData.Facility_Request__c = null;
                        update courseOfferingData;
                    }
                    
                    
                    system.debug('after --->');
                    return 'Request is not approved yet';
                }
                
                
            } catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    errorMessage += e.getDmlMessage(i) + '\n';
                }
                System.debug('exception evnthallbooking--->' + errorMessage);
                return errorMessage;
            } catch (Exception e) {
                errorMessage = e.getMessage();
                System.debug('exception facilitybooking--->' + errorMessage);
                return errorMessage;
            }
        } else {
            return 'No data to save';
        }
    }
}