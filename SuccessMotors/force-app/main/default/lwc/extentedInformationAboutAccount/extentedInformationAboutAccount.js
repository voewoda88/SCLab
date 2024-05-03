import { LightningElement, api, wire } from 'lwc';
import getAccounts from '@salesforce/apex/ExtentedInformationAboutAccountClass.getAccounts';
import { publish, subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';

export default class ExtentedInformationAboutAccount extends LightningElement {
    @api recordId;
    properties;
    accountList;
    error;
    searchKey = '';
    maxAmount = 4000000;
    pageNumber = 1;
    pageSize = 10;
    totalItemCount;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.getAccountsList();
        this.subscription = subscribe(
            this.messageContext,
            FILTERSCHANGEMC,
            (message) => {
                this.handleFilterChange(message);
            }
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleFilterChange(filters) {
        this.searchKey = filters.searchKey;
        this.maxAmount = filters.maxAmount;
        this.properties = null;
        this.getAccountsList();
    }

    getAccountsList() {
        getAccounts({ searchKey: this.searchKey, maxAmount: this.maxAmount, pageNumber: this.pageNumber })
            .then(result => {
                this.properties = result;
                this.accountList = this.properties.accounts;
                this.totalItemCount = this.properties.totalItemCount;
            })
            .catch(error => {
                console.error('Ошибка при получении данных: ' + error);
            });
    }

    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.properties = null;
        this.getAccountsList();
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.properties = null;
        this.getAccountsList();
    }

    get isAppPage() {
        return location.pathname.startsWith('/lightning/n/');
    }

    get isRecordPage() {
        return location.pathname.startsWith('/lightning/r/');
    }
}