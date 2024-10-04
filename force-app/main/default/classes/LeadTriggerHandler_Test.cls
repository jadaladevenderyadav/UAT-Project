@isTest
public with sharing class LeadTriggerHandler_Test {

    @TestSetup
    public static void createleadData() {
        
        Profile p = [select id from profile where name ='Counselor'];
        User counselorOwner = [Select id, name, IsActive from User where ProfileId=:p.id and isActive = true Limit 1 ];
        
        Profile publisherProfile = [Select Id, Name from Profile where Name = 'REVA Publisher'];
        User publisherUser = [Select Id, Name from User where ProfileId =:publisherProfile.Id and isActive = true LIMIT 1];

        Profile yellowAiProfile = [Select Id, Name from Profile where Name = 'YellowAISystemUser'];
        User yellowAiUsers = [Select Id, Name from User where ProfileId = : yellowAiProfile.Id and isActive = true LIMIT 1];
        
        Lead lead1= new Lead (
            LastName='Sai',
            Company='Test Company',
            utm_source__c='Organic',
            MobilePhone = '9876543210',
            Country_Code__c='India (+91)',
            OwnerId = counselorOwner.Id,
            pi__last_activity__c=DateTime.now()-1,
            pi__first_touch_url__c=''
        );
        insert lead1;
        
        Lead lead2= new Lead (
            LastName='John',
            Company='Test Company1',
            utm_source__c='Direct',
            MobilePhone = '9876543211',
            Country_Code__c='India (+91)',
            OwnerId = counselorOwner.Id,
            pi__last_activity__c=DateTime.now()-1,
            pi__first_touch_url__c=''
        );
        insert lead2;
        
        List<Lead> leads = new List<Lead>();
        
        Lead counselorLead = new Lead();
        counselorLead.LastName='Counselor Lead';
        counselorLead.Company='Test Company';
        counselorLead.utm_source__c='Manual';
        counselorLead.MobilePhone = '9876543210';
        counselorLead.Country_Code__c='India (+91)';
        counselorLead.OwnerId = counselorOwner.Id;
        insert counselorLead;
        
        Lead publisherLead = new Lead();
        publisherLead.LastName='Counselor Lead';
        publisherLead.Company='Test Company';
        publisherLead.utm_source__c='Manual';
        publisherLead.MobilePhone = '9876543210';
        publisherLead.Country_Code__c='India (+91)';
        publisherLead.LeadSource = 'Publisher - Careers360';
        publisherLead.OwnerId = publisherUser.Id;
        insert publisherLead;
        
        Lead yellowAILead = new Lead();
        yellowAILead.LastName='Counselor Lead';
        yellowAILead.Company='Test Company';
        yellowAILead.utm_source__c='Manual';
        yellowAILead.MobilePhone = '9876543210';
        yellowAILead.Country_Code__c='India (+91)';
        yellowAILead.LeadSource = 'Yellow.ai';
        yellowAILead.OwnerId = yellowAiUsers.Id;
        insert yellowAILead;

        Lead freshLead = new Lead();
        freshLead.LastName='Fresh Lead';
        freshLead.Company='Test Company';
        freshLead.utm_source__c='Fresh Lead';
        freshLead.MobilePhone = '9876543210';
        freshLead.Country_Code__c='India (+91)';
        insert freshLead;

        Lead piSourceNullLead = new Lead();
        piSourceNullLead.LastName='Fresh Lead';
        piSourceNullLead.Company='Test Company';
        piSourceNullLead.MobilePhone = '9876543210';
        insert piSourceNullLead;

        Lead primaryLead = new Lead();
        primaryLead.LastName='Fresh Lead';
        primaryLead.Company='Test Company';
        primaryLead.utm_source__c='Primary';
        primaryLead.MobilePhone = '9876543210';
        primaryLead.Primary_Source__c= 'Primary';
        insert primaryLead;

        Lead secondaryLead = new Lead();
        secondaryLead.LastName='Fresh Lead';
        secondaryLead.Company='Test Company';
        secondaryLead.utm_source__c='Secondary';
        secondaryLead.MobilePhone = '9876543210';
        secondaryLead.Country_Code__c = 'India (+91)';
        secondaryLead.Primary_Source__c= 'Secondary';
        secondaryLead.Secondary_Source__c= 'Secondary';
        insert secondaryLead;
    }
    
    @isTest
    public static void updateLeadSourceTest() {
        
        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        List<Lead> newLead = new List<Lead>();
        
        Lead oldLead = [Select Id, LastName, Company,utm_source__c, MobilePhone, Country_Code__C,pi__last_activity__c,pi__first_touch_url__c
                 from Lead where LastName='Sai' Limit 1];
        oldLeadMap.put(oldLead.Id,oldLead);
        
        oldLead.pi__first_touch_url__c='www.google.com';
        oldLead.pi__last_activity__c=DateTime.now();
        update oldLead;
        
        newLead.add(oldLead);
        
        Test.startTest();
        LeadTriggerHandler.updateLeadSource(oldLeadMap,newLead);
        Test.stopTest();
    }
    
    @isTest
    public static void updateCCAndMobilePhoneTest() {
        
        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        List<Lead> newLead = new List<Lead>();
        
        Lead oldLead = [Select Id, LastName, Company,utm_source__c, MobilePhone, Country_Code__C,pi__last_activity__c,pi__first_touch_url__c
                 from Lead where LastName='John' Limit 1];
        oldLeadMap.put(oldLead.Id,oldLead);
        
        oldLead.MobilePhone='9876543220';
        update oldLead;
        
        newLead.add(oldLead);
        
        Test.startTest();
        LeadTriggerHandler.updateCCAndMobilePhone(oldLeadMap,newLead);
        Test.stopTest();
    }
}