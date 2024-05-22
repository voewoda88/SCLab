@isTest
public class InboundInvoiceEmailTest {
    @isTest
    static void testHandleInboundEmailApproved() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOppty = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        
        insert testOppty;
        
        List<Opportunity> oppts = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        String invoiceNumber = oppts[0].Invoice_Number__c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Invoice(' + invoiceNumber +  ')';
        email.plainTextBody = 'The status is approved.';

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        InboundInvoiceEmail handler = new InboundInvoiceEmail();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        Opportunity updatedOppty = [SELECT StageName FROM Opportunity WHERE Id = :testOppty.Id];
        System.assertEquals('Qualification', updatedOppty.StageName);
        System.assert(result.success, 'Email processing should be successful.');
    }

    @isTest
    static void testHandleInboundEmailRejected() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOppty = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        
        insert testOppty;
        
        List<Opportunity> oppts = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        String invoiceNumber = oppts[0].Invoice_Number__c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Invoice(' + invoiceNumber +  ')';
        email.plainTextBody = 'The status is rejected.';

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        InboundInvoiceEmail handler = new InboundInvoiceEmail();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        Opportunity updatedOppty = [SELECT StageName FROM Opportunity WHERE Id = :testOppty.Id];
        System.assertEquals('Closed Lost', updatedOppty.StageName);
        System.assert(result.success, 'Email processing should be successful.');
    }

    @isTest
    static void testHandleInboundEmailNoInvoiceNumber() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Subject without invoice number';
        email.plainTextBody = 'The status is approved.';

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        InboundInvoiceEmail handler = new InboundInvoiceEmail();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        System.assert(!result.success, 'Email processing should not be successful.');
    }

    @isTest
    static void testHandleInboundEmailIncorrectStatus() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOppty = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        
        insert testOppty;
        
        List<Opportunity> oppts = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        String invoiceNumber = oppts[0].Invoice_Number__c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Invoice(' + invoiceNumber +  ')';
        email.plainTextBody = 'The status is unknown.';

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        InboundInvoiceEmail handler = new InboundInvoiceEmail();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        Opportunity updatedOppty = [SELECT StageName FROM Opportunity WHERE Id = :testOppty.Id];
        System.assertEquals('Prospecting', updatedOppty.StageName);
        System.assert(!result.success, 'Email processing should not be successful.');
    }

    @isTest
    static void testHandleInboundEmailClosedOpportunity() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOppty = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        
        insert testOppty;
        
        List<Opportunity> oppts = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        String invoiceNumber = oppts[0].Invoice_Number__c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Invoice(' + invoiceNumber +  ')';
        email.plainTextBody = 'The status is approved.';

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        InboundInvoiceEmail handler = new InboundInvoiceEmail();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        Opportunity updatedOppty = [SELECT StageName FROM Opportunity WHERE Id = :testOppty.Id];
        System.assertEquals('Closed Won', updatedOppty.StageName);
        System.assert(!result.success, 'Email processing should not be successful.');
    }
}