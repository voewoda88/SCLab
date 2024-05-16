public with sharing class InboundInvoiceEmail implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String[] statusesToCompare = new String[] {'approved', 'rejected'};
        String[] opptStages = new String[]{};
                                                
        String request = email.plainTextBody;
        String[] requestParts = request.split('\\s*\\(\\s*|\\s*\\)\\s*');
        String invoiceNumber = requestParts[1];
        String notFormattedStatus = requestParts[2].replace('.', '');
		String status = notFormattedStatus.toLowerCase();
            
        System.debug(status);
            
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
                                      WHERE Invoice_Number__c =: invoiceNumber];
            
       	System.debug('Beginner opportunity: ' + oppt);
            
        if(oppt[0].StageName.equals(opptStages[8]) || oppt[0].StageName.equals(opptStages[9])) {
            System.debug('Opportunity already been closed');
            result.success = true;
            return result;
        }
            
        Integer statusFlag = -1;
            
        if(status.equals('approved')) {
            System.debug('Status is approved');
            statusFlag = 0;
        }
            
        if(status.equals('rejected')) {
            System.debug('Status is reject');
            statusFlag = 1;
        }
            
        if(statusFlag == -1) {
            System.debug('No a singe test has been passed');
            result.success = true;
            return result;
        }
            
        Integer i = 0;
        List<Opportunity> oppts = new List<Opportunity>();
        for(String stage : opptStages) {
            if(stage.equals(oppt[0].StageName)) {
            	if(statusFlag == 1) {
                    oppt[0].StageName = opptStages[9];
                }
                if(statusFlag == 0) {
                    oppt[0].StageName = opptStages[i + 1];
                }
                System.debug('Updated Opportunity: ' + oppt[0]);
                oppts.add(oppt[0]);
                break;
            }
        	i++;
        }

        update oppts;
        
        result.success = true;
        return result; 
    }
}