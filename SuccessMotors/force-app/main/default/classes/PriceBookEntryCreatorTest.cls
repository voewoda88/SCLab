@isTest
public class PriceBookEntryCreatorTest {
    @isTest
    static void testCreatePriceBookEntries() {
        List<Product2> products = new List<Product2>();
        for(Integer i = 0; i < 5; i++) {
            Product2 prod = new Product2(Name='Test Product ' + i);
            products.add(prod);
        }
        
        insert products;
        
        Pricebook2 testPricebook = new Pricebook2(Name='SuccessMotorsPriceBook');
        insert testPricebook;
                
        Test.startTest();
        Integer entriesCount = PriceBookEntryCreator.createPriceBookEntries(products, testPricebook.Id, Test.getStandardPricebookId());
        Test.stopTest();
       
        System.assertEquals(products.size(), entriesCount, 'Incorrect number of PricebookEntry records created');
    }
}