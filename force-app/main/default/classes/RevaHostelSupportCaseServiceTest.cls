@isTest

public class RevaHostelSupportCaseServiceTest {
    @isTest
    static void testUpdateOwnershipAndShareCases() {
        // Query existing RecordType and Profile for testing
        RecordType caseRecordType;
        try {
            caseRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'REVA Hostel Support Request' LIMIT 1];
        } catch (Exception e) {
            System.debug('Error: RecordType with DeveloperName = REVA Hostel Support Request not found');
            return; // Exit the test if RecordType is not found
        }
        
        Profile studentProfile;
        Profile nonTeachingProfile;
        try {
            studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
            nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non-Teaching Profile' LIMIT 1];
        } catch (Exception e) {
            System.debug('Error: One or both Profiles not found');
            return; // Exit the test if Profiles are not found
        }

        // Create test Users
        User studentUser = new User(
            Username = 'studentuser@test.com',
            LastName = 'Test1',
            Email = 'studentuser@test.com',
            Alias = 'stud',
            ProfileId = studentProfile.Id,
            UserRoleId = null,
            IsActive = true,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert studentUser;

        User nonTeachingUser = new User(
            Username = 'nonteachinguser@test.com',
            LastName = 'Test1',
            Email = 'nonteachinguser@test.com',
            Alias = 'ntuser',
            ProfileId = nonTeachingProfile.Id,
            UserRoleId = null,
            IsActive = true,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert nonTeachingUser;

        // Create test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            RecordTypeId = caseRecordType.Id,
            CreatedById = studentUser.Id
        );
        insert testCase;

        // Set parameters for the method
        Set<Id> caseIds = new Set<Id>{testCase.Id};
        Id newOwnerId = nonTeachingUser.Id;
        String recordTypeName = caseRecordType.Name;
        String studentProfileName = studentProfile.Name;
        String nonTeachingProfileName = nonTeachingProfile.Name;
        String accessLevel = 'Read';

        Test.startTest();
        RevaHostelSupportCaseService.updateOwnershipAndShareCases(
            caseIds, newOwnerId, recordTypeName, studentProfileName, nonTeachingProfileName, accessLevel
        );
        Test.stopTest();
    }


}