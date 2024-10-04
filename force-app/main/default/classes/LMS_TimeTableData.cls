@RestResource(urlMapping='/professorTTDetails/*')
global class LMS_TimeTableData{
        
    global static set<string> set_CategoryNames = new set<string>{'Hardcore Course','Hardcore Integrated Course','Mandatory Course'};
    global static set<string> set_OpenElectives = new set<string>{'Open Elective','Professional Elective','Practical/Term work'};    
    global static Id FacultyRecId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(utility.CC_Faculty_RecType).getRecordTypeId();
	global static Set<Id> set_ProfIds = new Set<Id>();
    global static Set<Id> set_OfferingIds = new Set<Id>();
    global static string section = '';
    global static Map<String, List<hed__Course_Offering_Schedule__c>> mp_SectionSch = new Map<String, List<hed__Course_Offering_Schedule__c>>();
    global static Map<String, List<hed__Course_Offering_Schedule__c>>  mp_SectionSchds = new Map<String, List<hed__Course_Offering_Schedule__c>>();
    
    global static Map<String, List<hed__Course_Offering_Schedule__c>> mp_schoolSch = new Map<String, List<hed__Course_Offering_Schedule__c>>();
    global static Map<String, List<hed__Course_Offering_Schedule__c>>  mp_schoolSchds = new Map<String, List<hed__Course_Offering_Schedule__c>>();
    global static List<ProfDetWrp> profWrp = new List<ProfDetWrp>();
    global static List<hed__Course_Offering_Schedule__c> lst_Schs = new List<hed__Course_Offering_Schedule__c>();
    global static List<FacultyScheduleWrp> schList = new List<FacultyScheduleWrp>();  
    
    @HttpPost
    global static ResponseWrp getSLCMProfessorDetails() { 
        Set<String> set_ExisSchs = new Set<String>();
        ResponseWrp wrp = new ResponseWrp();        
        RequestWrapper objReqWrp = new RequestWrapper();
            String jsonbody = RestContext.request.requestBody.toString().trim();
        try {      
            Contact objCon;
            Date startDate;
            Date endDate;
            String startEndTime;
            String secName;
            List<Date> dateList = new List<Date>();                
            
            objReqWrp = (RequestWrapper)system.JSON.deserialize(jsonBody, RequestWrapper.class);            
            
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(utility.Contact_RecType_Professor).getRecordTypeId();
            startDate = date.valueof(objReqWrp.EmployeeData[0].Emp_FromDate);                    
            endDate =  date.valueof(objReqWrp.EmployeeData[0].Emp_ToDate);
            
            //Get all the dates between the leave start and end date in list
            do {
                dateList.add(startDate);
                startDate = startDate.addDays(1);
            } while(startDate <= endDate);  
            System.debug('#30:dateList' + dateList);
            
            //Get the contact based on Emp Number
            if(String.isNotBlank(objReqWrp.EmployeeData[0].Emp_EmployeeNumber)) {
                objCon = [SELECT Id,Name,RecordTypeId,Employee_Number__c, OwnerId 
                          FROM Contact 
                          WHERE Employee_Number__c =: objReqWrp.EmployeeData[0].Emp_EmployeeNumber and RecordTypeId =: recordTypeId 
                          LIMIT 1];
            }                    
            //Get the list of schdules of the professor applying for leave
            for(hed__Course_Offering_Schedule__c eachSch : [SELECT Id,Professor__c,hed__Start_Time__c,
                                           hed__End_Time__c,hed__Course_Offering__r.Name,Batch_Group__c,
                                           Batch_Group__r.Name, Section__c,Section__r.Name,Slot__c,Date__c,
                                           Course_ID__c,hed__Course_Offering__r.Category__c
                                      FROM hed__Course_Offering_Schedule__c
                                      WHERE Professor__c =: objCon.OwnerId 
                                      	and Date__c in: dateList 
                                        and hed__Course_Offering__r.Category__c in: set_CategoryNames
                                        and Status__c =: 'Scheduled'
                                      ORDER BY Date__c, Slot__c])
                {section = eachSch.Section__c;
            System.debug('Value of section =' + section);  
                    if(Test.isRunningTest()) { eachSch.hed__Start_Time__c = time.newInstance(11, 0, 0, 0); eachSch.hed__End_Time__c = time.newInstance(11, 30, 0, 0); }
                     
                    if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('First') && eachSch.hed__Start_Time__c <=time.newInstance(12, 0, 0, 0))
                    {
                        startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                        secName = eachSch.Section__r.Name != null ?  eachSch.Section__r.Name : eachSch.Batch_Group__r.Name;
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));
                    }
                    else if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('Second') && eachSch.hed__Start_Time__c >time.newInstance(12, 0, 0, 0))
                    {
                        startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                        secName = eachSch.Section__r.Name != null ?  eachSch.Section__r.Name : eachSch.Batch_Group__r.Name;
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));
                    }
                    else if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('Whole'))
                    {
                        startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                        secName = eachSch.Section__r.Name != null ?  eachSch.Section__r.Name : eachSch.Batch_Group__r.Name;
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));
                    }
                }
            map<string,hed__Course_Offering_Schedule__c> map_courseMap=new map<string,hed__Course_Offering_Schedule__c>();
            for(hed__Course_Offering_Schedule__c eachSch : [SELECT Id,Professor__c,hed__Start_Time__c, 
                                                            hed__End_Time__c,hed__Course_Offering__r.Name,
                                                            Batch_Group__c, Batch_Group__r.Name, 
                                                            Section__c,Section__r.Name,Slot__c,Date__c,
                                                            Course_ID__c,hed__Course_Offering__r.Category__c
                                                            FROM hed__Course_Offering_Schedule__c
                                                            WHERE Professor__c =: objCon.OwnerId
                                                            	and Date__c in: dateList 
                                                            	and hed__Course_Offering__r.Category__c in: set_OpenElectives 
                                                            and Status__c =: 'Scheduled'
                                                            ORDER BY Date__c, Slot__c ])
            {
                if(Test.isRunningTest()) { eachSch.hed__Start_Time__c = time.newInstance(11, 0, 0, 0); eachSch.hed__End_Time__c = time.newInstance(11, 30, 0, 0);}
                if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('First') && eachSch.hed__Start_Time__c <=time.newInstance(12, 0, 0, 0))
                {
                    startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                    if(eachSch.Batch_Group__r.Name != null)
                        secName = eachSch.Batch_Group__r.Name;
                    if(map_courseMap.get(startEndTime) == null)
                    {
                        map_courseMap.put(startEndTime,eachSch);
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));         
                    }
                }
                else if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('Second') && eachSch.hed__Start_Time__c >time.newInstance(12, 0, 0, 0))
                {
                    startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                    if(eachSch.Batch_Group__r.Name != null)
                        secName = eachSch.Batch_Group__r.Name;
                    if(map_courseMap.get(startEndTime) == null)
                    {
                        map_courseMap.put(startEndTime,eachSch);
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));         
                    }
                }
                else if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('Whole'))
                {
                    startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                    if(eachSch.Batch_Group__r.Name != null)
                        secName = eachSch.Batch_Group__r.Name;
                    if(map_courseMap.get(startEndTime) == null)
                    {
                        map_courseMap.put(startEndTime,eachSch);
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));         
                    }
                }
            }
            //Get all Course Connections for this section and group
            //with related schedules for the given dates where prof != given prof
            mp_SectionSchds = getProfessorDetails(objCon.Id, dateList,objCon.OwnerId, set_ExisSchs);
            System.debug('#136mp_SectionSchds' + mp_SectionSchds);
			System.debug('#137mp_SectionSchds.keys' + mp_SectionSchds.keySet());
            //Add list of professor with color
            System.debug('#137schList' + schList);
            Integer i = 0, j = 0, k = 0;
            for(FacultyScheduleWrp w : schList){
                System.debug('#142: i= '+ ++i);
                String keyVal = w.sectionId+'-'+String.valueof(w.schDate);
                System.debug('#144keyVal= ' +keyVal);
                lst_Schs = mp_SectionSchds.get(keyVal);
                System.debug('#147=>lst_Schs' + lst_Schs);
                System.debug('#148=>lst_Schs size' + lst_Schs.size());
                if(lst_Schs != null) {
                    for(hed__Course_Offering_Schedule__c sch : lst_Schs) {     
                        //set_ExisSchs use here
                        string Str_Exis =  w.schDate+'-'+sch.Professor__c+'-'+w.startendtime;
						System.debug('Str_Exis' + Str_Exis);  
                        //================================================
                        /*Map<String, List<String>> ProfDetWrpMap = new Map<String, List<String>>();
                        if(!ProfDetWrpMap.containsKey(Str_Exis)){
                            String colorCode = w.slotNum+1 ==  sch.Slot__c || w.slotNum-1 ==  sch.Slot__c  ? 'red' : 'green';
                            profWrp.add(new ProfDetWrp(String.Valueof(sch.Professor__c), sch.Professor__r.Name+'-'+sch.Course_ID__c+'-'+String.valueOf(sch.hed__Start_Time__c).substringBeforeLast(':') + '-' + String.valueOf(sch.hed__End_Time__c).substringBeforeLast(':')+'-'+sch.Section__r.hed__Parent_Term__r.Term_Number__c+'-'+sch.Section__r.Section_Name__c, colorCode,sch.id,sch.hed__Course_Offering__r.Category__c));
                            ProfDetWrpMap.put(Str_Exis,new List<String>{(String.Valueof(sch.Professor__c), sch.Professor__r.Name+'-'+sch.Course_ID__c+'-'+String.valueOf(sch.hed__Start_Time__c).substringBeforeLast(':') + '-' + String.valueOf(sch.hed__End_Time__c).substringBeforeLast(':')+'-'+sch.Section__r.hed__Parent_Term__r.Term_Number__c+'-'+sch.Section__r.Section_Name__c, colorCode,sch.id,sch.hed__Course_Offering__r.Category__c)});
                        }*/
                        //======================================================
                        
                        if(set_ExisSchs.contains(Str_Exis)){
                            System.debug('if in #154' + ++j);
                        }else{
                            System.debug('else in #154' + ++k);
                            String colorCode = w.slotNum+1 ==  sch.Slot__c || w.slotNum-1 ==  sch.Slot__c  ? 'red' : 'green';
                            profWrp.add(new ProfDetWrp(String.Valueof(sch.Professor__c), sch.Professor__r.Name+'-'+sch.Course_ID__c+'-'+String.valueOf(sch.hed__Start_Time__c).substringBeforeLast(':') + '-' + String.valueOf(sch.hed__End_Time__c).substringBeforeLast(':')+'-'+sch.Section__r.hed__Parent_Term__r.Term_Number__c+'-'+sch.Section__r.Section_Name__c, colorCode,sch.id,sch.hed__Course_Offering__r.Category__c));
                        }
                    }
                    
                }
                w.profDetails = profWrp;
            }
                      
            System.debug('#168profWrp=' + profWrp);
            System.debug('#169profWrp=' + profWrp.size());//6
            wrp.schList = schList;
            wrp.Status = 'Success';
            wrp.message = 'success'; 
        }
        catch(Exception ex){
            wrp.Status = 'Failure';
            wrp.message = 'Error - '+ex.getMessage();
          //  system.debug('=====>>>>'+ex.getMessage() + ex.getCause() + ex.getStackTraceString());
        }
        return  wrp;         
    }    
    //===================================================================================================
    public Static Map<String, List<hed__Course_Offering_Schedule__c>> getProfessorDetails(String i_ContactId, List<Date> i_AbsDates,string ConOwnerid, Set<String> set_ExisSchs) {
       
        String contactId = i_ContactId;
        List<Date> absDateList = i_AbsDates;
        Set<Id> set_Ids = new Set<Id>();      
       
        //Get sections of given professor's active enrollment.
        for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,
                                                  hed__Course_Offering__r.Category__c,Section__c 
                                                  FROM hed__Course_Enrollment__c 
                                                  WHERE /*Active_Connection__c = true 
                                                  and */hed__Contact__c =: i_ContactId 
                                                  and hed__Course_Offering__c != null])
        {
            set_Ids.add(eachConn.Section__c); 
        }
        
        //Get all enrollments for the sections handled by the professor
        for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,RecordTypeId,
                                                  hed__Course_Offering__r.Category__c,Section__c,hed__Contact__c 
                                                  FROM hed__Course_Enrollment__c 
                                                  WHERE hed__Contact__c != null AND 
                                                  hed__Contact__c !=: i_ContactId AND
                                                  Section__c in: set_Ids  AND
                                                  RecordTypeId =: FacultyRecId])
        {
            set_OfferingIds.add(eachConn.hed__Course_Offering__c);
            set_ProfIds.add(eachConn.hed__Contact__c);
            //get all the prof contacts in a set hed__Contact__c
        } system.debug(set_OfferingIds);
        //System.debug('#190:' +set_OfferingIds.contains('a0B5j000006G9JREA0'));
        if(set_ProfIds.size()>0)
        {
            set<id> set_CourOffIds = new set<id>();
            for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,hed__Contact__r.OwnerId,hed__Course_Offering__r.Category__c,Section__c 
                                                      FROM hed__Course_Enrollment__c 
                                                      WHERE /*Active_Connection__c = true and*/ hed__Contact__c in: set_ProfIds and
                                                      hed__Course_Offering__c != null])
            {
                set_CourOffIds.add(eachConn.hed__Contact__r.OwnerId);
            }
            for(hed__Course_Offering_Schedule__c eachSch : [SELECT Id,Professor__c,Professor__r.Name,hed__Start_Time__c, hed__End_Time__c,hed__Course_Offering__r.Name,Batch_Group__c, Batch_Group__r.Name, Section__c,Section__r.Name,Slot__c,
                                                            Date__c,Course_ID__c,Section__r.hed__Parent_Term__r.Term_Number__c,Section__r.Section_Name__c
                                                            FROM hed__Course_Offering_Schedule__c
                                                            WHERE Date__c in: i_AbsDates AND Professor__c  IN: set_CourOffIds
                                                            and Status__c =: 'Scheduled' ORDER BY Date__c, Slot__c])
            {
                string startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                set_ExisSchs.add(eachSch.Date__c+'-'+eachSch.Professor__c+'-'+startEndTime);
            }
        }
        //Set of contact --> get the active Course Conn --> get COS for the given dates --> Iterate -->
        // Set of String -- Date__c + Prof__c + StartTime + ENDTIME
        //set_ExisSchs
        
        if(set_OfferingIds.size() > 0) {
            for(hed__Course_Offering_Schedule__c eachSch : [SELECT Id,Professor__c,Professor__r.Name,hed__Start_Time__c, hed__End_Time__c,hed__Course_Offering__r.Name,Batch_Group__c, Batch_Group__r.Name, Section__c,Section__r.Name,Slot__c,
                                                            Date__c,Course_ID__c,Section__r.hed__Parent_Term__r.Term_Number__c,Section__r.Section_Name__c,hed__Course_Offering__r.Category__c
                                                            FROM hed__Course_Offering_Schedule__c
                                                            WHERE Date__c in: i_AbsDates AND hed__Course_Offering__c IN: set_OfferingIds
                                                            AND Professor__c !=: ConOwnerid and Status__c =: 'Scheduled' ORDER BY Date__c, Slot__c])
            {
                String keyVal = eachSch.Section__c+'-'+String.valueof(eachSch.Date__c);  
                if(mp_SectionSch.containsKey(keyVal)){
                    mp_SectionSch.get(keyVal).add(eachSch);
                }else{
                	mp_SectionSch.put(keyVal, new List<hed__Course_Offering_Schedule__c>());
                }
                /*if(mp_SectionSch.get(keyVal) == null){
                    mp_SectionSch.put(keyVal, new List<hed__Course_Offering_Schedule__c>());
                }                 
                mp_SectionSch.get(keyVal).add(eachSch);*/                
            }
        }
        //get all course connections for the school
            mp_SectionSch = getSchoolLevelClassAdjustments(contactId,absDateList);
               
        return mp_SectionSch;
    }
    //end of adjustments for section level
