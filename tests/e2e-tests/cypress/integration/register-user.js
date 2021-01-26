const {BASE_URL} = require("../support");
describe('register user', () => {
    before(() => {
        cy.resetDb();
    });

    beforeEach(() => {
        cy.visit('/register/user');
    });

    it('should show username is already taken', () => {
        cy.get('#user_name').type('Erik');
        cy.get('#user_password').type('P@ssword!');
        cy.get('#user_password_confirmation').type('P@ssword!');

        cy.get('button[type=submit]')
            .should('not.be', 'disabled')
            .click();
        cy.get('span[phx-feedback-for=user_unique_user_name]')
            .should('contain', 'Has already been taken');
    });

    it('should disabled submit when the form is not valid', () => {
        cy.get('button[type=submit]')
            .should('be.disabled');
    });

    it('should show the password confirmation does not match', () => {
        cy.get('#user_name').type('A brand new user name');
        cy.get('#user_password').type('P@ssword!');
        cy.get('#user_password_confirmation').type('P2ssword!');

        cy.get('button[type=submit]')
            .should('not.be', 'disabled');

        cy.get('span[phx-feedback-for=user_password_confirmation]')
            .should('contain', 'Does not match confirmation');
    });

    it('should registrate a user', () => {
        cy.get('#user_name').type('A brand new user name');
        cy.get('#user_password').type('P@ssword!');
        cy.get('#user_password_confirmation').type('P@ssword!');

        cy.get('button[type=submit]')
            .should('not.be', 'disabled')
            .click();

        cy.url().should('equal', `${BASE_URL}/editions`);
    });
});