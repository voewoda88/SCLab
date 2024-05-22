public class PriceBookEntryCreator {
    public static Integer createPriceBookEntries(List<Product2> products, Id priceBookId, Id standartPriceBookId) {
        
  		List<PricebookEntry> priceBookEntriesToInsert = new List<PricebookEntry>();
        List<PricebookEntry> standartPriceBookEntries = new List<PricebookEntry>();
        
        for(Product2 product : products) {
            PricebookEntry priceBookStandartEntry = new PricebookEntry(
            	Product2Id = product.Id,
                Pricebook2Id = standartPriceBookId,
                UnitPrice = generateRandomUnitPrice(),
                UseStandardPrice = false,
                IsActive = true
            );
            
            standartPriceBookEntries.add(priceBookStandartEntry);
            
            PricebookEntry priceBookEntry = new PricebookEntry(
            	Product2Id = product.Id,
                Pricebook2Id = priceBookId,
                UnitPrice = generateRandomUnitPrice(),
                UseStandardPrice = false,
                IsActive = true
            );
            
            priceBookEntriesToInsert.add(priceBookEntry);
        }
        
        insert standartPriceBookEntries;
        insert priceBookEntriesToInsert;
        
        return priceBookEntriesToInsert.size();
    }
    
    private static Decimal generateRandomUnitPrice() {
        return Math.round(Math.random() * 100 * 100) / 100;
    }
}