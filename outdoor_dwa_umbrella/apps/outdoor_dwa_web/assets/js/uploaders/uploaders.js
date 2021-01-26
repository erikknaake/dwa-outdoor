import {decorateUploadersWithS3} from "./s3";

export function createUploaders() {
    let Uploaders = {};

    decorateUploadersWithS3(Uploaders);
    return Uploaders;
}