public class rve_update_Checking_Eligibility_contact {
    
    @InvocableMethod
    public static void updateEligibility(List<List<String>> ActiveProgramBatchList) {
        
        List<Contact> listToUpdateEligible = new List<Contact>();
        try{
            
            list<hed__Program_Plan__c> programplan =[ SELECT Id, Name 
                                                     FROM hed__Program_Plan__c 
                                                     WHERE Id IN :ActiveProgramBatchList[0]];
            system.debug('programplan are===>'+programplan);
            if(!programplan.isEmpty()){            
            for(hed__Program_Plan__c programlist :programplan){
                List<Contact> eligibleStudents = rveSeatingArrangementUpdated.getEligibleStudents(programlist.id);
                system.debug('eligible studests list size==?'+eligibleStudents.size());
                system.debug('eligible studests==>'+eligibleStudents);
                if(!eligibleStudents.isEmpty()){
                for (Contact student : eligibleStudents) {
                    student.Checking_Eligibility_for_Exam__c = 'Eligible';
                    listToUpdateEligible.add(student);
                }
            }
            }
            } 
        }catch(Exception e){
            System.debug('An error occurred during update: ' + e.getMessage() + ' on line number: ' + e.getLineNumber());
            
        }
        
        if (!listToUpdateEligible.isEmpty()) {
            try {
                update listToUpdateEligible;
            } catch (DmlException e) {
                System.debug('An error occurred during update: ' + e.getMessage());
                throw new AuraHandledException('Failed to update eligibility: ' + e.getMessage());
            }
        }
    }
}

/*public class rve_update_Checking_Eligibility_contact {

// Method to update the Checking_Eligibility_for_Exam__c field to 'Eligible'
@InvocableMethod
public static void updateEligibility(String ActiveProgramBatch) {
// Get eligible students
List<Contact> eligibleStudents = rveSeatingArrangementUpdated.getEligibleStudents(ActiveProgramBatch);
list<Contact> listtoupdateeligible = new list<Contact>();
// Update the Checking_Eligibility_for_Exam__c field for each eligible student
for (Contact student : eligibleStudents) {
student.Checking_Eligibility_for_Exam__c = 'Eligible';
listtoupdateeligible.add(student);
}

// Perform the update in the database
if (!listtoupdateeligible.isEmpty()) {
update listtoupdateeligible;

}
}
}*/