public class RPL_EligibilityHandlerClass {
        public static Boolean isAlreadyExecuted = false;
    public static String getPlacementDriveId(
        List<Rpl_Eligibility__c> eligibilityList,
        Boolean isUpdate
    ) {
        String dynamicQuery = '';
        try {
            System.debug('Rpl_Recursive_Controller.isAlreadyExecuted ' + RPL_EligibilityHandlerClass.isAlreadyExecuted);
            System.debug('Inside Method');
            Map<Id, Rpl_Eligibility__c> placeDriveIdMap = new Map<Id, Rpl_Eligibility__c>();
            CriteriaWrapperClass crtWrap = new CriteriaWrapperClass();

            // Populate the criteria wrapper with values from the eligibility list
            for (Rpl_Eligibility__c eElg : eligibilityList) {
                if (!String.isEmpty(eElg.Rpl_Placement_Drive__c)) {
                    System.debug(eElg);
                    placeDriveIdMap.put(eElg.Rpl_Placement_Drive__c, eElg);
                    // Populate criteria wrapper class
                    crtWrap.tenthPercentage = eElg.Rpl_Tenth_Percentage__c;
                    crtWrap.studentVerificationStatus = eElg.Rpl_Verification_Status_Of_Student__c;
                    crtWrap.paymentStatus = eElg.Rpl_Fee_Payment_Status__c;
                    crtWrap.twelvePercentage = eElg.Rpl_Twelveth_Percentage__c;
                    crtWrap.UGPercentage = eElg.Rpl_UG_Percentage1__c;
                    crtWrap.PGPercentage = eElg.Rpl_PG_Percentage1__c;
                    crtWrap.currentBackLog = eElg.Rpl_Current_Backlogs__c;
                    crtWrap.specializationType = eElg.Rpl_Specialization__c;
                    crtWrap.totalBacklogs = eElg.Rpl_Total_Backlogs__c;
                    crtWrap.gender = eElg.Gender__c;
                    crtWrap.OfferCount = eElg.Offer_Count__c;
                    crtWrap.placementDriveId = eElg.Rpl_Placement_Drive__c;
                    crtWrap.gapYear = eElg.Rpl_Gap_Years__c;
                    crtWrap.placementInterest = eElg.Rpl_Placement_Interest__c;
                    crtWrap.attendance = eElg.Rpl_Attendance_Percentage__c;
                    crtWrap.includeCompanies = !String.isEmpty(eElg.Rpl_Include_Students_With_Offer_In__c)
                        ? String.escapeSingleQuotes(eElg.Rpl_Include_Students_With_Offer_In__c)
                        : '';
                    crtWrap.excludeCompanies = !String.isEmpty(eElg.Rpl_Exclude_Students_With_Offer_In__c)
                        ? String.escapeSingleQuotes(eElg.Rpl_Exclude_Students_With_Offer_In__c)
                        : '';
                    crtWrap.tenthCgpaOperator = eElg.Rpl_Tenth_CGPA_Operator__c;
                    crtWrap.twelfthCgpaOperator = eElg.Rpl_12th_CGPA_Operator__c;
                    crtWrap.tenthPercentageOperator = eElg.Rpl_Tenth_Percentage_Operator__c;
                    crtWrap.twelfthPercentageOperator = eElg.Rpl_12th_Percentage_Operator__c;
                    crtWrap.diplomaAggregateOperator = eElg.Rpl_Diploma_Aggregate_Operator__c;
                    crtWrap.attendanceOperator = eElg.Rpl_Attendance_Operator__c;
                    crtWrap.currentBacklogOperator = eElg.Rpl_Current_Backlogs_Operator__c;
                    crtWrap.totalBacklogOperator = eElg.Rpl_Total_Backlogs_Operator__c;
                    crtWrap.gapYearsOperator = eElg.Rpl_Gap_Years_Operator__c;
                    crtWrap.UGCgpaOperator = eElg.Rpl_UG_CGPA_Operator__c;
                    crtWrap.PGCgpaOperator = eElg.Rpl_PG_CGPA_Operator__c;
                    crtWrap.UgPercentageOperator = eElg.Rpl_UG_Percentage_Operator__c;
                    crtWrap.PgPercentageOperator = eElg.Rpl_PG_Percentage_Operator__c;
                    crtWrap.offerCountOperator = eElg.Rpl_Offer_Count_Operator__c;
                    crtWrap.tenthCGPA = eElg.Rpl_Tenth_CGPA__c;
                    crtWrap.twelveCGPA = eElg.Rpl_Twelveth_CGPA__c;
                    crtWrap.UgCGPA = eElg.Rpl_UG_CGPA__c;
                    crtWrap.PgCGPA = eElg.Rpl_PG_CGPA__c;
                    crtWrap.diplomaAggregate = eElg.Rpl_Diploma_Aggregate__c;
                    crtWrap.isPlacementInterest = eElg.Rpl_Placement_Interest__c;
                }
            }
            if (!String.isEmpty(crtWrap.specializationType)) {
                crtWrap.specialization = crtWrap.specializationType.split(',');
            } else {
                crtWrap.specialization = new List<String>();
            }

            if (!placeDriveIdMap.isEmpty()) {
                // If it's an update event, delete existing student registration drive records
                if (isUpdate == true) {
                    List<Rpl_Student_Registration_Drive__c> stdRegDrve = [
                        SELECT Rpl_Student_Registration__c, Rpl_Placement_Drive__c
                        FROM Rpl_Student_Registration_Drive__c
                        WHERE Rpl_Placement_Drive__c IN :placeDriveIdMap.keySet()
                    ];
                    system.debug('stdRegDrve are'+stdRegDrve);
                    if (stdRegDrve.size() > 0) {
                        delete stdRegDrve;
                    }
                }
                System.debug('In line 79');
                Set<Id> revaPlacementDriveIdSet = new Set<Id>();
                for (Rpl_Placement_Drive__c ePlceDrve : [
                    SELECT
                        ID,
                        Reva_Placement__r.Id
                    FROM Rpl_Placement_Drive__c
                    WHERE ID IN :placeDriveIdMap.keySet()
                ]) {
                    if (ePlceDrve.Reva_Placement__r != null && ePlceDrve.Reva_Placement__r.Id != null) {
                        revaPlacementDriveIdSet.add(ePlceDrve.Reva_Placement__r.Id);
                    }
                }

                if (!revaPlacementDriveIdSet.isEmpty()) {
                    String userOrGroupsIdString = String.join(new Set<Id>(revaPlacementDriveIdSet), '\',\'');

                    String query = 'SELECT ID, Contact__c, Rpl_Companies_Got_Placed_In__c FROM Rpl_Student_Registration__c';

                    query += ' WHERE (( Reva_Placement__c IN (\'' + userOrGroupsIdString + '\') ';

                    // Apply criteria based on student verification status
                    if (crtWrap.studentVerificationStatus == 'Include Verified Students Only') {
                        query += ' AND Rpl_Status__c = \'Registration Successfully\' ';
                    }
                    // Apply gender criteria
                    if (!String.isEmpty(crtWrap.gender)) {
                        if (crtWrap.gender == 'Male') {
                            query += ' AND Rpl_Gender__c = \'Male\' ';
                        } else if (crtWrap.gender == 'Female') {
                            query += ' AND Rpl_Gender__c = \'Female\' ';
                        }
                    }
                    // Apply specialization criteria
                    if (!crtWrap.specialization.isEmpty()) {
                        String specialization = String.join(crtWrap.specialization, '\',\'');
                        query += ' AND Rpl_Branch_Name__c IN (\'' + specialization + '\') ';
                    }
                    // Apply placement interest criteria
                    if (crtWrap.isPlacementInterest) {
                        query += ' AND Rpl_Interested_in_placement__c = \'Yes\' ';
                    }

                    System.debug('Query ' + query);
                    List<String> conditions = new List<String>();
                    // Build conditions for academic criteria
                    conditions.add(
                        '( Rpl_10th_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.tenthPercentageOperator, crtWrap.tenthPercentage) +
                        ' OR Rpl_Tenth_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.tenthCgpaOperator, crtWrap.tenthCGPA) +
                        ' )'
                    );
                    conditions.add(
                        '( Rpl_12th_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.twelfthPercentageOperator, crtWrap.twelvePercentage) +
                        ' OR Rpl_Twelfth_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.twelfthCgpaOperator, crtWrap.twelveCGPA) +
                        ' OR Rpl_Diploma_Percentage__c' +
                        getGreaterThanQueryString(
                            crtWrap.diplomaAggregateOperator,
                            crtWrap.diplomaAggregate
                        ) +
                        ' )'
                    );
                    conditions.add(
                        '( Rpl_UG_Overall_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.UgPercentageOperator, crtWrap.UGPercentage) +
                        ' OR Rpl_UG_Overall_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.UGCgpaOperator, crtWrap.UgCGPA) +
                        ' )'
                    );
                    conditions.add(
                        '( Rpl_PG_Overall_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.PgPercentageOperator, crtWrap.PGPercentage) +
                        ' OR Rpl_PG_OVerall_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.PGCgpaOperator, crtWrap.PgCGPA) +
                        ' )'
                    );
                    conditions.add(
                        ' Rpl_Current_Backlogs__c' +
                        getLesserThanQueryString(crtWrap.currentBacklogOperator, crtWrap.currentBackLog)
                    );
                    conditions.add(
                        ' Rpl_Total_Backlogs__c' +
                        getLesserThanQueryString(crtWrap.totalBacklogOperator, crtWrap.totalBacklogs)
                    );
                    conditions.add(
                        ' Rpl_Education_Gap__c' +
                        getLesserThanQueryString(crtWrap.gapYearsOperator, crtWrap.gapYear)
                    );

                    // Append conditions to the query
                    for (String eStr : conditions) {
                        if (!String.isEmpty(eStr)) {
                            System.debug('Query ' + query);
                            query += ' AND ' + eStr;
                        }
                    }

                    // Close the parentheses of the initial WHERE clause
                    query += '))';
                    dynamicQuery = query;

                    System.debug('Query ' + query);

                    // Execute the query to get student registrations
                    List<Rpl_Student_Registration__c> studentRegistrations = Database.query(query);
                    system.debug('registration result'+studentRegistrations);

                    if (studentRegistrations.isEmpty()) {
                        Rpl_Eligibility__c eligibility = new Rpl_Eligibility__c(Id = eligibilityList[0].ID);
                        eligibility.Rpl_Dynamic_Query__c = dynamicQuery;
                        update eligibility;
                        return null;
                    }

                    Set<Id> studentRegIds = new Set<Id>();
                    Set<Id> contactIds = new Set<Id>();

                    Map<Id, Rpl_Student_Registration__c> studentRegMap = new Map<Id, Rpl_Student_Registration__c>();

                    for (Rpl_Student_Registration__c eStd : studentRegistrations) {
                        studentRegIds.add(eStd.Id);
                        contactIds.add(eStd.Contact__c);
                        studentRegMap.put(eStd.Id, eStd);
                    }
					system.debug('studentRegMap result'+studentRegMap);
                    // Process payment status criteria
                    if (crtWrap.paymentStatus == 'Exclude Students With Payment Pending') {
                        studentRegIds.clear();
                        List<Contact> contactList = [
                            SELECT
                                Id,
                                (SELECT Id FROM Student_Registrations__r),
                                (SELECT Id FROM Student_Fees__r WHERE Amount_Pending__c > 0)
                            FROM Contact
                            WHERE Id IN :contactIds
                        ];
                        if (!contactList.isEmpty()) {
                            for (Contact eachContact : contactList) {
                                // Include students without pending fees
                                if (eachContact.Student_Fees__r.size() == 0 && eachContact.Student_Registrations__r.size() > 0) {
                                    studentRegIds.add(eachContact.Student_Registrations__r[0].Id);
                                }
                            }
                        }
                        // Update studentRegMap to include only students without pending fees
                        Map<Id, Rpl_Student_Registration__c> filteredStudentRegMap = new Map<Id, Rpl_Student_Registration__c>();
                        for (Id eStdId : studentRegIds) {
                            filteredStudentRegMap.put(eStdId, studentRegMap.get(eStdId));
                        }
                        studentRegMap = filteredStudentRegMap;
                    }

                    if (studentRegIds.isEmpty()) {
                        return null;
                    }

                    // Create a list of student registration drive records
                    List<Rpl_Student_Registration_Drive__c> stdRegDriveList = new List<Rpl_Student_Registration_Drive__c>();

                    for (Id eStdId : studentRegIds) {
                        Rpl_Student_Registration_Drive__c stdReg = new Rpl_Student_Registration_Drive__c();
                        stdReg.Rpl_Student_Registration__c = eStdId;
                        stdReg.Rpl_Placement_Drive__c = crtWrap.placementDriveId;
                        stdRegDriveList.add(stdReg);
                    }

                    if (!stdRegDriveList.isEmpty()) {
                        // Build sets for included and excluded companies
                        Set<String> includedCompaniesSet = new Set<String>();
                        if (!String.isEmpty(crtWrap.includeCompanies)) {
                            includedCompaniesSet.addAll(crtWrap.includeCompanies.split(','));
                        }

                        Set<String> excludedCompaniesSet = new Set<String>();
                        if (!String.isEmpty(crtWrap.excludeCompanies)) {
                            excludedCompaniesSet.addAll(crtWrap.excludeCompanies.split(','));
                        }

                        List<Rpl_Student_Registration_Drive__c> filteredStdRegDriveList = new List<Rpl_Student_Registration_Drive__c>();

                        for (Rpl_Student_Registration_Drive__c stdRegDrive : stdRegDriveList) {
                            Rpl_Student_Registration__c stdReg = studentRegMap.get(stdRegDrive.Rpl_Student_Registration__c);

                            String companiesGotPlacedIn = stdReg.Rpl_Companies_Got_Placed_In__c;

                            Set<String> studentCompanies = new Set<String>();

                            if (!String.isEmpty(companiesGotPlacedIn)) {
                                studentCompanies.addAll(companiesGotPlacedIn.split(';'));
                            }

                            Boolean includeStudent = true;

                            if (!includedCompaniesSet.isEmpty()) {
                                // Include only students who have offers from included companies
                                Set<String> tempSet = new Set<String>(studentCompanies);
                                tempSet.retainAll(includedCompaniesSet);
                                if (!tempSet.isEmpty()) {
                                    includeStudent = true;
                                } else {
                                    includeStudent = false;
                                }
                            }

                            if (!excludedCompaniesSet.isEmpty()) {
                                // Exclude students who have offers from excluded companies
                                Set<String> tempSet = new Set<String>(studentCompanies);
                                tempSet.retainAll(excludedCompaniesSet);
                                if (!tempSet.isEmpty()) {
                                    includeStudent = false;
                                }
                            }

                            if (includeStudent) {
                                filteredStdRegDriveList.add(stdRegDrive);
                            }
                        }

                        // Insert the filtered student registration drive records
                        if (!filteredStdRegDriveList.isEmpty()) {
                            insert filteredStdRegDriveList;
                        }
                    }
                }
            }
            // Update the eligibility record with the dynamic query
            Rpl_Eligibility__c eligibility = new Rpl_Eligibility__c(Id = eligibilityList[0].ID);
            eligibility.Rpl_Dynamic_Query__c = dynamicQuery;
            update eligibility;

        } catch (Exception e) {
            System.debug('Exception ' + e.getMessage() + ' Line ' + e.getLineNumber());
            ErrorLogUtility.logError(e);
        }
        return null;
    }

