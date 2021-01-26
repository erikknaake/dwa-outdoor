const {BASE_URL} = require("../support");

describe('login', () => {
    before(() => {
        cy.resetDb();
    });

    beforeEach(() => {
        cy.visit(`/login`);
    });

    it('should login as a regular user', () => {
        cy.get('#login_name').type('Robert');
        cy.get('#login_password').type('Erlang');
        cy.contains('Submit').click();
        cy.url()
            .should('equal', `${BASE_URL}/editions`);
    });

    it('should login as an organisator', () => {
        cy.get('#login_name').type('Maarten');
        cy.get('#login_password').type('OpenStack');
        cy.contains('Submit').click();
        cy.url()
            .should('equal', `${BASE_URL}/admin/reviews`);
    });

    it('should login as a team leader', () => {
        cy.get('#login_name').type('Erik');
        cy.get('#login_password').type('Kompose');
        cy.contains('Submit').click();
        cy.url()
            .should('equal', `${BASE_URL}/teams/tasks`);
    });

    it('should login as a team member', () => {
        cy.get('#login_name').type('Team BEAST');
        cy.get('#login_password').type('Kompose');
        cy.contains('Submit').click();
        cy.url()
            .should('equal', `${BASE_URL}/teams/tasks`);
    });

    it('should get an error for invalid credentials', () => {
        cy.get('#login_name').type('Team BEAST');
        cy.get('#login_password').type('sdfsdgreg');
        cy.contains('Submit').click();
        cy.get('form')
            .should('contain', 'The username password combination is invalid');
    });
});