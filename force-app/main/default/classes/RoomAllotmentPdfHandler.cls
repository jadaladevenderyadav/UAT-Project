public without sharing class RoomAllotmentPdfHandler {
    
    public Map<String, List<String>> RoomWithProgramBatches { get; private set; }
    public Map<String, Map<String,List<Contact>>> programBatchWithContacts { get; private set; }
    public Map<String, String> ProgramWithCourseIds {get; set;}
    public Map<String, Map<String,String>> RoomWithCourseNames {get; set;}
    public Map<String, String> ProgramWithSemester {get;set;}
    public Map<String, String> RoomWithBlockNames {get;set;}
    public Map<String, String> RoomWithIAType {get;set;}
    public Map<String,String> ProgramWithCourseName {get;set;}
    
    public Date DateWiseAllotment { get; private set; }
    public Time TimeWiseAllotment {get; private set; }
    public String schoolName { get; private set; }
    public Map<String,String> StartTime {get;set;}
    public Map<String,String> EndTime {get;set;}
    public String formattedDate { get; private set; }
    public String FormattedSemDate {get;set;}
    public String SemesterType {get;set;}
    public Boolean DisplayEligible { get; set; }
    public Boolean DisplayInEligible { get; set; }
    
    public RoomAllotmentPdfHandler(ApexPages.StandardController controller) {
        DisplayEligible = false;
        DisplayInEligible = false;
        RoomWithProgramBatches = new Map<String,List<String>>();
        RoomWithIAType = new Map<String,String>();
        programBatchWithContacts = new Map<String,Map<String,List<Contact>>>();
        ProgramWithCourseIds = new Map<String,String>();
        RoomWithCourseNames = new Map<String,Map<String,String>>();
        ProgramWithSemester = new Map<String, String>();
        RoomWithBlockNames = new Map<String,String>();
        StartTime = new Map<String,String>();
        EndTime = new MAp<String,String>();
        String AllotmentDate = ApexPages.currentPage().getParameters().get('DatePass');
        String AllotmentTime = ApexPages.currentPage().getParameters().get('TimePass');
        System.debug('DisplayTable=> ' + AllotmentDate);
        System.debug('AllotmentTime=> '+AllotmentTime);
        if (AllotmentDate != null) {
            DateWiseAllotment = Date.valueOf(AllotmentDate);
        }
        if(AllotmentTime !=null)
        {
            List<String>timelist = AllotmentTime.split(':');
            
            TimeWiseAllotment = Time.newInstance(Integer.valueOf(timelist[0]),Integer.valueOf(timelist[1]),Integer.valueOf(timelist[2]),0);
        }
        getProgramBatchSRNs();
        // Example condition for displaying the table and fields based on type
    }
    
    public void getProgramBatchSRNs() {
        try {
            // Step 1: Query Seating_Room_Allotment__c records
            List<IA_Seating_Room_Allotment__c> allotments = [SELECT Id,Name,IA_Type__c,Facility_Type__r.Block__c, rve_Date_of_Exam__c,School__r.Name,
                                                             Assigned_Program_Batches__c,Exam_Time__c,End_Time__c, Alloted_Students__c,
                                                             InEligible_SRN__c,School__r.Examination_Vertical_Head__c FROM IA_Seating_Room_Allotment__c where rve_Date_of_Exam__c=:DateWiseAllotment
                                                             and Exam_Time__c = :TimeWiseAllotment and (School__r.parent.Examination_Vertical_Head__c=:userinfo.getuserId()
                                                             or School__r.Examination_Vertical_Head__c=:userinfo.getuserId())];
            System.debug('allotments=> '+allotments);
            List<hed_Time_Table_Line_Item__c>TimeTableList = new List<hed_Time_Table_Line_Item__c>();
            Date dateValue = allotments[0].rve_Date_of_Exam__c!=null?allotments[0].rve_Date_of_Exam__c:Date.today();
            
            // Format the Date object to "dd/MM/yyyy" format
              formattedDate = datevalue.day()+'/'+datevalue.month()+'/'+datevalue.year();
              System.debug('Date=> ' + formattedDate);
            
            Date parsedDate;
            
            // Parse the input date string into a Date object
            try {
                parsedDate = Date.newInstance(
                   datevalue.year(),datevalue.month(),datevalue.day()
                );
            } catch (Exception e) {
                System.debug('Error parsing date: ' + e.getMessage());
                // Handle error or invalid date format
            }
            
            // Convert the Date object to a DateTime object
            DateTime dt = DateTime.newInstance(parsedDate, Time.newInstance(0, 0, 0, 0));
            
            // Format the DateTime object into the desired output format
            if (dt != null) {
                FormattedSemDate = dt.format('MMMM yyyy');
                System.debug('Formatted Date: ' + FormattedSemDate); // Output: March 2024
            }
            
            schoolName = allotments[0].School__r.Name;
            //StartTime = convertTime(allotments[0].Exam_Time__c);
            //EndTime = convertTime(allotments[0].End_Time__c);
            
            // Step 2: Iterate over each allotment record
            System.debug('allotments ' + allotments[0].Exam_Time__c);
            System.debug('allotmentssize ' + allotments.size());
            
            for (IA_Seating_Room_Allotment__c allotment : allotments) {
                System.debug('88=> '+allotment.Name);
                Map<Id,String>ProgramWithcourse = new Map<Id,String>();
                RoomWithBlockNames.put(allotment.Name,allotment.Facility_Type__r.Block__c);
                RoomWithIAType.put(allotment.Name,allotment.IA_Type__c);
                // Step 3: Get program batches
                // Parse Assigned Program Batches to get Program Batch IDs
                List<String> programBatchIds = allotment.Assigned_Program_Batches__c.split(',');
                System.debug('223=> ' + programBatchIds);
                
                TimeTableList = [SELECT Id, Course__r.hed__Course_ID__c, Course__r.Name,Reva_Exam_Notification__r.Rve_Semester__r.Name,
                                 Reva_Exam_Notification__r.hed_Program_Batch__r.Name FROM hed_Time_Table_Line_Item__c
                                 WHERE hed_Date__c = :allotment.rve_Date_of_Exam__c 
                                 AND Reva_Exam_Notification__r.Rve_Publish__c = true AND Reva_Exam_Notification__r.hed_Program_Batch__c IN :programBatchIds
                                 AND hed_Start_Time__c =:allotment.Exam_Time__c
                                 Order By Course__r.Name];
                
                System.debug('TimeTableList=> '+TimeTableList);
                
                // Step 3: Query Contact records filtered by Program Batch IDs
                List<String> allotedSRNs = allotment.Alloted_Students__c != null ? allotment.Alloted_Students__c.split(',') : new List<String>();
                List<String> ineligibleSRNs = allotment.InEligible_SRN__c != null ? allotment.InEligible_SRN__c.split(',') : new List<String>();
                
                Set<String> srnsToQuery = new Set<String>();
                srnsToQuery.addAll(allotedSRNs);
                srnsToQuery.addAll(ineligibleSRNs);
                System.debug('srnsToQuery=> '+srnsToQuery.size());
                System.debug('TimeTableList=> '+TimeTableList);
                
                List<Contact> contacts = [SELECT Id, Name, SRN_Number__c, Program_Batch__r.Name,program_Batch__c
                                          FROM Contact 
                                          WHERE Program_Batch__c IN :programBatchIds 
                                          AND SRN_Number__c != null 
                                          AND SRN_Number__c IN :srnsToQuery 
                                          ORDER BY SRN_Number__c];
                System.debug('226=> ' + contacts.size());
                
                //  List<String> courseIds = new List<String>();
                //   List<String> CourseNames = new List<String>();
                for (hed_Time_Table_Line_Item__c timeTable : TimeTableList) {
                    
                    ProgramWithcourse.put(timeTable.Reva_Exam_Notification__r.hed_Program_Batch__c,timeTable.Course__r.Name);
                    String programBatchName = timeTable.Reva_Exam_Notification__r.hed_Program_Batch__r.Name;
                    ProgramWithCourseIds.put(timeTable.Reva_Exam_Notification__r.hed_Program_Batch__r.Name, timeTable.Course__r.hed__Course_ID__c);
                    ProgramWithSemester.put(timeTable.Reva_Exam_Notification__r.hed_Program_Batch__r.Name,timeTable.Reva_Exam_Notification__r.Rve_Semester__r.Name);
                    // Add Course Name to the list
                    // Check if the key exists in the map
                    String outerKey = allotment.Name;
                    String innerKey = timeTable.Reva_Exam_Notification__r.hed_Program_Batch__r.name;
                    String innerValue = timeTable.Course__r.Name;
                    if (RoomWithCourseNames.containsKey(outerKey)) {
                        // Outer key exists, update inner map
                        Map<String, String> innerMap = RoomWithCourseNames.get(outerKey);
                        innerMap.put(innerKey, innerValue);
                    } else {
                        // Outer key doesn't exist, create a new inner map and insert
                        Map<String, String> innerMap = new Map<String, String>();
                        innerMap.put(innerKey, innerValue);
                        RoomWithCourseNames.put(outerKey, innerMap);
                    }
                    
                    
                    Pattern pattern = Pattern.compile('[0-9]+'); // Regular expression to find numbers
                    Matcher matcher = pattern.matcher(timeTable.Reva_Exam_Notification__r.Rve_Semester__r.Name);
                    
                    // Loop through all matches to get the last one
                    while (matcher.find()) {
                        SemesterType = checkEvenOdd(Integer.valueOf(matcher.group(0)));
                        
                    }
                    
                    System.debug('Last Number: ' + SemesterType); // Output: 1
                }
                
                // Step 4: Create a map of Program Batch name to list of Contacts
                for (Contact contact1 : contacts) {
                    String key = allotment.Name;
                    System.debug('key=> '+key);
                    StartTime.put(allotment.name,convertTime(allotment.Exam_Time__c));
                    EndTime.put(allotment.name,convertTime(allotment.End_Time__c));
                    
                    //     System.debug('Contact=> '+contact1.SRN_Number__c);
                    if ((allotment.Alloted_Students__c != null && allotment.Alloted_Students__c.contains(contact1.SRN_Number__c)) || 
                        (allotment.InEligible_SRN__c != null && allotment.InEligible_SRN__c.contains(contact1.SRN_Number__c))) {
                            if (!programBatchWithContacts.containsKey(key)) {
                                Map<String,List<contact>>InnerMap = new Map<String,List<contact>>();
                                Innermap.put(contact1.Program_Batch__r.name,new List<contact>{contact1});
                                programBatchWithContacts.put(key, innermap);
                            }
                            else{
                                Map<String, List<Contact>> Innermap1 = programBatchWithContacts.get(key);
                                
                                // Check if Innermap1 is null
                                if (Innermap1 == null) {
                                    // Initialize a new map if it doesn't exist for this key
                                    Innermap1 = new Map<String, List<Contact>>();
                                }
                                
                                // Get the list for the specific program batch
                                List<Contact> InnerMap1list = Innermap1.get(contact1.Program_Batch__r.name);
                                
                                // Check if InnerMap1list is null
                                if (InnerMap1list == null) {
                                    // Initialize a new list if it doesn't exist
                                    InnerMap1list = new List<Contact>();
                                }
                                
                                // Add the new contact to the list
                                InnerMap1list.add(contact1);
                                
                                // Update the inner map with the new list
                                Innermap1.put(contact1.Program_Batch__r.name, InnerMap1list);
                                
                                // Update the main map with the updated inner map
                                programBatchWithContacts.put(key, Innermap1);
                                
                            }
                            // Add program batch to the room map only if it's not already present
                            if (!RoomWithProgramBatches.containsKey(allotment.Name)) {
                                RoomWithProgramBatches.put(allotment.Name, new List<String>());
                            }
                            List<String> programBatches = RoomWithProgramBatches.get(allotment.Name);
                            if (!programBatches.contains(contact1.Program_Batch__r.Name)) {
                                programBatches.add(contact1.Program_Batch__r.Name);
                                system.debug('the program batches ar####'+programBatches);
                            }
                        }
                }
            }  
            } catch(Exception e) {
                System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
            }
        }
        
        public static String checkEvenOdd(Integer semnumber) {
            if (Math.mod(semnumber, 2) == 0) {
                return 'Even';  // The number is even
            } else {
                return 'Odd';   // The number is odd
            }
        }
        
        public static string convertTime(Time TimeToBeConverted){
            DateTime dateTimeValue = DateTime.newInstance(Date.today(), TimeToBeConverted);
            String formattedTime = dateTimeValue.format('h:mm a');
            //  System.debug('51=> '+formattedTime);
            return formattedTime;
        }
    }