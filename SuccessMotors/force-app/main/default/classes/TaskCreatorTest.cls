@isTest
public class TaskCreatorTest {
	@testSetup
    static void setup() {
        Contact testContact = new Contact(
        	FirstName = 'Test First Name',
            LastName = 'Test Last Name',
            OwnerId = UserInfo.getUserId()
        );
        
        insert testContact;
        
        Account testAccount = new Account(
        	Name = 'Test Account'	
        );
        
        insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(
        	Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
            
        insert testOpportunity;
        
        Payment__c testPayment = new Payment__c(
        	FirstName__c = 'Test First Name',
            LastName__c = 'Test Last Name',
            OpportunityName__c = 'Test Opportunity',
            Amount__c = 1000
        );
            
        insert testPayment;
    }
    
    @isTest
    static void testCreateDeliveryTask() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Payment__c testPayment = [SELECT Id, FirstName__c, LastName__c FROM Payment__c WHERE FirstName__c = 'Test First Name' AND LastName__c = 'Test Last Name'];
        
        TaskCreator taskCreator = new TaskCreator();
        
        Test.startTest();
        taskCreator.createDeliveryTask(testPayment, testOpportunity.Id);
        Test.stopTest();
        
        Task createdTask = [SELECT Id, Subject, Priority, Status, ReminderDateTime, WhatId FROM Task WHERE WhatId =: testOpportunity.Id AND Subject = 'Delivery of goods' LIMIT 1];
        System.assertNotEquals(null, createdTask);
        System.assertEquals('High', createdTask.Priority);
        System.assertEquals('Not Started', createdTask.Status);
        System.assertEquals(Datetime.newInstance(Date.today().addDays(1), Time.newInstance(10, 0, 0, 0)), createdTask.ReminderDateTime);
        System.assertEquals(testOpportunity.Id, createdTask.WhatId);
    }
    
    @isTest
    static void testCreatePaidTask() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Payment__c testPayment = [SELECT Id, FirstName__c, LastName__c FROM Payment__c WHERE FirstName__c = 'Test First Name' AND LastName__c = 'Test Last Name' LIMIT 1];

        TaskCreator taskCreator = new TaskCreator();
        
        Test.startTest();
        taskCreator.createPaidTask(testPayment, testOpportunity.Id, 500);
        Test.stopTest();

        Task createdTask = [SELECT Id, Subject, Priority, Status, ReminderDateTime, WhatId, Description FROM Task WHERE WhatId = :testOpportunity.Id AND Subject = 'Opportunity pay' LIMIT 1];
        System.assertNotEquals(null, createdTask);
        System.assertEquals('High', createdTask.Priority);
        System.assertEquals('Not Started', createdTask.Status);
        System.assertEquals('The extra money came for the opportunity: 500', createdTask.Description);
        System.assertEquals(Datetime.newInstance(Date.today().addDays(1), Time.newInstance(12, 0, 0, 0)), createdTask.ReminderDateTime);
        System.assertEquals(testOpportunity.Id, createdTask.WhatId);
    }
}