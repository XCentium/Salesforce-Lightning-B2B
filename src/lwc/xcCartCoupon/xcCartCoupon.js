import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

import addPromo from '@salesforce/apex/XC_CouponAPI.addPromo';
import removePromo from '@salesforce/apex/XC_CouponAPI.removePromo';
import getCoupon from '@salesforce/apex/XC_CouponAPI.getCoupon';
import calculateDiscount from '@salesforce/apex/XC_CouponAPI.calculateDiscount';

// Event name constants
const COUPON_CHANGE_EVT = 'couponchanged';
const COUPON_REMOVE_EVT = 'couponremoved';

export default class XcCartCoupon extends LightningElement {

    /**
     * Cart ID
     */
    @api mCartId;

    /**
     * Currently applied coupon code
     */
    mCode = null;

    /**
     * Currently applied coupon name
     */
    @track mCouponName = null;

    /**
     * Coupon applied flag
     */
    @track mHasCoupon = false;

    /**
     * Error message to display
     */
    @track mErrorMsg;

    /**
     * Show error flage
     */
    @track mShowError = false;

    /**
     * Loaded flag
     */
    @track mLoaded = false;

    /**
     * Operation in progress flag
     */
    @track mOpInProgress = false;

    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    pageRef;

    connectedCallback() {
        registerListener(
            COUPON_REMOVE_EVT,
            this.handlePubSubRemove,
            this
        );

        getCoupon({
            inputData: {
                cartId: this.mCartId
            }
        }).then(result => {
            this.mHasCoupon = result.hasCoupon;
            this.mCode = result.code;
            this.mCouponName = result.name;
            this.mLoaded = true;
        })
        .catch(error => {
            console.error(error);
            this.mLoaded = true;
        });
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    /**
     * Calculates the discount.
     */
    calculateDiscount() {
        calculateDiscount({
            inputData: {
                cartId: this.mCartId
            }
        }).then(result => {
            fireEvent(this.pageRef, COUPON_CHANGE_EVT);
        })
        .catch(error => {
            console.error(error);
            fireEvent(this.pageRef, COUPON_CHANGE_EVT);
        });
    }

    /**
     * Applies promo code.
     */
    applyPromo() {
        this.mOpInProgress = true;
        addPromo({
            inputData: {
                cartId: this.mCartId,
                code: this.template.querySelector('textarea').value
            }
        }).then(result => {
            this.mErrorMsg = null;
            this.mShowError = false;
            this.mHasCoupon = result.success;
            this.mCode = result.code;
            this.mCouponName = result.name;
            this.mOpInProgress = false;
            this.calculateDiscount();
        })
        .catch(error => {
            this.mErrorMsg = error.body.message;
            this.mShowError = true;
            this.mOpInProgress = false;
        });
    }

    /**
     * Handles key press event
     * @param {*} e the event object
     */
    handleKeyPress(e) {
        // Checks for enter key
        if (13 === e.keyCode) {
            this.applyPromo();
            e.preventDefault();
        }
    }

    /**
     * Handles apply click event
     * @param {*} e the event object
     */
    handleApply(e) {
        this.applyPromo();
    }

    /**
     * Handles coupon remove.
     * @param {*} e the event object
     */
    handleRemove(e) {
        this.mOpInProgress = true;
        removePromo({
            inputData: {
                cartId: this.mCartId
            }
        }).then(result => {
            this.mCode = null;
            this.mHasCoupon = false;
            this.mOpInProgress = false;
            this.calculateDiscount();
        })
        .catch(error => {
            this.mOpInProgress = false;
        });
    }

    /**
     * Handle pubsub remove coupon.
     */
    handlePubSubRemove() {
        this.mCode = null;
        this.mCouponName = null;
        this.mHasCoupon = false;
    }
}