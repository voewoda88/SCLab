import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getEmail from '@salesforce/apex/SendIvoiceController.getEmail';
import getContact from '@salesforce/apex/SendIvoiceController.getContact';
import sendEmail from '@salesforce/apex/SendIvoiceController.sendEmail';

export default class SendInvoice extends LightningElement {
    @api recordId;
    emailSubject;
    @track emailBody;
    error;
    contactName;
    contactEmail;

    disabledCategories = [
        'FORMAT_FONT',
        'FORMAT_TEXT',
        'FORMAT_BODY',
        'ALIGN_TEXT',
        'INSERT_CONTENT',
        'REMOVE_FORMATTING'
    ]

    @wire(getEmail, { opportunityId: '$recordId' })
    wiredEmail({ error, data}) {
        if(data) {
            this.emailSubject = data[0];
            this.emailBody = data[1];
            this.error = undefined;
        } else {
            this.emailSubject = undefined;
            this.emailBody = undefined;
            this.error = error;
        }
    }

    @wire(getContact, {opportunityId: '$recordId'})
    wiredContact({ error, data }) {
        if(data) {
            this.contactName = data[0];
            this.contactEmail = data[1];
            error = undefined;
        } else {
            this.contactName = undefined;
            this.contactEmail = undefined;
            this.error = error;
        }
    }

    handleSend(event) {
        this.emailBody = this.template.querySelector('lightning-input-rich-text').value;

        let customEmailTemplate = {
            emailSubject: this.emailSubject,
            emailBody: this.emailBody,
            contactName: this.contactName,
            contactEmail: this.contactEmail,
            opptId: this.recordId
        }

        let flag = sendEmail({ customEmail: customEmailTemplate });
        if(flag) {
            const toastEvent = new ShowToastEvent({
                title: "Mail has been sent!",
                message: "Your have succesfully sent a mail.",
                variant: "success"
            });
            this.dispatchEvent(toastEvent);
        } else {
            const toastEvent = new ShowToastEvent({
                title: "Mail hasn't been sent!",
                message: "There was a problem sending your email",
                variant: "error"
            })
            this.dispatchEvent(toastEvent);
        }

        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handlePreview(event) {
        let page = '/apex/opportunityInvoicePage?id=' + this.recordId;
        window.open(page);
    }
}