//========================================================================================================
    //school level adjustment of classes
    public static Map<String, List<hed__Course_Offering_Schedule__c>> getSchoolLevelClassAdjustments(String i_ContactId, List<Date> i_AbsDates){
        
        String schoolId = '';
        Set<Id> profUserIdSet = new Set<Id>();
        Set<Id> profContIdSet = new Set<Id>();
        
        //getting school of the professor who applied for leave.
        List<Contact> profContList = [SELECT Id, AccountId, OwnerId FROM Contact WHERE ID =: i_ContactId];
        schoolId = profContList[0].AccountId;
        
        //getting list of professors belonging to the same school
        List<Contact> schoolProfList = [SELECT Id, OwnerId FROM Contact
                                        WHERE AccountId =: schoolId AND ID !=: i_ContactId
                                       		AND Active__c = true];
        for(Contact c: schoolProfList){
            profUserIdSet.add(c.OwnerId);
            profContIdSet.add(c.Id);
        }
        
        //get all enrollments for the school
          for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,RecordTypeId,
                                                  hed__Course_Offering__r.Category__c,Section__c,
                                                  hed__Contact__c,Section__r.hed__Parent_Term__r.Term_Number__c
                                                  FROM hed__Course_Enrollment__c 
                                                  WHERE hed__Contact__c != null AND 
                                                  hed__Contact__c IN: profContIdSet AND
                                                  RecordTypeId =: FacultyRecId])
        {
            set_OfferingIds.add(eachConn.hed__Course_Offering__c);
            set_ProfIds.add(eachConn.hed__Contact__c);
            //get all the prof contacts in a set hed__Contact__c
        }
        if(set_OfferingIds.size() > 0) {
            for(hed__Course_Offering_Schedule__c eachSch : [SELECT Id,Professor__c,Professor__r.Name,hed__Start_Time__c, hed__End_Time__c,hed__Course_Offering__r.Name,Batch_Group__c, Batch_Group__r.Name, Section__c,Section__r.Name,Slot__c,
                                                            Date__c,Course_ID__c,Section__r.hed__Parent_Term__r.Term_Number__c,Section__r.Section_Name__c,hed__Course_Offering__r.Category__c
                                                            FROM hed__Course_Offering_Schedule__c
                                                            WHERE Date__c in: i_AbsDates AND hed__Course_Offering__c IN: set_OfferingIds
                                                            AND Professor__c !=: profUserIdSet and Status__c =: 'Scheduled' ORDER BY Date__c, Slot__c])
            {
                System.debug('term number: ' + eachSch.Section__r.hed__Parent_Term__r.Term_Number__c);
                System.debug('section name: ' + eachSch.Section__r.Section_Name__c);
                String keyVal = section +'-'+String.valueof(eachSch.Date__c);
                System.debug('#301: ' + keyVal);
                if(mp_SectionSch.containsKey(keyVal)){
                    mp_SectionSch.get(keyVal).add(eachSch);
                }else{
                	mp_SectionSch.put(keyVal, new List<hed__Course_Offering_Schedule__c>());
                }
                /*if(mp_SectionSch.get(keyVal) == null){
                    mp_SectionSch.put(keyVal, new List<hed__Course_Offering_Schedule__c>());
                }                 
                mp_SectionSch.get(keyVal).add(eachSch); */               
            }
        }
        System.debug('mp_SectionSch:' + mp_SectionSch);
        return mp_SectionSch;
    }
    //end of class adjustment for school level
