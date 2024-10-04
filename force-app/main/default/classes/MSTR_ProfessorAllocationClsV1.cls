Public class MSTR_ProfessorAllocationClsV1{

@AuraEnabled
public static hed__Term__c getTermDetails(string termId){
    hed__Term__c objTerm = [SELECT id,Name,Program_Batch__r.Name,No_Of_Sections__c FROM hed__Term__c WHERE id =: termId];    
    return objTerm;
}

@AuraEnabled
public static mainCourseWrap getProgramPlan(string termId){
    mainCourseWrap mainWrp = new mainCourseWrap();
    mainWrp.lstSection = new list<string>();
    list<string> termIds = new list<string>();
    string sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
    string facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
    
    system.debug('++++++++++'+termId);
    system.debug('++++++++++'+sectionRtId);
    hed__Term__c objTerm = [SELECT id,Program_Batch__c FROM hed__Term__c WHERE id =: termId];
    
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                            AND recordTypeId =: sectionRtId ORDER By Section_Number__c ASC]){
        mainWrp.lstSection.add('Section '+trm.Section_Name__c);
        termIds.add(trm.id);
    }
    system.debug('++++++++++'+mainWrp);
    
    map<string,boolean> mapCourseOff = new map<string,boolean>();
    
    for(hed__Course_Offering__c co : [SELECT id,Name,hed__Course__c,Faculty_Course_Connection_Created__c 
                                     FROM hed__Course_Offering__c WHERE hed__Term__c =: termId]){
        mapCourseOff.put(co.hed__Course__c,co.Faculty_Course_Connection_Created__c);                                 
    }                                 
    
    map<string,list<hed__Course_Enrollment__c>> mapProfessors = new map<string,list<hed__Course_Enrollment__c>>();
    
    for(hed__Course_Offering__c co : [SELECT id,Name,Category__c,hed__Course__c,hed__Term__c,Parent_Course_Offering__c,hed__Term__r.Section_Name__c,
                                     Faculty_Course_Connection_Created__c,(SELECT id FROM hed__Course_Enrollment__r WHERE recordTypeId =: facultyRtId) 
                                     FROM hed__Course_Offering__c WHERE hed__Term__c =: termIds]){
                                     
        if(co.Category__c == 'Hardcore Course' || co.Category__c == 'Practical/Term Work' || 
                              co.Category__c == 'Hardcore Integrated Course' || co.Category__c == 'Mandatory Course'){   
                              
            if(co.hed__Course_Enrollment__r.size() > 0){                  
                string coName = co.hed__Course__c+'-'+co.hed__Term__r.Section_Name__c;
                list<hed__Course_Enrollment__c> temp = co.hed__Course_Enrollment__r;
                if(!mapProfessors.containsKey(coName)){
                    
                    mapProfessors.put(coName,temp);
                }
                else{
                    mapProfessors.get(coName).addAll(temp);
                }
            }
                                           
        }  
        
        if( // (co.Category__c == 'Open Elective' && string.isNotBlank(co.Parent_Course_Offering__c)) || 
                       (co.Category__c == 'Professional Elective' && string.isNotBlank(co.Parent_Course_Offering__c))){
        
            if(co.hed__Course_Enrollment__r.size() > 0){                  
                string coName = co.hed__Course__c+'-'+co.hed__Term__r.Section_Name__c;
                list<hed__Course_Enrollment__c> temp = co.hed__Course_Enrollment__r;
                if(!mapProfessors.containsKey(coName)){
                    
                    mapProfessors.put(coName,temp);
                }
                else{
                    mapProfessors.get(coName).addAll(temp);
                }
            }                   
        }                                 
    }
    system.debug('++++++++++'+mapProfessors);
    map<string,courseWrap> mapHardCore = new map<string,courseWrap>();
    map<string,courseWrap> mapHcIntegrated = new map<string,courseWrap>();
    map<string,courseWrap> mapPractical = new map<string,courseWrap>();
    map<string,courseWrap> mapMandatory = new map<string,courseWrap>();
    map<string,parentWrap> mapOpenElective = new map<string,parentWrap>();
    map<string,parentWrap> mapProfElective = new map<string,parentWrap>();
    
    for(hed__Term__c allTerm : [SELECT id,Name,Section_Name__c,(SELECT id,Category__c,hed__Course__c,Credits__c,Min_Professors_Per_Course__c,
                               Sequence__c,hed__Course__r.Name,hed__Term__c,Parent_Course_Offering__c,Parent_Course_Offering__r.Sequence__c,
                               Parent_Course_Offering__r.hed__Course__c,Parent_Course_Offering__r.hed__Course__r.Name,hed__Term__r.Section_Name__c,  
                               Parent_Course_Offering__r.Name,Faculty_Course_Connection_Created__c FROM hed__Course_Offerings__r ORDER By Sequence__c ASC) FROM hed__Term__c 
                               WHERE id =: termIds ORDER By Section_Number__c ASC]){  
     system.debug('+++++++++'+allTerm);                            
        for(hed__Course_Offering__c co : allTerm.hed__Course_Offerings__r){
            if(co.Category__c == 'Hardcore Course'){
                if(mapHardCore.containsKey(co.hed__Course__c)){
                    mapHardCore.get(co.hed__Course__c).lstSection.add(mapCourseSection(co,mapProfessors));
                }
                else{
                    courseWrap course = new courseWrap();
                    course = mapCourses(co);
                    course.isConfirmed = mapCourseOff.get(co.hed__Course__c);
                    course.lstSection.add(mapCourseSection(co,mapProfessors));
                    mapHardCore.put(co.hed__Course__c,course);                    
                }    
            } 
            if(co.Category__c == 'Practical/Term Work'){
                if(mapPractical.containsKey(co.hed__Course__c)){
                    mapPractical.get(co.hed__Course__c).lstSection.add(mapCourseSection(co,mapProfessors));
                }
                else{
                    courseWrap course = new courseWrap();
                    course = mapCourses(co);
                    course.isConfirmed = mapCourseOff.get(co.hed__Course__c);
                    course.lstSection.add(mapCourseSection(co,mapProfessors));
                    mapPractical.put(co.hed__Course__c,course);
                }
            }
            if(co.Category__c == 'Hardcore Integrated Course'){
                if(mapHcIntegrated.containsKey(co.hed__Course__c)){
                    mapHcIntegrated.get(co.hed__Course__c).lstSection.add(mapCourseSection(co,mapProfessors));
                }
                else{
                    courseWrap course = new courseWrap();
                    course = mapCourses(co);
                    course.isConfirmed = mapCourseOff.get(co.hed__Course__c);
                    course.lstSection.add(mapCourseSection(co,mapProfessors));
                    mapHcIntegrated.put(co.hed__Course__c,course);
                }
            }
            if(co.Category__c == 'Mandatory Course'){ 
                if(mapMandatory.containsKey(co.hed__Course__c)){
                    mapMandatory.get(co.hed__Course__c).lstSection.add(mapCourseSection(co,mapProfessors));
                }
                else{
                    courseWrap course = new courseWrap();
                    course = mapCourses(co);
                    course.isConfirmed = mapCourseOff.get(co.hed__Course__c);
                    course.lstSection.add(mapCourseSection(co,mapProfessors));
                    mapMandatory.put(co.hed__Course__c,course);
                }
            }
          /*  if(co.Category__c == 'Open Elective' && string.isNotBlank(co.Parent_Course_Offering__c)){
                if(mapOpenElective.containsKey(co.Parent_Course_Offering__r.Name)){
                    boolean isCourseMatch = false;
                    boolean isSectionMatch = false;
                    for(courseWrap cwrp : mapOpenElective.get(co.Parent_Course_Offering__r.Name).lstCourse){
                        if(cwrp.courseId == co.hed__Course__c){
                            isCourseMatch = true;
                            for(courseSectionWrap sWrp : cwrp.lstSection){
                                if(sWrp.recordId == co.id){
                                    isSectionMatch = true;
                                }
                            }
                        }
                    }
                    
                    if(!isCourseMatch){
                        mapOpenElective.get(co.Parent_Course_Offering__r.Name).lstCourse.add(mapCourses(co));
                    }
                    
                    if(!isSectionMatch){
                        for(courseWrap cwrp : mapOpenElective.get(co.Parent_Course_Offering__r.Name).lstCourse){
                            if(cwrp.courseId == co.hed__Course__c){
                                cwrp.lstSection.add(mapCourseSection(co,mapProfessors));
                            }
                        }
                    }
                }
                else{
                    parentWrap prtWrp = new parentWrap();
                    prtWrp = mapParantCourses(co);
                    prtWrp.lstCourse.add(mapCourses(co));
                    for(courseWrap cwrp : prtWrp.lstCourse){
                        cwrp.lstSection.add(mapCourseSection(co,mapProfessors));
                    }
                    mapOpenElective.put(co.Parent_Course_Offering__r.Name,prtWrp);
                }
            } */
            if(co.Category__c == 'Professional Elective' && string.isNotBlank(co.Parent_Course_Offering__c)){
                if(mapProfElective.containsKey(co.Parent_Course_Offering__r.Name)){
                    boolean isCourseMatch = false;
                    boolean isSectionMatch = false;
                    for(courseWrap cwrp : mapProfElective.get(co.Parent_Course_Offering__r.Name).lstCourse){
                      //  cwrp.isConfirmed = mapCourseOff.get(co.hed__Course__c);
                        if(cwrp.courseId == co.hed__Course__c){
                            isCourseMatch = true;
                            for(courseSectionWrap sWrp : cwrp.lstSection){
                                if(sWrp.recordId == co.id){
                                    isSectionMatch = true;
                                }
                            }
                        }
                    }
                    
                    if(!isCourseMatch){
                        mapProfElective.get(co.Parent_Course_Offering__r.Name).lstCourse.add(mapCourses(co));
                    }
                    
                    if(!isSectionMatch){
                        for(courseWrap cwrp : mapProfElective.get(co.Parent_Course_Offering__r.Name).lstCourse){
                            if(cwrp.courseId == co.hed__Course__c){
                                cwrp.isConfirmed = mapCourseOff.get(co.hed__Course__c);
                                cwrp.lstSection.add(mapCourseSection(co,mapProfessors));
                            }
                        }
                    }
                }
                else{
                    parentWrap prtWrp = new parentWrap();
                    prtWrp = mapParantCourses(co);                    
                    prtWrp.lstCourse.add(mapCourses(co));
                    for(courseWrap cwrp : prtWrp.lstCourse){
                        cwrp.isConfirmed = mapCourseOff.get(co.hed__Course__c);
                        cwrp.lstSection.add(mapCourseSection(co,mapProfessors));
                    }
                    mapProfElective.put(co.Parent_Course_Offering__r.Name,prtWrp);
                }
            }   
        }                             
    }
    mainWrp.listHardCore = mapHardCore.values();
    mainWrp.listHcIntegrated = mapHcIntegrated.values();
    mainWrp.listPractical = mapPractical.values();
    mainWrp.listMandatory = mapMandatory.values();
    mainWrp.listOpenElective = mapOpenElective.values();
    mainWrp.listProfElective = mapProfElective.values();
    system.debug('++++++++++'+mainWrp);
    return mainWrp;
}

