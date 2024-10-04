/**
* @File Name : UpdateTHeTotalAttendeceOfStudentApexHand.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : August 23, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 23, 2024 |   | Initial Version
**/

public class UpdateTHeTotalAttendeceOfStudentApexHand {
	Public static List<Id> enrollmentIds;
	@InvocableMethod	
	Public static void LightningStudio(List<Id> enrollmentIds){
		List<id>enrollmentId = new list<Id>();
		enrollmentId =enrollmentIds;
		UpdateTHeTotalAttendeceOfStudent bc = new UpdateTHeTotalAttendeceOfStudent(enrollmentId);
		database.executebatch(bc);
	}
}