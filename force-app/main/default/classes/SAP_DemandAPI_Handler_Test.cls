@isTest
public class SAP_DemandAPI_Handler_Test 
{
     @isTest
    static void testCreateDemands()
    {
        List<Id> testDemandIds = new List<Id>();
        Test.startTest();
        SAP_DemandAPI_Handler.createDemands(testDemandIds);
        Test.stopTest();
    }
}