@AuraEnabled
public static parentWrap mapParantCourses(hed__Course_Offering__c courseOffer){
    parentWrap courses = new parentWrap();
    courses.count = string.valueof(courseOffer.Sequence__c);
    courses.recordId = courseOffer.id;
    courses.courseName = courseOffer.Parent_Course_Offering__r.Name; // courseOffer.hed__Course__r.Name;
    courses.courseId = courseOffer.hed__Course__c;   
    courses.isConfirmed = courseOffer.Faculty_Course_Connection_Created__c; 
    return courses;
}

@AuraEnabled
public static courseWrap mapCourses(hed__Course_Offering__c courseOffer){
    courseWrap courses = new courseWrap();
    courses.count = string.valueof(courseOffer.Sequence__c);
    courses.courseName = courseOffer.hed__Course__r.Name;
    courses.courseId = courseOffer.hed__Course__c;
  //  courses.isConfirmed = courseOffer.Faculty_Course_Connection_Created__c;    
    return courses;
}

@AuraEnabled
public static courseSectionWrap mapCourseSection(hed__Course_Offering__c courseOffer,map<string,list<hed__Course_Enrollment__c>> mapProfessors){
    courseSectionWrap courses = new courseSectionWrap();
    courses.count = string.valueof(courseOffer.Sequence__c);
    courses.recordId = courseOffer.id;
    courses.courseName = courseOffer.hed__Course__r.Name;
    courses.courseId = courseOffer.hed__Course__c;
    courses.sectionName = courseOffer.hed__Term__r.Section_Name__c;
    courses.termId = courseOffer.hed__Term__c;
    courses.minCource = courseOffer.Min_Professors_Per_Course__c;
    string coName = courseOffer.hed__Course__c+'-'+courseOffer.hed__Term__r.Section_Name__c;
    system.debug('+++++++'+coName);
    system.debug('+++++++'+mapProfessors.containsKey(coName));
    system.debug('+++++++'+courseOffer.Min_Professors_Per_Course__c);    
    if(mapProfessors.containsKey(coName) && courseOffer.Min_Professors_Per_Course__c != Null){
        system.debug('******'+mapProfessors.get(coName).size());
        if(courseOffer.Min_Professors_Per_Course__c <= mapProfessors.get(coName).size()){
            courses.professorAssiened = true;
        }
    }
    return courses;
}

