import { LightningElement, api, track } from 'lwc';

export default class XcScopedNotification extends LightningElement {

    /**
     * Message to display
     */
    @api message;

    /**
     * Variant (i.e. info, success, warning, or error)
     */
    @api variant = 'info'

    /**
     * Info flag
     */
    @track mIsInfo = false;

    /**
     * Success flag
     */
    @track mIsSuccess = false;

    /**
     * Warning flag
     */
    @track mIsWarning = false;

    /**
     * Error flag
     */
    @track mIsError = false;

    connectedCallback() {
        // Determines the type
        switch (this.variant) {
            case 'success':
                this.mIsSuccess = true;
                break;
            case 'warning':
                this.mIsWarning = true;
                break;
            case 'error':
                this.mIsError = true;
                break;
            default:
                this.mIsInfo = true;
                break;
        }
    }
}