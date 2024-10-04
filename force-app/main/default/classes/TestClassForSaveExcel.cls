public without sharing class TestClassForSaveExcel {
    @AuraEnabled
    public static void createNewContentVersion(String documentName, String fileData, Id recordId) {
        System.debug('documentName ' + documentName);
        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.Title = documentName + '.csv';
        newContentVersion.VersionData = EncodingUtil.base64Decode(fileData);
        System.debug('fileData ' +fileData );
        newContentVersion.PathOnClient = documentName + '.csv'; // Set this to the desired file name
        newContentVersion.FirstPublishLocationId = recordId; // Link to the record
        System.debug('recordId ' + recordId);
        try{
        insert newContentVersion;

        }catch(Exception e){
            System.debug('Exception ' + e.getMessage());
        }
 
    }
}