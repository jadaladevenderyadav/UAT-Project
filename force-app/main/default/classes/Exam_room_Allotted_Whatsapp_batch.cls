global class Exam_room_Allotted_Whatsapp_batch implements Database.Batchable<sobject>, Database.AllowsCallouts {

    // RecordIds property to store the input parameter
    public list<Id> RecordIds { get; set; }

    // Constructor to initialize RecordIds
    global Exam_room_Allotted_Whatsapp_batch(list<String> recordIds) {
        this.RecordIds = recordIds;
    }

    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
           select id ,name,Room__c, Facility_Type__r.Floor__c, Facility_Type__r.Block__c,Course_Name__c,
            IA_Type__c, rve_Date_of_Exam__c, Exam_Time__c, End_Time__c,Alloted_Students__c, InEligible_SRN__c 
            from IA_Seating_Room_Allotment__c 
            where Id = :RecordIds   
        ]);
    }

    // Execute method to process the records
    global void execute(Database.BatchableContext bc, List<IA_Seating_Room_Allotment__c> allotmentList) {
        try {
            // Lists to store data for notifications
           
                List<String> roomnumber = new List<String>();
                List<String> Floor = new List<String>();
                List<String> Block = new List<String>();
                List<String> coursename = new List<String>();
                List<String> examname = new List<String>();
                List<String> date1 = new List<String>();
                List<String> starttime = new List<String>();
                List<String> endtime = new List<String>();
                
                
                // Iterate through the records and gather data
        
         Map<Id,String>ProgramWithCourseName = new Map<Id,String>();


           list <hed_Time_Table_Line_Item__c> lineitemlist =[select id,name,Course__r.name,hed_Date__c, hed_Start_Time__c, 
                                                hed_End_Time__c, Reva_Exam_Notification__r.hed_Program_Batch__r.Name,
                                                Reva_Exam_Notification__r.hed_Program_Batch__c
                                                from hed_Time_Table_Line_Item__c where hed_Start_Time__c = :allotmentList[0].Exam_Time__c
                                                AND hed_Date__c = :allotmentList[0].rve_Date_of_Exam__c ];
                                                 

            for(hed_Time_Table_Line_Item__c lineitems : lineitemlist ){
                ProgramWithCourseName.put(lineitems.Reva_Exam_Notification__r.hed_Program_Batch__c, lineitems.Course__r.name);

            }                                  
                
                List<Contact> contactList = new List<Contact>();
                for (IA_Seating_Room_Allotment__c request : allotmentList) {
                    roomnumber.add(request.Room__c);
                    Floor.add(request.Facility_Type__r.Floor__c);
                    Block.add(request.Facility_Type__r.Block__c);
                    //coursename.add(request.Course_Name__c);
                    date1.add(String.valueOf(request.rve_Date_of_Exam__c));
                    starttime.add(parseTime(request.Exam_Time__c));
                    endtime.add(parseTime(request.End_Time__c));
                    
                // Check if the IA_Type__c is IA 1 or IA 2 and update examname accordingly
                if (request.IA_Type__c == 'IA 1') {
                    examname.add('Internal Assessment- 1');
                } else if (request.IA_Type__c == 'IA 2') {
                    examname.add('Internal Assessment- 2');
                }
                
                // Query to fetch related contacts
                Set<String> AllSRN = new Set<String>();
                       Set<String> SRNNumbers = new Set<String>();
                       Set<String> SRNNumbers1 = new Set<String>();
                       
                       if (request.Alloted_Students__c != null) {
                           SRNNumbers.addAll(new Set<String>(request.Alloted_Students__c.split(',')));
                       }
                       
                     /*  if (request.InEligible_SRN__c != null) {
                           SRNNumbers1.addAll(new Set<String>(request.InEligible_SRN__c.split(',')));
                       }
                       */
                       AllSRN.addAll(SRNNumbers);
                     //  AllSRN.addAll(SRNNumbers1);
                       
                    //   System.debug('ineligible: ' + SRNNumbers1);
                       System.debug('eligible: ' + SRNNumbers);
                       System.debug('all: ' + AllSRN);
                       
                       List<Contact> roomContacts = [SELECT Id, Name, Email,MobilePhone, SRN_Number__c,
                                                     Program_Batch__r.Name, Program_Batch__c
                                                     FROM Contact
                                                     WHERE SRN_Number__c IN :AllSRN
                                                     AND Active__c = TRUE
                                                     AND MobilePhone != null];
                       
                       contactList.addAll(roomContacts);
            }
                          
            // Fetching template details
            String templateId = 'room_allotment_notification_student';
        
         
            // Iterate through contacts to create notifications
            for (Contact clist : contactList) {
                
                system.debug(clist.Name+'<<>>'+clist.MobilePhone);
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();

                // Set dynamic values for each key based on related record
                // notification.params.put('name', con.Name);
                notification.params.put('studentname',clist.Name );
                notification.params.put('roomnumber', String.join(roomnumber, ','));
                notification.params.put('Floor', String.join(Floor, ','));
                notification.params.put('Block', String.join(Block, ','));
                //notification.params.put('coursename', String.join(ProgramWithCourseName.get(clist.Program_Batch__c),','));
                // Assuming ProgramWithCourseName.get returns a List<String>
                List<String> courseNames = new List<String>();

                courseNames.add(ProgramWithCourseName.get(clist.Program_Batch__c)); 
                // Use ternary operator to check if courseNames is not null and then join; otherwise, set default text
                String courseNameString = (courseNames != null) ? String.join(courseNames, ',') : 'No course names available';
 
                // Now you can use courseNameString as needed, for example adding it to notification params
                notification.params.put('coursename', courseNameString);
                notification.params.put('endtime', String.join(endtime, ','));
                notification.params.put('starttime', String.join(starttime, ','));
                notification.params.put('date', String.join(date1, ','));
                notification.params.put('examname', String.join(examname, ','));
                
                   // Map to store notifications for each contact's phone number
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

                // Add notification to map
                phoneNumbersToNotifications.put(clist.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                
                //Send Whatsapp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> '+response);
            }

            ///////////////////////////// SMS Notification /////////////////////////////////

            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        
           // List<Contact>ContactList = new List<Contact>();
            
            for(IA_Seating_Room_Allotment__c IA : allotmentList)
            {
                List<String> allotedSRNs = IA.Alloted_Students__c != null ? IA.Alloted_Students__c.split(',') : new List<String>();
              //  List<String> InEligibleSRNs = IA.InEligible_SRN__c != null ? IA.InEligible_SRN__c.split(',') : new List<String>();
    
                Set<String> srnsToQuery = new Set<String>();
                srnsToQuery.addAll(allotedSRNs);
              //  srnsToQuery.addAll(InEligibleSRNs);
                
              List<Contact>ContactList1 = [SELECT Id, Name, SRN_Number__c, Program_Batch__c,MobilePhone,Father_Mobile_Number__c,Father_Name__c
                               FROM Contact 
                               WHERE SRN_Number__c != null 
                               AND SRN_Number__c IN :srnsToQuery AND Program_Batch__c!=null
                               ORDER BY SRN_Number__c];
                
                if(!ContactList1.isEmpty())
                {
                    for(Contact con : contactList1) {
                        String phoneNumber = con.MobilePhone; 
                        
                        String formattedDate = (String.valueOf(IA.rve_Date_of_Exam__c.format()));
                      //  System.debug('Formatted Date: ' + formattedDate);
                        
                        String FormattedStartTime = parseTime(IA.Exam_Time__c);
                        String FormattedEndTime = parseTime(IA.End_Time__c);
                        String IAType = IA.IA_Type__c=='IA 1'?'Internal Assessment- 1':'Internal Assessment- 2';
                        
                        String message = 'Dear '+con.Name+', You have been allotted to Room: '+IA.name+', '+IA.Facility_Type__r.Floor__c+', '+IA.Facility_Type__r.Block__c+' for the '+ProgramWithCourseName.get(con.Program_Batch__c)+' '+IAType+' on '+formattedDate+', '+FormattedStartTime+'-'+FormattedEndTime+'. REVA University';
                        
                        if(phoneNumber != null && message != null){
                            SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                            shrtMessage.dltContentId = '1007436787716273695';
                            shrtMessage.message = message;
                            shrtMessage.recipient = phoneNumber;
                            messageList.add(shrtMessage);
                        }
                    }
                    
                }
                
            }
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Room Allotment', messageList);
            }


            ///////////////////////////// Email Notification ///////////////////////////////

            List<Messaging.SingleEmailMessage> sendemaillist = new List<Messaging.SingleEmailMessage>();

              for (IA_Seating_Room_Allotment__c request : allotmentList) {
                    
                // Check if the IA_Type__c is IA 1 or IA 2 and update examname accordingly
                String IAType = request.IA_Type__c == 'IA 1'?'Internal Assessment- 1':request.IA_Type__c == 'IA 2'?'Internal Assessment- 2':'IA';
                
                // Query to fetch related contacts
                Set<String> AllSRN = new Set<String>();
                       
                       if (request.Alloted_Students__c != null) {
                           AllSRN.addAll(new Set<String>(request.Alloted_Students__c.split(',')));
                       }
                    
                       System.debug('all: ' + AllSRN);
                       
                       List<Contact> roomContacts = [SELECT Id, Name, Email,MobilePhone, SRN_Number__c,
                                                     Program_Batch__r.Name, Program_Batch__c
                                                     FROM Contact
                                                     WHERE SRN_Number__c IN :AllSRN
                                                     AND Active__c = TRUE
                                                     AND MobilePhone != null and Email!=null];

                System.debug('170=> '+parseDate(request.rve_Date_of_Exam__c)+', '+parseTime(request.Exam_Time__c));
                String subject =  IAType+' Class Allotment Details for '+''+parseDate(request.rve_Date_of_Exam__c)+', '+parseTime(request.Exam_Time__c)+' -'+parseTime(request.End_Time__c);
                for(Contact con : roomContacts)
                {
                    String Body = '<!DOCTYPE html>' +
                    '<html>' +
                    '<head>' +
                    '<meta charset="utf-8">' +
                    '</head>' +
                    '<body>' +
                    '<p>Dear '+con.Name+ ',</p>' +
                    '<p>Greetings of the day!</p>' +
                    '<p>You have been allotted  to Room: '+request.name+', '+request.Facility_Type__r.Floor__c+', '+request.Facility_Type__r.block__c+' for the '+ProgramWithCourseName.get(con.Program_Batch__c)+' '+IAType+' scheduled on '+parseDate(request.rve_Date_of_Exam__c) +' from '+parseTime(request.Exam_Time__c)+' to '+parseTime(request.End_Time__c)+'.</p>' +
                    '<p>Do"s and Don"ts</p>'+
                    '<p>1.Students should be present in the Examination Hall 10 minutes before the commencement of the examination. </p>'+
                    '<p>2.Students should bring the Identity Card and Hall Ticket during the examinations without fail. Students are not allowed to write examination if they do not bring both ID card and hall ticket. </p>'+
                    '<p>3.Do not bring any unauthorised material in the exam hall.</p>'+
                    '<p>4.Borrowing of writing materials, calculators, scales etc. is not allowed.'+
                    '<p>5.Any attempt by a student to discuss with fellow students or copy from fellow students will be treated as exam malpractice. </p>'+
                    '<p>All the best!</p>'+
                    '<p>Thank You & Warm regards,</p>'+
                    '<p>REVA University</p>' +
                    '</body>' +
                    '</html>';


                    // Create email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new string[] {con.Email}); // Assuming email is stored in Contact's Email field
                email.setSubject(subject);
                email.setHtmlBody(body);
                sendemaillist.add(email);
                }

                  // Send email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(sendemaillist);
            if (results[0].isSuccess()) {
                System.debug('Email sent successfully.');
            } else {
                System.debug('Failed to send email: ' + results[0].getErrors()[0].getMessage());
            }
                       
            }
          
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }
        
public static String parseTime(Time ConvertTime){
       
        String timeStr = String.valueOf(ConvertTime); // Your time string
       
        // Extract hour and minutes
        Integer hour = Integer.valueOf(timeStr.substring(0, 2));
        Integer minutes = Integer.valueOf(timeStr.substring(3, 5)); // Extract the minutes part
       
        // Determine AM/PM
        String suffix = (hour >= 12) ? 'PM' : 'AM';
       
        // Convert to 12-hour format
        hour = (hour > 12) ? hour - 12 : (hour == 0 ? 12 : hour);
           
            // Ensure minutes are formatted with two digits
            String formattedMinutes = (minutes < 10) ? '0' + minutes.toString() : minutes.toString();
       
        // Format the time string including minutes
        String formattedTime = hour + ':' + formattedMinutes + ' ' + suffix;
       
        // Output the formatted time string
        System.debug(formattedTime);
        return formattedTime;
    }

    public static String parseDate(Date dateneedstobeconvert){
        String formattedDate = String.valueOf(dateneedstobeconvert.format());
        System.debug('Formatted Date: ' + formattedDate);
        return formattedDate;
    }

    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}