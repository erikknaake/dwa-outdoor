const {BASE_URL} = require("../support");
describe('admin homepage', () => {
    before(() => {
        cy.resetDb();
    });

    beforeEach(() => {
        cy.loginOrganisator();
        cy.visit('/admin');
    });

    it('should navigate to the review queue', () => {
        cy.contains('REVIEWS').click();
        cy.url().should('equal', `${BASE_URL}/admin/reviews`);
    });

    it('should navigate to travel questions', () => {
        cy.contains('TRAVEL QUESTIONS').click();
        cy.url().should('equal', `${BASE_URL}/admin/travel-questions`);
    });

    it('should navigate to practical tasks', () => {
        cy.contains('PRACTICAL TASKS').click();
        cy.url().should('equal', `${BASE_URL}/admin/practical-tasks`);
    });

    it('should navigate to editions', () => {
        cy.contains('EDITIONS').click();
        cy.url().should('equal', `${BASE_URL}/admin/editions`);
    });

    it('should navigate to projects', () => {
        cy.contains('PROJECTS').click();
        cy.url().should('equal', `${BASE_URL}/admin/projects`);
    });

    it('should navigate to public home', () => {
        cy.contains('HOME').click();
        cy.url().should('equal', `${BASE_URL}/`);
    });
})