public class RTRRouteChangeSMS {
    @InvocableMethod(label='RTR Send SMS Notifications for Route Change' description='RTR Send SMS Notification To Route Change')
    public static void RouteChangeSMSNotification(List<String> recordIds){
        if(recordIds != null && !recordIds.isEmpty()){
            makeCalloutAsync(recordIds);           
        } else {
            System.debug('RecordIds List is Empty');
        }   
    }

    @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        
        List<RTR_Reva_Transport_Request__c> requestList = [
            SELECT Id, RTR_Routes__r.Name, RTR_New_Number__r.Name, RTR_Pick_Up_Point__r.Name 
            FROM RTR_Reva_Transport_Request__c 
            WHERE Id IN :recordIds
        ];

        Set<String> oldRoutes = new Set<String>();
        Set<String> newRoutes = new Set<String>();
              
        for (RTR_Reva_Transport_Request__c request : requestList) {
            oldRoutes.add(request.RTR_Routes__r.Name);
            newRoutes.add(request.RTR_New_Number__r.Name);
        }
         
        List<Transport_Registeration__c> trRegList = [
            SELECT Id, Contact__r.Id, Route_Master__r.Name, Route_Pick_Up_Point__r.Name,
                   Registration_Status__c, Reva_Transport__r.Name, Contact__r.MobilePhone 
            FROM Transport_Registeration__c 
            WHERE ((Registration_Status__c = 'Active' AND Reva_Transport__r.Active__c = true) 
                   OR (Registration_Status__c = 'Active' AND Reva_Transport__r.Active__c = NULL))  
            AND Route_Master__r.Name IN :oldRoutes LIMIT 50000
        ];
        System.debug('TrRegList-->> '+trRegList);
        
        if(!trRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            for(RTR_Reva_Transport_Request__c request : requestList) {
                String newRouteNumber = request.RTR_New_Number__r.Name;
                String routeNumber = request.RTR_Routes__r.Name;
                
                for(Transport_Registeration__c trReg : trRegList) {
                    if((trReg.Route_Master__r.Name == routeNumber) && trReg.Contact__r.MobilePhone!= NULL) {
                        String phoneNumber = trReg.Contact__r.MobilePhone;
                        
                        String message = 'Dear Student' + '\nThis is to inform you that the route number '+ routeNumber +
                                         ' is canceled for Today. ' + 'You can take route number '+ newRouteNumber +
                                         ' Instead.'+ '\nWe regret the inconvenience this may cause and appreciate your understanding.' +
                                         '\nREVA University';
                        
                        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                        shrtMessage.dltContentId = '1007503156789986306';
                        shrtMessage.message = message;
                        shrtMessage.recipient = phoneNumber;
                        messageList.add(shrtMessage);
                    }
                }
            }
            
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('RTR Route Change SMS', messageList);
            }
        }
    }
}