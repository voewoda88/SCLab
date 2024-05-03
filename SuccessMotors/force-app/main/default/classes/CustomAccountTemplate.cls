public with sharing class CustomAccountTemplate {
    @AuraEnabled
    public Account account {get; set;}

    @AuraEnabled
    public Decimal amount {get; set;}
}