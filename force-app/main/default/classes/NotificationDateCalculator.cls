public class NotificationDateCalculator {
    public static List<Date> getNotificationDates(Date semesterStartDate) {
        List<Date> notificationDates = new List<Date>();
        
        // Four weeks before the start date
        notificationDates.add(semesterStartDate.addDays(-28));
        
        // Fifteen days before the start date
        notificationDates.add(semesterStartDate.addDays(-15));
        
        // Once every week till 30 days after the start date
        for (Integer i = 0; i <= 30; i += 7) {
            notificationDates.add(semesterStartDate.addDays(i));
        }
        
        // Once every three days from 31st to 45th day after the start date
        for (Integer i = 31; i <= 45; i += 3) {
            notificationDates.add(semesterStartDate.addDays(i));
        }
        
        // Once every alternate day from 46th to 60th days after the start date
        for (Integer i = 46; i <= 60; i += 2) {
            notificationDates.add(semesterStartDate.addDays(i));
        }
        
        return notificationDates;
    }
}