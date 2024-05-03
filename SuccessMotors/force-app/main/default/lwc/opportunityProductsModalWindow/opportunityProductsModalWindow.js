import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getOpportunityProducts from '@salesforce/apex/ExtentedInformationAboutAccountClass.getOpportunityProducts';

const columns = [
    { label: 'Product Name', fieldName: 'name', type: 'text' },
    { label: 'Quantity', fieldName: 'quantity', type: 'text', cellAttributes: { alignment: 'center' }},
    { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency', cellAttributes: { alignment: 'center' } },
    { label: 'Total Price', fieldName: 'totalPrice', type: 'currency', cellAttributes: { alignment: 'center' }},
];

export default class OpportunityProductsModalWindow extends LightningModal {
    @api opportunityId;
    products;
    error;
    data = [];
    columns = columns;

    connectedCallback() {
        getOpportunityProducts({ opportunityId: this.opportunityId})
            .then(result => {
                this.products = result;
                const data = this.generateData();
                this.data = data;
            })
            .catch(error => {
                console.error('Ошибка при получении данных: ' + error);
            });
    }

    generateData() {
        return this.products.map(product => {
            return {
                name: product.Name,
                quantity: product.Quantity,
                unitPrice: product.UnitPrice,
                totalPrice: product.TotalPrice
            }
        })
    }

    handleClose(event) {
        this.close('Close');
    }
}