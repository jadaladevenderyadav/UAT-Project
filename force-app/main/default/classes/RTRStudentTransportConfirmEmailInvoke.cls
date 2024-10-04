public class RTRStudentTransportConfirmEmailInvoke {
@InvocableMethod(label='RTR Student Transport Confirmation Email Invoke' description='RRTR Student Transport Confirmation Email Invoke')
    public static void RTRStudentTransportConfirmationEmail(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRStudentTransportConfirmation studentTransportConfirmEmail = new RTRStudentTransportConfirmation(recordIds);
            Id JobId = Database.executeBatch(studentTransportConfirmEmail, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}