    // Helper method to construct greater than query strings
    public static String getGreaterThanQueryString(String operator, Decimal value) {
        String query = '';
        query += String.isEmpty(operator) ? '>= ' : operator + ' ';
        query += (value == null) ? '0 ' : String.valueOf(value) + ' ';
        return query;
    }

    // Helper method to construct less than query strings
    public static String getLesserThanQueryString(String operator, Decimal value) {
        String query = '';
        query += String.isEmpty(operator) ? '<= ' : operator + ' ';
        query += (value == null) ? '0 ' : String.valueOf(value) + ' ';
        return query;
    }

    /**
     * Wrapper class to hold criteria values.
     */
    public class CriteriaWrapperClass {
        public Boolean isPlacementInterest;
        public String specializationType;
        public String studentVerificationStatus;
        public String paymentStatus;
        public List<String> specialization;
        public Decimal tenthPercentage;
        public Decimal twelvePercentage;
        public Decimal tenthCGPA;
        public Decimal twelveCGPA;
        public Decimal UGPercentage;
        public Decimal PGPercentage;
        public Decimal UgCGPA;
        public Decimal PgCGPA;
        public Decimal currentBackLog;
        public Decimal yearback;
        public Decimal totalBacklogs;
        public String gender;
        public Decimal OfferCount;
        public Id placementDriveId;
        public String includeCompanies;
        public String excludeCompanies;
        public Decimal gapYear;
        public Boolean placementInterest;
        public Decimal attendance;
        public String tenthCgpaOperator;
        public String twelfthCgpaOperator;
        public String tenthPercentageOperator;
        public String twelfthPercentageOperator;
        public String diplomaAggregateOperator;
        public String attendanceOperator;
        public String currentBacklogOperator;
        public String totalBacklogOperator;
        public String gapYearsOperator;
        public String UGCgpaOperator;
        public String PGCgpaOperator;
        public String UgPercentageOperator;
        public String PgPercentageOperator;
        public String offerCountOperator;
        public Decimal diplomaAggregate;
    }
}
















