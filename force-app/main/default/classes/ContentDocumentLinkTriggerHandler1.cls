public class ContentDocumentLinkTriggerHandler1 {
    public static void handleAfterInsert(List<ContentDocumentLink> newContentDocumentLinks) {
        List<ContentDocumentLink> linksToUpdate = new List<ContentDocumentLink>();
        
        // Loop through the inserted ContentDocumentLink records
        for (ContentDocumentLink cdl : newContentDocumentLinks) {
            // Create a new ContentDocumentLink record to update the Visibility field
            ContentDocumentLink updatedCdl = new ContentDocumentLink(
                Id = cdl.Id,
                Visibility = 'AllUsers' // Set this to the desired visibility value
            );
            // Add the record to the list of records to update
            linksToUpdate.add(updatedCdl);
        }

        // Perform the update
        if (!linksToUpdate.isEmpty()) {
            update linksToUpdate;
        }
    }
}