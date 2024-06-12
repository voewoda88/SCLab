public with sharing class TaskCreator {
    public void createDeliveryTask(Payment__c payment, Id opptId) {
        Task deliveryTask = new Task();

        Contact paymentContact = getPaymentContact(payment.FirstName__c, payment.LastName__c);

        deliveryTask.OwnerId = paymentContact.OwnerId;
        deliveryTask.Priority = 'High';
        deliveryTask.Status = 'Not Started';
        deliveryTask.Subject = 'Delivery of goods';
        Date today = Date.today();
        deliveryTask.ReminderDateTime = Datetime.newInstance(today.addDays(1), Time.newInstance(10, 0, 0, 0));
        deliveryTask.WhatId = opptId;

        insert deliveryTask;
    }

    public void createPaidTask(Payment__c payment, Id opptId, Decimal extraMoney) {
        Task paidTask = new Task();
        
        Contact paymentContact = getPaymentContact(payment.FirstName__c, payment.LastName__c);

        paidTask.OwnerId = paymentContact.OwnerId;
        paidTask.Priority = 'High';
        paidTask.Status = 'Not Started';
        paidTask.Subject = 'Opportunity pay';
        paidTask.Description = 'The extra money came for the opportunity: ' + extraMoney;
        Date today = Date.today();
        paidTask.ReminderDateTime = Datetime.newInstance(today.addDays(1), Time.newInstance(12, 0, 0, 0));
        paidTask.WhatId = opptId;

        insert paidTask;
    }

    private static Contact getPaymentContact(String firstName, String lastName) {
        return [SELECT Id, FirstName, LastName, OwnerId FROM Contact WHERE FirstName = :firstName AND LastName = :lastName];
    }
}