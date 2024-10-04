public without sharing class RevaTransportHandler {
    @AuraEnabled(cacheable=true)
    public static Transport_Registeration__c revaTransportRegPage() {
        
        String conId;
        string useremail =  UserInfo.getUserEmail();
        System.debug('Loggedin User Id---->>> '+useremail);
        
        List<User> userList = [SELECT Id, Profile.Name FROM User WHERE Email = :userEmail LIMIT 1];
        System.debug('UserList-->> '+userList);
        
        if(!userList.isEmpty() && userList[0].Profile.Name == 'Applicant Profile'){
            
            List<Contact> conDetails = [SELECT Id, Name, Personal_Email__c, Record_Type_Name__c From Contact Where Personal_Email__c=:useremail LIMIT 1];
            System.debug('conDetails-->> '+conDetails);
            conId = conDetails[0].Id;
            System.debug('ContactId--->>> '+conId);   
            
        } else
        {               
            List<Contact> conDetails = [SELECT Id, Name, email, Record_Type_Name__c From Contact Where email=:useremail LIMIT 1];
            System.debug('conDetails-->> '+conDetails);
            conId = conDetails[0].Id;
            System.debug('ContactId--->>> '+conId);            
        }
        
        List<Transport_Registeration__c> TransportRegList =[SELECT Id, Name, Route_Pick_Up_Point__r.Name,Reva_Transport__r.Name,Route_Master__r.Name,
                                                      Route_Master__r.RTR_Route_Path__c, Contact__r.Name, Registration_Status__c,
                                                      Contact__r.Id FROM Transport_Registeration__c Where Contact__r.Id=:conId];
                
        if(!TransportRegList.isEmpty()){
            System.debug('TransportRegList---->>> ' + TransportRegList[0]);
            return TransportRegList[0];
        }        
        else{
            return null;
        }
    }
    
    //Display Registration Details 
    @AuraEnabled(cacheable=true)
    public static List<Reva_Transport__c> revaTransportPortal() {
        List<Reva_Transport__c> revaRegistrationList = [SELECT Id, Name, Active__c,Reg_Start_Date__c, Reg_End_Date__c,(SELECT Id, Name From Program_Batches__r), 
                                                        CreatedDate FROM Reva_Transport__c where Active__c = true ];
        System.debug('revaTransportList ' + revaRegistrationList);
        return revaRegistrationList;
    }
    
    @AuraEnabled(cacheable=true)
    public static contact ContactDetails(){
        
        string useremail =  UserInfo.getUserEmail();
        System.debug('Loggedin User Id---->>> '+useremail);
        
        List<User> userList = [SELECT Id, Profile.Name FROM User WHERE Email = :userEmail LIMIT 1];
        System.debug('UserList-->> '+userList);
        
        if(!userList.isEmpty() && userList[0].Profile.Name == 'Applicant Profile'){
            
            Contact conDetails = [SELECT Id, Name, Personal_Email__c, Record_Type_Name__c, Program_Batch__r.Name,Active_Semester__r.Name, RH_Current_Pursuing_Year_of_Student__c,Ready_to_be_Transitioned__c From Contact Where Personal_Email__c=:useremail LIMIT 1];
            System.debug('conDetails-->> '+conDetails);
            return conDetails;
            
        } else{
            
            Contact conDetails = [SELECT Id, Name, email, Record_Type_Name__c, Program_Batch__r.Name,Active_Semester__r.Name, RH_Current_Pursuing_Year_of_Student__c,Ready_to_be_Transitioned__c From Contact Where email=:useremail LIMIT 1];
            System.debug('conDetails-->> '+conDetails);
            return conDetails;
        }
        
    }
    
}