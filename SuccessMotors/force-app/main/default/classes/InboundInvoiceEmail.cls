public with sharing class InboundInvoiceEmail implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String subjectToCompare = 'Opportunity Invoice';
        String[] statusesToCompare = new String[] {'approved', 'rejected'};
        String[] opptStages = new String[] {'Prospecting', 'Qualification', 'Needs Analysis', 'Value Proposition', 
            								'Id. Decision Makers', 'Perception Analysis', 'Proposal/Price Quote', 
            								'Negotiation/Review', 'Closed Won', 'Closed Lost'};
        if(email.subject.equalsIgnoreCase(subjectToCompare)) {
            String request = email.plainTextBody;
            String[] requestParts = request.split('\\s*\\(\\s*|\\s*\\)\\s*');
            String invoiceNumber = requestParts[1];
            String notFormattedStatus = requestParts[2].replace('.', '');
			String status = notFormattedStatus.toLowerCase();
            
            List<Opportunity> oppt = [SELECT Id, Name, StageName 
                                      FROM Opportunity 
                                      WHERE Invoice_Number__c =: invoiceNumber];
            
            System.debug('Beginner opportunity: ' + oppt);
            
            if(oppt[0].StageName.equals(opptStages[8]) || oppt[0].StageName.equals(opptStages[9])) {
                System.debug('Opportunity already been closed');
                result.success = true;
                return result;
            }
            
            Integer statusFlag = -1;
            
            if(statusesToCompare[0].equals(status)) {
                System.debug('Status is approved');
                statusFlag = 0;
            }
            
            if(statusesToCompare[1].equals(status)) {
                System.debug('Status is reject');
                statusFlag = 1;
            }
            
            if(statusFlag == -1) {
                System.debug('No a singe test has been passed');
                result.success = true;
                return result;
            }
            
            Integer i = 0;
            for(String stage : opptStages) {
                if(stage.equals(oppt[0].StageName)) {
                    if(statusFlag == 1) {
                        oppt[0].StageName = opptStages[8];
                    }
                    if(statusFlag == 0) {
                        oppt[0].StageName = opptStages[i + 1];
                    }
                    System.debug('Updated Opportunity: ' + oppt[0]);
                   	update oppt;
                    break;
                }
                i++;
            }
        }
        
        result.success = true;
        return result; 
    }
}