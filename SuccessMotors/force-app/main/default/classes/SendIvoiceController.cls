public with sharing class SendIvoiceController {
    @AuraEnabled(cacheable=true)
    public static List<String> getEmail(Id opportunityId){
        try {
           List<String> dataFromEmails = new List<String>();
           
           EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE name = 'Opportunity Invoice Template'];

           Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, opportunityId);
           
           dataFromEmails.add((String)email.Subject);
           dataFromEmails.add((String)email.getHtmlBody());
           
           System.debug(dataFromEmails);

           return dataFromEmails;
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getContact(Id opportunityId) {
        try {
            List<OpportunityContactRole> contact = [SELECT Contact.Name, Contact.Account.Name, Contact.Phone, Contact.Email, IsPrimary
                                                    FROM OpportunityContactRole
                                                    WHERE OpportunityId =: opportunityId
                                                    AND IsPrimary = true ];
            System.debug(contact[0].Contact.Name);
            System.debug(contact[0].Contact.Email);
            
            List<String> contactInformation = new List<String>();
            contactInformation.add(contact[0].Contact.Name);
            contactInformation.add(contact[0].Contact.Email);

            return contactInformation;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean sendEmail(CustomEmailTemplate customEmail) {
        try {
            System.debug(customEmail);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            List<String> contentVersionIds = new List<String>();
            List<ContentDocumentLink> documentLinkList = [SELECT ContentDocument.Title, ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId =: customEmail.opptId AND ContentDocument.Title = 'INVOICE'];
            System.debug(documentLinkList); 

            contentVersionIds.add(documentLinkList[0].ContentDocument.LatestPublishedVersionId);

            String[] toAddresses =  new String[] {customEmail.contactEmail};

            mail.setToAddresses(toAddresses);
            mail.setSubject(customEmail.emailSubject);
            mail.setHtmlBody(customEmail.emailBody);
            mail.setEntityAttachments(contentVersionIds);
            mail.setReplyTo('inboundinvoiceemail@24rccilu6bawa9jsjc78rqkl1an6tq0weuxmsvy18dvdtcsn9c.ir-1lbh42ao.ap47.apex.salesforce.com');

            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            return inspectResults(results);      
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        for(Messaging.SendEmailResult res : results) {
            if(res.isSuccess()) {
                System.debug('Email send successfully');
            } else {
                sendResult = false;
                System.debug('The following errors occured: ' + res.getErrors());
            }
        }

        return sendResult;
    }
}