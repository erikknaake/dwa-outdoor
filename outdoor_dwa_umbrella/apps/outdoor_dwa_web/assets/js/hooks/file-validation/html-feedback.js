export function checkFileTime(editionStartDate, editionEndDate, min, max) {
    if (isNaN(min) || isNaN(max)) {
        return feedbackHtml('info-circle', 'blue-600', 'Automated systems could not detect whether or not this file was created during this edition.');
    } else if (new Date(editionStartDate) > min) {
        return feedbackHtml('exclamation-circle', 'red-600', 'Automated systems detected this file was created before the edition.');
    } else if (new Date(editionEndDate) < max) {
        return feedbackHtml('exclamation-circle', 'red-600', 'Automated systems detected this file was created after the edition.')
    } else {
        return feedbackHtml('check-circle', 'green-600', 'Automated systems detected this file was created during the edition. (Note: people willingly cheating can bypass these checks)');
    }
}

export function feedbackHtml(symbol, textColor, tooltip) {
    return `<div class="tooltip">
                <i class="fas fa-${symbol} text-${textColor} tooltip__icon"></i>
                <div class="tooltip__text">${tooltip}</div>
            </div>`;
}