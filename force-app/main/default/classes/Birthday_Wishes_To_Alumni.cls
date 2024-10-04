public class Birthday_Wishes_To_Alumni {
    // Method to send birthday wishes emails to contacts
    public static void sendBirthdayWishes() {
        // Get today's day and month
        Integer todayDay = Date.today().day();
        Integer todayMonth = Date.today().month();
        System.debug('Today\'s Day: ' + todayDay);
        System.debug('Today\'s Month: ' + todayMonth);
        
        // Query contacts with alumni record type and matching birthdate (day and month)
        List<Contact> contacts = [SELECT Id, Name, Email, Birthdate
                                  FROM Contact
                                  WHERE RecordType.Name = 'Alumni'];
        
        List<String> emailAddresses = new List<String>();
        for(Contact c : contacts){
            if(c.Birthdate != null && c.Birthdate.day() == todayDay && c.Birthdate.month() == todayMonth){
                emailAddresses.add(c.Email);
            }
        }
        System.debug('Number of Contacts with Birthdays Today: ' + emailAddresses.size());
        
        // Check if there are any contacts with birthdays today
        if (!emailAddresses.isEmpty()) {
            // Send birthday wishes email to all contacts
            sendEmails(emailAddresses);
        } else {
            System.debug('No contacts found with birthdays matching today\'s date.');
        }
    }
    
    // Method to send birthday wishes email to multiple contacts
    private static void sendEmails(List<String> emailAddresses) {
        System.debug('Sending birthday wishes emails to: ' + String.join(emailAddresses, ', '));
        
        // Retrieve the image from Static Resource and encode it to base64
        String imageBase64 = getImageFromStaticResourceAsBase64('Birthday_Wishes_To_Alumni');
        
        // Create email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // Set email parameters
        email.setToAddresses(emailAddresses);
        email.setSubject('Happy Birthday!');
        
        // Set email body content with image
        String bodyContent = '<html><body><img src="data:image/jpg;base64,' + imageBase64 + '" alt="Birthday Image"></body></html>';
        email.setHtmlBody(bodyContent);
        
        // Send email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        System.debug('Birthday wishes emails sent successfully.');
    }
    
    // Method to retrieve the image from Static Resource and encode it to base64
    private static String getImageFromStaticResourceAsBase64(String resourceName) {
        String imageBase64 = '';
        try {
            // Retrieve the Static Resource
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
            // Convert the image Blob to base64 encoding
            imageBase64 = EncodingUtil.base64Encode(sr.Body);
        } catch(Exception e) {
            System.debug('Error retrieving image from Static Resource: ' + e.getMessage());
        }
        return imageBase64;
    }
}