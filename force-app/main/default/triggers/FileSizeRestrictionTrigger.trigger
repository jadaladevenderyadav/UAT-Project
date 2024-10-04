trigger FileSizeRestrictionTrigger on ContentVersion (before insert) {
    // Maximum file size in bytes (5 MB)
    /*Integer maxSizeInBytes = 5 * 1024 * 1024;
  	system.debug('cv.ContentSize00000');

    for (ContentVersion cv : Trigger.new) {
        
        system.debug('cv.ContentSize'+cv.ContentSize);
        // Attempt to validate file size
        if (cv.ContentSize != null && cv.ContentSize > maxSizeInBytes) {
            system.debug('cv.ContentSize'+cv.ContentSize);
            cv.addError('File size exceeds the 5 MB limit.');
        }
    }*/
}