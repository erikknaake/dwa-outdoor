describe('practical task', () => {
    const encoding = 'base64';

    before(() => {
        cy.resetDb();
    });

    beforeEach(() => {
        cy.loginTeamLeader();
        cy.visit('/teams/tasks');
    });

    it('should submit a jpg', () => {
        const file = 'example.jpg';
        cy.contains('Details')
            .first()
            .click();
        cy.url()
            .should('match', /\/teams\/practical-tasks\/[0-9]+$/);

        cy.contains('Choose file')
            .get('input[type=file]')
            .attachFile(file);
        cy.contains('Upload').click();
        cy.get('tbody > tr')
            .should('contain', '1')
            .should('contain', 'Pending')
            .contains('_v1')
            .click();
        cy.get('.modal img')
            .then((el) => {
                const img = el.get(0)
                cy.request({url: img.currentSrc, encoding}).then((resp) => {
                    cy.fixture(file, encoding).should('equal', resp.body);
                });
            });
        cy.get('.modal__overlay').click();
        cy.get('.modal').should('be.hidden');
    });

    it('should submit a png', () => {
        const file = 'example.png';
        cy.contains('Details')
            .first()
            .click();
        cy.url()
            .should('match', /\/teams\/practical-tasks\/[0-9]+$/);

        cy.contains('Choose file')
            .get('input[type=file]')
            .attachFile(file);
        cy.contains('Upload').click();
        cy.get('tbody > tr')
            .should('contain', '1')
            .should('contain', 'Pending')
            .contains('_v1')
            .click();
        cy.get('.modal img')
            .then((el) => {
                const img = el.get(0)
                cy.request({url: img.currentSrc, encoding}).then((resp) => {
                    cy.fixture(file, encoding).should('equal', resp.body);
                });
            });
        cy.get('.modal__overlay').click();
        cy.get('.modal').should('be.hidden');
    });

    it('should submit a video mp4', () => {
        const file = 'example.mp4';
        cy.contains('Details')
            .first()
            .click();
        cy.url()
            .should('match', /\/teams\/practical-tasks\/[0-9]+$/);

        cy.contains('Choose file')
            .get('input[type=file]')
            .attachFile({filePath: file, encoding: 'binary', mimeType: 'video/mp4'});

        cy.contains('Upload').click();
        cy.get('tbody > tr')
            .should('contain', '1')
            .should('contain', 'Pending')
            .contains('_v1')
            .click();
        cy.get('.modal video')
            .then((el) => {
                const video = el.get(0);
                assert.isNotEmpty(video.currentSrc);
                // Requesting the video causes cypress to hang when there are test that need to be run after this test
            });
        cy.get('.modal__overlay').click();
        cy.get('.modal').should('be.hidden');
    });

    it('should not be able to submit a invalid file type', () => {
        const file = 'example.json';
        cy.contains('Details')
            .first()
            .click();
        cy.url()
            .should('match', /\/teams\/practical-tasks\/[0-9]+$/);

        cy.contains('Choose file')
            .get('input[type=file]')
            .attachFile(file);
        cy.get('.form__invalid-feedback').should('contain', 'The file you selected is unsupported');
    });
});