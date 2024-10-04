public class STOB_ProfessorStudentTriggerHandler
{
    public static void RollupPreference(list<Professor_Student_Course_Preference__c> lst_Preference,
                                        map<id,Professor_Student_Course_Preference__c> olaMap_Preference)
    {
        set<id> set_courseid = new set<id>();
        set<id> set_Termid = new set<id>();
        map<id,hed__Course_Offering__c> map_CourseOff = new map<id,hed__Course_Offering__c>();
        
        for(Professor_Student_Course_Preference__c objStuPref : lst_Preference)
        {
            if(olaMap_Preference == null && objStuPref.Course_Offering__c  != null && objStuPref.Preference__c != null
               && objStuPref.Contact__c != null && objStuPref.Semester__c !=null)
            {
                set_courseid.add(objStuPref.Course_Offering__c);
                set_Termid.add(objStuPref.Semester__c);
            }
            if(olaMap_Preference !=null && (olaMap_Preference.get(objStuPref.Id).Course_Offering__c != objStuPref.Course_Offering__c ||
                                            olaMap_Preference.get(objStuPref.Id).Preference__c != objStuPref.Preference__c) 
                                       && objStuPref.Contact__c != null && objStuPref.Semester__c !=null)
            {
                if(objStuPref.Course_Offering__c  != null)
                    set_courseid.add(objStuPref.Course_Offering__c);
                else if(olaMap_Preference.get(objStuPref.Id).Course_Offering__c != null)
                    set_courseid.add(olaMap_Preference.get(objStuPref.Id).Course_Offering__c);
                set_Termid.add(objStuPref.Semester__c);
            }
        }
        if(set_courseid.size() >0 && set_Termid.size()>0)
        {
            for(Id CourseId : set_courseid)
            {
                map_CourseOff.put(CourseId,new hed__Course_Offering__c(id=CourseId,Student_Preference_1__c=0,Student_Preference_2__c =0,Student_Preference_3__c = 0));
            }
            for(Professor_Student_Course_Preference__c objStuPref : [select id,Name,Course_Offering__c,Preference__c,Contact__c,Semester__c from Professor_Student_Course_Preference__c
                                                                     where Course_Offering__c in: set_courseid and Semester__c in: set_Termid]) 
            {
                if(map_CourseOff.get(objStuPref.Course_Offering__c) != null)
                {
                    if(objStuPref.Preference__c == '1')  map_CourseOff.get(objStuPref.Course_Offering__c).Student_Preference_1__c += 1;
                    if(objStuPref.Preference__c == '2')  map_CourseOff.get(objStuPref.Course_Offering__c).Student_Preference_2__c += 1;
                    if(objStuPref.Preference__c == '3')  map_CourseOff.get(objStuPref.Course_Offering__c).Student_Preference_3__c += 1;
                }
            }
        }
        if(map_CourseOff.size()>0)
        {
            update map_CourseOff.values();
        }
    }
}