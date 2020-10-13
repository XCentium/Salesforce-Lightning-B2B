/**
 * @FileName: videoEmbed
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/20/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from 'lwc';

export default class VideoEmbed extends LightningElement {
    @api embedUrl;
}