@isTest
public class ExtendedInformationAboutAccountTest {
	@isTest
    static void testGetAccountOpportunities() {
        Account testAccount = new Account(
        	Name = 'Test Account'
        );
            
       	insert testAccount;
        
        Opportunity testOpportunity1 = new Opportunity(
            Name = 'Test Opportunity 1',
            StageName = 'Prospecting',
            AccountId = testAccount.Id,
            CloseDate = Date.today() + 30,
            Amount = 1000
        );
        
        Opportunity testOpportunity2 = new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Prospecting',
            AccountId = testAccount.Id,
            CloseDate = Date.today() + 60,
            Amount = 2000
        );
        
        List<Opportunity> testOpportunities = new List<Opportunity>{testOpportunity1, testOpportunity2};
        
        insert testOpportunities;
        
        List<Opportunity> result = ExtentedInformationAboutAccountClass.getAccountOpportunities(testAccount.Id);
        
        System.assertNotEquals(null, result);
        // Проверка, что результат содержит ожидаемое количество сделок
        System.assertEquals(2, result.size());
        // Проверка, что результат содержит ожидаемые сделки
        System.assertEquals(testOpportunity1.Name, result[0].Name);
        System.assertEquals(testOpportunity2.Name, result[1].Name);
    }
    
	@isTest
    static void testGetOpportunityProducts() {
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity', 
            StageName = 'Prospecting', 
            CloseDate = Date.today() + 30
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
        
        List<OpportunityLineItem> result = ExtentedInformationAboutAccountClass.getOpportunityProducts(testOpportunity.Id);
        
        System.assertEquals('Test Opportunity Test Product', result[0].Name);
    }
    
    @isTest
    static void testGetAccounts1() {
        List<Account> testAccounts = new List<Account> {
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };
        
        insert testAccounts;
        
        Opportunity testOpportunity1 = new Opportunity(
            Name = 'Test Opportunity 1',
            StageName = 'Prospecting', 
            CloseDate = Date.today() + 30,
            AccountId = testAccounts[0].Id,
            Amount = 1000
        );
        
        insert testOpportunity1;
        
        Properties result =  ExtentedInformationAboutAccountClass.getAccounts('', 2000, 1);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.accounts.size());
    }
    
    @isTest
    static void testGetAccounts2() {
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 10; i++) {
        	Account testAccount = new Account(Name = 'Test Account ' + i);
            testAccounts.add(testAccount);
       	}
        
        insert testAccounts;
        
        Integer index = 1;
        for(Account account : testAccounts) {
            Opportunity testOpportunity = new Opportunity(
            	Name = 'Test Opportunity ' + index,
            	StageName = 'Prospecting', 
            	CloseDate = Date.today() + 30,
            	AccountId = account.Id,
            	Amount = 1000
        	);
            
            insert testOpportunity;
            
            index = index + 1;
        }
        
        Properties result =  ExtentedInformationAboutAccountClass.getAccounts('', 2000, 1);
        System.assertNotEquals(null, result);
        System.assertEquals(10, result.accounts.size());
    }
    
    @isTest
    static void testGetAccount3() {
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 15; i++) {
        	Account testAccount = new Account(Name = 'Test Account ' + i);
            testAccounts.add(testAccount);
       	}
        
        insert testAccounts;
        
        Integer index = 1;
        for(Account account : testAccounts) {
            Opportunity testOpportunity = new Opportunity(
            	Name = 'Test Opportunity ' + index,
            	StageName = 'Prospecting', 
            	CloseDate = Date.today() + 30,
            	AccountId = account.Id,
            	Amount = 1000
        	);
            
            insert testOpportunity;
            
            index = index + 1;
        }
        
        Properties result =  ExtentedInformationAboutAccountClass.getAccounts('', 2000, 2);
        System.assertNotEquals(null, result);
        System.assertEquals(5, result.accounts.size());
    }
}