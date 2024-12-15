global class BirthdayEmailBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, FirstName, LastName, Email, Birthdate FROM Contact WHERE Email != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Birthday Notification'];

        for(Contact contact : scope) {
            if(isBirthdayToday(contact.Birthdate)) {
                System.debug('Processing contact: ' + contact.Id + ', ' + contact.FirstName + ' ' + contact.LastName);

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(emailTemplate.Id);
                email.setTargetObjectId(contact.Id);
                email.setSaveAsActivity(false);
                emails.add(email);
            }
        }

        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    global void finish(Database.BatchableContext bc) {

    }

    private Boolean isBirthdayToday(Date birthdayDate) {
        if(birthdayDate == null) {
            return false;
        }
        Date today = Date.today();
        return today.month() == birthdayDate.month() && today.day() == birthdayDate.day();
    }
}