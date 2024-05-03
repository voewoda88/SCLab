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
        
        EmailTemplate testTemplate = new EmailTemplate(
            Name = 'Opportunity Invoice Template',
            Subject = 'Test Subject',
            Body = 'Test Body',
            HtmlValue = 'Test HTML'
        );

        insert testTemplate;

        Test.startTest();
        List<String> emailData = SendIvoiceController.getEmail(testOpportunity.Id);
        Test.stopTest();

        System.assertEquals(2, emailData.size(), 'Should return two values');
        System.assertEquals('Test Subject', emailData[0], 'Subject should match');
        System.assertEquals('Test Body', emailData[1], 'HTML Body should match');
    }
}