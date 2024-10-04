public class ASM_IamProfListView {
    @AuraEnabled
    public static profDtWpr fetchData(String iaType){
        profDtWpr dWpr = new profDtWpr();
        dWpr.isAllowed = true;
        dWpr.message = '';
        dWpr.list_CrsCons = new List<hed__Course_Enrollment__c>();
        Contact cont = [SELECT Id FROM Contact WHERE OwnerId =: UserInfo.getUserId() LIMIT 1];
        Id facId = cont.Id;
        Date dt = System.today();
        Set<String> set_FirstCrs = new Set<String>();
        set_FirstCrs.add('Theory');
        set_FirstCrs.add('Project');
        for(hed__Course_Enrollment__c con : [SELECT Id,Name,hed__Course_Offering__c,hed__Course_Offering__r.hed__Course__c,
                                             hed__Course_Offering__r.hed__Term__r.Push_to_Logisys__c,
                                             hed__Course_Offering__r.hed__Term__r.hed__Parent_Term__r.Name,
                                             hed__Course_Offering__r.hed__Course__r.Name,Section__c,Section__r.Active__c,
                                             hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c,Program__c,
                                             School__c,Semester__c,Section_Batch_Group__c,IA1_Start_Date__c,IA1_End_Date__c,
                                             IA2_Start_Date__c,IA2_End_Date__c
                                             FROM hed__Course_Enrollment__c WHERE hed__Contact__c =: facId //='0030w00000qRo2EAAS'
                                             AND ((hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c IN: set_FirstCrs AND Section__r.hed__Parent_Term__r.Active__c = true) 
                                                  OR (hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c = 'Practical' AND Section__r.hed__Parent_Term__r.hed__Parent_Term__r.Active__c = true))
                                             AND RecordType.Name = 'Faculty'])
        {
            if(((iaType == 'IA1' && dt > con.IA1_End_Date__c) || (iaType == 'IA2' && dt > con.IA2_End_Date__c)) && (dt < con.IA2_End_Date__c.addDays(10) && con.hed__Course_Offering__r.hed__Term__r.Push_to_Logisys__c == false)){
                dWpr.list_CrsCons.add(con);
            }
        }
        if(dWpr.list_CrsCons.isEmpty()){
            dWpr.isAllowed = false;
            dWpr.message = iaType+' marks entry not allowed at this moment';
        }
        return dWpr;
    }
        
    public class profDtWpr{
        @AuraEnabled public Boolean isAllowed{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public List<hed__Course_Enrollment__c> list_CrsCons{get;set;}
    }
}