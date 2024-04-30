public without sharing class OpportunityInvoiceModalWindowController {
    public String Id {get; set;}

    public OpportunityInvoiceModalWindowController(ApexPages.StandardSetController controller) {
        controller.setPageSize(1);
    }
    
    public OpportunityInvoiceModalWindowController(ApexPages.StandardController stdController) {
        Id = ApexPages.currentPage().getParameters().get('id');
        System.debug(Id);
    }

    public PageReference cancel() {
        PageReference opp = new PageReference('/' + Id);
        opp.setRedirect(True);
        return opp;
    }
    
    public PageReference pdfSave() {
        PageReference pageToSave;
        pageToSave = Page.opportunityInvoicePage;
        pageToSave.getParameters().put('id', Id);
        
        System.debug('Id: ' + Id);

        Blob pdfBlob;
        if(!Test.isRunningTest()) {
            pdfBlob = pageToSave.getContent();
        } else {
            pdfBlob = Blob.valueOf('Test');
        }

        System.debug(pdfBlob);
        
        List<ContentDocumentLink> notesattch = [SELECT id, ContentDocument.Title, LinkedEntityId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =: Id 
                                                ORDER BY ContentDocument.Title ASC];
        
        Boolean documentLinkflag = False;

        for(ContentDocumentLink contentDocumentLink : notesattch) {
            if(contentDocumentLink.ContentDocument.Title == 'INVOICE') {
                documentLinkflag = True;

                ContentVersion conVer = getContentVersionDocument(pdfBlob, contentDocumentLink.ContentDocument.Title);

                Id contentDocId = [SELECT ContentDocumentId 
                                   FROM ContentVersion 
                                   WHERE Id =: conVer.Id].ContentDocumentId;

                DELETE contentDocumentLink;

                getContentDocumentLink(contentDocId);
            }
        }

        if(!documentLinkflag) {
            ContentVersion conVer = getContentVersionDocument(pdfBlob, 'INVOICE');
            
            Id contentDocId = [SELECT ContentDocumentId 
                               FROM ContentVersion 
                               WHERE Id =: conVer.Id].ContentDocumentId;
        
            getContentDocumentLink(contentDocId);
        }

        PageReference opp = new PageReference('/' + Id);
        opp.setRedirect(True);
        return opp;
    }

    private ContentVersion getContentVersionDocument(Blob pdfBlob, String title) {
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = title + '.pdf';
        conVer.Title = title;
        conVer.VersionData = pdfBlob;

        System.debug(conVer);

        INSERT conVer;

        return conVer;
    }

    private ContentDocumentLink getContentDocumentLink(Id contentDocumentId) {
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.LinkedEntityId = Id;
        contentDocLink.ContentDocumentId = contentDocumentId;
        contentDocLink.shareType = 'V';

        INSERT contentDocLink;

        return contentDocLink;
    }
}