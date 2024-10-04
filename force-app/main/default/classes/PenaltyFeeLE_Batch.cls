global class PenaltyFeeLE_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        return Database.getQueryLocator([
            SELECT Id, Name, Student_Status__c, RecordTypeId, Program_Type__c, School_Name__c, Program_Batch_Name__c, Admission_Mode__c, Quota__c, Caste_Category__c, Active_Semester__r.hed__Start_Date__c,
            (SELECT Id, Name, Fee_Year__c, Fee_Type__c, Due_Date__c,Actual_Program_Fee__c, Session__c, Amount__c, Amount_Pending__c,Contact__r.Active_Semester__r.IA_1_Start_date__c,Contact__c,Program_Enrollment__r.hed__Program_Plan__c,Contact__r.Enrollment_Type__c
             FROM Student_Fees__r 
             WHERE Amount_Pending__c > 0 AND Fee_Type__c IN ('University Fee', 'Tuition Fee') and Fee_Year__c !='1st Year') 
            FROM Contact 
            WHERE Student_Status__c = 'Pursuing' AND RecordTypeId = :ContactRecTypeId AND Primary_Academic_Program_Name__c !='Bachelor of Commerce Sanjaynagar'
            AND (Admission_Mode__c NOT IN ('CET','DCET','PGCET') OR Quota__c !='Government Quota' OR Caste_Category__c NOT IN ('ST','SC'))
            AND Id = '0035j00000rPKCdAAO'
            AND Active_Semester__r.hed__Start_Date__c != null AND Active_Semester__r.Active__c = true             
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> ListCon) {
        List<Student_Fee__c> lst_UpStuFee = new List<Student_Fee__c>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<User> usersToUpdate = new List<User>();
        
        for(Contact con : ListCon)
        {
            Boolean paymentMade = True;
            Decimal Totalamount = 0;
            system.debug('Contact==='+con);
            Date startDate;
            Integer daysBetween = 0;
            string feetype;
            Set<Id> set_BatchIds = new Set<Id>();
            map<id,list<hed__Term__c>> map_term = new map<id,list<hed__Term__c>>();
            for (hed__Program_Enrollment__c objProgEnroll : [SELECT Id, Active__c, hed__Program_Plan__c, hed__Contact__c FROM hed__Program_Enrollment__c 
                                                             WHERE hed__Contact__c = :con.Id AND Active__c = true
                                                            ]) {
                                                                set_BatchIds.add(objProgEnroll.hed__Program_Plan__c);
                                                            }
            Map<Id, Student_Fee__c> existingPenaltyMap = new Map<Id, Student_Fee__c>();
            
            for (Student_Fee__c existingPenalty : [SELECT Id, Contact__c,Fee_Type__c,Due_Date__c, Amount_Pending__c, Actual_Program_Fee__c, Amount__c,Amount_Paid__c 
                                                   FROM Student_Fee__c WHERE Fee_Type__c =:'Penalty Fee' AND Contact__c =:con.id
                                                  ]) {
                                                      existingPenaltyMap.put(con.Id, existingPenalty);
                                                  }
            
            // Bulk query for user records
            Map<Id, User> userMap = new Map<Id, User>();
            
            for (User user : [
                SELECT Id, IsActive, ContactId FROM User WHERE ContactId =: con.Id
            ]) {
                userMap.put(con.id, user);
                
            }
            
            if(!set_BatchIds.isEmpty())
            {
                for(hed__Term__c objTerm : [Select Id,Name,Active__c,hed__Start_Date__c,IA_1_Start_date__c,IA_2_Start_date__c,Program_Batch__c,Term_Number__c from hed__Term__c 
                                            where Program_Batch__c in: set_BatchIds and Term_Number__c !=1])
                {
                    if(map_term.get(objTerm.Program_Batch__c) == null)
                    {
                        list<hed__Term__c> lst_term = new list<hed__Term__c>();
                        lst_term.add(objTerm);
                        map_term.put(objTerm.Program_Batch__c,lst_term);
                    }
                    else
                    {
                        map_term.get(objTerm.Program_Batch__c).add(objTerm);
                    }
                }
                for(Student_Fee__c objStu : con.Student_Fees__r)
                {
                    system.debug('fee list==='+objStu);
                    if (objStu.Contact__c != null && objStu.Contact__r.Active_Semester__r.IA_1_Start_date__c != null) {
                        system.debug('start date');
                        startDate = objStu.Contact__r.Active_Semester__r.IA_1_Start_date__c;
                        daysBetween = startDate.daysBetween(Date.today());
                    }
                    if(map_term.get(objStu.Program_Enrollment__r.hed__Program_Plan__c) != null)
                    {
                        System.debug('session');
                        List<String> strList = new list<String>();
                        if(objStu.Session__c != null)
                        {
                            strList = objStu.Session__c.split('');
                        }
                        for(hed__Term__c objTerm : map_term.get(objStu.Program_Enrollment__r.hed__Program_Plan__c))
                        {
                            if (!strList.isEmpty() && strList[0] == '2' && objTerm.Term_Number__c == 3 && objTerm.Active__c == true && objStu.Contact__r.Enrollment_Type__c == 'Lateral Entry') {
                                Totalamount += objStu.Amount_Pending__c;
                                feetype = objStu.Fee_Year__c;
                                system.debug('Totalamount2===' + Totalamount);
                                system.debug('2nd year');                            
                                                         
                            }
                        }
                    }
                }
                Set<Id> processedContactIds = new Set<Id>();
                if (Totalamount > 0) {
                    system.debug('TOTAL AMOUNT==='+Totalamount);
                    Decimal penaltyAmount = 0;
                    paymentMade = true; 
                    Integer daysWithinRange = daysBetween - 30;
                    system.debug('daysWithinRange==' + daysWithinRange);
                    system.debug('daysBetween==' + daysBetween);
                    system.debug('Totalamount===' + Totalamount);
                    Integer thisYear = Date.today().year();
                    // For days between 31 and 45
                    if (daysBetween > 0 && daysBetween <= 15) {
                        Decimal penaltyPerDay = 300;
                        penaltyAmount = penaltyPerDay * (daysBetween);
                        Date dueDate1 = startDate;
                        //  penaltyAmount = penaltyPerDay * daysWithinRange;
                        if (existingPenaltyMap.containsKey(con.Id)) {
                            Student_Fee__c existingPenalty = existingPenaltyMap.get(con.Id);
                             
                            Integer existingDaysDue = (existingPenalty.Amount__c / penaltyPerDay).intValue();
                            Integer newDaysDue = (penaltyAmount / penaltyPerDay).intValue();
                            system.debug('existingDaysDue===' + existingDaysDue);
                            system.debug('newDaysDue===' + newDaysDue);
                            if (newDaysDue > existingDaysDue) {
                                Integer additionalDays = newDaysDue - existingDaysDue;
                                Decimal additionalPenalty = additionalDays * penaltyPerDay;
                               
                                    existingPenalty.Amount_Pending__c += additionalPenalty;
                                    existingPenalty.Actual_Program_Fee__c += additionalPenalty;
                                    existingPenalty.Amount__c += additionalPenalty;
                                lst_UpStuFee.add(existingPenalty);
                                }
                                
                            
                        } else {
                            Student_Fee__c objNewStuFee = new Student_Fee__c(
                                Name = 'Penalty Fee '+thisYear,
                                Fee_Type__c = 'Penalty Fee', 
                                Contact__c = con.Id,
                                Amount__c = penaltyAmount,
                                Due_Date__c = dueDate1,
                                Session__c = feetype,
                                Fee_Year__c = feetype,
                                Amount_Pending__c = penaltyAmount,
                                Actual_Program_Fee__c = penaltyAmount
                            );
                            lst_UpStuFee.add(objNewStuFee);
                        } 
                    }
                    // For days between 46 and 60
                    else if (daysBetween > 15 && daysBetween <= 30) {
                        Integer daysWithinRange15to30 = daysBetween - 15;
                        Decimal penaltyPerDay = 500;
                        Decimal previousPenalty = 300 * 15;  // Penalty from days 31 to 45
                        penaltyAmount = previousPenalty + (penaltyPerDay * daysWithinRange15to30);
                        system.debug('penalty amount==='+penaltyAmount);
                        if (existingPenaltyMap.containsKey(con.Id)) {
                            Student_Fee__c existingPenalty = existingPenaltyMap.get(con.Id);
                            Decimal totalPaid = existingPenalty.Amount_Paid__c;
                          
                            Date todayDate = Date.today();
                            Date dueDate = existingPenalty.Due_Date__c;
                            //Integer newDaysDue = dueDate.daysBetween(todayDate);
                            //system.debug('Duedate days==='+newDaysDue);
                            
                            Integer existingDaysDue = (existingPenalty.Amount__c / penaltyPerDay).intValue();
                            Integer newDaysDue = (penaltyAmount / 500).intValue();
                            system.debug('existingDaysDue===' + existingDaysDue);
                            system.debug('newDaysDue===' + newDaysDue);
                            if (newDaysDue > existingDaysDue) {
                                Integer additionalDays = newDaysDue - existingDaysDue;
                                Decimal additionalPenalty = additionalDays * penaltyPerDay;
                               
                                    existingPenalty.Amount_Pending__c += additionalPenalty;
                                    existingPenalty.Actual_Program_Fee__c += additionalPenalty;
                                    existingPenalty.Amount__c += additionalPenalty;
                                 lst_UpStuFee.add(existingPenalty);
                                }
                               
                            }
                        } 
                    
                    else if (daysBetween > 30 && daysBetween <= 60) {
                        if (!processedContactIds.contains(con.Id)) {
                            Contact conup = new Contact(
                                Id = con.Id,
                                Attendance_Blocked__c = true
                            );
                            contactsToUpdate.add(conup);
                            processedContactIds.add(con.Id); // Add to set after adding to the list
                        }
                    } 
                    else if (daysBetween > 60) {
                        if (userMap.containsKey(con.Id)) {
                            User contactUser = userMap.get(con.Id);
                            if (contactUser != null && contactUser.IsActive) {
                                contactUser.IsActive = false;
                                usersToUpdate.add(contactUser);
                            }
                        }
                    }
                }
                if (paymentMade) {
                    if (!processedContactIds.contains(con.Id)) {
                        Contact conUpdate = new Contact(
                            Id = con.Id,
                            Attendance_Blocked__c = false
                        );
                        contactsToUpdate.add(conUpdate);
                        processedContactIds.add(con.Id); // Add to set after adding to the list
                    }
                }
                
                
            }
        }
        if (!lst_UpStuFee.isEmpty()) {
            try {
                upsert lst_UpStuFee;
            } catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug('Error on row ' + i + ': ' + e.getDmlMessage(i));
                }
                System.debug('DML exception: ' + e.getMessage());
            }
        }
        if (!contactsToUpdate.isEmpty()) {
            try {
                update contactsToUpdate;
            } catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug('Error on row ' + i + ': ' + e.getDmlMessage(i));
                }
                System.debug('DML exception: ' + e.getMessage());
            }
        }
        
        if (!usersToUpdate.isEmpty()) {
            try {
                update usersToUpdate;
            } catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug('Error on row ' + i + ': ' + e.getDmlMessage(i));
                }
                System.debug('DML exception: ' + e.getMessage());
            }
        }
        
        System.debug('records===' + lst_UpStuFee);
    }
    
    global void finish(Database.BatchableContext BC) {
        // Any cleanup or post-processing logic can be added here
    }
}