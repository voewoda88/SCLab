public with sharing class CustomEmailTemplate {
    @AuraEnabled
    public String emailSubject {get; set;}

    @AuraEnabled
    public String emailBody {get; set;}

    @AuraEnabled
    public String contactName {get; set;}

    @AuraEnabled
    public String contactEmail {get; set;}

    @AuraEnabled
    public Id opptId {get; set;}
}