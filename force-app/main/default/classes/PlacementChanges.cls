public class PlacementChanges {
    
    public static void changeTwelvethFileNameToDiploma(){
        List<ContentVersion> twelvethFiles = [SELECT Id,Title, ContentDocumentId
			FROM ContentVersion
			WHERE Title LIKE '%Twelveth%' AND FirstPublishLocationId = 'a2q0T000000FARzQAO'];
        system.debug('Files ' + twelvethFiles);
        for(ContentVersion cv : twelvethFiles){
            String modifiedString = cv.Title.replace('Twelveth', 'Diploma');
            cv.Title = modifiedString;
        }
                system.debug('Files ' + twelvethFiles);

        update twelvethFiles;
    }

}