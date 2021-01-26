import {BASE_URL} from "../support";

describe('register team', () => {
    before(() => {
        cy.resetDb();
    });

    beforeEach(() => {
        cy.loginUser();
        cy.visit(`/editions`);
    });

    it('should register a team', function () {
        cy.get('tr')
            .last()
            .contains('View')
            .click();

        cy.contains('JOIN THE CHALLENGE')
            .click();

        cy.get('#team_organisation_name').type('Osbornegroep');
        cy.get('#team_team_name').type('Ossen');
        cy.get('#team_group_size').type('12');
        cy.get('#team_postalcode').type('1111AB');
        cy.get('#team_city').type('Biddinghuizen');
        cy.get('#team_password').type('a password');
        cy.get('#team_password_confirmation').type('a password');
        cy.contains('Join the challenge').click();

        cy.url().should('equal', `${BASE_URL}/teams/tasks`).then(() => {
            cy.contains('LOGOUT').click();
            cy.contains('LOG IN').click();
            cy.get('#login_name').type('Ossen');
            cy.get('#login_password').type('a password');
            cy.contains('Submit').click();
            cy.url()
                .should('equal', `${BASE_URL}/teams/tasks`);
        });

    });

    it('should not be able to register a team for a closed edition', function() {
        cy.get('a')
            .contains('View')
            .first()
            .click();

        cy.get('h4').should('contain', 'CLOSED');
    });
});