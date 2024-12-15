trigger PaymentTrigger on Payment__c(after insert) {
    try {
        List<String> opptsNames = new List<String>();

        for(Payment__c payment : Trigger.new) {
            if(payment.OpportunityName__c != null) {
                opptsNames.add(payment.OpportunityName__c);
            }
        } 

        Map<String, Opportunity> opptsMap = new Map<String, Opportunity>();
        if(!opptsNames.isEmpty()) {
            for(Opportunity oppt : [SELECT Id, Name, Amount, PaymentStatus__c FROM Opportunity WHERE Name IN :opptsNames]) {
                opptsMap.put(oppt.Name, oppt);
            }
        } else {
            throw new AuraHandledException('Opportunity Name list is empty');
        }

        List<Opportunity> opptsToUpdate = new List<Opportunity>();

        TaskCreator taskCreator = new TaskCreator();

        for(Payment__c payment : Trigger.new) {
            if(payment.OpportunityName__c != null && opptsMap.containsKey(payment.OpportunityName__c)) {
                Opportunity relatedOppt = opptsMap.get(payment.OpportunityName__c);

                if(relatedOppt.PaymentStatus__c.equals('Fully Paid')) {
                    taskCreator.createPaidTask(payment, relatedOppt.Id, payment.Amount__c);
                    break;
                }

                Decimal opptAmount = relatedOppt.Amount;
                if(relatedOppt.PaymentStatus__c.equals('Partially Paid')) {
                    Decimal paymentAmount = 0;
                    for(Payment__c tmpPayment : [SELECT Id, Amount__c FROM Payment__c WHERE OpportunityName__c = :relatedOppt.Name]) {
                        paymentAmount += tmpPayment.Amount__c;
                    }
                    System.debug(paymentAmount);
                    paymentAmount = paymentAmount + payment.Amount__c;
                    System.debug(paymentAmount);
                    if(paymentAmount == opptAmount) {
                        relatedOppt.PaymentStatus__c = 'Fully Paid';
                        taskCreator.createDeliveryTask(payment, relatedOppt.Id);
                    } else if(paymentAmount >= opptAmount) {
                        relatedOppt.PaymentStatus__c = 'Fully Paid';
                        taskCreator.createPaidTask(payment, relatedOppt.Id, paymentAmount - opptAmount);
                    }
                    break;
                }

                if(payment.Amount__c == opptAmount) {
                    relatedOppt.PaymentStatus__c = 'Fully Paid';
                    relatedOppt.StageName = 'Closed Won';
                    taskCreator.createDeliveryTask(payment, relatedOppt.Id);
                } else if(payment.Amount__c < opptAmount) {
                    relatedOppt.PaymentStatus__c = 'Partially Paid';
                }

                opptsToUpdate.add(relatedOppt);
            } 
        }

        if(!opptsToUpdate.isEmpty()) {
            update opptsToUpdate;
        }

    } catch(Exception e) {
        System.debug('Error: ' + e.getMessage());
        throw e;
    }
}