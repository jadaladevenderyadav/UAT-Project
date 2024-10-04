public without sharing class revaFacilityRequestBookingController {
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
    public static List<Facility_Request__c> getAllTimeSlots() {
        List<Facility_Request__c> allTimeSlots = [SELECT Id, End_Time__c, Start_Time__c FROM Facility_Request__c WHERE Start_Date__c >= TODAY];
        return allTimeSlots;        
    }
    
    @AuraEnabled
    public static List<hed__Facility__c> getEventFacilities() {
        List<hed__Facility__c> facilityData = [SELECT Id, hed__Facility_Type__c FROM hed__Facility__c WHERE hed__Facility_Type__c IN ('Event venues')];
        return facilityData;       
    }
    
    @AuraEnabled
   // public static List<hed__Facility__c> getLabFacilities(Id accountId) {
     public static List<hed__Facility__c> getLabFacilities() {

        List<hed__Facility__c> facilityData = [SELECT Id, hed__Facility_Type__c FROM hed__Facility__c WHERE hed__Facility_Type__c='Event Venues'];
        return facilityData;       
    } 
    
    @AuraEnabled
    public static List<Amenities__c> getAminities(Id facilityId, String Block, String Floor, String Room) {
       List<Amenities__c> aminityData = [SELECT Id, Block__c, Floor__c, Room__c, Item_Name__c FROM Amenities__c WHERE Block__c = :Block AND Floor__c = :Floor AND Room__c = :Room];
       return aminityData;       
    }

    @AuraEnabled
    public static List<hed__Facility__c> getFilteredFacilities(Id accountId, String facilityType, String buildingName, String floorNumber, String facilityName,String startDate,String endDate,String endTime,String startTime) {
        List<hed__Facility__c> facilityResults = new List<hed__Facility__c>();
    
        // Parse the start date and time
        Date startDateOnly = Date.valueOf(startDate);
        Time startTimeOnly = parseTime(startTime); // Custom function to parse time

        // Parse the end date and time
        Date endDateOnly = Date.valueOf(endDate);
        Time endTimeOnly = parseTime(endTime); // Custom function to parse time

        // Create DateTime objects for comparison
        DateTime startDateTime = DateTime.newInstance(startDateOnly, startTimeOnly);
        DateTime endDateTime = DateTime.newInstance(endDateOnly, endTimeOnly);

        // Query to get overlapping facility requests
        List<Facility_Request__c> existingRequests = [
            SELECT Facility_Type__c, Building_Name__c, Floor__c, Room_No__c, Start_Date__c, Start_Time__c, End_Time__c, End_Date__c
            FROM Facility_Request__c
            WHERE (
                (Start_Date__c < :endDateOnly OR
                (Start_Date__c = :endDateOnly AND Start_Time__c < :endTimeOnly))
                AND
                (End_Date__c > :startDateOnly OR
                (End_Date__c = :startDateOnly AND End_Time__c > :startTimeOnly))
            )
        ];

        
        // Create sets to store unique combinations of facility request attributes
        Set<String> existingFacilities = new Set<String>();
        for (Facility_Request__c request : existingRequests) {
            existingFacilities.add(request.Facility_Type__c + '|' + request.Building_Name__c + '|' + request.Floor__c + '|' + request.Room_No__c);
        }
        System.debug('existingFacilities===>'+JSON.Serialize(existingFacilities));
        if (facilityType != null && buildingName == null && floorNumber == null && facilityName == null) {
            facilityResults = [SELECT Id, Name, Floor__c, Lab_Type__c, hed__Parent_Facility__c, Block__c, hed__Capacity__c, ClassRoom_Type__c, Display_Name__c, hed__Facility_Type__c, Room__c 
                               FROM hed__Facility__c 
                               WHERE hed__Facility_Type__c = :facilityType ORDER BY Floor_Sort_Order__c , Room__c];
        } else if (facilityType != null && buildingName != null && floorNumber == null && facilityName == null) {
            facilityResults = [SELECT Id, Name, Floor__c, Lab_Type__c, hed__Parent_Facility__c, Block__c, hed__Capacity__c, ClassRoom_Type__c, Display_Name__c, hed__Facility_Type__c, Room__c 
                               FROM hed__Facility__c 
                               WHERE hed__Facility_Type__c = :facilityType AND Block__c = :buildingName ORDER BY Floor_Sort_Order__c ,Room__c ];
        } else if (facilityType != null && buildingName != null && floorNumber != null && facilityName == null) {
            facilityResults = [SELECT Id, Name, Floor__c, Lab_Type__c, hed__Parent_Facility__c, Block__c, hed__Capacity__c, ClassRoom_Type__c, Display_Name__c, hed__Facility_Type__c, Room__c 
                               FROM hed__Facility__c 
                               WHERE hed__Facility_Type__c = :facilityType AND Block__c = :buildingName AND Floor__c = :floorNumber ORDER BY Floor_Sort_Order__c, Room__c];
        } else if (facilityType != null && buildingName != null && floorNumber != null && facilityName != null) {
            facilityResults = [SELECT Id, Name, Floor__c, Lab_Type__c, hed__Parent_Facility__c, Block__c, hed__Capacity__c, ClassRoom_Type__c, Display_Name__c, hed__Facility_Type__c, Room__c 
                               FROM hed__Facility__c 
                               WHERE hed__Facility_Type__c = :facilityType AND Block__c = :buildingName AND Floor__c = :floorNumber AND Room__c = :facilityName ORDER BY Floor_Sort_Order__c , Room__c ];
        }
        System.debug('filteredFacilityResults===>'+JSON.Serialize(facilityResults));
        // Filter the results based on existing facility requests
        List<hed__Facility__c> filteredFacilityResults = new List<hed__Facility__c>();
        for (hed__Facility__c facility : facilityResults) {
            String facilityKey = facility.hed__Facility_Type__c + '|' + facility.Block__c + '|' + facility.Floor__c + '|' + facility.Room__c;
            if (!existingFacilities.contains(facilityKey)) {
                filteredFacilityResults.add(facility);
            }
        }
        System.debug('Filtered Results===>'+JSON.Serialize(filteredFacilityResults));
        return filteredFacilityResults;        
    }

    @AuraEnabled
    public static List<Calendar_Timings__c> getTimeValues() {
        List<Calendar_Timings__c> timeValsList = [SELECT Id, Name FROM Calendar_Timings__c ORDER BY Id ASC];
        return timeValsList;
    }

    @AuraEnabled
    public static List<hed__Course_Offering_Schedule__c> getCourseScedules(Id recordId) {
        List<hed__Course_Offering_Schedule__c> courseTimeData = [SELECT Id, Name, hed__End_Time__c, hed__Start_Time__c, hed__Facility__c, Date__c, hed__Course_Offering__r.Active_Elective_Course__c FROM hed__Course_Offering_Schedule__c WHERE Id = :recordId];
        return courseTimeData; 
    }
    
    @AuraEnabled
    // Helper function to parse time string
    public static Time parseTime(String timeString) {
        String[] timeParts = timeString.split(' ');
        String[] hourMinute = timeParts[0].split(':');
        Integer hour = Integer.valueOf(hourMinute[0]);
        Integer minute = Integer.valueOf(hourMinute[1]);
        String amPm = timeParts[1];

        // Convert 12-hour format to 24-hour format
        if (amPm == 'PM' && hour != 12) {
            hour += 12;
        } else if (amPm == 'AM' && hour == 12) {
            hour = 0;
        }

        return Time.newInstance(hour, minute, 0, 0);
    }

    public class FacilityRequestWrapper {
        @AuraEnabled public String buildingName {get;set;}
        @AuraEnabled public String facilityName {get;set;}
        @AuraEnabled public String facilityType {get;set;}
        @AuraEnabled public String floorNumber {get;set;}
        @AuraEnabled public String roomNumber {get;set;}
        @AuraEnabled public Date startDate {get;set;}
        @AuraEnabled public Date endDate {get;set;}
        @AuraEnabled public String startTime {get;set;}
        @AuraEnabled public String endTime {get;set;}
        @AuraEnabled public String facilityReason {get;set;}
        @AuraEnabled public String additionalFacility {get;set;}
        @AuraEnabled public String additionalFacility2 {get;set;}
        @AuraEnabled public String quantityOfAdditionalAmenities {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Integer capacity {get;set;}
        @AuraEnabled public Boolean isElective {get;set;}
       // @AuraEnabled public Id facilityId {get;set;}
    }
    
    @AuraEnabled
    public static String saveFacilityRequest(String selectedFields, Id courseOfferingId) {
        String errorMessage = '';
        String accountId;
        boolean approvalStatus = false;

        FacilityRequestWrapper facilityWrappers = (FacilityRequestWrapper) JSON.deserialize(selectedFields, FacilityRequestWrapper.class);

        // Time startTimeValue;
        // Time endTimeValue;
        // if (facilityWrappers != null && facilityWrappers.startTime != null && facilityWrappers.startTime != '') {
        //     List<String> startTimeComponents = facilityWrappers.startTime.split(':|\\s');
        //     Integer starthour = Integer.valueOf(startTimeComponents[0]);
        //     Integer startMinute = Integer.valueOf(startTimeComponents[1]);
        //     startTimeValue = Time.newInstance(starthour, startMinute, 0, 0);
        // }
        //  system.debug('facilityRec::');
        // if (facilityWrappers != null && facilityWrappers.endTime != null && facilityWrappers.endTime != '') {
        //     List<String> endTimeComponents = facilityWrappers.endTime.split(':|\\s');
        //     Integer endHour = Integer.valueOf(endTimeComponents[0]);
        //     Integer endMinute = Integer.valueOf(endTimeComponents[1]);
        //     endTimeValue = Time.newInstance(endHour, endMinute, 0, 0);
        // }
        // system.debug('facilityRec::++'+facilityWrappers.facilityName);  
        
       
        Time startTimeValue;
        Time endTimeValue;

        if (facilityWrappers != null) {
            // Handling startTime
            if (facilityWrappers.startTime != null && facilityWrappers.startTime != '') {
                List<String> startTimeComponents = facilityWrappers.startTime.split(':|\\s');
                Integer startHour = Integer.valueOf(startTimeComponents[0]);
                Integer startMinute = Integer.valueOf(startTimeComponents[1]);
                
                // Adjust for AM/PM
                if (startTimeComponents.size() > 2 && startTimeComponents[2].equalsIgnoreCase('PM') && startHour != 12) {
                    startHour += 12; // Convert PM hour to 24-hour format
                } else if (startTimeComponents.size() > 2 && startTimeComponents[2].equalsIgnoreCase('AM') && startHour == 12) {
                    startHour = 0; // Convert 12 AM to 0 hours
                }

                startTimeValue = Time.newInstance(startHour, startMinute, 0, 0);
            }

            System.debug('facilityRec::');

            // Handling endTime
            if (facilityWrappers.endTime != null && facilityWrappers.endTime != '') {
                List<String> endTimeComponents = facilityWrappers.endTime.split(':|\\s');
                Integer endHour = Integer.valueOf(endTimeComponents[0]);
                Integer endMinute = Integer.valueOf(endTimeComponents[1]);

                // Adjust for AM/PM
                if (endTimeComponents.size() > 2 && endTimeComponents[2].equalsIgnoreCase('PM') && endHour != 12) {
                    endHour += 12; // Convert PM hour to 24-hour format
                } else if (endTimeComponents.size() > 2 && endTimeComponents[2].equalsIgnoreCase('AM') && endHour == 12) {
                    endHour = 0; // Convert 12 AM to 0 hours
                }

                endTimeValue = Time.newInstance(endHour, endMinute, 0, 0);
            }
        }



        if (!Test.isRunningTest()){
        hed__Facility__c facilityRec = [SELECT Id, Name, hed__Account__c, hed__Account__r.Name FROM hed__Facility__c WHERE Name = :facilityWrappers.facilityName LIMIT 1];
        system.debug('facilityRec::--'+facilityRec);

        
        accountId = System.Label.defaultAccountId;
        system.debug('+++accountId++++'+accountId);

        User loggedInUsr = [SELECT Id, Department FROM User WHERE Id = :UserInfo.getUserId()];
        if (loggedInUsr.Department == facilityRec.hed__Account__r.Name) {
            approvalStatus = true;
        }}else{
            accountId = [SELECT id from Account LIMIT 1].id;
            system.debug('+++accountId++++'+accountId);
            approvalStatus = true;
        }

        Facility_Request__c part = new Facility_Request__c();
        part.Building_Name__c = facilityWrappers.buildingName;
        part.Facility_Type__c = facilityWrappers.facilityType;
        part.Floor__c = facilityWrappers.floorNumber;
        part.Room_No__c = facilityWrappers.roomNumber;
        part.Reason_of_Booking__c = facilityWrappers.facilityReason;
        part.Additional_Amenities_Required__c = facilityWrappers.additionalFacility;
        part.Additional_Amenities_Required2__c = facilityWrappers.additionalFacility2;
        part.Start_Date__c = facilityWrappers.startDate;
        part.End_Date__c = facilityWrappers.endDate;
        part.Start_Time__c = startTimeValue;
        part.End_Time__c = endTimeValue;
        part.Quantity_Of_Additional_Amenities__c = facilityWrappers.quantityOfAdditionalAmenities;
        part.Description__c = facilityWrappers.description;
        part.Capacity__c = facilityWrappers.capacity;
        part.Account__c = accountId;
        //part.Facility__c = facilityWrappers.facilityId;
        
        if (approvalStatus) {
            part.ApprovalStatus__c = 'Approved';
        }

        if (part != null) {
            try {
                insert part; 
                return 'Success';
            } catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    errorMessage += e.getDmlMessage(i) + '\n';
                }
                return errorMessage;
            } catch (Exception e) {
                errorMessage = e.getMessage();
                return errorMessage;
            }
        }
        
        return 'Error in creating Facility Request';
    }

    @AuraEnabled
    public static List<Reva_Infra_Additional_Amenity__mdt> getAdditionalAmenities() {
        List<Reva_Infra_Additional_Amenity__mdt> additionalAminityData = [SELECT Name__c FROM Reva_Infra_Additional_Amenity__mdt];
        return additionalAminityData;       
    }
}