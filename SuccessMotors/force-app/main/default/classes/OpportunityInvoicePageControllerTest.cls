@isTest
public class OpportunityInvoicePageControllerTest {
	@isTest
    static void testConstructorWithSetController() {
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Opportunity>());
        
        OpportunityInvoicePageController controller = new OpportunityInvoicePageController(setController);
        
        System.assertEquals(1, setController.getPageSize());
    }
    
    @isTest
    static void testConstructorWithStandardController() {
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Test Street',
            BillingCity = 'Test City',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country'
        );
        
        insert testAccount;
        
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduserforinvoice@testorg.com'
        );
        
    	insert u;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity', 
            StageName = 'Prospecting', 
            CloseDate = Date.today(),
        	AccountId = testAccount.Id,
            OwnerId = u.Id
        );
        
        insert testOpportunity;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            IsActive = true
    	);
        
    	insert testProduct;

		Id priceBookId = Test.getStandardPricebookId();
        
        PricebookEntry pbEntry = new PricebookEntry(
        	Pricebook2Id = pricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        
        insert pbEntry;
        
        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = pbEntry.Id,
            Quantity = 1,
            TotalPrice = 100
        );
        
    	insert testOpportunityLineItem;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Phone = '1234567890',
            Email = 'test@example.com'
    	);
        
    	insert testContact;

        OpportunityContactRole testRole = new OpportunityContactRole(
            OpportunityId = testOpportunity.Id,
            ContactId = testContact.Id,
            IsPrimary = true
        );
        
        insert testRole;
        
        ApexPages.currentPage().getParameters().put('id', testOpportunity.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
        
        OpportunityInvoicePageController controller = new OpportunityInvoicePageController(stdController);
        
        System.assertEquals(testOpportunity.Id, controller.oppt.Id);
        System.assertEquals(testAccount.Id, controller.account.Id);
        System.assertEquals('Testing', controller.opportunityOwner);
    }
}