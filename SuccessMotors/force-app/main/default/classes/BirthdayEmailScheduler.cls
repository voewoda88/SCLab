global class BirthdayEmailScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BirthdayEmailBatch(), 200);
    }
}