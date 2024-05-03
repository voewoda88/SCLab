public with sharing class ExtentedInformationAboutAccountClass {    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getAccountOpportunities(Id accountId) {
        try {
            List<Opportunity> oppts = [SELECT Id, Name, CreatedDate, CloseDate, Amount, AccountId
                                       FROM Opportunity
                                       WHERE AccountId =: accountId];
            System.debug('List Of Opportunitites: ' + oppts);
            
            return oppts;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityProducts(Id opportunityId) {
        try {
            List<OpportunityLineItem> products = [SELECT OpportunityId, Name, Quantity, UnitPrice, TotalPrice
                                                  FROM OpportunityLineItem
                                                  WHERE OpportunityId =: opportunityId];
            System.debug('Opportunity products: ' + products);
            
            return products;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Properties getAccounts(String searchKey, Decimal maxAmount, Integer pageNumber) {
        try {
            String searchPattern = '%' + searchKey + '%';
            Decimal safeMaxAmount = maxAmount;
            Integer safePageSize = 10;
            Integer safePageNumber = pageNumber;

            Integer offset = (safePageNumber - 1) * safePageSize;

            Properties properties = new Properties();
            properties.pageNumber = safePageNumber;
            properties.pageSize = safePageSize;

            List<Account> accounts = [SELECT Id, Name
                                      FROM Account
                                      WHERE Name LIKE :searchPattern
                                      ORDER BY Name ASC];
            System.debug('Accounts: ' + accounts);
            
            Integer accountIndex = 0;
            List<CustomAccountTemplate> accountsTemplateList = createAccountTemplateList(accounts, safeMaxAmount);
            properties.totalItemCount = accountsTemplateList.size();
            accountsTemplateList = checkedAccountTemplateList(accountsTemplateList, safeMaxAmount, offset);

            properties.accounts = accountsTemplateList;

            return properties;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<CustomAccountTemplate> checkedAccountTemplateList(List<CustomAccountTemplate> accountsTemplateList, Decimal safeMaxAmount, Integer offset) {

        if(accountsTemplateList.size() < 10) {
            return accountsTemplateList;
        }

        Integer index = 0;
        Boolean removeFlag = false;

        if(offset == 0) {
            index = accountsTemplateList.size() - 10;
        } else {
            index = offset;
            removeFlag = true;
        }

        for(Integer i = 0; i < index; i++) {
            if(!removeFlag) {
                accountsTemplateList.remove(accountsTemplateList.size() - 1);
            } else {
                accountsTemplateList.remove(0);
            }
        }

        return accountsTemplateList;
    }

    private static List<CustomAccountTemplate> createAccountTemplateList(List<Account> accounts, Decimal safeMaxAmount) {
        List<CustomAccountTemplate> accountsTemplateList = new List<CustomAccountTemplate>();

        for(Account account : accounts) {
            CustomAccountTemplate accountTemplate = new CustomAccountTemplate();
            accountTemplate.account = account;

            Decimal amount = 0;

            List<Opportunity> oppts = [SELECT Id, Name, Amount
                                       FROM Opportunity
                                       WHERE AccountId =: account.Id];
            
            for(Opportunity oppt : oppts) {
                amount = amount + oppt.Amount;
            }

            if(amount == 0 || amount > safeMaxAmount) {
                continue;
            } else {
                accountTemplate.account.Name = accountTemplate.account.Name + '(Amount: ' + amount + ')';
                accountTemplate.amount = amount;
                accountsTemplateList.add(accountTemplate);
            }
        }

        return accountsTemplateList;
    }
}