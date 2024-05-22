public with sharing class InboundInvoiceEmail implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String subject = email.subject;
        String requestBody = email.plainTextBody;
        String invoicePrefix = 'INV-';
        String statusApproved = 'approved';
        String statusRejected = 'rejected';

        System.debug('Request body: ' + requestBody);

        String invoiceNumber;
        Integer prefixIndex = subject.indexOf(invoicePrefix);
        if(prefixIndex != -1) {
            invoiceNumber = subject.substring(prefixIndex, subject.indexOf(')'));
            System.debug(invoiceNumber);
        } else {
            result.success = false;
            System.debug('Invoice number not found in subject');
            return result;
        }

        String status;
        if(requestBody.toLowerCase().contains(statusApproved)) {
            status = statusApproved;
        } else if (requestBody.toLowerCase().contains(statusRejected)) {
            status = statusRejected;
        } else {
            status = 'Incorrect input';
            result.success = false;
            System.debug('Status is incorrect');
            return result;
        }

        System.debug(status);

        List<String> opptStages = new List<String>();
        Schema.DescribeSObjectResult opportunityDescribe = Schema.SObjectType.Opportunity;
            
        Schema.DescribeFieldResult stageFieldDescribe = opportunityDescribe.fields.getMap().get('StageName').getDescribe();
            
        if (stageFieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
        	List<Schema.PicklistEntry> picklistValues = stageFieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry picklistEntry : picklistValues) {
        			opptStages.add(picklistEntry.getValue());
    			}
        } else {
           	System.debug('Field Stage is not a picklist.');
        }

        List<Opportunity> oppt = [SELECT Id, Name, StageName 
                                  FROM Opportunity 
                                  WHERE Invoice_Number__c = :invoiceNumber];
        
        if (oppt.isEmpty()) {
            result.success = false;
            System.debug('No opportunities found with the given invoice number');
            return result;
        }

        Opportunity opportunity = oppt[0];
        Integer statusFlag = status == statusApproved ? 0 : 1;

        if (opportunity.StageName.equals(opptStages[opptStages.size() - 1]) || opportunity.StageName.equals(opptStages[opptStages.size() - 2])) {
            System.debug('Opportunity already been closed');
            result.success = false;
            return result;
        }

        for(Integer i = 0; i < opptStages.size(); i++) {
            if(opptStages[i].equals(opportunity.StageName)) {
                if(statusFlag == 1) {
                    opportunity.StageName = opptStages[opptStages.size() - 1];
                    System.debug('Status is closed lost');
                } else if (statusFlag == 0 && i + 1 < opptStages.size()) {
                    opportunity.StageName = opptStages[i + 1];
                    System.debug('Status is approved');
                }
                System.debug('Updated Opportunity: ' + opportunity);
                break;
            }
        }

        update opportunity;

        result.success = true;
        return result;
    }
}