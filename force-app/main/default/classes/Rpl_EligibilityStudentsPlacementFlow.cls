/**
* @description       : This class is used in Eligibility Student Placement Flow 
*                      for segregating data based on the included company list.
* @author            : Vikranth
* @group             : 
* @Created By on     : 09-11-2023
* @last modified by  :
**/
public class Rpl_EligibilityStudentsPlacementFlow {

    /**
    * @description       : Invocable method to exclude companies based on the included company list.
    * @param inputVariables : List of input variables containing IncludedCompanyName.
    * @return returnList    : List of return variables containing the excluded company names.
    **/
    @InvocableMethod 
    public static List<ReturnVariable> excludeTheCompanyList(List<InputVariable> inputVariables) {
        List<String> includeCompanyList = inputVariables[0].IncludedCompanyName.split(';');
        List<ReturnVariable> returnList = new List<ReturnVariable>();
        ReturnVariable rtr = new ReturnVariable();
        
        try {
            // Query companies not in the included list.
            rtr.excludeCompanyName = [SELECT Id, Name FROM Rpl_Company__c WHERE Name NOT IN :includeCompanyList];        
            returnList.add(rtr);
        } catch (Exception ex) {
            // Log any exceptions
            ErrorLogUtility.logError(ex);
        }
        
        return returnList;        
    } 
    
    /**
    * @description        : Input variable class for the Invocable method.
    **/
    public class InputVariable {
        @InvocableVariable public String IncludedCompanyName;
        @InvocableVariable public String copy1ofIncludeCompaniesWithOffer;        
    }
    
    /**
    * @description        : Return variable class for the Invocable method.
    **/
    public class ReturnVariable {
        @InvocableVariable public List<Rpl_Company__c> excludeCompanyName;        
    }
}