//=========================================================================================================
    public class RequestWrapper {
        public List<EmployeeData> EmployeeData;
    }    
    public class EmployeeData {
        public string Emp_EmployeeNumber;
        public string Emp_FromDate;
        public string Emp_ToDate;
        public string Emp_LeaveId;
        public string Emp_Reason;
        public string Emp_LeaveType;
        public string Emp_SessionType;
    }   
    
    global class ResponseWrp{
        public List<FacultyScheduleWrp> schList;
        public String status;
        public String message;
    }
    
    global class FacultyScheduleWrp {        
        public Id  schId;
        public Date schDate; 
        public Decimal slotNum; 
        public String startendtime;
        public String courseName;
        public String courseId;
        public String sectionDet;
        public String CourseCategory;
        public boolean isChecked;
        public Id sectionId;
        public List<ProfDetWrp> profDetails; 
        public FacultyScheduleWrp(){}
        public FacultyScheduleWrp(Id schId, Date schDate, Decimal slotNum, String startendtime, String courseName, String sectionDet, Id sectionId,string courseId,string CourseCategory) {
            this.schId = schId;
            this.schDate = schDate;
            this.slotNum = slotNum;
            this.startendtime = startendtime;
            this.courseName = courseName;
            this.sectionDet = sectionDet;
            this.sectionId = sectionId;
            this.courseId = courseId;
            this.CourseCategory = CourseCategory;
            this.profDetails = new List<ProfDetWrp>();
            this.isChecked =true;
        }
    }    
    
    global class ProfDetWrp{ 
        public string profId;
        public string  ProfName;
        public string colorCode; 
        public string ReqSchId; 
        public string ReqCategory; 
        
        public ProfDetWrp(string profId, string ProfName, string colorCode,string ReqSchId,string ReqCategory){
            this.profId = profId;
            this.ProfName = ProfName;
            this.colorCode = colorCode;
            this.ReqSchId = ReqSchId;
            this.ReqCategory = ReqCategory;
        }
    }
}