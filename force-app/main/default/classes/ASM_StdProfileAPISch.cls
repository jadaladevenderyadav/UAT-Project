global class ASM_StdProfileAPISch  implements Schedulable{
    global void execute(SchedulableContext sc){
         Integer days = Integer.valueOf(Label.StudentMasterScheduleTime);
        Database.executeBatch(new ASM_StdProfileAPIBatch(System.today().addDays(days)),100);
    }
}