public without sharing class LeadTriggerHandler {

    public static void updateLeadSource(Map<Id,Lead> oldLeadMap, List<Lead> newLeads){

        for (Lead eachLead : newLeads) {

               // Making sure that the update is from the sync -- D0nt pass utmsource in the flow. (not for creatio nor for update)
            if (eachLead.pi__last_activity__c != oldLeadMap.get(eachLead.Id).pi__last_activity__c) {

    
                if ((eachLead.utm_source__c == '' || eachLead.utm_source__c == null) 
                        && eachLead.pi__first_touch_url__c !='' && (oldLeadMap.get(eachLead.Id).pi__first_touch_url__c == '' || oldLeadMap.get(eachLead.Id).pi__first_touch_url__c == null)) {
                    eachLead.utm_source__c = 'Organic';
                }
                else if ((eachLead.utm_source__c == '' || eachLead.utm_source__c == null) 
                        && eachLead.pi__first_touch_url__c == '' && (oldLeadMap.get(eachLead.Id).pi__first_touch_url__c == '' || oldLeadMap.get(eachLead.Id).pi__first_touch_url__c == null)) {
                    eachLead.utm_source__c = 'Direct';
                }
                if (oldLeadMap.get(eachLead.Id).utm_source__c != eachLead.utm_source__c) {
                    PardotSourceUtility.setSourcesOnLead(eachLead, oldLeadMap.get(eachLead.Id)); 
                }
                 
           }
        }
    }
    
    public static void updateCCAndMobilePhone(Map<Id,Lead> oldLeadMap, List<Lead> newLeads){
        for(Lead eachLead: newLeads){
            if(eachLead.MobilePhone != null){
                if((eachLead.Country_Code__C != oldLeadMap.get(eachLead.id).Country_Code__C
                    || eachLead.MobilePhone != oldLeadMap.get(eachLead.id).MobilePhone)){
                        if(!eachLead.MobilePhone.contains('-')){
                            eachLead.MobilePhone = eachLead.Country_Code__c.substringBetween('(',')')+'-'+eachLead.MobilePhone;
                        }
                        else{
                            eachLead.MobilePhone = eachLead.Country_Code__c.substringBetween('(',')')+'-'+eachLead.MobilePhone.substringAfter('-');
                        }
                    }
            }
        }
    }
    

    public static void insertPrimarySource(List<Lead> newLeads){

        Profile counselorProfile = [Select Id, Name from Profile where Name = 'Counselor'];
        List<User> counselorUsers = [Select Id, Name from User where ProfileId =:counselorProfile.Id and isActive = true];

        Profile publisherProfile = [Select Id, Name from Profile where Name = 'REVA Publisher'];
        List<User> publisherUsers = [Select Id, Name from User where ProfileId = : publisherProfile.Id and isActive = true];
		
        Profile yellowAiProfile = [Select Id, Name from Profile where Name = 'YellowAISystemUser'];
        List<User> yellowAiUsers = [Select Id, Name from User where ProfileId = : yellowAiProfile.Id and isActive = true];
        
        String portalName = RegistrationFormUtility.getPortalName();
        Site admissionsSite = [Select Id, GuestRecordDefaultOwnerId from Site where Name = : portalName];


        Set<Id> publisherUserIds = new Set<Id>();
        Set<Id> counselorUserIds = new Set<Id>();
        set<Id> yellowAiUserIds = new Set<Id>();

        for(User publisher : publisherUsers){
            publisherUserIds.add(publisher.Id);
        }
 		
        for(User yellowAi : yellowAiUsers){
            yellowAiUserIds.add(yellowAi.Id);
        }

        for(User counselor: counselorUsers){
            counselorUserIds.add(counselor.Id);
        }


        for(Lead eachLead : newLeads){

            //Common fields to be set : Company, Mobile Phone & UtmSource and Primary Source based on LeadSource 
            eachLead.Company = eachLead.LastName;  //no matter what Counselors enter in the Company Field let company = last name

            if(eachLead.Country_Code__c != null && eachLead.MobilePhone !=null){ //MobilePhone to be concatenated with the country code
                eachLead.MobilePhone = eachLead.Country_Code__c.substringBetween('(',')')+'-'+eachLead.MobilePhone;
            }
            //Update utm source and Primary source for Manual leads by counselor or Publisher leads through API or leads through data uplaod
            if(eachLead.OwnerId != admissionsSite.GuestRecordDefaultOwnerId){
                eachLead.utm_source__c = eachLead.LeadSource;
                eachLead.Primary_Source__c = eachLead.LeadSource; 
            }

            //Specific field updates For Counselors Leads
            if(counselorUserIds.contains(eachLead.OwnerId)){
                eachLead.Assigned__C = true;
                eachLead.Assigned_Users__C = eachLead.OwnerId;
                eachLead.Last_Assigned_Date__c = system.today();
            }

            //Specific field update For Publisher Leads
            else if(publisherUserIds.contains(eachLead.OwnerId)){
                eachLead.Mobile_OTP_Verified__c = true;     
            }
            
             //Specific field update For Yellow AI Leads
            else if(yellowAiUserIds.contains(eachLead.OwnerId)){
                if(eachLead.Country_Code__c == 'India (+91)'){
               		 eachLead.Mobile_OTP_Verified__c = true;  
                }
                else{
                    eachLead.Email_OTP_Verified__c = true; 
                }
            }
            
        }
    }
}