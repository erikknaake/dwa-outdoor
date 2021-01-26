describe('review submission', () => {
    before(() => {
        cy.resetDb();
    });

    beforeEach(() => {
        cy.loginOrganisator();
        cy.visit('/admin/reviews');
    });

    it('should see a new submission', () => {
        cy.get('tbody > tr:visible')
            .should('have.length', 2);
        cy.submitFile();
        cy.get('tbody > tr:visible')
            .should('have.length', 3);
        cy.get('tbody > tr:visible')
            .last()
            .contains('View')
            .click();
        cy.url()
            .should('match', /\/admin\/reviews\/\d+/);
    });
});