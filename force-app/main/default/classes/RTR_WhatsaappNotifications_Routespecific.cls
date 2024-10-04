public class RTR_WhatsaappNotifications_Routespecific {
     @InvocableMethod(label='RTR Send WhatsApp Notifications To routespecific' description='RTR Send notifications via WhatsApp To routespecific')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds!=null && !recordIds.isEmpty()){
            
            makeCalloutAsync(recordIds);           
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        
        List<RTR_Reva_Transport_Request__c> requestList = [select id,RTR_Routes__r.Name, RTR_New_Number__r.Name,RTR_Pick_Up_Point__r.Name 
                                                           ,RTR_Route_Pick_Up_Point__r.Name from RTR_Reva_Transport_Request__c where id IN: recordIds ];
        list<String> newrouteNames = new list<String>();
        list<String> routeNames = new list<String>();
        list<String> pickupPointNames = new list<String>();
        
        for (RTR_Reva_Transport_Request__c reqList : requestList) {
            routeNames.add(reqList.RTR_Routes__r.Name);
            pickupPointNames.add(reqList.RTR_Pick_Up_Point__r.Name);
            newrouteNames.add(reqList.RTR_New_Number__r.Name);
            // Other processing if needed
        }
        


        
        List<Transport_Registeration__c> TrRegList = [Select id, Contact__r.id,Route_Master__r.Name, Route_Pick_Up_Point__r.Name 
                                                      ,Registration_Status__c, Reva_Transport__r.Name From Transport_Registeration__c 
                                                      where Registration_Status__c ='Active' AND Reva_Transport__r.Active__c = true  
                                                      AND Route_Master__r.Name IN : routeNames  AND Route_Pick_Up_Point__r.Name IN: pickupPointNames];
        // populate contactId in List
        List<Id> contactIds = new List<Id>();
        
        for(Transport_Registeration__c trsRegList :TrRegList){
            System.debug('TrsRegList ContactId-->> '+trsRegList.Contact__r.id);
            contactIds.add(trsRegList.Contact__r.id);
        }
        
        // Fetch the related record data
        List<Contact> requiredFields = [select id ,Name, MobilePhone from Contact where id IN :contactIds ];
        
        System.debug('requiredFields-->> '+requiredFields);
        
    //    if(!requiredFields.isEmpty()){
            
            Contact requiredField = requiredFields[0];
            
            // Create WhatsAppNotification instance
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'change_bus_route_number';
            
            // Fetch keys from custom metadata based on templateId
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
            
           // Populate the params map dynamically
notification1.params = new Map<String, String>();
for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
    // Split values based on comma and add each as a separate key
    String[] keys = metadata.Template_Field__c.split(',');
    for (String key : keys) {
        // You can set dynamic values for each key based on the related record
        if (key.trim() == 'name') {
            notification1.params.put(key.trim(), requiredField.Name);
        } else if (key.trim() == 'oldnumber') {
            // Assuming text is a text field
            // Convert the list of routeNames to a comma-separated string
            String routeNamesString = String.join(routeNames, ',');
            notification1.params.put(key.trim(), routeNamesString);
        } else if (key.trim() == 'newnumber') {
            // Assuming newnumber is a text field
            // Convert the list of pickupPointNames to a comma-separated string
            String newrouteNamesString = String.join(newrouteNames, ',');
            notification1.params.put(key.trim(), newrouteNamesString);
        }
    }
	}

        
        	// Create list of notifications
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};

            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            phoneNumbersToNotifications.put(requiredField.MobilePhone, notifications);

            // Send notifications
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
           
    }
    
        }