@RestResource(urlMapping='/payments/*')
global with sharing class PaymentManager {
    @HttpPost
    global static String createPayment(List<Payment__c> payments) {
        RestRequest req = RestContext.request;
        String authHeader = req.headers.get('Authorization');
        System.debug(payments);
        System.debug(req);
        System.debug(authHeader);

        return 'Okay';     
    }

    @HttpGet
    global static String getMethod() {
        return 'OKAY';
    }
}