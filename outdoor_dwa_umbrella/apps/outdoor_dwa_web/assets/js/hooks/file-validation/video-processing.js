import {createFFmpeg, fetchFile} from "@ffmpeg/ffmpeg";
import {checkFileTime} from "./html-feedback";

export function processVideo(parentId, statusTarget, editionStartDate, editionEndDate) {
    const videoElement = document.querySelector(`#${parentId} video`);
    const ffmpeg = createFFmpeg();
    (async () => {
        await ffmpeg.load();
        const name = 'test.mp4';
        const outputName = 'test.txt';
        ffmpeg.FS('writeFile', name, await fetchFile(videoElement.currentSrc));
        await ffmpeg.run('-i', name, '-c', 'copy', '-map_metadata', '0', '-map_metadata:s:v', '0:s:v', '-map_metadata:s:a', '0:s:a', '-f', 'ffmetadata', outputName);
        const creationDate = parseCreationDate(uint8ArrayToString(ffmpeg.FS('readFile', outputName)));

        statusTarget.innerHTML = checkFileTime(editionStartDate, editionEndDate, creationDate, creationDate);
    })();
}

function uint8ArrayToString(arr) {
    return String.fromCharCode.apply(null, arr);
}

function parseCreationDate(str) {
    return new Date(str.split('\n').reduce((prev, cur) => {
        const splitted = cur.split('=');
        if(splitted[0] === 'creation_time') {
            return splitted[1];
        }
        return prev;
    }));
}