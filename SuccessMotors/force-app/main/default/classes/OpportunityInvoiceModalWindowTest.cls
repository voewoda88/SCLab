@isTest
public class OpportunityInvoiceModalWindowTest {
	@isTest
    static void testConstructorWithStandardSetController() {
        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(new List<Opportunity>());
    
        OpportunityInvoiceModalWindowController controller = new OpportunityInvoiceModalWindowController(standardSetController);

        System.assertEquals(1, standardSetController.getPageSize());
    }
    
    @isTest
    static void testConstructorWithStandardController() {       
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity', 
            StageName = 'Prospecting', 
            CloseDate = Date.today()
        );
        
        insert testOpportunity;
        
		ApexPages.currentPage().getParameters().put('id', testOpportunity.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
        
        OpportunityInvoiceModalWindowController controller = new OpportunityInvoiceModalWindowController(stdController);
        
        System.assertEquals(testOpportunity.Id, controller.Id);
    }
    
    @isTest
    static void testCancelMethod() {
        OpportunityInvoiceModalWindowController controller = new OpportunityInvoiceModalWindowController(new ApexPages.StandardSetController(new List<Opportunity>()));
        controller.Id = '00128000009xXyzAAE';
    
        PageReference result = controller.cancel();
    
        System.assertEquals('/00128000009xXyzAAE', result.getUrl());
        System.assert(result.getRedirect());
  	}  
    
    @isTest
    static void testSavePdf1() {
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30) 
        );
        
        insert testOpportunity;
        
        PageReference testPage = Page.opportunityInvoicePage;
        Test.setCurrentPage(testPage);
        
        ApexPages.currentPage().getParameters().put('id', testOpportunity.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
        
        OpportunityInvoiceModalWindowController controller = new OpportunityInvoiceModalWindowController(stdController);
        PageReference result = controller.pdfSave();
        
        System.assertEquals('/' + testOpportunity.Id, result.getUrl());
    }
    
    @isTest
    static void testSavePdf2() {
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30) 
        );
        
        insert testOpportunity;
        
        ContentVersion cv = new ContentVersion(
            Title = 'INVOICE',
            PathOnClient = 'INVOICE.pdf',
            VersionData = Blob.valueOf('Test')
        );
        
        insert cv;
        
        Id contentDocId = [SELECT ContentDocumentId 
                           FROM ContentVersion 
                           WHERE Id =: cv.Id].ContentDocumentId;
        
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
        	LinkedEntityId = testOpportunity.Id,
            ContentDocumentId = contentDocId,
            shareType = 'V'
        );
        
        insert contentDocLink;
        
        PageReference testPage = Page.opportunityInvoicePage;
        Test.setCurrentPage(testPage);
        
        ApexPages.currentPage().getParameters().put('id', testOpportunity.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
        
        OpportunityInvoiceModalWindowController controller = new OpportunityInvoiceModalWindowController(stdController);
        PageReference result = controller.pdfSave();
        
        System.assertEquals('/' + testOpportunity.Id, result.getUrl());
    }
}