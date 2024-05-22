@isTest
public class SendInvoiceControllerTest {
    @isTest
    static void testGetEmail() {
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30) 
        );

        insert testOpportunity;

        Test.startTest();
        List<String> emailData = SendIvoiceController.getEmail(testOpportunity.Id);
        Test.stopTest();

        System.assertEquals(2, emailData.size(), 'Should return two values');
        System.assertEquals('Invoice(INV-100035) for Test Opportunity', emailData[0], 'Subject should match');
    }
    
    @isTest
    static void testGetContact() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            LastName = 'Test Contact', 
            AccountId = testAccount.Id, 
            Email = 'test@example.com'
        );
        
        insert testContact;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity', 
            StageName = 'Prospecting', 
            CloseDate = Date.today()
        );
        
        insert testOpportunity;

        OpportunityContactRole testOCR = new OpportunityContactRole(
            OpportunityId = testOpportunity.Id, 
            ContactId = testContact.Id, 
            IsPrimary = true
        );
        
        insert testOCR;

        List<String> contactInformation = SendIvoiceController.getContact(testOpportunity.Id);

        System.assertEquals('Test Contact', contactInformation[0]);
        System.assertEquals('test@example.com', contactInformation[1]);
    }
    
    @isTest
    static void testSuccessfullySendEmail() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            LastName = 'Test Contact', 
            AccountId = testAccount.Id, 
            Email = 'test@example.com'
        );
        
        insert testContact;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity', 
            StageName = 'Prospecting', 
            CloseDate = Date.today()
        );
        
        insert testOpportunity;
        
        Blob pdfBlob = Blob.valueOf('Test');
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient ='INVOICE.pdf';
        conVer.Title = 'INVOICE';
        conVer.VersionData = pdfBlob;
        
        insert conVer;

        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId,
            LinkedEntityId = testOpportunity.Id,
            ShareType = 'V'
        );
        
        insert testContentDocumentLink;
        
        CustomEmailTemplate customEmail = new CustomEmailTemplate();
        customEmail.opptId = testOpportunity.Id;
        customEmail.contactEmail = testContact.Email;
        customEmail.emailSubject = 'Test Subject';
        customEmail.emailBody = 'Test Body';

        Boolean result = SendIvoiceController.sendEmail(customEmail);

        System.assert(result);
    }
}