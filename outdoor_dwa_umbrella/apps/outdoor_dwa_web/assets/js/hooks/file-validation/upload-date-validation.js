import Worker from './exif.worker.js';
import {processVideo} from "./video-processing";

let worker;
export function validateDateForMedia(parentId, editionStartDate, editionEndDate) {
    const imageElement = document.querySelector(`#${parentId} img`);
    const statusTarget = document.getElementById('media-time-status');
    statusTarget.innerHTML = '<div class="tooltip"><i class="animate-spin fas fa-spinner tooltip__icon"></i><div class="tooltip__text">Automated systems are checking the creation date of this file.</div></div>';

    if (imageElement) {
        processImage(imageElement, statusTarget, editionStartDate, editionEndDate)
    } else {
        processVideo(parentId, statusTarget, editionStartDate, editionEndDate)
    }
}

export function stopProcessingReviewFile() {
    worker.terminate();
}

function processImage(imageElement, statusTarget, editionStartDate, editionEndDate) {
    imageElement
        .decode()
        .then(() => {
            worker = new Worker();
            worker.onmessage = ({data}) => {
                statusTarget.innerHTML = data;
            }
            worker.postMessage({
                url: imageElement.currentSrc,
                editionStartDate,
                editionEndDate,
                isImage: true
            });
        });
}

