@isTest
public class ChangeVisibilityWhenFileUploadedTest {
    @isTest
    public static void testMethodvisibility(){        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testusercloud@example.com.test',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        User testUser1 = [SELECT Id FROM User WHERE Username = 'testusercloud@example.com.test'];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.jpg',
            VersionData = Blob.valueOf('Test file content')
        );
        insert contentVersion;
        
        ContentVersion insertedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = insertedContentVersion.ContentDocumentId,
            LinkedEntityId = testUser1.Id, 
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert contentDocumentLink;
        
        ContentDocumentLink updatedContentDocumentLink = [SELECT Id, Visibility FROM ContentDocumentLink WHERE Id = :contentDocumentLink.Id];
        
        System.assertEquals('AllUsers', updatedContentDocumentLink.Visibility);
    	}
	}