public with sharing class RegFormFileController {

    @AuraEnabled
    public static String uploadFile(Id contactId, String fileName, String base64Data, String contentType) {
        try {
            List<ContentDocument> rec = getFiles(contactId);
            System.debug('Rec Size -->'+rec.size());
            if(rec.size() > 0){
                Delete rec;
            }
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
          //  contentVersion.FileType = getFileType(contentType); // Set the FileType based on contentType
            contentVersion.IsMajorVersion = true;
            insert contentVersion;

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
            contentDocumentLink.LinkedEntityId = contactId;
            contentDocumentLink.ShareType = 'V';
            contentDocumentLink.Visibility = 'AllUsers';
            insert contentDocumentLink;

            return contentDocumentLink.ContentDocumentId;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ContentDocument> getFiles(Id contactId) {
        List<ContentDocument> documents = new List<ContentDocument>();
        List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :contactId];
        if (!links.isEmpty()) {
            Set<Id> documentIds = new Set<Id>();
            for (ContentDocumentLink link : links) {
                documentIds.add(link.ContentDocumentId);
            }
         //   documents = [SELECT Id, Title, LatestPublishedVersionId, FileExtension FROM ContentDocument WHERE Id IN :documentIds];
          documents = [SELECT Id, Title, LatestPublishedVersionId, FileExtension FROM ContentDocument WHERE Title = 'FilledRegForm.pdf'];          
        }
        return documents;
    }

    @AuraEnabled
    public static String getContentVersionDownloadUrl(Id contentVersionId) {
        return '/sfc/servlet.shepherd/version/download/' + contentVersionId;
    }

    @AuraEnabled
    public static List<ContentDocument> getRegistrationFormImage() {
        List<ContentDocument> documents = new List<ContentDocument>();
       /* List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :contactId];
        if (!links.isEmpty()) {
            Set<Id> documentIds = new Set<Id>();
            for (ContentDocumentLink link : links) {
                documentIds.add(link.ContentDocumentId);
            }
           documents = [SELECT Id, Title, LatestPublishedVersionId, FileExtension FROM ContentDocument WHERE Title = 'RegistrationForm'];          
        } */
        documents = [SELECT Id, Title, LatestPublishedVersionId, FileExtension FROM ContentDocument WHERE Title = 'RegistrationForm-AY2024-25'];          
        return documents;
    } 

    // For downloading image
    @AuraEnabled(cacheable=true)
    public static String getImageContent(String imageUrl) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(imageUrl);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            return null; // Handle error
        }
    }
}