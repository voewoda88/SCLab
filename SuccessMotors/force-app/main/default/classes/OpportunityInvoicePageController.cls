public without sharing class OpportunityInvoicePageController {
   	
    public Opportunity oppt {get; set;}
    public Account account {get; set;}
    public String opportunityOwner {get; set;}
    public String invoiceDate {get; set;}
    public List<OpportunityContactRole> contact {get; set;}
    public List<OpportunityLineItem> opportunityProducts {get; set;}
    public Decimal totalBalance {get; set;}
    
    public OpportunityInvoicePageController(ApexPages.StandardSetController controller) {
        controller.setPageSize(1);
    }

    public OpportunityInvoicePageController(ApexPages.StandardController stdController) {
        Id opptyID = ApexPages.currentPage().getParameters().get('id');

        System.debug(opptyID);

        this.oppt = [SELECT AccountId, OwnerId, Invoice_Number__c 
                     FROM Opportunity
                     WHERE Id =: ApexPages.currentPage().getParameters().get('id')
                    ];
        System.debug(this.oppt);
        
        this.account = [SELECT Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                        FROM Account
                        WHERE Id =: this.oppt.AccountId
                       ];

        User opportunityOwnerUser = [SELECT Name
                                     FROM User
                                     WHERE Id =: this.oppt.OwnerId
                                    ];
        
        opportunityOwner = opportunityOwnerUser.Name;

        Datetime todayDate = Datetime.now();
        invoiceDate = todayDate.format('dd.MM.yyyy');

        this.contact = [SELECT Contact.Name, Contact.Account.Name, Contact.Phone, Contact.Email, IsPrimary
                        FROM OpportunityContactRole
                        WHERE OpportunityId =: ApexPages.currentPage().getParameters().get('id')
                        AND IsPrimary = true
                       ];
                       
        this.opportunityProducts = [SELECT OpportunityId, Name, Quantity, UnitPrice, TotalPrice
                                    FROM OpportunityLineItem
                                    WHERE OpportunityId =: ApexPages.currentPage().getParameters().get('id')
                                   ];
        
                                   
        Decimal tmpBalance = 0;                           
        for(OpportunityLineItem oli : this.opportunityProducts) {
            tmpBalance += oli.TotalPrice;
        }                           
        
        this.totalBalance = tmpBalance;
        
    }
}