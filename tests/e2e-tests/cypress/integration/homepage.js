const {BASE_URL} = require("../support");
describe('homepage', () => {
    before(() => {
        cy.resetDb();
    });

    beforeEach(() => {
        cy.visit(`/`);
    });

    it('should navigate to register an user', () => {
        cy.contains('Join the challenge')
            .click()
        cy.url()
            .should('equal', `${BASE_URL}/editions`);
    });

    it('should navigate to login', () => {
        cy.contains('LOG IN')
            .click()
        cy.url()
            .should('equal', `${BASE_URL}/login`);
    });

    it('should navigate to register', () => {
        cy.contains('REGISTER')
            .click()
        cy.url()
            .should('equal', `${BASE_URL}/register/user`);
    });
});