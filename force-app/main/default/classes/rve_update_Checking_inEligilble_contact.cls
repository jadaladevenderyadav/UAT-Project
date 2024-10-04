public class rve_update_Checking_inEligilble_contact {
    
    @InvocableMethod
    public static void updateInEligibility(List<List<String>> ActiveProgramBatchList) {
        List<Contact> listToUpdateinEligible = new List<Contact>();
        try {
            list<hed__Program_Plan__c> programplan =[ SELECT Id, Name 
                                                     FROM hed__Program_Plan__c 
                                                     WHERE Id IN :ActiveProgramBatchList[0]];
            
            System.debug('programplan=> '+programplan);
            if(!programplan.isEmpty()){
                for(hed__Program_Plan__c programlist :programplan){
                    List<Contact> ineligibleStudents = rveSeatingArrangementUpdated.getIneligibleStudents(programlist.id);
                    if(!ineligibleStudents.isEmpty()){
                        for (Contact student : ineligibleStudents) {
                            student.Checking_Eligibility_for_Exam__c = 'InEligible';
                            listToUpdateinEligible.add(student);
                        }
                    }
                }
            }
            if (!listToUpdateinEligible.isEmpty()) {
                
                update listToUpdateinEligible;
            }
        } catch (Exception e) {
            System.debug('An error occurred during update: ' + e.getMessage());
            throw new AuraHandledException('Failed to update eligibility: ' + e.getMessage());
        }
    }
}