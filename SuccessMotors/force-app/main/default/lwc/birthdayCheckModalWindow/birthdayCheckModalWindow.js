import { LightningElement } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import sheduleBatch from '@salesforce/apex/BirthdayNotificationController.sheduleBatch';
import scheduleCheck from '@salesforce/apex/BirthdayNotificationController.scheduleCheck';
import deleteSchedule from '@salesforce/apex/BirthdayNotificationController.deleteSchedule';
import runOnceBatch from '@salesforce/apex/BirthdayNotificationController.runOnceBatch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BirthdayCheckModalWindow extends LightningElement {
    batchVariable = 'Schedule batch';
    cronString = '';
    scheduleStatus;
    oneBatchCommand = 'Run once';

    connectedCallback() {
        this.checkSchedule();
    }

    checkSchedule() {
        scheduleCheck()
            .then(result => {
                this.scheduleStatus = result;
                if(this.scheduleStatus) {
                    this.batchVariable = 'Abort Batch';
                }
            })
            .catch(error => {
                console.error('Error checking schedule:', error);
            });
    }

    handleScheduleBatch(event) {
        const cronInputElement = this.template.querySelector('[data-id="cronInput"]');
        if(cronInputElement) {
            this.cronString = cronInputElement.value;
            if(this.cronString) {
                this.sheduleBatchMethod();
            }
        }
    }

    sheduleBatchMethod() {
        sheduleBatch({ cronExp: this.cronString, schedulerClassName: this.batchVariable })
            .then(result => {
                if(result) {
                    this.batchVariable = 'Abort Batch';
                    this.scheduleStatus = true;
                    this.showToast('Success', 'Scheduled job created successfully', 'success');
                    this.dispatchEvent(new CloseActionScreenEvent());
                } else {
                    this.showToast('Error', 'Error scheduling job', 'error');
                }
            })
    }

    handleAbortScheduleBatch(event) {
        deleteSchedule()
            .then(result => {
                this.scheduleStatus = result;
                if(this.scheduleStatus) {
                    this.batchVariable = 'Schedule batch';
                    this.showToast('Success', 'Scheduled job deleted successfully', 'success');
                    this.scheduleStatus = false;
                    this.cronString = '';
                }
            })
            .catch(error => {
                console.error('Error checking schedule:', error);
                this.showToast('Error', 'Scheduled job deletion error', 'error');
            });
    }

    handleRunOnce(event) {
        if(this.scheduleStatus) {
            this.showToast('Error', 'Scheduled job must be deleted', 'error');
        } else {
            runOnceBatch({ batchClassName: this.oneBatchCommand })
                .then(result => {
                    this.showToast('Success', 'A single batch was successfully launched', 'success');
                    this.dispatchEvent(new CloseActionScreenEvent());
                })
                .catch(error => {
                    console.error('Error launched single batch: ', error);
                    this.showToast('Error', 'Error launched single batch', 'error');
                })
        }    
    }

    handleCancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}