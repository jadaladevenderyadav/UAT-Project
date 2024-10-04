public class RevaHostelSupportCaseService {
   /* public static void updateOwnershipAndShareCases(Set<Id> caseIds, Id newOwnerId, String recordTypeName, String studentProfileName, String nonTeachingProfileName, String accessLevel) {
        // Get the Record Type Id for the specified record type name
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = :recordTypeName LIMIT 1].Id;

        // Get the profile IDs for the student and non-teaching profiles
        Id studentProfileId = [SELECT Id FROM Profile WHERE Name = :studentProfileName LIMIT 1].Id;
        Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = :nonTeachingProfileName LIMIT 1].Id;

        // Get users with the specified profiles
        List<User> students = [SELECT Id FROM User WHERE ProfileId = :studentProfileId AND IsActive = true];
        List<User> nonTeachingStaff = [SELECT Id FROM User WHERE ProfileId = :nonTeachingProfileId AND IsActive = true];

        // Update case ownership for cases with the specified record type
        List<Case> casesToUpdate = [SELECT Id, OwnerId, CreatedBy.ProfileId, CreatedById FROM Case WHERE Id IN :caseIds AND RecordTypeId = :recordTypeId];
        for (Case c : casesToUpdate) {
            c.OwnerId = newOwnerId;
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }

        // Validate access level
        String caseAccessLevel;
        if (accessLevel.equalsIgnoreCase('Read')) {
            caseAccessLevel = 'Read';
        } else if (accessLevel.equalsIgnoreCase('Edit')) {
            caseAccessLevel = 'Edit';
        } else if (accessLevel.equalsIgnoreCase('Transfer')) {
            caseAccessLevel = 'Transfer';
        } else {
            throw new IllegalArgumentException('Invalid access level: ' + accessLevel);
        }

        // Share cases with the users
        List<CaseShare> caseShares = new List<CaseShare>();
        for (Case c : casesToUpdate) {
            // Share with the student who created the case
            if (c.CreatedBy.ProfileId == studentProfileId) {
                CaseShare caseShare = new CaseShare();
                caseShare.CaseId = c.Id;
                caseShare.UserOrGroupId = c.CreatedById;
                caseShare.CaseAccessLevel = caseAccessLevel;
                caseShare.RowCause = Schema.CaseShare.RowCause.Manual;
                caseShares.add(caseShare);
            }

            // Share with all non-teaching staff users
            for (User nonTeachingUser : nonTeachingStaff) {
                CaseShare caseShare = new CaseShare();
                caseShare.CaseId = c.Id;
                caseShare.UserOrGroupId = nonTeachingUser.Id;
                caseShare.CaseAccessLevel = caseAccessLevel;
                caseShare.RowCause = Schema.CaseShare.RowCause.Manual;
                caseShares.add(caseShare);
            }
        }

        if (!caseShares.isEmpty()) {
            system.debug('+++++caseShares+++++'+caseShares);
            insert caseShares;
        }
    }*/
}