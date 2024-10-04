public class AlumniConversationsController {
	@AuraEnabled(cacheable=true)
    public static List<cloudx_cms__SS_Carousel_Slide__c> getAlumniConversations() {
        List<cloudx_cms__SS_Carousel_Slide__c> aluConvoList = new List<cloudx_cms__SS_Carousel_Slide__c>();
        Id aluConversationsRecordTypeId = Schema.SObjectType.cloudx_cms__SS_Carousel_Slide__c.getRecordTypeInfosByDeveloperName().get('Alumni_Conversations').getRecordTypeId();
        system.debug('aluConversationsRecordTypeId--->'+aluConversationsRecordTypeId);
        try{
            aluConvoList =  [
           select id,
                  Alumni_Message__c, 
                  Alumni_Name__c,
            	  Year__c,
                  Degree_Stream__c, 
                  RecordTypeId 
            from cloudx_cms__SS_Carousel_Slide__c
            where RecordTypeId =:aluConversationsRecordTypeId
            ORDER BY CreatedDate ASC
        ];
            
        }catch(exception e){
           aluConvoList = null; 
            system.debug(' error aluConvoList--->'+e);
        } 
        system.debug('aluConvoList--->'+aluConvoList);
        return aluConvoList;
    }
}