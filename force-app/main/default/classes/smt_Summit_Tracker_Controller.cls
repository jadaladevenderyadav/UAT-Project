public without sharing class smt_Summit_Tracker_Controller {
    @AuraEnabled
    public static String createSummitTracker(String summitTrackerName, String schoolId, String batch) {
        try {
            
                smt_Summit_Tracker__c smtTracker = new smt_Summit_Tracker__c(
                    Name = summitTrackerName, 
                    smt_School__c = schoolId,
                    smt_Year__c = Decimal.valueOf(batch)
                );
                insert AS USER smtTracker;
                return smtTracker.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Particular__c> getSummitParticulars(String summitSectionId, String semester){
        
                if(semester == 'Odd'){
                       return [SELECT Id, Name, smt_Achieved__c, smt_Target_Text__c, smt_Timeline__c, smt_Percentage_Achieved__c,
                        smt_Is_Evidence_Applicable__c ,smt_Is_Target_Applicable__c, smt_Evidence_To_Be_Attached__c, 
                        smt_Actual_Percentage_Achieved__c
                        FROM smt_Summit_Particular__c
                        WHERE (smt_Is_Evidence_Applicable__c = TRUE 
                               OR smt_Is_Target_Applicable__c =  TRUE) AND 
                               smt_Summit_Section__c=:summitSectionId AND 
                               (Name Like '%OS' OR Name Like '%Odd')
                        WITH USER_MODE
                        ORDER BY Name ASC];
                    
                }else{
                       return [SELECT Id, Name, smt_Achieved__c, smt_Target_Text__c, smt_Timeline__c, smt_Percentage_Achieved__c,
                        smt_Is_Evidence_Applicable__c ,smt_Is_Target_Applicable__c, smt_Evidence_To_Be_Attached__c, 
                        smt_Actual_Percentage_Achieved__c
                        FROM smt_Summit_Particular__c
                        WHERE (smt_Is_Evidence_Applicable__c = TRUE 
                               OR smt_Is_Target_Applicable__c =  TRUE)AND 
                               smt_Summit_Section__c=:summitSectionId AND 
                               (NOT Name LIKE '%OS') AND (NOT Name LIKE '%Odd')
                        WITH USER_MODE
                        ORDER BY Name ASC];
                }
            
    }
    
    @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Particular__c> getAllSummitParticulars(String summitSectionId){
       
                return [SELECT Id, Name, smt_Achieved__c, smt_Target_Text__c, smt_Timeline__c, 
                        smt_Percentage_Achieved__c,smt_Target__c,smt_Is_Evidence_Applicable__c ,
                        smt_Is_Target_Applicable__c, smt_Evidence_To_Be_Attached__c, 
                        smt_Actual_Percentage_Achieved__c
                        FROM smt_Summit_Particular__c
                        WHERE smt_Summit_Section__c=:summitSectionId
                        WITH USER_MODE
                        ORDER BY Name ASC
                       ];
            }
      
    
    @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Tracker__c> getSummitTracker(String schoolId){
        
                return [SELECT Id, Name, smt_Total_Weightage_Achieved__c, smt_Year__c 
                        FROM smt_Summit_Tracker__c
                        WHERE smt_Is_Active__c = TRUE AND smt_School__c =:schoolId 
                        WITH USER_MODE];
            }
       
    
    
    @AuraEnabled
    public static void updateSummitParticular(String jsonData){
        try{
           
                    JsonToUpdateSummitParticular obj = new JsonToUpdateSummitParticular();
                    obj = obj.parse(jsonData);
                    
                    smt_Summit_Particular__c particular = new smt_Summit_Particular__c(Id = obj.Id);
                    particular.smt_Achieved__c = isDecimal(obj.achievedValue) ? Decimal.valueOf(obj.achievedValue) : 0;
                    particular.smt_Evidence_To_Be_Attached__c = obj.evidenceValue;
                    
                    Update AS USER particular;
                
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateAllSummitParticular(String jsonData){
        try{
            
                    JsonToSummitParticular obj = new JsonToSummitParticular();
                    List<JsonToSummitParticular> summitParticulars = obj.parse(jsonData);
                    List<smt_Summit_Particular__c> summitParticularsToUpdate = new List<smt_Summit_Particular__c>();
                    
                    for(JsonToSummitParticular summitParticular : summitParticulars){
                        String timeLineString = summitParticular.timeLine.substring(0, 10); 
                        Date timeLine = Date.valueOf(timeLineString); 
                        smt_Summit_Particular__c particular = 
                            new smt_Summit_Particular__c(Id = summitParticular.summitParticularId);
                        particular.Name = summitParticular.summitParticularName;
                        particular.smt_Timeline__c = timeLine;
                        particular.smt_Target__c = summitParticular.target;
                        particular.smt_Target_Text__c = summitParticular.targetText;
                        particular.smt_Is_Evidence_Applicable__c = summitParticular.isEvidenceApplicable;
                        particular.smt_Is_Target_Applicable__c	= summitParticular.isTargetApplicable;
                        summitParticularsToUpdate.add(particular);
                    }
                    
                    
                    Update AS USER summitParticularsToUpdate;
                
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static Boolean isDecimal(String input) {
        try {
            Decimal decimalValue = Decimal.valueOf(input);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Summit_Section_Metadata__mdt> getSummitSectionsMetadata(){
        
                return [SELECT Id, MasterLabel, smt_Weightage__c 
                        FROM Summit_Section_Metadata__mdt 
                        WITH USER_MODE
                        ORDER BY MasterLabel ASC];
            
        
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Summit_Particular__mdt> getSummitParticularsMetadata(String summitSectionLabel){
        
                return [SELECT MasterLabel, Summit_Section__c, Id 
                        FROM Summit_Particular__mdt 
                        WHERE Summit_Section__r.MasterLabel =: summitSectionLabel 
                        WITH USER_MODE
                        ORDER BY MasterLabel ASC];
          
    }
    
    @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Section__c> getSummitSectionRecords(String summitTrackerId){
      
                return [ SELECT Id, Name, smt_Weightage__c, smt_Sum_Of_Percentage_Achieved__c, smt_Number_Of_Particulars__c, 
                        smt_Target_Achieved__c, smt_No_Of_Particulars_Without_Condition__c, 
                        smt_Target_Achieved_With_Weightage__c, smt_Progress_Made_Summit_Particulars__c
                        FROM smt_Summit_Section__c 
                        WHERE smt_Summit_Tracker__c =: summitTrackerId
                        ORDER BY Name ASC];
           
    }
    
    @AuraEnabled
    public static void createSummitSections(String jsonData, String summitTrackerId) {
        try {
           
                List<smt_Summit_Section__c> sectionsToCreate = new List<smt_Summit_Section__c>();
                JsonToSummitSection obj = new JsonToSummitSection();
                List<JsonToSummitSection> summitSections = obj.parse(jsonData);
                System.debug(summitSections.size());
                
                // Iterate over each section data
                for (JsonToSummitSection summitSection : summitSections) {
                    smt_Summit_Section__c section = new smt_Summit_Section__c();
                    section.Name = summitSection.sectionName;
                    section.smt_Weightage__c = summitSection.weightage;
                    section.smt_Summit_Tracker__c = summitTrackerId;
                    
                    sectionsToCreate.add(section);
                }
                
                if (!sectionsToCreate.isEmpty()) {
                    insert AS USER sectionsToCreate;
                }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating Summit Section records: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createSummitParticular(String jsonData, String summitSectionId) {
        try {
                List<smt_Summit_Particular__c> particularsToCreate = new List<smt_Summit_Particular__c>();
                JsonToSummitParticular obj = new JsonToSummitParticular();
                List<JsonToSummitParticular> summitParticulars = obj.parse(jsonData);
                
                for (JsonToSummitParticular summitParticular : summitParticulars) {
                    String timeLineString = summitParticular.timeLine.substring(0, 10); 
                    Date timeLine = Date.valueOf(timeLineString); 
                    smt_Summit_Particular__c particular = new smt_Summit_Particular__c();
                    particular.Name = summitParticular.summitParticularName;
                    particular.smt_Timeline__c = timeLine;
                    particular.smt_Target__c = summitParticular.target;
                    particular.smt_Target_Text__c = summitParticular.targetText;
                    particular.smt_Is_Evidence_Applicable__c = summitParticular.isEvidenceApplicable;
                    particular.smt_Is_Target_Applicable__c	= summitParticular.isTargetApplicable;
                    particular.smt_Summit_Section__c = summitSectionId;
                    particularsToCreate.add(particular);
                }
                
                if (!particularsToCreate.isEmpty()) {
                    insert particularsToCreate;
                }
           
        } catch (Exception e) {
            throw new AuraHandledException('Error creating Summit Section records: ' + e.getMessage());
        }
    }
    
    public class JsonToSummitSection {
        
        public Integer id;
        public String sectionName;
        public Integer weightage;
        
        
        public List<JsonToSummitSection> parse(String json) {
            return (List<JsonToSummitSection>) System.JSON.deserialize(json, List<JsonToSummitSection>.class);
        }
    }
    public class JsonToSummitParticular {
        
        public Integer id;
        public String summitParticularName;
        public String summitParticularId;
        public String timeline;
        public Integer target;
        public String targetText;
        public Boolean isTargetApplicable;
        public Boolean isEvidenceApplicable;
        
        
        public List<JsonToSummitParticular> parse(String json) {
            return (List<JsonToSummitParticular>) System.JSON.deserialize(json, List<JsonToSummitParticular>.class);
        }
    }
    
    public class JsonToUpdateSummitParticular {
        
        public String id;
        public String achievedValue;
        public String evidenceValue;
        
        public JsonToUpdateSummitParticular parse(String json) {
            return (JsonToUpdateSummitParticular) System.JSON.deserialize(json, JsonToUpdateSummitParticular.class);
        }
    }
}