@AuraEnabled
public static list<PreferencesMainWrap> getPreferencesDetails(string termId,string courseId,string Category){
    map<string,PreferencesMainWrap> mapProf = new map<string,PreferencesMainWrap>();
    list<string> termIds = new list<string>();    
    string sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
    string facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
    set<string> profIds = new set<string>();
        
    hed__Term__c objTerm = [SELECT id,Program_Batch__c FROM hed__Term__c WHERE id =: termId];
    
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                            AND recordTypeId =: sectionRtId ORDER By Section_Number__c ASC]){
        termIds.add(trm.id);
    }
    
    string batchId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Batch_Short_Name__c,Batch_Number__c,hed__Parent_Term__r.Section_Name__c FROM hed__Term__c WHERE  
                            recordTypeId =: batchId AND hed__Parent_Term__c =: termIds]){
         termIds.add(trm.id);                   
    }
    
    for(Professor_Student_Course_Preference__c prof : [SELECT id,Preference__c,Professor__c,Professor__r.Name,Professor__r.Designation__c,Course_Offering__c,
                                                      Course_Offering__r.Parent_Course_Offering__c,Course_Offering__r.Min_Professors_Per_Course__c FROM Professor_Student_Course_Preference__c 
                                                      WHERE Semester__c =: termId AND Course_Offering__r.hed__Course__c =: courseId 
                                                      AND Course_Offering__r.Category__c =: Category AND Professor__c != Null]){
                                                      
        if(mapProf.containsKey(prof.Preference__c)){
            PreferencesProfessorWrap courseWrp = new PreferencesProfessorWrap();
            courseWrp = mapProfessor(prof);
            mapProf.get(prof.Preference__c).lstPreferences.add(courseWrp);
        }
        else{
            PreferencesMainWrap mainWrp = new PreferencesMainWrap();
            mainWrp.Preferences = 'Preference - ' + prof.Preference__c;
            PreferencesProfessorWrap courseWrp = new PreferencesProfessorWrap();
            courseWrp = mapProfessor(prof);
            mainWrp.lstPreferences.add(courseWrp);
            mapProf.put(prof.Preference__c,mainWrp);
        }  
        
        profIds.add(prof.Professor__c); 
        
    }
    
    system.debug('++++++++'+profIds);
    system.debug('++++++++'+termIds);
    system.debug('++++++++'+courseId);
    system.debug('++++++++'+facultyRtId);
    map<string,integer> mapProfSec = new map<string,integer>();
    map<string,integer> mapProfSecTerm = new map<string,integer>();
    
    for(hed__Course_Enrollment__c cc : [SELECT id,hed__Course_Offering__c,Section__c,hed__Contact__c,hed__Contact__r.Name,hed__Course_Offering__r.hed__Course__c,
                                        Section__r.Section_Name__c,Unique_Key__c,Order_Count__c 
                                        FROM hed__Course_Enrollment__c WHERE Section__c =: termIds AND hed__Contact__c =: profIds AND
                                        RecordTypeId =: facultyRtId ORDER By Section__r.Section_Number__c]){
                                        
        if(cc.hed__Course_Offering__r.hed__Course__c == courseId){
            if(mapProfSec.containsKey(cc.hed__Contact__c)){
                integer temp = mapProfSec.get(cc.hed__Contact__c) + 1;
                mapProfSec.put(cc.hed__Contact__c,temp);
            }
            else{
                mapProfSec.put(cc.hed__Contact__c,1);
            }    
        }
        
        if(mapProfSecTerm.containsKey(cc.hed__Contact__c)){
            integer temp = mapProfSecTerm.get(cc.hed__Contact__c) + 1;
            mapProfSecTerm.put(cc.hed__Contact__c,temp);
        }
        else{
            mapProfSecTerm.put(cc.hed__Contact__c,1);
        }
    }                                    
    
    system.debug('++++++++'+mapProfSecTerm);
    
    for(PreferencesMainWrap prof : mapProf.values()){
        if(prof.lstPreferences.size() > 0){
            prof.recordCount = prof.lstPreferences.size() + 1;
        }
        else{
            prof.recordCount = 1;    
        }
        
        for(PreferencesProfessorWrap pp : prof.lstPreferences){
            if(mapProfSec.containsKey(pp.ProfessorId)){
                pp.sectionAssigned = mapProfSec.get(pp.ProfessorId);
            }
            else{
                pp.sectionAssigned = 0;
            }
            
            if(mapProfSecTerm.containsKey(pp.ProfessorId)){
                pp.totalSections = mapProfSecTerm.get(pp.ProfessorId);
                pp.totalCount = mapProfSecTerm.get(pp.ProfessorId);
            }
            else{
                pp.totalSections = 0;
                pp.totalCount = 0;
            }
        }
    }
    system.debug('+++++++++'+mapProf.values());
    return mapProf.values();
}

@AuraEnabled
public static PreferencesProfessorWrap mapProfessor(Professor_Student_Course_Preference__c prof){
    PreferencesProfessorWrap objprof = new PreferencesProfessorWrap();
    objprof.Professor = prof.Professor__r.Name;
    objprof.Designation = prof.Professor__r.Designation__c;
    objprof.ProfessorId = prof.Professor__c;
    return objprof;
}

@AuraEnabled
public static list<ProfessorMainWrap> getprofessorDetails(string termId,string courseId,string Category){
    map<string,ProfessorMainWrap> mapProf = new map<string,ProfessorMainWrap>();
    list<string> termIds = new list<string>();
    string sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
    string facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
    string contactRtId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
    
    hed__Term__c objTerm = [SELECT id,Program_Batch__c,Program_Batch__r.hed__Account__r.ParentId FROM hed__Term__c WHERE id =: termId];
    
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                            AND recordTypeId =: sectionRtId ORDER By Section_Number__c ASC]){
        termIds.add(trm.id);
    }
    
    string batchId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Batch_Short_Name__c,Batch_Number__c,hed__Parent_Term__r.Section_Name__c FROM hed__Term__c WHERE  
                            recordTypeId =: batchId AND hed__Parent_Term__c =: termIds]){
         termIds.add(trm.id);                   
    }
        
    hed__Course_Offering__c course = [SELECT id,Min_Professors_Per_Course__c,Max_Professors_Per_Course__c,hed__Course__c,hed__Capacity__c,Quality_Circle_Head_Contact__c 
                                      FROM hed__Course_Offering__c WHERE hed__Term__c =: termId AND hed__Course__c =: courseId
                                      AND Category__c =: Category LIMIT 1];
    
    map<string,list<hed__Course_Enrollment__c>> mapcourseConnection = new map<string,list<hed__Course_Enrollment__c>>();
    
    for(hed__Course_Enrollment__c cc : [SELECT id,hed__Course_Offering__c,Section__c,hed__Contact__c,hed__Contact__r.Name,hed__Course_Offering__r.hed__Course__c,
                                        Section__r.Section_Name__c,Unique_Key__c,Order_Count__c 
                                        FROM hed__Course_Enrollment__c WHERE Section__c =: termIds AND hed__Course_Offering__r.hed__Course__c =: courseId AND 
                                        hed__Course_Offering__r.Category__c =: Category AND RecordTypeId =: facultyRtId ORDER By Section__r.Section_Number__c]){
        
        string ukey = cc.hed__Course_Offering__r.hed__Course__c+'-'+cc.Section__r.Section_Name__c+'-'+cc.Order_Count__c;
        if(mapcourseConnection.containsKey(ukey)){
            mapcourseConnection.get(ukey).add(cc);
        }
        else{
            mapcourseConnection.put(ukey,new list<hed__Course_Enrollment__c>{cc});
        }        
    }
    
    system.debug('mapcourseConnection++++++'+mapcourseConnection);
    system.debug('Max_Professors_Per_Course__c++++++++++'+course.Max_Professors_Per_Course__c);
    map<id,list<Professor_Student_Course_Preference__c>> mapPreference = new map<id,list<Professor_Student_Course_Preference__c>>();   
    map<string,string> pref1 = new map<string,string>();
    map<string,string> pref2 = new map<string,string>();
    integer prefMaxCount = 0;
    
    for(Professor_Student_Course_Preference__c prf : [SELECT id,Preference__c,Preference_No__c,Professor__c,Professor__r.Name,Semester__c,
                                             Professor__r.Designation__c,Unique_Key__c,Course_Offering__r.hed__Course__c FROM Professor_Student_Course_Preference__c 
                                             WHERE Semester__c=: termId AND Course_Offering__r.hed__Course__c =: courseId AND Course_Offering__r.Category__c =: Category 
                                             ORDER By Semester__r.Section_Number__c]){
    
        if(mapPreference.containsKey(prf.Course_Offering__r.hed__Course__c)){
            mapPreference.get(prf.Course_Offering__r.hed__Course__c).add(prf);
        }
        else{
            mapPreference.put(prf.Course_Offering__r.hed__Course__c,new list<Professor_Student_Course_Preference__c>{prf});
        }
        
        if(prefMaxCount < integer.valueof(prf.Preference__c)){
            prefMaxCount = integer.valueof(prf.Preference__c);
        }
        
    //    if(prf.Preference__c == '1'){
            pref1.put(prf.Professor__c,prf.Professor__r.Name);
    //    }
    //    else{
            pref2.put(prf.Professor__c,prf.Professor__r.Name);
     //   }
    }
    
    if(prefMaxCount < (termIds.size() / 2)){
        
     //   pref1 = new map<string,string>();
     //   pref2 = new map<string,string>();
        
        for(contact con : [SELECT id,Name FROM Contact WHERE recordTypeId =: contactRtId AND AccountId =: objTerm.Program_Batch__r.hed__Account__r.ParentId]){
            pref1.put(con.id,con.Name);
            pref2.put(con.id,con.Name);
        }
        
    }
    system.debug('prefMaxCount+++++'+prefMaxCount);
    for(hed__Course_Offering__c objCourse : [SELECT id,Min_Professors_Per_Course__c,Parent_Course_Offering__c,hed__Term__c,hed__Term__r.Section_Name__c,
                                             hed__Term__r.Section_Number__c,hed__Course__c FROM hed__Course_Offering__c WHERE hed__Term__c =: termIds 
                                             AND hed__Course__c =: courseId AND Category__c =: Category ORDER By hed__Term__r.Section_Number__c]){
     //   for(Professor_Student_Course_Preference__c prof : mapPreference.get(objCourse.hed__Course__c)){
             
            for(integer i = 1; i <= course.Max_Professors_Per_Course__c; i++){
                string ukey = objCourse.hed__Course__c+'-'+objCourse.hed__Term__r.Section_Name__c+'-'+string.valueof(i);
                system.debug('ukey+++++++++'+ukey);
                if(mapcourseConnection.containsKey(ukey)){ 
                    for(hed__Course_Enrollment__c cc : mapcourseConnection.get(ukey)){
                       // if(cc.hed__Contact__c ==  prof.Professor__c){
                            if(!mapProf.containsKey(string.valueof(i))){
                                ProfessorMainWrap profWrp = new ProfessorMainWrap();
                                profWrp.Preferences = 'Professor - ' + string.valueof(i);
                                profWrp.PreferenceCount = decimal.valueof(cc.Order_Count__c);
                                profWrp.orderCount = cc.Order_Count__c;
                                if(string.isNotBlank(course.Quality_Circle_Head_Contact__c)){
                                    profWrp.primaryFaculty = course.Quality_Circle_Head_Contact__c;
                                }
                                if(i == 1){
                                    profWrp.mapProfessor = pref1;    
                                }
                                else{
                                    profWrp.mapProfessor = pref2;
                                }
                                mapProf.put(string.valueof(i),profWrp);
                            }            
                            ProfessorWrap pw = new ProfessorWrap();
                            pw.professor = cc.hed__Contact__r.Name;
                            pw.professorId = cc.hed__Contact__c;
                          //  pw.Preference = cc.Preference__c;
                            pw.isCreated = true;
                            pw.section = cc.Section__r.Section_Name__c;
                            pw.connectionId = cc.id;
                            pw.courseOfferingId = cc.hed__Course_Offering__c;
                            pw.uniqueKey = cc.Unique_Key__c;
                            pw.termId = objCourse.hed__Term__c;
                            mapProf.get(string.valueof(i)).lstPreferences.add(pw);
                     //   }
                    }
                }
                else{
                    if(mapProf.containsKey(string.valueof(i))){
                        ProfessorWrap pw = new ProfessorWrap();
                      //  pw.professor = prof.Professor__r.Name;
                        pw.professorId = '';
                      //  pw.Preference = prof.Preference__c;
                      //  pw.recordId = prof.id;
                        pw.isCreated = false;
                        pw.section = objCourse.hed__Term__r.Section_Name__c;
                        pw.courseOfferingId = objCourse.id;
                        pw.uniqueKey = ukey;
                        pw.termId = objCourse.hed__Term__c;
                        mapProf.get(string.valueof(i)).lstPreferences.add(pw);
                        if(i == 1){
                            mapProf.get(string.valueof(i)).mapProfessor = pref1;
                        }
                        else{
                            mapProf.get(string.valueof(i)).mapProfessor = pref2;
                        }
                    }
                    else{
                        ProfessorMainWrap profWrp = new ProfessorMainWrap();
                        profWrp.Preferences = 'Professor - ' + string.valueof(i);
                        profWrp.PreferenceCount = i;
                        profWrp.orderCount = string.valueof(i);
                        if(string.isNotBlank(course.Quality_Circle_Head_Contact__c)){
                            profWrp.primaryFaculty = course.Quality_Circle_Head_Contact__c;
                        }
                        if(i == 1){
                            profWrp.mapProfessor = pref1;
                        }
                        else{
                            profWrp.mapProfessor = pref2;
                        }              
                        ProfessorWrap pw = new ProfessorWrap();
                     //   pw.professor = prof.Professor__r.Name;
                        pw.professorId = '';
                     //   pw.Preference = prof.Preference__c;
                     //   pw.recordId = prof.id;
                        pw.isCreated = false;
                        pw.section = objCourse.hed__Term__r.Section_Name__c;
                        pw.courseOfferingId = objCourse.id;
                        pw.uniqueKey = ukey;
                        pw.termId = objCourse.hed__Term__c;
                        profWrp.lstPreferences.add(pw);                    
                        mapProf.put(string.valueof(i),profWrp);
                    } 
                }
           // }
        }        
    }
    system.debug('+++++++++'+mapProf.values());
    return mapProf.values();
}

