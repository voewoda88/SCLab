import { LightningElement, wire, api } from 'lwc';
import OpportunityProductsModalWindow from 'c/opportunityProductsModalWindow';
import getAccountOpportunities from '@salesforce/apex/ExtentedInformationAboutAccountClass.getAccountOpportunities';

const actions = [
    { label: 'Show opportunity', name: 'show_oppt' },
    { label: 'Opportunity Products', name: 'oppt_products'},
];

const columns = [
    { label: 'Opportunity Name', fieldName: 'name', type: 'text' },
    { label: 'Created Date', fieldName: 'createdDate', type: 'date' },
    { label: 'Close Date', fieldName: 'closeDate', type: 'date' },
    { label: 'Amount', fieldName: 'amount', type: 'currency', cellAttributes: { alignment: 'center' }},
    {
        type: 'action', 
        typeAttributes: { rowActions: actions },
    }
];

export default class AccordionAccountInformation extends LightningElement {
    @api accountid;
    @api label;
    opportunities;
    error;
    data = [];
    columns = columns;

    @wire(getAccountOpportunities, { accountId: '$accountid' })
    getOpportunities({ error, data }) {
        if(data) {
            this.opportunities = data;
            this.error = undefined;
        } else {
            this.opportunities = undefined;
            this.error = error;
        }
    }

    handleSectionToggle(event) {
        const data = this.generateData();
        this.data = data;
    }

    generateData() {
        return this.opportunities.map(opportunity => {
            return {
                name: opportunity.Name,
                createdDate: opportunity.CreatedDate,
                closeDate: opportunity.CloseDate,
                amount: opportunity.Amount,
                opptId: opportunity.Id
            }
        })
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const opptId = row.opptId;

        switch(actionName) {
            case 'show_oppt':
                window.location.href = '/' + opptId;
                break;
            case 'oppt_products':
                this.createOpportunityProductsModalWindow(opptId);
                break;
        }
    }

    createOpportunityProductsModalWindow(opptId) {
        try {
            OpportunityProductsModalWindow.open({
                opportunityId: opptId,
                size: 'medium'
            }).then((result) => {
                console.log(result);
            })
        } catch(error) {
            cosole.error('Ошибка при открытии модального окна: ', error.message);
        }
    }
}