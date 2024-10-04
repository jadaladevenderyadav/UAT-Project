public class SAP_DemandAPI_Handler {
    @future(callout=true)
    public static void createDemands(List<Id> demandIds) {
        SAP_DemandAPI.DemandCreationAPI(demandIds);
    }

}