@AuraEnabled
public static mainCourseWrap saveProfessorDetails(string termId,string courseId,string primaryProfessor,list<ProfessorMainWrap> allCourses,boolean isConfirmrd){

    list<hed__Course_Enrollment__c> lstCourseConnect = new list<hed__Course_Enrollment__c>();
    string ccRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
    system.debug('courseId+++++++++++'+courseId);
    system.debug('isConfirmrd+++++++++++'+isConfirmrd);
    hed__Course_Offering__c course = [SELECT id,Min_Professors_Per_Course__c,Max_Professors_Per_Course__c,hed__Course__c,hed__Capacity__c,Quality_Circle_Head_Contact__c,Quality_Circle_Head__c, 
                                      Faculty_Course_Connection_Created__c FROM hed__Course_Offering__c WHERE hed__Term__c =: termId AND hed__Course__c =: courseId LIMIT 1];
    if(string.isNotBlank(primaryProfessor)){                                  
        course.Quality_Circle_Head_Contact__c =  primaryProfessor;
        contact objCon = [SELECT id,ownerId FROM contact WHERE id =: primaryProfessor];
        course.Quality_Circle_Head__c = objCon.ownerId;
    }
    else{
        course.Quality_Circle_Head_Contact__c = Null;
        course.Quality_Circle_Head__c =  Null;
    }
    course.Faculty_Course_Connection_Created__c = isConfirmrd;
    update course;                                
    
    for(ProfessorMainWrap mcourse : allCourses){
        for(ProfessorWrap pp : mcourse.lstPreferences){
            if(pp.isCreated){
                hed__Course_Enrollment__c cc = new hed__Course_Enrollment__c();
                cc.recordTypeId = ccRtId;
                cc.hed__Contact__c = pp.professorId;
                cc.hed__Course_Offering__c = pp.courseOfferingId;
            //    cc.Preference__c = pp.Preference;
                cc.id = pp.connectionId;
          //      cc.Professor_Student_Course_preference_Id__c = pp.recordId;
                cc.Order_Count__c = mcourse.orderCount;
                cc.Section__c = pp.termId;
                lstCourseConnect.add(cc);
            }
            else{
                if(string.isNotBlank(pp.professorId)){
                    hed__Course_Enrollment__c cc = new hed__Course_Enrollment__c();
                    cc.recordTypeId = ccRtId;
                    cc.hed__Contact__c = pp.professorId;
                    cc.hed__Course_Offering__c = pp.courseOfferingId;
               //     cc.Preference__c = pp.Preference;
                   // cc.id = pp.connectionId;
                  //  cc.Professor_Student_Course_preference_Id__c = pp.recordId;
                    cc.Order_Count__c = mcourse.orderCount;
                    cc.Section__c = pp.termId;
                    lstCourseConnect.add(cc);
                }
            }
        }
    }

    if(lstCourseConnect.size() > 0){
        upsert lstCourseConnect;
    }

    mainCourseWrap mainWrp = new mainCourseWrap();
    mainWrp = getProgramPlan(termId);
    return mainWrp;
}


