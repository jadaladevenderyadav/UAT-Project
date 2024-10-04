public class DateCalculator {
    public static List<Date> calculateNext15Days() {
        List<Date> next15Days = new List<Date>();
        
        // Get today's date
        Date currentDate = Date.today();
        
        // Calculate the next 15 days or until next 60 days whichever comes first
        for (Integer i = 0; i < 60; i++) {
            Date nextDate = currentDate.addDays(15);
            next15Days.add(nextDate);
            /*if (nextDate <= currentDate.addDays(14)) {
            } else {
                break;
            }*/
        }
        
        return next15Days;
    }
}