public class SendNotificationBeforeOnedaySCH  implements Schedulable {
    Public void execute(SchedulableContext sc) {
        SendNotificationBeforeOneday batch = new SendNotificationBeforeOneday();
        Database.executeBatch(batch, 50); // You can adjust the batch size as needed
    }

}