@isTest
public class BirthdayNotificationControllerTest {
	@isTest
    static void testSuccessfulSchedule() {
        String cronExp = '0 0 12 * * ?';
        String schedulerClassName = 'BirthdayEmailScheduler';
        
        Test.startTest();
        Boolean result = BirthdayNotificationController.sheduleBatch(cronExp, schedulerClassName);
        Test.stopTest();
        
        System.assert(result, true);
        
        CronTrigger ct = [SELECT Id, CronExpression, State FROM CronTrigger WHERE CronExpression = :cronExp LIMIT 1];
        System.assertEquals('WAITING', ct.State);
    }
    
    @isTest
    static void testEmptyCronExpression() {
        String cronExp = '';
        String schedulerClassName = 'BirthdayEmailScheduler';
        
        Test.startTest();
        Boolean result = BirthdayNotificationController.sheduleBatch(cronExp, schedulerClassName);
        Test.stopTest();
        
        System.assert(!result);
    }
    
    @isTest
    static void testInvalidSchedulerClassName() {
        String cronExp = '0 0 12 * * ?'; 
        String schedulerClassName = 'InvalidSchedulerClass';

        Test.startTest();
        Boolean result = BirthdayNotificationController.sheduleBatch(cronExp, schedulerClassName);
        Test.stopTest();

        System.assert(!result);
    }
    
    @isTest
    static void testSchedulerClassNotSchedulable() {
        String cronExp = '0 0 12 * * ?';
        String schedulerClassName = 'NonSchedulableClass';

        if (!Test.isRunningTest()) {
            Type nonSchedulableClass = Type.forName('NonSchedulableClass');
            if (nonSchedulableClass == null) {
                NonSchedulableClass instance = new NonSchedulableClass();
            }
        }

        Test.startTest();
        Boolean result = BirthdayNotificationController.sheduleBatch(cronExp, schedulerClassName);
        Test.stopTest();

        System.assert(!result);
    }
    
    @isTest
    static void testScheduleCheckJobExists() {
        Test.startTest();
        Boolean result = BirthdayNotificationController.scheduleCheck();
        Test.stopTest();
        
        System.assert(!result);
    }
    
    @isTest
    static void testSuccessfulDeleteJob() {
        String cronExp = '0 0 12 * * ?';
        String schedulerClassName = 'BirthdayEmailScheduler';
        
        Test.startTest();
        BirthdayNotificationController.sheduleBatch(cronExp, schedulerClassName);
       	Boolean result = BirthdayNotificationController.deleteSchedule();
        Test.stopTest();
        
        System.assert(result);
    }
    
    @isTest
    static void testDeleteScheduleException() {
      	Test.startTest();
      	try {
            Boolean result = BirthdayNotificationController.deleteSchedule();
            System.assert(false, 'Expected an AuraHandledException to be thrown.');
      	} catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();  
    }
    
    @isTest
    static void testRunOnceBatchSuccess() {
        Test.startTest();
        BirthdayNotificationController.runOnceBatch('BirthdayEmailBatch');
        Test.stopTest();

        Integer batchJobCount = [SELECT COUNT() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status = 'Processing'];
        System.assertEquals(0, batchJobCount);
    }
    
    @isTest
    static void testRunOnceBatchClassNotFound() {
        Test.startTest();
        try {
            BirthdayNotificationController.runOnceBatch('NonExistentBatchClass');
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}