@AuraEnabled
public static list<groupWrap> getprofessorBatchDetails(string termId,string courseId,string Category){

    map<string,groupWrap> mapGroup = new map<string,groupWrap>();
    
    list<string> termIds = new list<string>();
    string sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
    string groupId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
    string batchId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
    string facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
    string contactRtId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
    
    hed__Term__c objTerm = [SELECT id,Program_Batch__c,Program_Batch__r.hed__Account__r.ParentId FROM hed__Term__c WHERE id =: termId];
    
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                            AND recordTypeId =: sectionRtId ORDER By Section_Number__c ASC]){
        termIds.add(trm.id);
    }
    /*
    string batchId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Batch_Short_Name__c,Batch_Number__c,hed__Parent_Term__r.Section_Name__c FROM hed__Term__c WHERE  
                            recordTypeId =: batchId AND hed__Parent_Term__c =: termIds]){
         termIds.add(trm.id);                   
    }
    */
    list<electiveWrap> lstBatch = new list<electiveWrap>();
    integer batchSize = 0;
    
    list<hed__Term__c> listBatchTerm = new list<hed__Term__c>();
    
    if(Category == 'Practical/Term work'){
        for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Batch_Short_Name__c,Batch_Number__c,hed__Parent_Term__r.Section_Name__c FROM hed__Term__c WHERE  
                            recordTypeId =: batchId AND hed__Parent_Term__c =: termIds]){
                            
            electiveWrap objBatch = new electiveWrap();
            objBatch.name = trm.Name;
            objBatch.id = trm.id;
            objBatch.semesterId = trm.hed__Parent_Term__c;
            objBatch.sequenceNo = trm.Batch_Number__c;
            objBatch.SectionName = trm.hed__Parent_Term__r.Section_Name__c;
            lstBatch.add(objBatch);
            listBatchTerm.add(trm);
            
        }
        
        batchSize = lstBatch.size() / termIds.size();
    }
    
    if(Category == 'Professional Elective'){
        for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Batch_Short_Name__c,Batch_Number__c,hed__Parent_Term__r.Section_Name__c FROM hed__Term__c WHERE  
                            recordTypeId =: groupId AND hed__Parent_Term__c =: termIds]){
                            
            electiveWrap objBatch = new electiveWrap();
            objBatch.name = trm.Name;
            objBatch.id = trm.id;
            objBatch.semesterId = trm.hed__Parent_Term__c;
            objBatch.sequenceNo = trm.Batch_Number__c;
            objBatch.SectionName = trm.hed__Parent_Term__r.Section_Name__c;
            lstBatch.add(objBatch);
        }
        
        batchSize = lstBatch.size() / termIds.size();
    }
        
    hed__Course_Offering__c course = [SELECT id,Min_Professors_Per_Course__c,Max_Professors_Per_Course__c,hed__Course__c,hed__Capacity__c,Quality_Circle_Head_Contact__c 
                                      FROM hed__Course_Offering__c WHERE hed__Term__c =: termId AND hed__Course__c =: courseId
                                      AND Category__c =: Category LIMIT 1];
                                      
    map<string,list<hed__Course_Enrollment__c>> mapcourseConnection = new map<string,list<hed__Course_Enrollment__c>>();
    
    for(hed__Course_Enrollment__c cc : [SELECT id,hed__Course_Offering__c,Section__c,hed__Contact__c,hed__Contact__r.Name,hed__Course_Offering__r.hed__Course__c,
                                        Section__r.Section_Name__c,Unique_Key__c,Order_Count__c,Section__r.Batch_Number__c,Section__r.Batch_Short_Name__c,
                                        Section__r.hed__Parent_Term__r.Section_Name__c 
                                        FROM hed__Course_Enrollment__c WHERE Section__c =: listBatchTerm AND hed__Course_Offering__r.hed__Course__c =: courseId AND 
                                        hed__Course_Offering__r.Category__c =: Category AND RecordTypeId =: facultyRtId ORDER By Section__r.Section_Number__c]){
        
        string ukey = cc.hed__Course_Offering__r.hed__Course__c+'-'+string.valueof(cc.Section__r.Batch_Number__c)+'-'+cc.Section__r.hed__Parent_Term__r.Section_Name__c+'-'+cc.Order_Count__c;
        system.debug('ukey++++++++'+ukey);
        if(mapcourseConnection.containsKey(ukey)){
            mapcourseConnection.get(ukey).add(cc);
        }
        else{
            mapcourseConnection.put(ukey,new list<hed__Course_Enrollment__c>{cc});
        }        
    }          
    
    map<id,list<Professor_Student_Course_Preference__c>> mapPreference = new map<id,list<Professor_Student_Course_Preference__c>>();   
    map<string,string> pref1 = new map<string,string>();
    map<string,string> pref2 = new map<string,string>();
    integer prefMaxCount = 0;                        
                                      
    for(Professor_Student_Course_Preference__c prf : [SELECT id,Preference__c,Preference_No__c,Professor__c,Professor__r.Name,Semester__c,
                                             Professor__r.Designation__c,Unique_Key__c,Course_Offering__r.hed__Course__c FROM Professor_Student_Course_Preference__c 
                                             WHERE Semester__c=: termId AND Course_Offering__r.hed__Course__c =: courseId AND Course_Offering__r.Category__c =: Category 
                                             ORDER By Semester__r.Section_Number__c]){
    
        if(mapPreference.containsKey(prf.Course_Offering__r.hed__Course__c)){
            mapPreference.get(prf.Course_Offering__r.hed__Course__c).add(prf);
        }
        else{
            mapPreference.put(prf.Course_Offering__r.hed__Course__c,new list<Professor_Student_Course_Preference__c>{prf});
        }
        
        if(prefMaxCount < integer.valueof(prf.Preference__c)){
            prefMaxCount = integer.valueof(prf.Preference__c);
        }
        
            pref1.put(prf.Professor__c,prf.Professor__r.Name);
            pref2.put(prf.Professor__c,prf.Professor__r.Name);
    }
    
    if(prefMaxCount < (termIds.size() / 2)){
                
        for(contact con : [SELECT id,Name FROM Contact WHERE recordTypeId =: contactRtId AND AccountId =: objTerm.Program_Batch__r.hed__Account__r.ParentId]){
            pref1.put(con.id,con.Name);
            pref2.put(con.id,con.Name);
        }        
    }
    
    list<hed__Course_Offering__c> lstCourseOff = [SELECT id,Min_Professors_Per_Course__c,Parent_Course_Offering__c,hed__Term__c,hed__Term__r.Section_Name__c,
                                             hed__Term__r.Section_Number__c,hed__Course__c FROM hed__Course_Offering__c WHERE hed__Term__c =: termIds 
                                             AND hed__Course__c =: courseId AND Category__c =: Category ORDER By hed__Term__r.Section_Number__c];
    
    
    system.debug('Max_Professors_Per_Course__c++++++++++++'+course.Max_Professors_Per_Course__c);   
    system.debug('BatchSize++++++++++'+listBatchTerm.size());
    system.debug('Batch++++++++++'+listBatchTerm);                                      

    for(integer b = 1; b <= batchSize; b++){
        string batchName = 'Batch'+string.valueof(b);
        groupWrap objGroup = new groupWrap();
        objGroup.groupName = batchName;
        map<string,ProfessorMainWrap> mapProf = new map<string,ProfessorMainWrap>();
        
        for(integer i = 1; i <= course.Max_Professors_Per_Course__c; i++){
        for(hed__Course_Offering__c objCourse : lstCourseOff){
        
                string ukey = objCourse.hed__Course__c+'-'+string.valueof(b)+'-'+objCourse.hed__Term__r.Section_Name__c+'-'+string.valueof(i);
                system.debug('++++++'+ukey);
                if(mapcourseConnection.containsKey(ukey)){ 
                    for(hed__Course_Enrollment__c cc : mapcourseConnection.get(ukey)){
                       // if(cc.hed__Contact__c ==  prof.Professor__c){
                            if(!mapProf.containsKey(string.valueof(i))){
                                ProfessorMainWrap profWrp = new ProfessorMainWrap();
                                profWrp.Preferences = 'Professor - ' + string.valueof(i);
                                profWrp.PreferenceCount = decimal.valueof(cc.Order_Count__c);
                                profWrp.orderCount = cc.Order_Count__c;
                                if(string.isNotBlank(course.Quality_Circle_Head_Contact__c)){
                                    profWrp.primaryFaculty = course.Quality_Circle_Head_Contact__c;
                                }
                                if(i == 1){
                                    profWrp.mapProfessor = pref1;    
                                }
                                else{
                                    profWrp.mapProfessor = pref2;
                                }
                                mapProf.put(string.valueof(i),profWrp);
                            }            
                            ProfessorWrap pw = new ProfessorWrap();
                            pw.professor = cc.hed__Contact__r.Name;
                            pw.professorId = cc.hed__Contact__c;
                            pw.isCreated = true;
                            pw.section = cc.Section__r.Section_Name__c;
                            pw.connectionId = cc.id;
                            pw.courseOfferingId = cc.hed__Course_Offering__c;
                            pw.uniqueKey = ukey;
                            system.debug('Test++++++'+pw.uniqueKey);
                            pw.termId = objCourse.hed__Term__c;
                            for(electiveWrap gp : lstBatch){
                                if(gp.semesterId == objCourse.hed__Term__c && gp.sequenceNo == b){
                                    pw.groupId = gp.id;
                                }
                            }
                            mapProf.get(string.valueof(i)).lstPreferences.add(pw);
                    }
                }
                else{
                    if(mapProf.containsKey(string.valueof(i))){
                        ProfessorWrap pw = new ProfessorWrap();
                        pw.professorId = '';
                        pw.isCreated = false;
                        pw.section = objCourse.hed__Term__r.Section_Name__c;
                        pw.courseOfferingId = objCourse.id;
                        pw.uniqueKey = ukey;
                        pw.termId = objCourse.hed__Term__c;
                        for(electiveWrap gp : lstBatch){
                            if(gp.semesterId == objCourse.hed__Term__c && gp.sequenceNo == b){
                                pw.groupId = gp.id;
                            }
                        }
                        mapProf.get(string.valueof(i)).lstPreferences.add(pw);
                        if(i == 1){
                            mapProf.get(string.valueof(i)).mapProfessor = pref1;
                        }
                        else{
                            mapProf.get(string.valueof(i)).mapProfessor = pref2;
                        }
                    }
                    else{
                        ProfessorMainWrap profWrp = new ProfessorMainWrap();
                        profWrp.Preferences = 'Professor - ' + string.valueof(i);
                        profWrp.PreferenceCount = i;
                        profWrp.orderCount = string.valueof(i);
                        if(string.isNotBlank(course.Quality_Circle_Head_Contact__c)){
                            profWrp.primaryFaculty = course.Quality_Circle_Head_Contact__c;
                        }
                        if(i == 1){
                            profWrp.mapProfessor = pref1;
                        }
                        else{
                            profWrp.mapProfessor = pref2;
                        }              
                        ProfessorWrap pw = new ProfessorWrap();
                        pw.professorId = '';
                        pw.isCreated = false;
                        pw.section = objCourse.hed__Term__r.Section_Name__c;
                        pw.courseOfferingId = objCourse.id;
                        pw.uniqueKey = ukey;
                        pw.termId = objCourse.hed__Term__c;
                        for(electiveWrap gp : lstBatch){
                            if(gp.semesterId == objCourse.hed__Term__c && gp.sequenceNo == b){
                                pw.groupId = gp.id;
                            }
                        }
                        profWrp.lstPreferences.add(pw);                    
                        mapProf.put(string.valueof(i),profWrp);
                    } 
                }
            }
        }   
        objGroup.mainProffesors =  mapProf.values();    
        mapGroup.put(batchName,objGroup);
    
    }    
        
        
        
        
        
        
        
        
             
    system.debug('mapGroup++++++++++'+mapGroup);                                                                                                            
    return mapGroup.values();
}

