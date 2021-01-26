// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

import 'cypress-file-upload';
import {BASE_URL, WS_URL} from "./index";

Cypress.Commands.add("resetDb", () => {
 
    if (Cypress.env("IS_WINDOWS")) {
        cy.exec(`cd "..\\..\\outdoor_dwa_umbrella\\apps\\outdoor_dwa" && mix ecto.e2e`, {env: {MIX_ENV:'prod', COMPILE_PROD_CONFIG:'true', DATABASE_URL:'ecto://postgres:postgres@localhost/dwa_outdoor', SECRET_KEY_BASE:'WnP6FgChxWpqluRF2I0ZE4idgnRlOPtbeuOwoNdR6pNWdUu3/pluNA6s/Kqw+CaW'}})
    } else {
        cy.exec(`cd ../../outdoor_dwa_umbrella/apps/outdoor_dwa && MIX_ENV=prod DATABASE_URL=ecto://postgres:postgres@localhost/dwa_outdoor SECRET_KEY_BASE=required COMPILE_PROD_CONFIG=true mix ecto.e2e`)
    }
});

Cypress.Commands.add('formTokens', function (page) {
    cy.request(`/${page}`)
        .then((response) => {
            const data = new DOMParser().parseFromString(response.body, 'text/html');
            const csrfToken = data.querySelector('meta[name=csrf-token]').content;
            const {
                id: formId, dataset: {
                    ["phxSession"]: session,
                    ["phxStatic"]: staticVal
                }
            } = data.querySelector('div[data-phx-main=true]');
            cy.wrap(csrfToken).as('csrfToken');
            cy.wrap(staticVal).as('static');
            cy.wrap(session).as('session');
            cy.wrap(formId).as('formId');
        });
});

Cypress.Commands.add('wsSendForm', function (page, messageFn) {
    cy.formTokens(page).then(obj => {
        let ws = new WebSocket(`${WS_URL}/live/websocket?_csrf_token=${this.csrfToken}&_track_static%5B0%5D=http%3A%2F%2Flocalhost%3A4000%2Fcss%2Fapp.css&_track_static%5B1%5D=http%3A%2F%2Flocalhost%3A4000%2Fjs%2Fapp.js&_mounts=0&vsn=2.0.0`);
        cy.wrap(ws).as('ws');
        const params = {
            "_csrf_token": this.csrfToken,
            "_mounts": 0,
            "_track_static": ["http://localhost:4000/css/app.css", "http://localhost:4000/js/app.js"]
        };
        const listenMessage = JSON.stringify(["4", "4", `lv:${this.formId}`, "phx_join", {
            "url": `http://localhost:4000/${page}`,
            params,
            "session": this.session,
            "static": this.static
        }]);
        if (ws.readyState === WebSocket.OPEN) {
            ws.send(listenMessage)
            ws.send(messageFn(this));
        } else {
            ws.onopen = () => {
                ws.send(listenMessage)
                ws.send(messageFn(this));
            };
        }
    });
});

Cypress.Commands.add('sendWsFormAndWait', function (page, messageFn, onMessageFn) {
    cy.wsSendForm(page, (obj) => messageFn(obj))
        .then(ws => {
            return new Cypress.Promise(resolve => {
                ws.onmessage = (data) => {
                    onMessageFn(data, resolve);
                }
            }).then((val) => {
                return val;
            });
        })
});

Cypress.Commands.add('login', function (username, password, saveToken = true) {
    cy.sendWsFormAndWait('login', (obj) =>
            JSON.stringify(["4", "5", `lv:${obj.formId}`, "event", {
                "type": "form",
                "event": "save",
                "value": `_csrf_token=${obj.csrfToken}&login%5Bname%5D=${username}&login%5Bpassword%5D=${password}`
            }]),
        ({data}, resolve) => {
            const message = JSON.parse(data);
            if (message[3] === 'phx_reply' && message[4].response.diff) {
                const {response: {diff: {e: [results]}}} = message[4];
                const token = results[1].token;
                cy.wrap(token).as('token');
                if (saveToken) {
                    window.localStorage.setItem('token', token);
                }
                resolve(token);
            }
        });
})

