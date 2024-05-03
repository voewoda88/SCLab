import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';

const DELAY = 350;

export default class ExtentedAccountFilter extends LightningElement {
    searchKey = '';
    maxAmount = 4000000;

    @wire(MessageContext)
    messageContext;

    handleSearchKeyChange(event) {
        this.searchKey = event.detail.value;
        this.fireChangeEvent();
    }

    handleMaxAmountChange(event) {
        this.maxAmount = event.detail.value;
        this.fireChangeEvent();
    }

    fireChangeEvent() {
        // Debouncing this method: Do not actually fire the event as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex
        // method calls in components listening to this event.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            const filters = {
                searchKey: this.searchKey,
                maxAmount: this.maxAmount
            };
            publish(this.messageContext, FILTERSCHANGEMC, filters);
        }, DELAY);
    }
}