public class RTR_BusBreakdownDuringtripSMSInvoke {
@InvocableMethod(label='RTR Bus BreakDown During Trip SMS Notifications' description='RTR Bus BreakDown During Trip SMS Notifications')
    public static void busbreakdownSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRBusBreakDownSMS smsBreakDown = new RTRBusBreakDownSMS(recordIds);
            Id JobId = Database.executeBatch(smsBreakDown, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}