@AuraEnabled
public static mainCourseWrap savePraticalDetails(string termId,string courseId,string primaryProfessor,list<groupWrap> allGroups,boolean isConfirmrd){
    // list<ProfessorMainWrap> allCourses
    list<hed__Course_Enrollment__c> lstCourseConnect = new list<hed__Course_Enrollment__c>();
    string ccRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
    
    hed__Course_Offering__c course = [SELECT id,Min_Professors_Per_Course__c,Max_Professors_Per_Course__c,hed__Course__c,hed__Capacity__c,Quality_Circle_Head_Contact__c,Quality_Circle_Head__c, 
                                      Faculty_Course_Connection_Created__c FROM hed__Course_Offering__c WHERE hed__Term__c =: termId AND hed__Course__c =: courseId LIMIT 1];
    if(string.isNotBlank(primaryProfessor)){                                  
        course.Quality_Circle_Head_Contact__c =  primaryProfessor;
        contact objCon = [SELECT id,ownerId FROM contact WHERE id =: primaryProfessor];
        course.Quality_Circle_Head__c = objCon.ownerId;
    }
    else{
        course.Quality_Circle_Head_Contact__c = Null;
        course.Quality_Circle_Head__c = Null;
    }
    course.Faculty_Course_Connection_Created__c = isConfirmrd;
    update course;                                
    system.debug('+++++++++'+allGroups);
    for(groupWrap gw : allGroups){
        for(ProfessorMainWrap mcourse : gw.mainProffesors){
            for(ProfessorWrap pp : mcourse.lstPreferences){
                if(pp.isCreated){
                    hed__Course_Enrollment__c cc = new hed__Course_Enrollment__c();
                    cc.recordTypeId = ccRtId;
                    cc.hed__Contact__c = pp.professorId;
                    cc.hed__Course_Offering__c = pp.courseOfferingId;
                //    cc.Preference__c = pp.Preference;
                    cc.id = pp.connectionId;
              //      cc.Professor_Student_Course_preference_Id__c = pp.recordId;
                    cc.Order_Count__c = mcourse.orderCount;
                  //  cc.Section__c = pp.termId;
                    cc.Section__c = pp.groupId;
                    lstCourseConnect.add(cc);
                }
                else{
                    if(string.isNotBlank(pp.professorId)){
                        hed__Course_Enrollment__c cc = new hed__Course_Enrollment__c();
                        cc.recordTypeId = ccRtId;
                        cc.hed__Contact__c = pp.professorId;
                        cc.hed__Course_Offering__c = pp.courseOfferingId;
                   //     cc.Preference__c = pp.Preference;
                       // cc.id = pp.connectionId;
                      //  cc.Professor_Student_Course_preference_Id__c = pp.recordId;
                        cc.Order_Count__c = mcourse.orderCount;
                       // cc.Section__c = pp.termId;
                        cc.Section__c = pp.groupId;
                        lstCourseConnect.add(cc);
                    }
                }
            }
        }
    }

    if(lstCourseConnect.size() > 0){
        upsert lstCourseConnect;
    }

    mainCourseWrap mainWrp = new mainCourseWrap();
    mainWrp = getProgramPlan(termId);
    return mainWrp;
}

