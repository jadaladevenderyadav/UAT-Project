trigger Change_visibility_when_file_uploaded on ContentDocumentLink (after insert) {
    // Call the trigger handler method
    ContentDocumentLinkTriggerHandler1.handleAfterInsert(Trigger.new);
}


/*trigger Change_visibility_when_file_uploaded on ContentDocumentLink (after insert) {
 // Define a list to hold ContentDocumentLink records that need to be updated
    List<ContentDocumentLink> linksToUpdate = new List<ContentDocumentLink>();

    // Loop through the inserted ContentDocumentLink records
    for (ContentDocumentLink cdl : Trigger.new) {
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
}*/