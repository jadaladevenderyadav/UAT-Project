public without sharing class revaSWCustomMetadataController {
    
    @AuraEnabled(cacheable=true)
    public static List<RSW_Manodhaara_CMT__mdt> getAllCustomMetadata() {
        return [SELECT Id, RSW_Manodhaara_App_Info__c FROM RSW_Manodhaara_CMT__mdt];
    }
    
    // added by srinivasuveera on 25-10-2023 for the Hostel module
    
    @AuraEnabled(cacheable=true)
    public static List<Reva_Hostel_Setting__mdt> getHostelCustomMetadata() {
        return [SELECT Id, Reva_Hostel_Description__c FROM Reva_Hostel_Setting__mdt];
    }
  
    //*******************************************************************************************************//
    @AuraEnabled(cacheable=true)
    public static HostelFeeResponse calculateHostelFee(String roomType, Boolean isPremium, Boolean isFinalYear) {
        HostelFeeResponse response = new HostelFeeResponse();
        String Checkgender ;
        List<REVA_Hostel_Fees__c> hostelSettings = [SELECT Id, Name,Gender__c, Hostel_Room_Fees__c, Occupancy__c, Is_Final_Year__c, Premium__c FROM REVA_Hostel_Fees__c];
        
         User currentUser = [SELECT ContactId,Contact.hed__Gender__c  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(currentUser.Contact.hed__Gender__c == 'Male'){
              Checkgender = 'Boys';
        }else{
            if(currentUser.Contact.hed__Gender__c == 'Female'){
              Checkgender = 'Girls';
          }
        }
        //Checkgender= currentUser.Contact.hed__Gender__c == 'Male' ? Boys : Girls;
        
        // Debug log for the size of hostelSettings
        System.debug('Number of Hostel Settings: ' + hostelSettings.size());
         System.debug('Number of Hostel Settings: ' + Checkgender);
        for (REVA_Hostel_Fees__c setting : hostelSettings) {
            System.debug('Processing Hostel Setting: ' + setting);
            
            // Check if the student is in the final year and the setting is for final year
            if (isFinalYear && setting.Is_Final_Year__c && setting.Premium__c == isPremium && setting.Occupancy__c == roomType && setting.Gender__c == Checkgender ) {
                System.debug('Matching Setting Found for Final Year: ' + setting);
                response.hostelFee = setting.Hostel_Room_Fees__c != null ? setting.Hostel_Room_Fees__c : 0;
                break;
            } 
            // Check if the student is not in the final year and the setting is not for final year
            else if (!isFinalYear && !setting.Is_Final_Year__c && setting.Premium__c == isPremium && setting.Occupancy__c == roomType  && setting.Gender__c == Checkgender) {
                System.debug('Matching Setting Found for Non-Final Year: ' + setting);
                response.hostelFee = setting.Hostel_Room_Fees__c != null ? setting.Hostel_Room_Fees__c : 0;
                break;
            }
        }
        
        // If a matching setting is not found, look for a generic setting without considering final year
        if (response.hostelFee == null) {
            for (REVA_Hostel_Fees__c setting : hostelSettings) {
                System.debug('Processing Hostel Setting (Generic): ' + setting);
                
                if (setting.Premium__c == isPremium && setting.Occupancy__c == roomType && setting.Gender__c == Checkgender) {
                    System.debug('Matching Generic Setting Found: ' + setting);
                    response.hostelFee = setting.Hostel_Room_Fees__c != null ? setting.Hostel_Room_Fees__c : 0;
                    break;
                }
            }
        }
        
        // Debug log for the final hostel fee value
        System.debug('Final Hostel Fee: ' + response.hostelFee);
        
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RoomPriceResponse> getAllRoomPrices() {
        List<RoomPriceResponse> roomPrices = new List<RoomPriceResponse>();
        
        List<REVA_Hostel_Fees__c> metadataRecords = [SELECT Id,Name, Hostel_Room_Fees__c, Occupancy__c FROM REVA_Hostel_Fees__c];
        
        for (REVA_Hostel_Fees__c metadata : metadataRecords) {
            RoomPriceResponse roomPrice = new RoomPriceResponse();
            roomPrice.roomType = metadata.Name;
            roomPrice.price = metadata.Hostel_Room_Fees__c != null ? metadata.Hostel_Room_Fees__c : 0;
            roomPrices.add(roomPrice);
        }
        
        return roomPrices;
    }
    
    public class HostelFeeResponse {
        @AuraEnabled
        public Decimal hostelFee { get; set; }
    }
    public class RoomPriceResponse {
        @AuraEnabled
        public String roomType { get; set; }
        
        @AuraEnabled
        public Decimal price { get; set; }
    }
}