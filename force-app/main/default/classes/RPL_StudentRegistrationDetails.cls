/**
 * @description       : Controller for handling student registration details
 * @author            : Kiruba Sankar M
 * @group             :
 * @last modified on  : 12-05-2023
 * @last modified by  : Kiruba Sankar M
 **/
public without sharing class RPL_StudentRegistrationDetails {
	@AuraEnabled(cacheable=true)
	public static List<Contact> getContactDetails(String contactId) {
		return [
			SELECT
				ID,
				Name,
				hed__Gender__c,
				Birthdate,
				Personal_Email__c,
				SRN_Number__c,
				MobilePhone,
				School_Name__c,
				Program_Name__c,
				Primary_Academic_Program__r.Rpl_Placement_Vertical_Head__c,
				Primary_Academic_Program__r.Name,
				Father_Name__c,
				Mother_Name__c,
				Primary_Academic_Program__r.Program_Type__c,
				hed__WorkEmail__c,
				RH_Parent_Phone_Number__c,
				Bank_Branch_Name__c,
				hed__UniversityEmail__c,
				Primary_Academic_Program__r.Program_Alias__c
			FROM Contact
			WHERE Id = :contactId
		];
	}

	@AuraEnabled
	public static Id insertStudentRegDetails(Rpl_Student_Registration__c stdRegDetails) {
		try {
			insert stdRegDetails;
			return stdRegDetails.Id;
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
		}
		return null;
	}

	@AuraEnabled
	public static Id updateStudentRegDetails(Rpl_Student_Registration__c stdRegDetails) {
		try {
			update stdRegDetails;
			return stdRegDetails.Id;
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
		}
		return null;
	}

	@AuraEnabled(cacheable=true)
	public static List<Rpl_Student_Registration__c> getTheStudentRegistrationDetails(String recordId) {
		try {
			if (!String.isEmpty(recordId)) {
				return [
					SELECT
						ID,
						Rpl_SRN__c,
						Rpl_Branch__c,
						Name,
						Rpl_Gender__c,
						Rpl_Date_of_Birth__c,
						Rpl_Contact_No__c,
						Rpl_School__c,
						Rpl_Personal_Mail_ID__c,
						Course_Name__c,
						Rpl_University_Mail_ID__c,
						Rpl_10th_Percentage__c,
						Rpl_Is_Diploma_Student__c,
						Rpl_Branch_Name__c,
						Rpl_10th_Board_Name__c,
						Rpl_Is_Diploma_Marksheet_Rejected__c,
						Contact__r.Primary_Academic_Program__r.No_of_Years__c,
						Rpl_Status__c,
						Rpl_Is_Diploma_Marksheet_Verified__c,
						Rpl_PG_Overall_Percentage__c,
						Rpl_UG_Overall_Percentage__c,
						Rpl_No_Of_UG_Marksheet_Uploaded__c,
						Rpl_Is_Graduation_Details_Rejected__c,
						Rpl_Is_Resume_Rejected__c,
						Rpl_Is_Student_Details_Rejected__c,
						Rpl_Reason_For_Education_Gap__c,
						Rpl_10th_Year_of_passing__c,
						Rpl_Interested_in_placement__c,
						Rpl_12th_Percentage__c,
						Rpl_Sem_1_CGPA__c,
						Rpl_Sem_2_CGPA__c,
						Rpl_Sem_3_CGPA__c,
						Rpl_Sem_4_CGPA__c,
						Rpl_Sem_5_CGPA__c,
						Rpl_Sem_6_CGPA__c,
						Rpl_Is_Graduation_Details_Verified__c,
						Rpl_Is_Student_Details_Verified__c,
						Rpl_No_Of_PG_Marksheet_Uploaded__c,
						Rpl_Is_Resume_Verified__c,
						Rpl_Is_Tenth_Marksheet_Rejected__c,
						Rpl_Is_Twelveth_Marksheet_Uploaded__c,
						Rpl_Is_Tenth_Marksheet_Uploaded__c,
						Rpl_Is_Resume_Uploaded__c,
						Rpl_Sem_7_CGPA__c,
						Rpl_Sem_8_CGPA__c,
						Rpl_Pan_Card_No__c,
						Rpl_UG_College_Name__c,
						Rpl_UG_Degree__c,
						Rpl_Current_Backlogs__c,
						Rpl_12th_Board_Name__c,
						Rpl_IsResumeUpload__c,
						Rpl_Is_Under_Approval_Process__c,
						Rpl_Twelfth_CGPA__c,
						Rpl_Tenth_CGPA__c,
						Rpl_PG_OVerall_CGPA__c,
						Rpl_UG_Overall_CGPA__c,
						Rpl_UG_Verified_Semester_Marksheets__c,
						Rpl_Is_Twelveth_Marksheet_Verified__c,
						Rpl_Is_Tenth_Marksheet_Verified__c,
						Rpl_Last_Name__c,
						Rpl_Middle_Name__c,
						Rpl_First_Name__c,
						Rpl_12th_Year_of_passing__c,
						Rpl_isStudentDetailsComplete__c,
						Rpl_isTwelveUpload__c,
						IsTenUpload__c,
						RPL_IsGraduationComplete__c,
						isUnderStatus__c,
						Father_Name__c,
						Mother_Name__c,
						Rpl_Current_Address__c,
						RPL_Permanent_Address__c,
						Rpl_Is_UG_Aggregate_Uploaded__c,
						Rpl_PG_Verified_Semester_Marksheets__c,
						Rpl_Is_UG_Aggregate_Rejected__c,
						Rpl_Is_Twelveth_Marksheet_Rejected__c,
						Rpl_Parents_Contact_No__c,
						Rpl_Total_Backlogs__c,
						Rpl_Cleared_Backlogs__c,
						Rpl_Education_Gap__c,
						Rpl_UG_Board_Name_University_Name__c,
						Rpl_UG_Year_of_Graduation__c,
						Rpl_UG_CGPA__c,
						Rpl_UG_Stream__c,
						Rpl_PG1_Sem_CGPA__c,
						Rpl_PG2_Sem_CGPA__c,
						Rpl_PG3_Sem_CGPA__c,
						Rpl_PG4_Sem_CGPA__c,
						Rpl_Is_UG_Aggregate_Verified__c,
						Rpl_UG_Rejected_Semester_Marksheets__c,
						Rpl_PG_Rejected_Semester_Marksheets__c,
						Rpl_PG1_Specialization__c,
						Rpl_PG2_Specialization__c,
						Rpl_Diploma_Percentage__c,
						Rpl_DiplomaName__c,
						Rpl_Student_Image__c,
						Rpl_Diploma_Graduation_Year__c,
						Rpl_Diploma_University__c,
						Rpl_Program_Type__c,
						Rpl_Active_Semester__c
					FROM Rpl_Student_Registration__c
					WHERE Contact__c = :recordId OR Id = :recordId
				];
			}
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
		}
		return null;
	}

	@AuraEnabled
	public static String sendOtpToEmail(String personEmailId) {
		try {
			String otpValue;
			OrgWideEmailAddress owea = new OrgWideEmailAddress();
            owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='REVA University'];
			if (!String.isEmpty(personEmailId)) {
				otpValue = String.valueOf(Integer.valueof(Math.round((Math.random() * (900000) + 100000))));
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String[] toAddresses = new List<String>{ personEmailId };
				mail.setToAddresses(toAddresses);
				mail.setSubject('Your OTP Code');
				mail.setPlainTextBody('Your OTP code is: ' + otpValue);
				mail.setOrgWideEmailAddressId(owea.Id);
				Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
			}
			return otpValue;
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	@AuraEnabled
	public static String sendOtpToMobile(String phoneNumber) {
		try {
			String otpValue;
			if (!String.isEmpty(phoneNumber) || Test.isRunningTest()) {
				otpValue = String.valueOf(Integer.valueof(Math.round((Math.random() * (900000) + 100000))));
				List<SMS_API_Utility.shortMessageWrp> messages = new List<SMS_API_Utility.shortMessageWrp>();

				SMS_API_Utility.shortMessageWrp messageWrapper = new SMS_API_Utility.shortMessageWrp();
				messageWrapper.message =
					otpValue +
					' is your One Time Password(OTP) for Mobile Verification. This OTP is valid till Five Minutes From Now - REVA University';
				messageWrapper.recipient = phoneNumber;
				messages.add(messageWrapper);

				if (!messages.isEmpty() && !Test.isRunningTest()) {
					SMS_API_Utility.SendSMSOneToMany('SMS OTP', messages);
				}
			}
			return otpValue;
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
	}

	@AuraEnabled
	public static Integer checkForTheStudentList(String contactId) {
		try {
			return [SELECT ID FROM Rpl_Student_Registration__c WHERE Contact__c = :contactId].size();
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static contactWrapper checkTheStudentPreFinalYear(String contactId) {
		try {
			contactWrapper wrp = new contactWrapper();

			if (String.isEmpty(contactId)) {
				return null;
			}
			if (Test.isRunningTest()) {
				wrp.isPrefinalYear = false;
				wrp.programAlias = 'BT-CSIT';
			}

			List<Contact> prefinalYearContact = [
				SELECT
					Id,
					Program_Name__c,
					Program_Batch__r.Name,
					Active_Semester__r.Name,
					Primary_Academic_Program__r.Program_Type__c,
					Rpl_Is_Placement_Created__c,
					Primary_Academic_Program__r.Program_Alias__c,
					Rpl_Is_Pre_Final_Year__c
				FROM Contact
				WHERE Id = :contactId
				LIMIT 1
			];
			if (!prefinalYearContact.isEmpty()) {
				wrp.programAlias = prefinalYearContact[0].Primary_Academic_Program__r.Program_Alias__c;
				wrp.isPrefinalYear = prefinalYearContact[0].Rpl_Is_Placement_Created__c;
			}
			return wrp;
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
			throw new AuraHandledException('getPlacementDetials' + e.getMessage() + 'Line Number  ' + e.getLineNumber());
		}
	}

	@AuraEnabled
	public static revaWrapper getPlacementDetails(String contactId) {
		try {
			contactWrapper wrp = checkTheStudentPreFinalYear(contactId);
			Date currentDate = Date.today();
			revaWrapper rvWrp = new revaWrapper();
			if (wrp != null && !String.isEmpty(wrp.programAlias)) {
				Integer currentYear = Integer.valueOf(Date.Today().Year());

				List<Rpl_Reva_Placement__c> revPlacList = [
					SELECT
						ID,
						Name,
						CurrentYear__c,
						Rpl_Registration_Start_Date__c,
						Rpl_Registration_End_Date__c,
						Rpl_Academic_Program__c
					FROM Rpl_Reva_Placement__c
					WHERE Rpl_Active__c = TRUE AND CurrentYear__c = :currentYear AND Rpl_Registration_End_Date__c > :currentDate
				];

				Rpl_Reva_Placement__c revaPlacement = new Rpl_Reva_Placement__c();
				if (!revPlacList.isEmpty()) {
					for (Rpl_Reva_Placement__c eachRevaPlacement : revPlacList) {
						if (eachRevaPlacement.Rpl_Academic_Program__c != null) {
							if (eachRevaPlacement.Rpl_Academic_Program__c.contains(wrp.programAlias)) {
								revaPlacement = eachRevaPlacement;
								break;
							}
						}
					}
				}

				if (revaPlacement.Id != null) {
					Integer revaPlacementStartYear = revaPlacement.Rpl_Registration_Start_Date__c.year();
					Integer revaPlacementEndYear = revaPlacement.Rpl_Registration_End_Date__c.year();
					String contPreFinal = revaPlacementStartYear + ' - ' + revaPlacementEndYear;
					rvWrp.revaPlacementId = revaPlacement.Id;
					rvWrp.Name = revaPlacement.Name;
					rvWrp.contPreFinal = contPreFinal;
					rvWrp.isPreOrFinalYear = wrp.isPrefinalYear;
				}
			}
			return rvWrp;
		} catch (Exception e) {
			ErrorLogUtility.logError(e);
			throw new AuraHandledException('getPlacementDetials' + e.getMessage() + 'Line Number  ' + e.getLineNumber());
		}
	}

	public class revaWrapper {
		@AuraEnabled
		public Id revaPlacementId;
		@AuraEnabled
		public Boolean isPreOrFinalYear;
		@AuraEnabled
		public String Name;
		@AuraEnabled
		public String contPreFinal;
	}

	public class contactWrapper {
		@AuraEnabled
		public Boolean isPrefinalYear = false;
		@AuraEnabled
		public String programAlias;
	}
}