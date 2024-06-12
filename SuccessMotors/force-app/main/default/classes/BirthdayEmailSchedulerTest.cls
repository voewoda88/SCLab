@isTest
public class BirthdayEmailSchedulerTest {
	public static String CRON_EXP = '0 0 0 2 9 ? 2026';
    @isTest
    static void testScheduler() {
        Test.startTest();
        String jobId = System.schedule('BirthdayEmailScheduler', CRON_EXP, new BirthdayEmailScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
      	System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2026-09-02 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}