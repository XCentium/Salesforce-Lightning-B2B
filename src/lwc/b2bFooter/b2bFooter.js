import { LightningElement, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";

import fontawesome_pro_581_web from "@salesforce/resourceUrl/fontawesome_pro_581_web";

export default class B2bFooter extends LightningElement {
  @api showImage = false;
  @api imgUrl = "";
  @api imgHeight = "";
  @api backgroundColor;
  @api textColor;

  @api ctaText;

  @api colOneHeading;
  @api colOneLinkOneText;
  @api colOneLinkOneURL;
  @api colOneLinkTwoText;
  @api colOneLinkTwoURL;
  @api colOneLinkThreeText;
  @api colOneLinkThreeURL;
  @api colOneLinkFourText;
  @api colOneLinkFourURL;
  @api colOneLinkFiveText;
  @api colOneLinkFiveURL;

  @api colTwoHeading;
  @api colTwoLinkOneText;
  @api colTwoLinkOneURL;
  @api colTwoLinkTwoText;
  @api colTwoLinkTwoURL;
  @api colTwoLinkThreeText;
  @api colTwoLinkThreeURL;
  @api colTwoLinkFourText;
  @api colTwoLinkFourURL;
  @api colTwoLinkFiveText;
  @api colTwoLinkFiveURL;

  @api colThreeHeading;
  @api colThreeLinkOneText;
  @api colThreeLinkOneURL;
  @api colThreeLinkTwoText;
  @api colThreeLinkTwoURL;
  @api colThreeLinkThreeText;
  @api colThreeLinkThreeURL;
  @api colThreeLinkFourText;
  @api colThreeLinkFourURL;
  @api colThreeLinkFiveText;
  @api colThreeLinkFiveURL;

  @api socialFacebook;
  @api socialFacebookLink;
  @api socialTwitter;
  @api socialTwitterLink;
  @api socialLinkedin;
  @api socialLinkedinLink;
  @api socialInstagram;
  @api socialInstagramLink;
  @api socialYoutube;
  @api socialYoutubeLink;

  @api showExpCloudLogo;

  connectedCallback() {
    loadStyle(this, fontawesome_pro_581_web + "/css/all.css");
  }

  get footerStyles() {
    return `background-color:${this.backgroundColor};color:${this.textColor};`;
  }

  get imageStyles() {
    return `height:${this.imgHeight};`;
  }

  get facebookLink() {
    return `https://www.facebook.com/${this.socialFacebookLink}`;
  }

  get twitterLink() {
    return `https://twitter.com/${this.socialTwitterLink}`;
  }

  get linkedinLink() {
    return `https://www.linkedin.com/company/${this.socialLinkedinLink}`;
  }

  get instagramLink() {
    return `https://www.instagram.com/${this.socialInstagramLink}`;
  }

  get youtubeLink() {
    return `https://www.youtube.com/channel/${this.socialYoutubeLink}`;
  }
}