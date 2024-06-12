@isTest
public class PaymentTriggerTest {
	@testSetup
    static void setup() {
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        
        insert testAccount;

        Opportunity fullyPaidOpportunity = new Opportunity(
            Name = 'Fully Paid Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 1000,
            PaymentStatus__c = 'Fully Paid',
            AccountId = testAccount.Id
        );
        
        insert fullyPaidOpportunity;

        Opportunity partiallyPaidOpportunity = new Opportunity(
            Name = 'Partially Paid Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 2000,
            PaymentStatus__c = 'Partially Paid',
            AccountId = testAccount.Id
        );
        
        insert partiallyPaidOpportunity;
        
        Opportunity notPaidOpportunity = new Opportunity(
        	Name = 'Not Paid Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 2000,
            PaymentStatus__c = 'Not Paid',
            AccountId = testAccount.Id
        );
		
        insert notPaidOpportunity;
            
        Contact testContact = new Contact(
            FirstName = 'Test First Name',
            LastName = 'Test Last Name',
            OwnerId = UserInfo.getUserId()
        );
        
        insert testContact;
        
        /*Payment__c partialPayment = new Payment__c(
            FirstName__c = 'Test First Name',
            LastName__c = 'Test Last Name',
            Amount__c = 1000,
            OpportunityName__c = 'Partially Paid Opportunity'
        );
        
        insert partialPayment;*/
    }
    
    @isTest
    static void testFullPayment() {
        Opportunity testOpportunity = [SELECT Id, Name, Amount, PaymentStatus__c FROM Opportunity WHERE Name = 'Fully Paid Opportunity' LIMIT 1];
        
        Payment__c fullPayment = new Payment__c(
            FirstName__c = 'Test First Name',
            LastName__c = 'Test Last Name',
            Amount__c = 1000,
            OpportunityName__c = testOpportunity.Name
        );
        
        Test.startTest();
        insert fullPayment;
        Test.stopTest();
        
        Opportunity updatedOpportunity = [SELECT Id, PaymentStatus__c, StageName FROM Opportunity WHERE Name = 'Fully Paid Opportunity' LIMIT 1];
        System.assertEquals('Fully Paid', updatedOpportunity.PaymentStatus__c);
    }
    
    @isTest
    static void testPartiallyPayment() {
    	Opportunity testOpportunity = [SELECT Id, Name, Amount, PaymentStatus__c FROM Opportunity WHERE Name = 'Partially Paid Opportunity' LIMIT 1];
        
        Payment__c additionalPayment = new Payment__c(
            FirstName__c = 'Test First Name',
            LastName__c = 'Test Last Name',
            Amount__c = 1000,
            OpportunityName__c = testOpportunity.Name
        );
        
        Test.startTest();
        insert additionalPayment;
        Test.stopTest();
        
        Opportunity updatedOpportunity = [SELECT Id, PaymentStatus__c FROM Opportunity WHERE Name = :testOpportunity.Name];
        System.assertEquals('Fully Paid', updatedOpportunity.PaymentStatus__c);
    }
    
    @isTest
    static void testNotPaidToFully() {
        Opportunity testOpportunity = [SELECT Id, Name, Amount, PaymentStatus__c FROM Opportunity WHERE Name = 'Not Paid Opportunity' LIMIT 1];
        
        Payment__c fullPayment = new Payment__c(
            FirstName__c = 'Test First Name',
            LastName__c = 'Test Last Name',
            Amount__c = 2000,
            OpportunityName__c = testOpportunity.Name
        );
        
        Test.startTest();
        insert fullPayment;
        Test.stopTest();
        
        Opportunity updatedOpportunity = [SELECT Id, PaymentStatus__c FROM Opportunity WHERE Name = :testOpportunity.Name];
        System.assertEquals('Fully Paid', updatedOpportunity.PaymentStatus__c);
    }
    
    @isTest
    static void testNotPaidToPartially() {
        Opportunity testOpportunity = [SELECT Id, Name, Amount, PaymentStatus__c FROM Opportunity WHERE Name = 'Not Paid Opportunity' LIMIT 1];
        
        Payment__c fullPayment = new Payment__c(
            FirstName__c = 'Test First Name',
            LastName__c = 'Test Last Name',
            Amount__c = 1000,
            OpportunityName__c = testOpportunity.Name
        );
        
       	Test.startTest();
        insert fullPayment;
        Test.stopTest();
        
        Opportunity updatedOpportunity = [SELECT Id, PaymentStatus__c FROM Opportunity WHERE Name = :testOpportunity.Name];
        System.assertEquals('Partially Paid', updatedOpportunity.PaymentStatus__c);
    }
    
    @isTest
    static void testPartiallyWithExtraPayment() {
        Opportunity testOpportunity = [SELECT Id, Name, Amount, PaymentStatus__c FROM Opportunity WHERE Name = 'Partially Paid Opportunity' LIMIT 1];
        
        Payment__c additionalPayment = new Payment__c(
            FirstName__c = 'Test First Name',
            LastName__c = 'Test Last Name',
            Amount__c = 3000,
            OpportunityName__c = testOpportunity.Name
        );
        
        Test.startTest();
        insert additionalPayment;
        Test.stopTest();
        
        Opportunity updatedOpportunity = [SELECT Id, PaymentStatus__c FROM Opportunity WHERE Name = :testOpportunity.Name];
        System.assertEquals('Fully Paid', updatedOpportunity.PaymentStatus__c);
    }
}