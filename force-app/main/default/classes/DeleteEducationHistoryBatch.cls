global class DeleteEducationHistoryBatch implements Database.Batchable<sObject>, Database.Stateful {
	
    private Integer totalNumberOfRecords = 0;
    private Integer recordsToDeleteCount = 0;
    private List<String> contactIds = new List<String>();
    private Map<String, Set<String>> documentNameMap = new Map<String, Set<String>>();

    
    public DeleteEducationHistoryBatch(List<String> contactIds){
        this.contactIds = contactIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Contact ids');
        return Database.getQueryLocator([
            SELECT Id, Education_History_Name__c , hed__Contact__c, CreatedDate, (SELECT ContentDocumentId FROM AttachedContentDocuments) 
            FROM hed__Education_History__c 
                WHERE RecordTypeId = '0125j000000RLBmAAO' AND hed__Contact__c IN :contactIds ORDER BY hed__Contact__c ASC, CreatedDate ASC
        ]);
    }

    global void execute(Database.BatchableContext BC, List<hed__Education_History__c> scope) {
        System.debug('Scope ' + scope);
        List<hed__Education_History__c> recordsToDelete = new List<hed__Education_History__c>();
        
        for (hed__Education_History__c eduHistory : scope) {
            if(!documentNameMap.containsKey(eduHistory.hed__Contact__c)){
                Set<String> documentName = new Set<String>();
                documentName.add(eduHistory.Education_History_Name__c);
                documentNameMap.put(eduHistory.hed__Contact__c, documentName);
            }else{
                Set<String> documentNames = documentNameMap.get(eduHistory.hed__Contact__c);
                if(documentNames.contains(eduHistory.Education_History_Name__c) && eduHistory.AttachedContentDocuments.size()==0){
                    recordsToDelete.add(eduHistory);
                }else{
                    documentNames.add(eduHistory.Education_History_Name__c);
					documentNameMap.put(eduHistory.hed__Contact__c, documentNames);                    
                }
            }
            //System.debug(documentNameMap);
        }
        System.debug('Map ' + documentNameMap);
        System.debug('Records to delete ' +recordsToDelete);
        //delete recordsToDelete;
        totalNumberOfRecords += scope.size();
        recordsToDeleteCount += recordsToDelete.size();
        
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Total Records ' + totalNumberOfRecords);
        System.debug('Records To Delete ' + recordsToDeleteCount);
    }
}