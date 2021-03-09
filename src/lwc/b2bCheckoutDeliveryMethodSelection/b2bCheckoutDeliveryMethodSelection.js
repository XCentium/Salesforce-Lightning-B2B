import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import COMMUNITYID from "@salesforce/community/Id";
import CURRENCY from "@salesforce/i18n/currency";

import fetchDeliveryMethods from "@salesforce/apex/B2B_SPC_ComponentController.fetchDeliveryMethods";
import setCartItemDeliveryGroup from "@salesforce/apex/B2B_SPC_ComponentController.setCartItemDeliveryGroup";

export default class B2bCheckoutDeliveryMethod extends LightningElement {
	// Custom Labels
	labels = {
		toast: {
			processingErrorTitle: "Processing Error"
			, deliveryMethodNotSelected: "Delivery method not selected"
		},
		component: {
			altPleaseWait: "Please wait..."
		}
	};

	communityId = COMMUNITYID;
	currency = CURRENCY;

	effectiveAccountId;
	cartId;
	webstoreId;

	// To be displayed in a radio button group
	carrierOptions = [];
	defaultCarrierOption;
	selectedCarrierOption;

	cartDeliveryGroupMethodId;

	//@track showLoadingSpinner = false;

	@api
	setProperties(webstoreId, effectiveAccountId, cartId) {
		this.webstoreId = webstoreId;
		this.effectiveAccountId = effectiveAccountId;
		this.cartId = cartId;
	}

	@api
	loadDeliveryMethods() {
		console.log("b2bCheckoutDeliveryMethod: loadDeliveryMethods()");
		console.log(
			"b2bCheckoutDeliveryMethod: effectiveAccountId:",
			this.effectiveAccountId
		);
		console.log(
			"b2bCheckoutDeliveryMethod: webstoreId:",
			this.webstoreId
		);
		console.log("b2bCheckoutDeliveryMethod: cartId:", this.cartId);

		fetchDeliveryMethods({
			cartId: this.cartId
		})
			.then((result) => {
				this.processResult(result);
			})
			.catch((error) => {
				this.processError(error);
			});
	}

	processResult(result) {
		const customEvent = new CustomEvent("loadingspinner", {
			detail: false,
			bubbles: true
		});

		this.dispatchEvent(customEvent);

		if (result) {
			this.processResults(result);
		}

		this.processMessages(result);
	}

	processResults(result) {
		console.log(
			"b2bCheckoutDeliveryMethod: processResults()",
			JSON.stringify(result)
		);

		if (result.selectedDeliveryMethodId) {
			const id = result.selectedDeliveryMethodId;

			this.defaultCarrierOption = id;
			this.selectedCarrierOption = id;

			console.log(
				"b2bCheckoutDeliveryMethod: processResults(): defaultCarrierOption:",
				this.defaultCarrierOption
			);

			const customEvent = new CustomEvent("deliverymethodchange", {
				detail: true,
				bubbles: true
			});

			this.dispatchEvent(customEvent);
		}

		if (result.cartDeliveryGroupMethods) {
			const methods = result.cartDeliveryGroupMethods;

			let carriers = [];

			// Get Carriers from Methods' DeliveryMethod
			for (const method of methods) {
				carriers.push({
					Name: method.DeliveryMethod.Carrier
				});
			}

			// Remove Duplicate Carrier entries
			const filteredCarriers = carriers.reduce((acc, current) => {
				const x = acc.find((item) => item.Name === current.Name);
				if (!x) {
					return acc.concat([current]);
				} else {
					return acc;
				}
			}, []);

			// Push Delivery Methods into new Carrier parent objects
			for (let carrier of filteredCarriers) {
				carrier.DeliveryMethods = [];

				for (const method of methods) {
					let defaultVal = false;

					if (method.DeliveryMethodId === this.defaultCarrierOption) {
						defaultVal = true;
					}

					if (method.DeliveryMethod.Carrier === carrier.Name) {
						carrier.DeliveryMethods.push({
							Id: method.DeliveryMethodId,
							CartDeliveryGroupMethodId: method.Id,
							CartDeliveryGroupId: method.CartDeliveryGroupId,
							ExternalProvider: method.ExternalProvider,
							Name: method.Name,
							ShippingFee: method.ShippingFee,
							isDefault: defaultVal
						});
					}
				}
			}

			this.carrierOptions = filteredCarriers;

			console.log(
				"b2bCheckoutDeliveryMethod: processResults(): carrierOptions:",
				JSON.stringify(this.carrierOptions)
			);
		}
	}

	handleCarrierSelectionChange(event) {
		console.log(
			"b2bCheckoutDeliveryMethod: handleCarrierSelectionChange()"
		);

		const customEvent = new CustomEvent("loadingspinner", {
			detail: true,
			bubbles: true
		});

		this.dispatchEvent(customEvent);

		this.selectedCarrierOption = event.target.value;

		console.log(
			"b2bCheckoutDeliveryMethod: handleCarrierSelectionChange(): selectedCarrierOption:",
			this.selectedCarrierOption
		);

		// Set the CartDeliveryGroupMethodId
		for (const option of this.carrierOptions) {
			for (const method of option.DeliveryMethods) {
				if (method.Id === this.selectedCarrierOption) {
					this.cartDeliveryGroupMethodId =
						method.CartDeliveryGroupMethodId;
					break;
				}
			}
		}

		console.log(
			"b2bCheckoutDeliveryMethod: handleCarrierSelectionChange(): cartDeliveryGroupMethodId:",
			this.cartDeliveryGroupMethodId
		);

		setCartItemDeliveryGroup({
			cartDeliveryGroupMethodId: this.cartDeliveryGroupMethodId,
			deliveryMethodId: this.selectedCarrierOption,
			cartId: this.cartId
		})
			.then((result) => {
				const customEvent = new CustomEvent("deliverymethodchange", {
					detail: true,
					bubbles: true
				});

				this.dispatchEvent(customEvent);
			})
			.catch((error) => {
				this.processError(error);
			});
	}

	processError(error) {
		// console.log("processError()", error);
		//this.showLoadingSpinner = false;
		this.dispatchEvent(
			new ShowToastEvent({
				title: this.labels.toast.processingErrorTitle,
				message: error.body.message,
				variant: "error"
			})
		);
	}

	processMessages(result) {
		if (result.messagesJson) {
			let messages = JSON.parse(result.messagesJson);
			// console.log("processMessages()", messages);

			// Process messages returned
			// Display toasts when applicable
			// Create content for the details section

			for (var i = 0; i < messages.length; i++) {
				var message = messages[i];

				if (message.toast === true) {
					this.dispatchEvent(
						new ShowToastEvent({
							title: message.title,
							message: message.message,
							variant: message.severity
						})
					);
				}
			}

			this.showProcessLog = true;
		}
	}

	@api
	validateDeliveryMethodSelection() {

		if(this.selectedCarrierOption === undefined || this.selectedCarrierOption === null) {
			this.dispatchEvent(
				new ShowToastEvent({
					title: this.labels.toast.deliveryMethodNotSelected,
					//message: error.body.message,
					variant: "error"
				})
			);

			return false;
		}
		else {
			return true;
		}

	}

}