public class RPL_Mark_Number_Of_Drives_Not_Attended {
    
    @InvocableMethod(label='Mark Number Of Drives Not Attended')
    public static void blockAbsentStudents(List<List<string>> studentRegistrationIds){
        List<string> studentRegIds = studentRegistrationIds[0];
        
        List<Rpl_Student_Registration__c> studentRegistrationList = [Select Rpl_Is_Blocked__c, Rpl_Count_of_non_appeared_drives__c From Rpl_Student_Registration__c
                                                                     Where Id In:studentRegIds];
        for(Rpl_Student_Registration__c eachStudentRegistration : studentRegistrationList){	
           eachStudentRegistration.Rpl_Count_of_non_appeared_drives__c = (eachStudentRegistration.Rpl_Count_of_non_appeared_drives__c == NULL) ? 1 : eachStudentRegistration.Rpl_Count_of_non_appeared_drives__c + 1;
        }
        update  studentRegistrationList;               
    }
    
}