public without sharing class rveFacultyTimeTableController {

    public class timetableItem{
    public String Id {get;set;}
    public String StartTime {get;set;}
    public String EndTime {get;set;}
    public String LineItemDate {get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static List<hed__Program_Plan__c> searchProgramBatch(String searchKey) {
        String userId = userInfo.getUserId();
        String prgmBatchkey = '%' +  searchKey + '%';
        return[Select Id,Name,  hed__Account__r.Parent.Examination_Vertical_Head__c 
               from hed__Program_Plan__c where  hed__Account__r.Parent.Examination_Vertical_Head__c =:userId and Name LIKE:prgmBatchkey];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<hed__Term__c> getActiveSemester(String selectedValue){
        System.debug('selectedValue=> '+selectedvalue);
        return[Select Id,Name,Program_Batch__r.id, Active__c from hed__Term__c 
               where Program_Batch__r.id =:selectedValue and Active__c = true];
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<hed__Course_Offering__c> getCourses(String activeSemester){
        List<hed__Course_Offering__c> hedcourselist=new List<hed__Course_Offering__c>();
        List<hed__Term__c> termdata=[Select Id,Name, Active__c, (Select id, name, hed__Course__r.hed__Course_ID__c,hed__Course__r.name from hed__Course_Offerings__r ) 
                                     from hed__Term__c where Id =:activeSemester and Active__c = true];
        for(hed__Term__c tt:termdata){
            for(hed__Course_Offering__c tss:tt.hed__Course_Offerings__r){
                hedcourselist.add(tss);
            }
        }
        
        return hedcourselist;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<hed_Time_Table_Line_Item__c> getExamScheduleItems() {
        String userId = userInfo.getUserId();
        return [SELECT Id, Name, hed_Date__c, hed_Start_Time__c, hed_End_Time__c,Course__r.hed__Course_ID__c ,Reva_Exam_Notification__r.hed_IA_Type__c FROM hed_Time_Table_Line_Item__c
                where CreatedById =:userId AND Reva_Exam_Notification__r.Rve_Publish__c  = true ];
    }

    @AuraEnabled(cacheable=true)
    public static List<hed_Time_Table_Line_Item__c> getIAExamTimeTable(){
        try {
            String programBatch;
            String userId = userInfo.getUserId();
            User userCon = [SELECT Id, Username, Name, ContactId FROM User WHERE Id = :userId];
            List<Contact> conList = [SELECT Id, FirstName, LastName, Record_Type_Name__c, Program_Batch__c, Active_Semester__c FROM Contact WHERE Id = :userCon.ContactId];
            List<hed_Time_Table_Line_Item__c> timetableLineItem = new List<hed_Time_Table_Line_Item__c>();
    
            if (!conList.isEmpty()) {
                for (Contact con : conList) {
                    programBatch = con.Program_Batch__c;
                    System.debug('programBatch-->> ' + programBatch);
                }
    
                List<Rve_Exam_Notification__c> rveIANotification = [SELECT Id, Name, hed_Program_Batch__c, Rve_Semester__c, Rve_Publish__c, 
                                                                     (SELECT Id, Name, hed_Date__c, Course__r.hed__Course_ID__c, 
                                                                              Reva_Exam_Notification__r.hed_IA_Type__c, hed_End_Time__c,
                                                                              hed_Start_Time__c FROM Time_Table_Line_Items__r) 
                                                                     FROM Rve_Exam_Notification__c 
                                                                     WHERE hed_Program_Batch__c = :programBatch AND Rve_Publish__c = true];
    
                if (!rveIANotification.isEmpty()) {
                    for (Rve_Exam_Notification__c rveIA : rveIANotification) {
                        for (hed_Time_Table_Line_Item__c lineItems : rveIA.Time_Table_Line_Items__r) {
                            timetableLineItem.add(lineItems);
                        }
                    }
                }
            }
    
            // Return the list regardless of whether it is empty or not
            return timetableLineItem;
    
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
            return new List<hed_Time_Table_Line_Item__c>();
        }
    }
    

    // Function to update TimeTable LineItems which is coming from examScheduleDisplay LWC
@AuraEnabled
    public static void updategetExamScheduleItems(String JsonString){
    System.debug('JsonString=> '+JsonString);
    List<hed_Time_Table_Line_Item__c>updatedlist = new List<hed_Time_Table_Line_Item__c>();
    try{
             // Deserialize the JSON string into a list of EventData objects
        List<timetableItem> timetableItemlist = (List<timetableItem>) JSON.deserialize(jsonString, List<timetableItem>.class);

        if(timetableItemlist.size()>0)
        {
        // Iterate through each EventData object and convert the fields
        for (timetableItem timetable : timetableItemlist) {
            // Convert StartTime to Time
            Time startTime = getformattedtime(timetable.StartTime);
            Time EndTime = getformattedtime(timetable.EndTime);
            
            // Convert EventDate to Date
            Date eventDate = Date.valueOf(timetable.LineItemDate);

            // Perform your logic with the converted fields, e.g., update records
            System.debug('ID: ' + timetable.Id);
            System.debug('StartTime: ' + startTime);
            System.debug('EventDate: ' + eventDate);
            
            // Example update logic (assuming you have an sObject to update)
             hed_Time_Table_Line_Item__c record = [SELECT Id, hed_Start_Time__c,hed_End_Time__c, hed_Date__c FROM hed_Time_Table_Line_Item__c WHERE Id = :timetable.Id LIMIT 1];
             record.hed_Start_Time__c = startTime;
             record.hed_End_Time__c = EndTime;
             record.hed_Date__c = eventDate;
             System.debug('record=> '+record);
             updatedlist.add(record);
        }
    }

            if(updatedlist.size()>0)
            {
            update updatedlist;

            }

    }
    catch(Exception e)
    {
        System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
    }

    }

    // Helper method to parse time from string

    public static Time getformattedtime(String TimeTobeConverted) {
        try {
            List<String> timeParts = TimeTobeConverted.split(' '); // Split time and AM/PM
            String timeValue = timeParts[0]; // e.g., "01:00:00"
            String amPm = timeParts[1]; // e.g., "PM"
    
            // Further split the time value into hours, minutes, and seconds
            List<String> timeComponents = timeValue.split(':');
            Integer hour = Integer.valueOf(timeComponents[0]);
            Integer minute = Integer.valueOf(timeComponents[1]);
            Integer second = Integer.valueOf(timeComponents[2]);
    
            // Convert to 24-hour format
            if (amPm == 'PM' && hour != 12) {
                hour += 12; // Convert PM hours (except 12 PM) to 24-hour format
            } else if (amPm == 'AM' && hour == 12) {
                hour = 0; // Convert 12 AM to 0 hours
            }
    
            // Create Time instance
            Time startTimes = Time.newInstance(hour, minute, second, 0);
            return startTimes;
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
            // Return a default time instance or handle it appropriately
            return Time.newInstance(0, 0, 0, 0); // Default to 00:00:00
        }
    }
    
    @AuraEnabled
    public static string IATimeTableCreation(String notificationName, String semesterActive, String programBatch, String TimeTableData,String Iatypevalue){
        try{
        String Status='';
        List<Rve_Exam_Notification__c> notificationsToUpdate = [SELECT Id, Name, hed_Program_Batch__c, Rve_Semester__c, Rve_Publish__c, RecordType.DeveloperName FROM Rve_Exam_Notification__c 
                                                                                                  WHERE Rve_Publish__c = True AND  RecordType.DeveloperName = 'hed_IA_Notification' AND hed_Program_Batch__c =: programBatch ];
                                            
                                            if(notificationsToUpdate.size()>0)
                                            {
                                                for (Rve_Exam_Notification__c notification : notificationsToUpdate) {
                                                notification.Rve_Publish__c = false;
                                                }
                                                
                                                update notificationsToUpdate;
                                                System.debug('Records updated successfully.');
                                           
                                            }

              Id IANotificationRecordType = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByName().get('IA Notification').getRecordTypeId();
                                          
                                          Rve_Exam_Notification__c rveNotification = new Rve_Exam_Notification__c();
                                          rveNotification.Name = notificationName;
                                          rveNotification.Rve_Publish__c = true;
                                          rveNotification.Rve_Semester__c = semesterActive;
                                          rveNotification.hed_Program_Batch__c = programBatch;
                                          rveNotification.hed_IA_Type__c = Iatypevalue;
                                          rveNotification.RecordTypeId = IANotificationRecordType;
                                          
              insert rveNotification;


        List<TimeTableData> timetableItemlist = (List<TimeTableData>) JSON.deserialize(TimeTableData, List<TimeTableData>.class);
        List<hed_Time_Table_Line_Item__c> examLineItem = new List<hed_Time_Table_Line_Item__c>();
        if(timetableItemlist.size()>0)
        {
            for(TimeTableData Instance : timetableItemlist)
            {
                                              String startTimeString = Instance.StartTime;
                                              String endTimeString = Instance.EndTime;
                                              Time startTime;
                                              Time endTime;
                                                  if(!String.isEmpty(startTimeString)){
                                                   startTime = Time.newInstance(
                                                      Integer.valueOf(startTimeString.split(':')[0]),
                                                      Integer.valueOf(startTimeString.split(':')[1]),
                                                      Integer.valueOf(startTimeString.split(':')[2].substring(0, 2)),
                                                      0
                                                  );
                                                  
                                                  System.debug('Converted Salesforce Time: ' + startTime);
                                                                                                
                                                  if(!String.isEmpty(endTimeString)){
                                                   endTime = Time.newInstance(
                                                      Integer.valueOf(endTimeString.split(':')[0]),
                                                      Integer.valueOf(endTimeString.split(':')[1]),
                                                      Integer.valueOf(endTimeString.split(':')[2].substring(0, 2)),
                                                      0
                                                  );
                                                  
                                                  System.debug('Converted Salesforce Time: ' + endTime);
                                                  }}
                                                  hed_Time_Table_Line_Item__c rveExamLineItem = new hed_Time_Table_Line_Item__c();
                                                  rveExamLineItem.Reva_Exam_Notification__c = rveNotification.id;
                                                  rveExamLineItem.Name = Instance.CourseName;
                                                  rveExamLineItem.hed_Date__c = Instance.ExamDate;
                                                  rveExamLineItem.Course__c = Instance.CourseId;
                                                  rveExamLineItem.hed_Start_Time__c = StartTime;
                                                  rveExamLineItem.hed_End_Time__c = EndTime;
                                                  examLineItem.add(rveExamLineItem);
                                              }
// Use Database.insert to insert the records and get the DML status
List<Database.SaveResult> saveResults = Database.insert(examLineItem, false);

// Iterate through the saveResults to check the status of each insert operation
for (Integer i = 0; i < saveResults.size(); i++) {
    if (saveResults[i].isSuccess()) {
        // The insert was successful
        return 'success';
    } else {
        // The insert failed
        System.debug('Failed to insert record. Errors: ');
        for (Database.Error error : saveResults[i].getErrors()) {
            System.debug('Error: ' + error.getStatusCode() + ' - ' + error.getMessage());
        }
        return 'failure';
    }            }
        }
    }
        catch(Exception e)
        {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            return e.getMessage();
        }
        return 'success';
    }

    public class TimeTableData{
        public String CourseId {get;set;}
        public String CourseIdName {get;set;}
        public String CourseName {get;set;}
        public Date ExamDate {get;set;}
        public String StartTime {get;set;}
        public String EndTime {get;set;}

    }
    
    public class examStartTimeDetails{
        public string recordIdvalue{get;set;}
        public String starttime{get;set;} 
        public String courseName {get;set;}       
    }
    
    public class examEndTimeDetails{
        public string recordIdvalue {get;set;}
        public String endtime {get;set;} 
        public String courseName {get;set;}       
    }
    
    public class examDateDetails{
        public string recordIdvalue {get;set;}
        public String examdate {get;set;} 
        public String courseName {get;set;}       
    }
    
}