Cypress.Commands.add('loginUser', function () {
    cy.login('Robert', 'Erlang');
    window.localStorage.setItem('role', 'User');
});

Cypress.Commands.add('loginOrganisator', function () {
    cy.login('Maarten', 'OpenStack');
    window.localStorage.setItem('role', 'Organisator');
});

Cypress.Commands.add('loginCoOrganisator', function () {
    cy.login('Bart', 'Kubernetes')
    window.localStorage.setItem('role', 'CoOrganisator')
});

Cypress.Commands.add('loginTravelGuide', function(){
    cy.login('Ugur', 'Minio');
    window.localStorage.setItem('role', 'TravelGuide')
});

Cypress.Commands.add('loginAdmin', function(){
    cy.login('admin', 'admin');
    window.localStorage.setItem('isAdmin', 'true')
})

Cypress.Commands.add('loginTeamLeader', function () {
    cy.login('Erik', 'Kompose');
    window.localStorage.setItem('role', 'TeamLeader');
});

Cypress.Commands.add('getAuthenticatedPageParts', function (page, user = 'Erik', pass = 'Kompose', role = 'TeamLeader') {
    cy.login(user, pass, false).then(token => {
        cy.sendWsFormAndWait(page, obj => JSON.stringify(["4", "5", `lv:${this.formId}`, "event", {
            "type": "hook",
            "event": "AuthenticateToken",
            "value": {
                "token": token
            }
        }]), ({data}, resolve) => {
            const message = JSON.parse(data);
            if (message[3] === 'phx_reply' && message[4].response.diff) {
                resolve(message);
            }
        });
    });
})

function parseValue(str, regex) {
    return str.match(regex)[0].split('=')[1].replaceAll('"', '');
}

function uploadFile({url, fields}, file) {
    let formData = new FormData()
    Object.entries(fields).forEach(([key, val]) => formData.append(key, val));
    formData.append("file", Cypress.Blob.base64StringToBlob(file), 'image/jpeg');
    let xhr = new XMLHttpRequest();

    xhr.open("POST", url, true);
    xhr.send(formData);
}

function sendProgressDone(ws, formId, phxRef) {
    ws.send(JSON.stringify(["4", "13", `lv:${formId}`, "progress", {
        "event": null,
        "ref": phxRef,
        "entry_ref": "0",
        "progress": 100
    }]));
}

function sendSave(ws, formId, csrf) {
    ws.send(JSON.stringify(["4", "27", `lv:${formId}`, "event", {
        "type": "form",
        "event": "save",
        "value": `_csrf_token=${csrf}`
    }]));
}

function sendAllowUpload(ws, formId, phxRef, fileName) {
    const messageToSend = JSON.stringify(["4", "12", `lv:${formId}`, "allow_upload", {
        "ref": phxRef,
        "entries": [{
            "last_modified": 1607802112232,
            "name": fileName,
            "size": 4375,
            "type": "image/jpeg",
            "ref": "0"
        }]
    }]);
    ws.send(messageToSend);
}

function sendFileLiveViewLike(ws, formId, csrf, phxRef) {
    const fileName = 'example.jpg'
    cy.fixture(fileName, 'base64').then(function (file) {
        return new Cypress.Promise(resolve => {
            ws.onmessage = ({data}) => {
                const message = JSON.parse(data);
                if (message[3] === 'phx_reply' && message[4].response.entries) {
                    uploadFile(message[4].response.entries[0], file);
                    sendProgressDone(ws, formId, phxRef);
                    sendSave(ws, formId, csrf);
                    resolve();
                }
            }
            sendAllowUpload(ws, formId, phxRef, fileName);
        });
    });
}

Cypress.Commands.add('submitFile', function () {
    cy.getAuthenticatedPageParts('teams/tasks').then(function (val) {
        const taskId = val[4].response.diff[2][1][0][0][0][0].d[0][0];
        cy.getAuthenticatedPageParts(`/teams/practical-tasks/${taskId}`).then(function (val) {
            const input = val[4].response.diff[2][0][0][6][0];
            const phxRef = parseValue(input, /id="[^"]+"/)
            sendFileLiveViewLike(this.ws, this.formId, this.csrf, phxRef);
        });
    });
});