/*public class RPL_EligibilityHandlerClass {
    public static String getPlacementDriveId(
        List<Rpl_Eligibility__c> eligibilityList,
        Boolean isUpdate
    ) {
        String dynamicQuery = '';
        try {
            System.debug('Rpl_Recursive_Controller.isAlreadyExecuted ' + Rpl_Recursive_Controller.isAlreadyExecuted);
            System.debug('Inside Method');
            Map<Id, Rpl_Eligibility__c> placeDriveIdMap = new Map<Id, Rpl_Eligibility__c>();
            CriteriaWrapperClass crtWrap = new CriteriaWrapperClass();

            // Populate the criteria wrapper with values from the eligibility list
            for (Rpl_Eligibility__c eElg : eligibilityList) {
                if (!String.isEmpty(eElg.Rpl_Placement_Drive__c)) {
                    System.debug(eElg);
                    placeDriveIdMap.put(eElg.Rpl_Placement_Drive__c, eElg);
                    // Populate criteria wrapper class
                    crtWrap.tenthPercentage = eElg.Rpl_Tenth_Percentage__c;
                    crtWrap.studentVerificationStatus = eElg.Rpl_Verification_Status_Of_Student__c;
                    crtWrap.paymentStatus = eElg.Rpl_Fee_Payment_Status__c;
                    crtWrap.twelvePercentage = eElg.Rpl_Twelveth_Percentage__c;
                    crtWrap.UGPercentage = eElg.Rpl_UG_Percentage1__c;
                    crtWrap.PGPercentage = eElg.Rpl_PG_Percentage1__c;
                    crtWrap.currentBackLog = eElg.Rpl_Current_Backlogs__c;
                    crtWrap.specializationType = eElg.Rpl_Specialization__c;
                    crtWrap.totalBacklogs = eElg.Rpl_Total_Backlogs__c;
                    crtWrap.gender = eElg.Gender__c;
                    crtWrap.OfferCount = eElg.Offer_Count__c;
                    crtWrap.placementDriveId = eElg.Rpl_Placement_Drive__c;
                    crtWrap.gapYear = eElg.Rpl_Gap_Years__c;
                    crtWrap.placementInterest = eElg.Rpl_Placement_Interest__c;
                    crtWrap.attendance = eElg.Rpl_Attendance_Percentage__c;
                    crtWrap.includeCompanies = !String.isEmpty(eElg.Rpl_Include_Students_With_Offer_In__c)
                        ? String.escapeSingleQuotes(eElg.Rpl_Include_Students_With_Offer_In__c)
                        : '';
                    crtWrap.excludeCompanies = !String.isEmpty(eElg.Rpl_Exclude_Students_With_Offer_In__c)
                        ? String.escapeSingleQuotes(eElg.Rpl_Exclude_Students_With_Offer_In__c)
                        : '';
                    crtWrap.tenthCgpaOperator = eElg.Rpl_Tenth_CGPA_Operator__c;
                    crtWrap.twelfthCgpaOperator = eElg.Rpl_12th_CGPA_Operator__c;
                    crtWrap.tenthPercentageOperator = eElg.Rpl_Tenth_Percentage_Operator__c;
                    crtWrap.twelfthPercentageOperator = eElg.Rpl_12th_Percentage_Operator__c;
                    crtWrap.diplomaAggregateOperator = eElg.Rpl_Diploma_Aggregate_Operator__c;
                    crtWrap.attendanceOperator = eElg.Rpl_Attendance_Operator__c;
                    crtWrap.currentBacklogOperator = eElg.Rpl_Current_Backlogs_Operator__c;
                    crtWrap.totalBacklogOperator = eElg.Rpl_Total_Backlogs_Operator__c;
                    crtWrap.gapYearsOperator = eElg.Rpl_Gap_Years_Operator__c;
                    crtWrap.UGCgpaOperator = eElg.Rpl_UG_CGPA_Operator__c;
                    crtWrap.PGCgpaOperator = eElg.Rpl_PG_CGPA_Operator__c;
                    crtWrap.UgPercentageOperator = eElg.Rpl_UG_Percentage_Operator__c;
                    crtWrap.PgPercentageOperator = eElg.Rpl_PG_Percentage_Operator__c;
                    crtWrap.offerCountOperator = eElg.Rpl_Offer_Count_Operator__c;
                    crtWrap.tenthCGPA = eElg.Rpl_Tenth_CGPA__c;
                    crtWrap.twelveCGPA = eElg.Rpl_Twelveth_CGPA__c;
                    crtWrap.UgCGPA = eElg.Rpl_UG_CGPA__c;
                    crtWrap.PgCGPA = eElg.Rpl_PG_CGPA__c;
                    crtWrap.diplomaAggregate = eElg.Rpl_Diploma_Aggregate__c;
                    crtWrap.isPlacementInterest = eElg.Rpl_Placement_Interest__c;
                }
            }
            if (!String.isEmpty(crtWrap.specializationType)) {
                crtWrap.specialization = crtWrap.specializationType.split(',');
            } else {
                crtWrap.specialization = new List<String>();
            }

            if (!placeDriveIdMap.isEmpty()) {
                // If it's an update event, delete existing student registration drive records
                if (isUpdate == true) {
                    List<Rpl_Student_Registration_Drive__c> stdRegDrve = [
                        SELECT Rpl_Student_Registration__c, Rpl_Placement_Drive__c
                        FROM Rpl_Student_Registration_Drive__c
                        WHERE Rpl_Placement_Drive__c IN :placeDriveIdMap.keySet()
                    ];
                    if (stdRegDrve.size() > 0) {
                        delete stdRegDrve;
                    }
                }
                System.debug('In line 79');
                Set<Id> revaPlacementDriveIdSet = new Set<Id>();
                for (Rpl_Placement_Drive__c ePlceDrve : [
                    SELECT
                        ID,
                        Reva_Placement__r.Id
                    FROM Rpl_Placement_Drive__c
                    WHERE ID IN :placeDriveIdMap.keySet()
                ]) {
                    system.debug('reva placement drive'+ePlceDrve);
                    if (ePlceDrve.Reva_Placement__r != null && ePlceDrve.Reva_Placement__r.Id != null) {
                        revaPlacementDriveIdSet.add(ePlceDrve.Reva_Placement__r.Id);
                    }
                }
           

                if (!revaPlacementDriveIdSet.isEmpty()) {
                     List<String> revaPlacementDriveIdList = new List<String>();
                    for (Id driveId : revaPlacementDriveIdSet) {
                        revaPlacementDriveIdList.add((String)driveId);
                    }
                    system.debug('placement drive ids==>'+revaPlacementDriveIdList);
                    String userOrGroupsIdString = String.join(new List<Id>(revaPlacementDriveIdSet), '\',\'');

                    String query = 'SELECT ID, Contact__c, Rpl_Companies_Got_Placed_In__c FROM Rpl_Student_Registration__c';

                    query += ' WHERE (( Reva_Placement__c IN (\'' + userOrGroupsIdString + '\') ';

                    // Apply criteria based on student verification status
                    if (crtWrap.studentVerificationStatus == 'Include Verified Students Only') {
                        query += ' AND Rpl_Status__c = \'Registration Successfully\' ';
                    }
                    // Apply gender criteria
                    if (!String.isEmpty(crtWrap.gender)) {
                        if (crtWrap.gender == 'Male') {
                            query += ' AND Rpl_Gender__c = \'Male\' ';
                        } else if (crtWrap.gender == 'Female') {
                            query += ' AND Rpl_Gender__c = \'Female\' ';
                        }
                    }
                    // Apply specialization criteria
                    if (!crtWrap.specialization.isEmpty()) {
                        String specialization = String.join(crtWrap.specialization, '\',\'');
                        query += ' AND Rpl_Branch_Name__c IN (\'' + specialization + '\') ';
                    }
                    // Apply placement interest criteria
                    if (crtWrap.isPlacementInterest) {
                        query += ' AND Rpl_Interested_in_placement__c = \'Yes\' ';
                    }

                    System.debug('Query ' + query);
                    List<String> conditions = new List<String>();
                    // Build conditions for academic criteria
                    conditions.add(
                        '( Rpl_10th_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.tenthPercentageOperator, crtWrap.tenthPercentage) +
                        ' OR Rpl_Tenth_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.tenthCgpaOperator, crtWrap.tenthCGPA) +
                        ' )'
                    );
                    conditions.add(
                        '( Rpl_12th_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.twelfthPercentageOperator, crtWrap.twelvePercentage) +
                        ' OR Rpl_Twelfth_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.twelfthCgpaOperator, crtWrap.twelveCGPA) +
                        ' OR Rpl_Diploma_Percentage__c' +
                        getGreaterThanQueryString(
                            crtWrap.diplomaAggregateOperator,
                            crtWrap.diplomaAggregate
                        ) +
                        ' )'
                    );
                    conditions.add(
                        '( Rpl_UG_Overall_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.UgPercentageOperator, crtWrap.UGPercentage) +
                        ' OR Rpl_UG_Overall_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.UGCgpaOperator, crtWrap.UgCGPA) +
                        ' )'
                    );
                    conditions.add(
                        '( Rpl_PG_Overall_Percentage__c' +
                        getGreaterThanQueryString(crtWrap.PgPercentageOperator, crtWrap.PGPercentage) +
                        ' OR Rpl_PG_OVerall_CGPA__c' +
                        getGreaterThanQueryString(crtWrap.PGCgpaOperator, crtWrap.PgCGPA) +
                        ' )'
                    );
                    conditions.add(
                        ' Rpl_Current_Backlogs__c' +
                        getLesserThanQueryString(crtWrap.currentBacklogOperator, crtWrap.currentBackLog)
                    );
                    conditions.add(
                        ' Rpl_Total_Backlogs__c' +
                        getLesserThanQueryString(crtWrap.totalBacklogOperator, crtWrap.totalBacklogs)
                    );
                    conditions.add(
                        ' Rpl_Education_Gap__c' +
                        getLesserThanQueryString(crtWrap.gapYearsOperator, crtWrap.gapYear)
                    );

                    // Append conditions to the query
                    for (String eStr : conditions) {
                        if (!String.isEmpty(eStr)) {
                            System.debug('Query ' + query);
                            query += ' AND ' + eStr;
                        }
                    }

                    // Close the parentheses of the initial WHERE clause
                    query += '))';
                    dynamicQuery = query;

                    System.debug('Query ' + query);

                    // Execute the query to get student registrations
                    List<Rpl_Student_Registration__c> studentRegistrations = Database.query(query);

                    if (studentRegistrations.isEmpty()) {
                        Rpl_Eligibility__c eligibility = new Rpl_Eligibility__c(Id = eligibilityList[0].ID);
                        eligibility.Rpl_Dynamic_Query__c = dynamicQuery;
                        update eligibility;
                        return null;
                    }
				     //new code added
                    Set<Id> studentRegIds = new Set<Id>();
                    Set<Id> contactIds = new Set<Id>();

                    Map<Id, Rpl_Student_Registration__c> studentRegMap = new Map<Id, Rpl_Student_Registration__c>();

                    for (Rpl_Student_Registration__c eStd : studentRegistrations) {
                        studentRegIds.add(eStd.Id);
                        contactIds.add(eStd.Contact__c);
                        studentRegMap.put(eStd.Id, eStd);
                    }

                    if (crtWrap.paymentStatus == 'Exclude Students With Payment Pending') {
                        studentRegIds.clear();
                        List<Contact> contactList = [
                            SELECT
                                Id,
                                (SELECT Id FROM Student_Registrations__r),
                                (SELECT Id FROM Student_Fees__r WHERE Amount_Pending__c > 0)
                            FROM Contact
                            WHERE Id IN :contactIds
                        ];
                        if (!contactList.isEmpty()) {
                            for (Contact eachContact : contactList) {
                                // Include students without pending fees
                                if (eachContact.Student_Fees__r.size() == 0 && eachContact.Student_Registrations__r.size() > 0) {
                                    studentRegIds.add(eachContact.Student_Registrations__r[0].Id);
                                }
                            }
                        }
                        // Update studentRegMap to include only students without pending fees
                        Map<Id, Rpl_Student_Registration__c> filteredStudentRegMap = new Map<Id, Rpl_Student_Registration__c>();
                        for (Id eStdId : studentRegIds) {
                            filteredStudentRegMap.put(eStdId, studentRegMap.get(eStdId));
                        }
                        studentRegMap = filteredStudentRegMap;
                    }

                    if (studentRegIds.isEmpty()) {
                        return null;
                    }

                    // Create a list of student registration drive records
                    List<Rpl_Student_Registration_Drive__c> stdRegDriveList = new List<Rpl_Student_Registration_Drive__c>();

                    for (Id eStdId : studentRegIds) {
                        Rpl_Student_Registration_Drive__c stdReg = new Rpl_Student_Registration_Drive__c();
                        stdReg.Rpl_Student_Registration__c = eStdId;
                        stdReg.Rpl_Placement_Drive__c = crtWrap.placementDriveId;
                        stdRegDriveList.add(stdReg);
                    }

                    if (!stdRegDriveList.isEmpty()) {
                        // Build sets for included and excluded companies
                        Set<String> includedCompaniesSet = new Set<String>();
                        if (!String.isEmpty(crtWrap.includeCompanies)) {
                            includedCompaniesSet.addAll(crtWrap.includeCompanies.split(','));
                        }

                        Set<String> excludedCompaniesSet = new Set<String>();
                        if (!String.isEmpty(crtWrap.excludeCompanies)) {
                            excludedCompaniesSet.addAll(crtWrap.excludeCompanies.split(','));
                        }

                        List<Rpl_Student_Registration_Drive__c> filteredStdRegDriveList = new List<Rpl_Student_Registration_Drive__c>();

                        for (Rpl_Student_Registration_Drive__c stdRegDrive : stdRegDriveList) {
                            Rpl_Student_Registration__c stdReg = studentRegMap.get(stdRegDrive.Rpl_Student_Registration__c);

                            String companiesGotPlacedIn = stdReg.Rpl_Companies_Got_Placed_In__c;

                            Set<String> studentCompanies = new Set<String>();

                            if (!String.isEmpty(companiesGotPlacedIn)) {
                                studentCompanies.addAll(companiesGotPlacedIn.split(';'));
                            }

                            Boolean includeStudent = true;

                            if (!includedCompaniesSet.isEmpty()) {
                                // Include only students who have offers from included companies
                                Set<String> tempSet = new Set<String>(studentCompanies);
                                tempSet.retainAll(includedCompaniesSet);
                                if (!tempSet.isEmpty()) {
                                    includeStudent = true;
                                } else {
                                    includeStudent = false;
                                }
                            }

                            if (!excludedCompaniesSet.isEmpty()) {
                                // Exclude students who have offers from excluded companies
                                Set<String> tempSet = new Set<String>(studentCompanies);
                                tempSet.retainAll(excludedCompaniesSet);
                                if (!tempSet.isEmpty()) {
                                    includeStudent = false;
                                }
                            }

                            if (includeStudent) {
                                filteredStdRegDriveList.add(stdRegDrive);
                            }
                        }

                        // Insert the filtered student registration drive records
                        if (!filteredStdRegDriveList.isEmpty()) {
                            insert filteredStdRegDriveList;
                        }
                    }
                }
            }
            // Update the eligibility record with the dynamic query
            Rpl_Eligibility__c eligibility = new Rpl_Eligibility__c(Id = eligibilityList[0].ID);
            eligibility.Rpl_Dynamic_Query__c = dynamicQuery;
            update eligibility;

        } catch (Exception e) {
            System.debug('Exception ' + e.getMessage() + ' Line ' + e.getLineNumber());
            ErrorLogUtility.logError(e);
        }
        return null;
    }

    // Helper method to construct greater than query strings
    public static String getGreaterThanQueryString(String operator, Decimal value) {
        String query = '';
        query += String.isEmpty(operator) ? '>= ' : operator + ' ';
        query += (value == null) ? '0 ' : String.valueOf(value) + ' ';
        return query;
    }

    // Helper method to construct less than query strings
    public static String getLesserThanQueryString(String operator, Decimal value) {
        String query = '';
        query += String.isEmpty(operator) ? '<= ' : operator + ' ';
        query += (value == null) ? '0 ' : String.valueOf(value) + ' ';
        return query;
    }

    /**
     * Wrapper class to hold criteria values.
     */
   /* public class CriteriaWrapperClass {
        public Boolean isPlacementInterest;
        public String specializationType;
        public String studentVerificationStatus;
        public String paymentStatus;
        public List<String> specialization;
        public Decimal tenthPercentage;
        public Decimal twelvePercentage;
        public Decimal tenthCGPA;
        public Decimal twelveCGPA;
        public Decimal UGPercentage;
        public Decimal PGPercentage;
        public Decimal UgCGPA;
        public Decimal PgCGPA;
        public Decimal currentBackLog;
        public Decimal yearback;
        public Decimal totalBacklogs;
        public String gender;
        public Decimal OfferCount;
        public Id placementDriveId;
        public String includeCompanies;
        public String excludeCompanies;
        public Decimal gapYear;
        public Boolean placementInterest;
        public Decimal attendance;
        public String tenthCgpaOperator;
        public String twelfthCgpaOperator;
        public String tenthPercentageOperator;
        public String twelfthPercentageOperator;
        public String diplomaAggregateOperator;
        public String attendanceOperator;
        public String currentBacklogOperator;
        public String totalBacklogOperator;
        public String gapYearsOperator;
        public String UGCgpaOperator;
        public String PGCgpaOperator;
        public String UgPercentageOperator;
        public String PgPercentageOperator;
        public String offerCountOperator;
        public Decimal diplomaAggregate;
    }
}*/