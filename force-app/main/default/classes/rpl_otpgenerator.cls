/**
 * @description       : 
 * @author            : TeenaSingh@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-25-2023
 * @last modified by  : VikrantPuvvadi@UserSettingsUnder.SFDoc
**/

global without sharing class rpl_otpgenerator implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, 
                                                         Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        

        try {
            String recordId = getRecordIdFromSubject(email.subject);

            if (recordId != null) {
                String otp = generateOTP(); // Generate OTP
                String toAddress = getEmailFromContact(recordId); // Get recipient's email from Contact

                if (toAddress != null) {sendEmail(toAddress, otp); // Send the OTP email
                }
            }
            system.debug('result Email'+result);
            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.message = e.getMessage();
        }

        return result;
    }

    private String getRecordIdFromSubject(String subject) {
        String[] subjectParts = subject.split(':');
        if (subjectParts.size() == 2) {
            return subjectParts[1].trim();
        } else {
            return null;
        }
    }

    private String generateOTP() {
        // Generate your OTP logic here and return it as a string
        Integer otp = (Integer)Math.floor(Math.random() * 9000) + 1000;
        return String.valueOf(otp);
    }

    private String getEmailFromContact(String recordId) {
        Contact con = [SELECT Personal_Email__c FROM Contact WHERE Id = :recordId];
        return con.Email;
    }

    public void sendEmail(String toAddress, String otp) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = new String[] { toAddress };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Your OTP Code');
        mail.setPlainTextBody('Your OTP code is: ' + otp);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
    }
}