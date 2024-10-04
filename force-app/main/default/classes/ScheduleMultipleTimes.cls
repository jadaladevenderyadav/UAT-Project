public class ScheduleMultipleTimes {
    public static void scheduleFlows() {
        // Schedule the flow at 6 AM
        System.schedule('Flow at 11 AM', '0 0 11 * * ?', new MissedMealScheduleFlow());
 
        // Schedule the flow at 3 PM
        System.schedule('Flow at 3 PM', '0 0 15 * * ?', new MissedMealScheduleFlow());
 
        // Schedule the flow at 7 PM
        System.schedule('Flow at 7 PM', '0 0 19 * * ?', new MissedMealScheduleFlow());
 
        // Schedule the flow at 10 PM
        System.schedule('Flow at 10 PM', '0 0 22 * * ?', new MissedMealScheduleFlow());
    }
}