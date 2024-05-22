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
                                                
        List<ContentDocumentLink> contentDocLinksToDelete = new List<ContentDocumentLink>();
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocLinksToInsert = new List<ContentDocumentLink>();                                        

        Boolean documentLinkflag = False;

        for(ContentDocumentLink contentDocumentLink : notesattch) {
            if(contentDocumentLink.ContentDocument.Title == 'INVOICE') {
                documentLinkflag = True;

                contentDocLinksToDelete.add(contentDocumentLink);
                ContentVersion conVer = createContentVersion(pdfBlob, contentDocumentLink.ContentDocument.Title);
                contentVersionsToInsert.add(conVer);
            }
        }

        if(!documentLinkflag) {
            ContentVersion conVer = createContentVersion(pdfBlob, 'INVOICE');
            contentVersionsToInsert.add(conVer);
        }

        if(!contentVersionsToInsert.isEmpty()) {
            insert contentVersionsToInsert;
            for(ContentVersion conVer : contentVersionsToInsert) {
                Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
                contentDocLinksToInsert.add(createContentDocumentLink(contentDocId));
            }
        }

        if(!contentDocLinksToDelete.isEmpty()) {
            delete contentDocLinksToDelete;
        }
    
        if(!contentDocLinksToInsert.isEmpty()) {
            insert contentDocLinksToInsert;
        }

        PageReference opp = new PageReference('/' + Id);
        opp.setRedirect(True);
        return opp;
    }

    private ContentVersion createContentVersion(Blob pdfBlob, String title) {
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = title + '.pdf';
        conVer.Title = title;
        conVer.VersionData = pdfBlob;
    
        System.debug(conVer);
    
        return conVer;
    }
    
    private ContentDocumentLink createContentDocumentLink(Id contentDocumentId) {
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.LinkedEntityId = Id;
        contentDocLink.ContentDocumentId = contentDocumentId;
        contentDocLink.shareType = 'V';
    
        return contentDocLink;
    }
}