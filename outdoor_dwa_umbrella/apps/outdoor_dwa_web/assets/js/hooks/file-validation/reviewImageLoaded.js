import {stopProcessingReviewFile, validateDateForMedia} from "./upload-date-validation";

export function decorateHooksWithImageLoaded(Hooks) {
    Hooks.ReviewImageLoaded = {
        mounted() {
            this.handleEvent("reviewImage", ({editionStartDate, editionEndDate}) => {
                validateDateForMedia("review-image", editionStartDate, editionEndDate)
            });
        },
        destroyed() {
            stopProcessingReviewFile();
        }
    }
}