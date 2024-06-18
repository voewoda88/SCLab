public with sharing class BirthdayNotificationController {

    private static String sheduleJobName = 'Birthday Notification';

    @AuraEnabled(cacheable=true)
    public static Boolean sheduleBatch(String cronExp, String schedulerClassName) {
        try {
            if (String.isBlank(cronExp)) {
                throw new IllegalArgumentException('CRON expression cannot be empty');
            }
            
            Type schedulerType = Type.forName(schedulerClassName);

            if (schedulerType == null) {
                throw new IllegalArgumentException('Class not found: ' + schedulerClassName);
            }

            Object schedulerInstance = schedulerType.newInstance();

            if (!(schedulerInstance instanceof Schedulable)) {
                throw new IllegalArgumentException('Class ' + schedulerClassName + ' does not implement Schedulable');
            }

            String jobId = System.schedule(sheduleJobName, cronExp, (Schedulable) schedulerInstance);

            return true;
        } catch (Exception e) {
            System.debug('Error scheduling job (Exception): ' + e.getMessage());
            return false;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean scheduleCheck() {
        try {
            return staticScheduleCheck();
        } catch (Exception e) {
            System.debug('That job does not exist');
            return false;
        }
    }

    @AuraEnabled
    public static Boolean deleteSchedule() {
        try {
            CronTrigger job = getJob();

            if(job != null) {
                System.abortJob(job.Id);
            }
            
            return true;                 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static void runOnceBatch(String batchClassName) {
        try {
            Type batchType = Type.forName(batchClassName);
            if(batchType == null) {
                throw new IllegalArgumentException('Class not found: ' + batchClassName);
            }

            Object batchInstance = batchType.newInstance();
            if (!(batchInstance instanceof Database.Batchable<SObject>)) {
                throw new IllegalArgumentException('Class ' + batchClassName + ' does not implement Database.Batchable');
            }

            Database.executeBatch((Database.Batchable<SObject>) batchInstance);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getCronExpression(){
        try {
            CronTrigger tmp = [SELECT Id, CronJobDetail.Name, CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: sheduleJobName];
            return tmp.CronExpression;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static CronTrigger getJob() {
        return [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =: sheduleJobName];
    }

    private static Boolean staticScheduleCheck() {
        CronTrigger job = getJob();
            
        return job != null;
    }
}