@AuraEnabled
public static list<groupElectiveWrp> getElectiveDetails(string termId,string courseId,string Category){

    system.debug('++++++++'+courseId);
    system.debug('++++++++'+Category);

    map<string,groupElectiveWrp> mapProf = new map<string,groupElectiveWrp>();
    list<string> groups = new list<string>();
    list<string> termIds = new list<string>();
    string sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
    string groupId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
    string facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
    string contactRtId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
    
    hed__Term__c objTerm = [SELECT id,Program_Batch__c,Program_Batch__r.hed__Account__r.ParentId FROM hed__Term__c WHERE id =: termId];
    
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c,Group_Number__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                            AND recordTypeId =: groupId ORDER By Group_Number__c ASC]){
        groups.add(trm.Name);
        termIds.add(trm.id);
    }
    
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c,Group_Number__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                            AND recordTypeId =: sectionRtId ORDER By Group_Number__c ASC]){
       // termIds.add(trm.id);
    }
    
    hed__Course_Offering__c course = [SELECT id,Min_Professors_Per_Course__c,Max_Professors_Per_Course__c,hed__Course__c,hed__Capacity__c,Quality_Circle_Head_Contact__c 
                                      FROM hed__Course_Offering__c WHERE hed__Term__c =: termId AND hed__Course__c =: courseId
                                      AND Category__c =: Category LIMIT 1];
    
    map<string,list<hed__Course_Enrollment__c>> mapcourseConnection = new map<string,list<hed__Course_Enrollment__c>>();
    
    for(hed__Course_Enrollment__c cc : [SELECT id,hed__Course_Offering__c,Section__c,hed__Contact__c,hed__Contact__r.Name,hed__Course_Offering__r.hed__Course__c,
                                        Section__r.Section_Name__c,Unique_Key__c,Order_Count__c,Section__r.Group_Number__c 
                                        FROM hed__Course_Enrollment__c WHERE Section__c =: termIds AND hed__Course_Offering__r.hed__Course__c =: courseId AND 
                                        hed__Course_Offering__r.Category__c =: Category AND RecordTypeId =: facultyRtId ORDER By Section__r.Section_Number__c]){
        
        string ukey = course.id+'-'+cc.Section__r.Group_Number__c;
        if(mapcourseConnection.containsKey(ukey)){
            mapcourseConnection.get(ukey).add(cc);
        }
        else{
            mapcourseConnection.put(ukey,new list<hed__Course_Enrollment__c>{cc});
        }        
    }
    system.debug('+++++++++++'+mapcourseConnection);
    map<id,list<Professor_Student_Course_Preference__c>> mapPreference = new map<id,list<Professor_Student_Course_Preference__c>>();   
    map<string,string> pref1 = new map<string,string>();
    map<string,string> pref2 = new map<string,string>();
    integer prefMaxCount = 0;
    
    for(Professor_Student_Course_Preference__c prf : [SELECT id,Preference__c,Preference_No__c,Professor__c,Professor__r.Name,Semester__c,
                                             Professor__r.Designation__c,Unique_Key__c,Course_Offering__r.hed__Course__c FROM Professor_Student_Course_Preference__c 
                                             WHERE Semester__c=: termId AND Course_Offering__r.hed__Course__c =: courseId AND Course_Offering__r.Category__c =: Category 
                                             ORDER By Semester__r.Section_Number__c]){
    
        if(mapPreference.containsKey(prf.Course_Offering__r.hed__Course__c)){
            mapPreference.get(prf.Course_Offering__r.hed__Course__c).add(prf);
        }
        else{
            mapPreference.put(prf.Course_Offering__r.hed__Course__c,new list<Professor_Student_Course_Preference__c>{prf});
        }
        
        if(prefMaxCount < integer.valueof(prf.Preference__c)){
            prefMaxCount = integer.valueof(prf.Preference__c);
        }
        
            pref1.put(prf.Professor__c,prf.Professor__r.Name);
            pref2.put(prf.Professor__c,prf.Professor__r.Name);
    }
    
    if(prefMaxCount < (termIds.size() / 2)){
                
        for(contact con : [SELECT id,Name FROM Contact WHERE recordTypeId =: contactRtId AND AccountId =: objTerm.Program_Batch__r.hed__Account__r.ParentId]){
            pref1.put(con.id,con.Name);
            pref2.put(con.id,con.Name);
        }
        
    }
    
    for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c,Group_Number__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                            AND recordTypeId =: groupId AND Course_Offering__r.hed__Course__c =: courseId ORDER By Group_Number__c ASC]){
    
        for(integer i = 1; i <= course.Max_Professors_Per_Course__c; i++){
            string ukey = course.id+'-'+trm.Group_Number__c;
            if(mapcourseConnection.containsKey(ukey)){ 
                for(hed__Course_Enrollment__c cc : mapcourseConnection.get(ukey)){
                    if(!mapProf.containsKey(string.valueof(i))){
                        groupElectiveWrp profWrp = new groupElectiveWrp();
                        profWrp.Preferences = 'Professor - ' + string.valueof(i);
                        profWrp.PreferenceCount = decimal.valueof(cc.Order_Count__c);
                        profWrp.orderCount = cc.Order_Count__c;
                        if(string.isNotBlank(course.Quality_Circle_Head_Contact__c)){
                            profWrp.primaryFaculty = course.Quality_Circle_Head_Contact__c;
                        }
                        if(i == 1){
                            profWrp.mapProfessor = pref1;    
                        }
                        else{
                            profWrp.mapProfessor = pref2;
                        }
                        mapProf.put(string.valueof(i),profWrp);
                    }
                    ProfessorWrap pw = new ProfessorWrap();
                    pw.professor = cc.hed__Contact__r.Name;
                    pw.professorId = cc.hed__Contact__c;
                    pw.isCreated = true;
                    pw.connectionId = cc.id;
                    pw.courseOfferingId = course.id;
                    // pw.uniqueKey = cc.Unique_Key__c;
                    pw.uniqueKey = ukey;
                    pw.termId = trm.id;
                    mapProf.get(string.valueof(i)).mainProffesors.add(pw);
                }  
            }
            else{
                if(mapProf.containsKey(string.valueof(i))){
                    ProfessorWrap pw = new ProfessorWrap();
                    pw.professorId = '';
                    pw.isCreated = false;
                    pw.courseOfferingId = course.id;
                    pw.uniqueKey = ukey;
                    pw.termId = trm.id;
                    mapProf.get(string.valueof(i)).mainProffesors.add(pw);
                    if(i == 1){
                        mapProf.get(string.valueof(i)).mapProfessor = pref1;
                    }
                    else{
                        mapProf.get(string.valueof(i)).mapProfessor = pref2;
                    }
                }
                else{
                    groupElectiveWrp profWrp = new groupElectiveWrp();
                    profWrp.Preferences = 'Professor - ' + string.valueof(i);
                    profWrp.PreferenceCount = i;
                    profWrp.orderCount = string.valueof(i);
                    if(string.isNotBlank(course.Quality_Circle_Head_Contact__c)){
                        profWrp.primaryFaculty = course.Quality_Circle_Head_Contact__c;
                    }
                    if(i == 1){
                        profWrp.mapProfessor = pref1;
                    }
                    else{
                        profWrp.mapProfessor = pref2;
                    }              
                    ProfessorWrap pw = new ProfessorWrap();
                    pw.professorId = '';
                    pw.isCreated = false;
                    pw.courseOfferingId = course.id;
                    pw.uniqueKey = ukey;
                    pw.termId = trm.id;
                    profWrp.mainProffesors.add(pw);                    
                    mapProf.put(string.valueof(i),profWrp);
                }
            }
        }
    }
    system.debug('++++++++++'+mapProf.values());
    return mapProf.values();
}


@AuraEnabled
public static list<string> getGroupLst(string termId,string courseId,string Category){
    list<string> lstGroup = new list<string>();
    string groupRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
    string sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
    system.debug('+++++'+courseId);
    system.debug('+++++'+termId);
    system.debug('+++++'+Category);
    if(Category == 'Professional Elective'){
        for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                                AND recordTypeId =: groupRtId AND Course_Offering__r.hed__Course__c =: courseId ORDER By Section_Number__c ASC]){
            lstGroup.add(trm.Name);
        }        
    }
    else{    
        for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                                AND recordTypeId =: sectionRtId ORDER By Section_Number__c ASC]){
            lstGroup.add('Section '+trm.Section_Name__c);
        }
    }    
    system.debug('++++++++++'+lstGroup); 
  /*  
    if(lstGroup.size() == 0){
        for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                                AND recordTypeId =: sectionRtId ORDER By Section_Number__c ASC]){
            lstGroup.add('Section '+trm.Section_Name__c);
        }
    }
    */
    return lstGroup;
}   

@AuraEnabled
public static list<string> getSectionLst(string termId){
    list<string> lstSection = new list<string>();
    string sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
    system.debug('+++++'+termId);
      
        for(hed__Term__c trm : [SELECT id,Name,hed__Parent_Term__c,Section_Name__c FROM hed__Term__c WHERE hed__Parent_Term__c =: termId 
                                AND recordTypeId =: sectionRtId ORDER By Section_Number__c ASC]){
            lstSection.add('Section '+trm.Section_Name__c);
        }
      
    system.debug('++++++++++'+lstSection); 
    return lstSection;
}     

