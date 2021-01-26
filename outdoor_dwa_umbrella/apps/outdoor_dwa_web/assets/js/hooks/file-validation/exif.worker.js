import ExifReader from 'exifreader';
import * as dayjs from "dayjs";
import customParseFormat from 'dayjs/plugin/customParseFormat';
import {checkFileTime, feedbackHtml} from "./html-feedback";

dayjs.extend(customParseFormat)

onmessage = ({data: {url, editionStartDate, editionEndDate}}) => {
    fetch(url)
        .then((resp) => resp.arrayBuffer())
        .then((buffer) => {
            const tags = ExifReader.load(buffer);
            const imageTags = {
                DateTime: tags.DateTime.description,
                DateTimeDigitized: tags.DateTimeDigitized.description,
                DateTimeOriginal: tags.DateTimeOriginal.description
            };
            const min = getMinImageTagDatetime(imageTags)
            const max = getMaxImageTagDatetime(imageTags)
            postMessage(checkFileTime(editionStartDate, editionEndDate, min, max));
        }).catch((error) => {
            postMessage(feedbackHtml('info-circle', 'blue-600', 'Automated systems could not detect whether or not this file was created during this edition.'))
        });
}

function imageTagsToDateStringArray(imageTags) {
    return [imageTags.DateTime, imageTags.DateTimeDigitized, imageTags.DateTimeOriginal].map(parseDate);
}

const formats = [
    "MM-DD-YYYY HH:mm:s",
    "MM:DD:YYYY HH:mm:s",
    "YY-MM-DD HH:mm:s",
    "YY:MM:DD HH:mm:s",
    "YYYY-MM-DD HH:mm:s",
    "YYYY:MM:DD HH:mm:s",
]

function parseDate(str) {
    const ISO = dayjs(str);
    if (ISO.isValid()) {
        return ISO;
    }

    return formats.reduce((prev, cur) => {
        const attempt = dayjs(str, cur);
        return attempt.isValid() ? attempt : prev;
    });
}

function getMaxImageTagDatetime(imageTags) {
    return Math.max.apply(null, imageTagsToDateStringArray(imageTags));
}

function getMinImageTagDatetime(imageTags) {
    return Math.min.apply(null, imageTagsToDateStringArray(imageTags));
}
