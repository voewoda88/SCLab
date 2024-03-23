# SC: Laboratory

Цель: Разработать приложение для управления процессами компании по продаже автомобилей и запчастей используя среду разработки Salesforce. 

## Этап 1

Разработка веб-формы генерации заявок для сайта компании, а также автоматизация простейших бизнес-процессов.

### Шаг 1. Загрузка каталога продуктов с помощью DataLoader

Установив весь необходимый софт и связав его с организацией, была произведена загрузка каталога([Success](https://github.com/voewoda88/SCLab/blob/stage1/Data%20Loader%20Info/success031524070632475.csv) | [Error](https://github.com/voewoda88/SCLab/blob/stage1/Data%20Loader%20Info/error031524070632476.csv)). Предварительно было создано пользовательское поле Product Type(Type__c - picklist) и установлены значения:

1. Car
2. Part
3. Accessory

Данные значения являются стандартными и никакие другие установлены быть не могут. Настройки поля Product Type [здесь](https://successcraft-7b-dev-ed.develop.lightning.force.com/lightning/setup/ObjectManager/Product2/FieldsAndRelationships/00NIR000009lGZ5/view).

P.S. После загрузки данных, в орге оставались стандартные данные, которые я принялся удалять. Только недавно заметил, что я зацепил пару данных, которые были в файле. Но они были загружены, это можно увидеть в отчете.

### Шаг 2. Реализация Web-To-Lead формы

Перед генерированием была настроена Google reCAPTCHA(Установлены соответствующие настройки и получены необходимые ключи). После получения формы, был установлен весь необходимый софт и производена настройка платформы Firebase для последующей постановки формы на хостинг. После того, как был произведен тестовый deploy формы, я приступил к написанию разметки. 

Исходный код формы: [тык](https://github.com/voewoda88/SCLab/tree/stage1/Web%20Form).

Ссылка на форму: [тык](https://successmotors-417317.web.app).

Также, для объекта Lead было создано пользовательское поле Product(Product__c - text). Настройки данного поля можно увидеть [здесь](https://successcraft-7b-dev-ed.develop.lightning.force.com/lightning/setup/ObjectManager/Lead/FieldsAndRelationships/00NIR000009lGZF/view). 

При отправке формы на организацию она корректно конвертируется в объект типа Lead.

### Шаг 3. Реализация алгоритмов для бизнес-процессов

#### 3.1 Планирование задач для менеджеров

Реализация планирования задач для менеджеров была произведена с помощью инструмента Process Builder. С его помощью был реализован алгоритм для создания напоминания при создании объекта Contact. Все поля для объекта Task были заполнены в соответствии с требованиями. Настройки алгоритма можно посмотреть [здесь](https://successcraft-7b-dev-ed.develop.lightning.force.com/lightning/setup/ProcessAutomation/home).

#### 3.2 Подготовка opportunity.

Перед созданием объектов Price Book Entry была создана книга цен SuccessMotorsPriceBook. Данную запись можно посмотреть [здесь](https://successcraft-7b-dev-ed.develop.lightning.force.com/lightning/r/Pricebook2/01sIR000004D6MuYAK/view). 

Для создания объектов Price Book Entry был написан скрипт на APEX:

```java
public class PriceBookEntryCreator {
    public static Integer createPriceBookEntries(List<Product2> products, Id priceBookId, Id standartPriceBookId) {
        
  		List<PricebookEntry> priceBookEntriesToInsert = new List<PricebookEntry>();
        
        for(Product2 product : products) {
            PricebookEntry priceBookStandartEntry = new PricebookEntry(
            	Product2Id = product.Id,
                Pricebook2Id = standartPriceBookId,
                UnitPrice = generateRandomUnitPrice(),
                UseStandardPrice = false,
                IsActive = true
            );
            
            insert priceBookStandartEntry;
            
            PricebookEntry priceBookEntry = new PricebookEntry(
            	Product2Id = product.Id,
                Pricebook2Id = priceBookId,
                UnitPrice = generateRandomUnitPrice(),
                UseStandardPrice = false,
                IsActive = true
            );
            
            priceBookEntriesToInsert.add(priceBookEntry);
            
            insert priceBookEntry;
        }
        
        return priceBookEntriesToInsert.size();
    }
    
    private static Decimal generateRandomUnitPrice() {
        return Math.round(Math.random() * 100 * 100) / 100;
    }
}
```
Перед вызовом функции createPriceBookEntries нужно выполнить необходимые запросы и получить список продуктов, ID книги цен и ID стандартной книги цен. Данные переменные передать как аргументы функции в необходимом порядке.

Unit-Test для данного класса: 

```java
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
```

Для того, чтобы связать наши созданные объекты с Opportunity использовался инструмент Flow Builder. Был реализован алгоритм для создания объекта Opportunity Product, который выполняется каждый раз при конвертации объекта Lead. Реализацию можно посмотреть [здесь](https://successcraft-7b-dev-ed.develop.lightning.force.com/builder_platform_interaction/flowBuilder.app?flowId=301IR0000009jzpYAA).