@AuraEnabled
public static mainCourseWrap saveProElectiveDetails(string termId,string courseId,string primaryProfessor,list<groupElectiveWrp> allGroups,boolean isConfirmrd){
    // list<ProfessorMainWrap> allCourses
    list<hed__Course_Enrollment__c> lstCourseConnect = new list<hed__Course_Enrollment__c>();
    string ccRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        
    hed__Course_Offering__c course = [SELECT id,Min_Professors_Per_Course__c,Max_Professors_Per_Course__c,hed__Course__c,hed__Capacity__c,Quality_Circle_Head_Contact__c,Quality_Circle_Head__c, 
                                      Faculty_Course_Connection_Created__c FROM hed__Course_Offering__c WHERE hed__Term__c =: termId AND hed__Course__c =: courseId LIMIT 1];
    if(string.isNotBlank(primaryProfessor)){                                  
        course.Quality_Circle_Head_Contact__c =  primaryProfessor;
        contact objCon = [SELECT id,ownerId FROM contact WHERE id =: primaryProfessor];
        course.Quality_Circle_Head__c = objCon.ownerId;
    }
    else{
        course.Quality_Circle_Head_Contact__c = Null;
        course.Quality_Circle_Head__c = Null;
    }
    course.Faculty_Course_Connection_Created__c = isConfirmrd;
    update course;                                
    
    for(groupElectiveWrp gw : allGroups){
        for(ProfessorWrap pp : gw.mainProffesors){
            if(pp.isCreated){
                hed__Course_Enrollment__c cc = new hed__Course_Enrollment__c();
                cc.recordTypeId = ccRtId;
                cc.hed__Contact__c = pp.professorId;
                cc.hed__Course_Offering__c = course.id;
                cc.id = pp.connectionId;
                cc.Order_Count__c = gw.orderCount;
                cc.Section__c = pp.termId;
                lstCourseConnect.add(cc);
            }
            else{
                if(string.isNotBlank(pp.professorId)){
                    hed__Course_Enrollment__c cc = new hed__Course_Enrollment__c();
                    cc.recordTypeId = ccRtId;
                    cc.hed__Contact__c = pp.professorId;
                    cc.hed__Course_Offering__c = course.id;
                    cc.Order_Count__c = gw.orderCount;
                    cc.Section__c = pp.termId;
                    lstCourseConnect.add(cc);
                }
            }
        }
    }

    if(lstCourseConnect.size() > 0){
        upsert lstCourseConnect;
    }

    mainCourseWrap mainWrp = new mainCourseWrap();
    mainWrp = getProgramPlan(termId);
    return mainWrp;
}

public class mainCourseWrap{

    @AuraEnabled public list<courseWrap> listHardCore {get;set;}
    @AuraEnabled public list<parentWrap> listOpenElective {get;set;}
    @AuraEnabled public list<parentWrap> listProfElective {get;set;}
    @AuraEnabled public list<courseWrap> listPractical {get;set;}
    @AuraEnabled public list<courseWrap> listHcIntegrated {get;set;}
    @AuraEnabled public list<courseWrap> listMandatory {get;set;}
    @AuraEnabled public list<string> lstSection {get;set;}
    
}

public class parentWrap{
    @AuraEnabled public string count {get;set;}
    @AuraEnabled public string recordId {get;set;}
    @AuraEnabled public string courseName {get;set;}
    @AuraEnabled public string courseId {get;set;}
    @AuraEnabled public boolean isConfirmed {get;set;}
    @AuraEnabled public list<courseWrap> lstCourse {get;set;}
    
    public parentWrap(){
        lstCourse = new list<courseWrap> ();
    }
}
public class courseWrap{
    @AuraEnabled public string count {get;set;}
    @AuraEnabled public string courseName {get;set;}
    @AuraEnabled public string courseId {get;set;}
    @AuraEnabled public boolean isConfirmed {get;set;}
    @AuraEnabled public list<courseSectionWrap> lstSection {get;set;}
    
    public courseWrap(){
        lstSection = new list<courseSectionWrap> ();
    }
}
public class courseSectionWrap{
    @AuraEnabled public string count {get;set;}
    @AuraEnabled public string recordId {get;set;}
    @AuraEnabled public string courseName {get;set;}
    @AuraEnabled public string courseId {get;set;}
    @AuraEnabled public string sectionName {get;set;}
    @AuraEnabled public string termId {get;set;}
    @AuraEnabled public decimal minCource {get;set;}
    @AuraEnabled public boolean professorAssiened {get;set;}
    
    public courseSectionWrap(){
        professorAssiened = false;
    }
}

public class PreferencesMainWrap{
    @AuraEnabled public string Preferences {get;set;}
    @AuraEnabled public integer recordCount {get;set;}    
    @AuraEnabled public list<PreferencesProfessorWrap> lstPreferences {get;set;}
    
    public PreferencesMainWrap(){
        lstPreferences = new list<PreferencesProfessorWrap>();
    }
}

public class PreferencesProfessorWrap{
    @AuraEnabled public string Professor {get;set;}
    @AuraEnabled public string ProfessorId {get;set;}
    @AuraEnabled public string Designation {get;set;}
    @AuraEnabled public string Exps {get;set;}
    @AuraEnabled public integer sectionAssigned {get;set;}
    @AuraEnabled public integer totalSections {get;set;}
    @AuraEnabled public integer totalCount {get;set;}
}

public class ProfessorMainWrap{
    @AuraEnabled public string Preferences {get;set;}
    @AuraEnabled public decimal PreferenceCount {get;set;}
    @AuraEnabled public string orderCount {get;set;}
    @AuraEnabled public string primaryFaculty {get;set;}
    @AuraEnabled public map<string,string> mapProfessor {get;set;}
    @AuraEnabled public list<ProfessorWrap> lstPreferences {get;set;}
    
    public ProfessorMainWrap(){
        lstPreferences = new list<ProfessorWrap>();
        mapProfessor = new map<string,string>();
        primaryFaculty = '';
    }
}
public class ProfessorWrap{
    @AuraEnabled public string professor {get;set;}
    @AuraEnabled public string professorId {get;set;}
    @AuraEnabled public string Preference {get;set;}
    @AuraEnabled public string connectionId {get;set;}
    @AuraEnabled public string section {get;set;}
    @AuraEnabled public string courseOfferingId {get;set;}
    @AuraEnabled public string recordId {get;set;}
    @AuraEnabled public string termId {get;set;}
    @AuraEnabled public string uniqueKey {get;set;}
    @AuraEnabled public boolean isCreated {get;set;}
    @AuraEnabled public string groupId {get;set;}
    @AuraEnabled public string groupName {get;set;}
}

public class groupWrap{
    @AuraEnabled public string groupName {get;set;}
    @AuraEnabled public list<ProfessorMainWrap> mainProffesors{get;set;}
    public groupWrap(){
        mainProffesors = new list<ProfessorMainWrap>();
    }
}


public class electiveWrap{
    @AuraEnabled public string name {get;set;}
    @AuraEnabled public string id {get;set;}
    @AuraEnabled public string semesterId {get;set;}
    @AuraEnabled public string TermId {get;set;}
    @AuraEnabled public decimal sequenceNo {get;set;}
    @AuraEnabled public string SectionName {get;set;}
}

public class groupElectiveWrp{
    @AuraEnabled public string Preferences {get;set;}
    @AuraEnabled public decimal PreferenceCount {get;set;}
    @AuraEnabled public string orderCount {get;set;}
    @AuraEnabled public string primaryFaculty {get;set;}
    @AuraEnabled public map<string,string> mapProfessor {get;set;}
    @AuraEnabled public list<string> groups {get;set;}    
    @AuraEnabled public list<ProfessorWrap> mainProffesors{get;set;} 
    
    public groupElectiveWrp(){
        mapProfessor = new map<string,string>();  
        groups = new list<string>();  
        mainProffesors = new list<ProfessorWrap>();
    }  
}
}