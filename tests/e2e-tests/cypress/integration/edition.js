import {BASE_URL} from "../support";

describe('edition', () => {
    before(() => {
        cy.resetDb();
    });

    beforeEach(() => {
        cy.loginOrganisator();
        cy.visit('/admin/editions')
    });

    it('should add a travel guide', () => {
        cy.get('tbody > tr:nth-child(2) a[href*="agents"]')
            .last()
            .contains('View')
            .click();

        cy.get('select[name=user_id]')
            .select('Ugur');

        cy.get('button')
            .contains('Add')
            .click();

        cy.contains('Current Travel Agents:')
            .siblings()
            .should('contain', 'Ugur').then(() => {

            window.localStorage.clear();
            cy.visit('/login');

            cy.get('#login_name').type('Ugur');
            cy.get('#login_password').type('Minio');
            cy.contains('Submit').click();
            cy.url()
                .should('equal', `${BASE_URL}/admin/reviews`);
        });
    });

    it('shouldnt allow travelguides on editions overview', () => {
        window.localStorage.clear();
        cy.loginTravelGuide()
        cy.visit('admin/editions')
        cy.url().should('equal', `${BASE_URL}/login?redirect=/admin/editions`);
    });

    it('should add a co-organisator', () => {
        cy.get('tbody > tr:nth-child(2) a[href*="coorganisators"]')
            .last()
            .contains('View')
            .click();

        cy.get('select[name=user_id]')
            .select('Bart');

        cy.get('button')
            .contains('Add')
            .click();

        cy.contains('Current Co-Organisators:')
            .siblings()
            .should('contain', 'Bart').then(() => {

            window.localStorage.clear();
            cy.visit('/login');

            cy.get('#login_name').type('Bart');
            cy.get('#login_password').type('Kubernetes');
            cy.contains('Submit').click();
            cy.url()
                .should('equal', `${BASE_URL}/admin/editions`);
        });
    });

    it('shouldnt allow coorganisators to create editions', () => {
        window.localStorage.clear();
        cy.loginCoOrganisator()
        cy.visit('admin/editions')

        cy.get('a').should('not.contain', 'Create');
    });


    it('shouldnt allow coorganisators to edit editions', () => {
        window.localStorage.clear();
        cy.loginCoOrganisator()
        cy.visit('admin/editions')

        cy.get('tbody > tr')
            .eq(1)
            .get('a')
            .contains('Edit')
            .should('have.class', 'button--disabled')
            .should('not.have.attr', 'href');
    });

    it('should allow coorganisators to add a travel guide', () => {
        window.localStorage.clear();
        cy.loginCoOrganisator();
        cy.visit('/admin/editions')

        cy.get('tbody > tr:nth-child(2) a[href*="agents"]')
            .last()
            .contains('View')
            .click();

        cy.get('select[name=user_id]')
            .select('Luciano');

        cy.get('button')
            .contains('Add')
            .click();

        cy.contains('Current Travel Agents:')
            .siblings()
            .should('contain', 'Luciano').then(() => {

            window.localStorage.clear();
            cy.visit('/login');

            cy.get('#login_name').type('Luciano');
            cy.get('#login_password').type('LiveView');
            cy.contains('Submit').click();
            cy.url()
                .should('equal', `${BASE_URL}/admin/reviews`);
        });
    });

    it('shouldnt allow coorganisators to add coorganisators', () => {
        window.localStorage.clear();
        cy.loginCoOrganisator()
        cy.visit('admin/editions')

        cy.get('tbody > tr')
            .eq(1)
            .get('a[href*="coorganisators"]')
            .contains('View')
            .click();
        cy.url().should('match', /\/login\?redirect=\/admin\/editions\/\d+\/coorganisators/);
    });

    it('should create an edition', () => {
        cy.loginAdmin();
        cy.visit('/admin/editions');
        cy.contains('Create').click();
        cy.get('#edition_start_datetime_year')
            .select('2022');
        cy.get('#edition_start_datetime_month')
            .select('March');
        cy.get('#edition_start_datetime_day')
            .select('03');
        cy.get('#edition_start_datetime_hour')
            .select('20');

        cy.get('#edition_end_datetime_year')
            .select('2022');
        cy.get('#edition_end_datetime_month')
            .select('March');
        cy.get('#edition_end_datetime_day')
            .select('03');
        cy.get('#edition_end_datetime_hour')
            .select('23');
        cy.get('#edition_end_datetime_minute')
            .select('59');

        cy.get('#edition_is_open_for_registration')
            .click();
        cy.get('button')
            .contains('Create')
            .click();

        cy.url()
            .should('equal', `${BASE_URL}/admin/editions`);

        cy.get('tbody > tr')
            .should('have.length', 3)
            .first()
            .get('td')
            .eq(3)
            .children()
            .should('have.length', 1);
    });

    it('should edit an edition not to be open for registration', () => {
        cy.loginAdmin();
        cy.visit('/admin/editions');
        cy.get('tbody > tr')
            .eq(2)
            .get('a')
            .contains('Edit')
            .click();
        cy.get('#edition_is_open_for_registration')
            .click();
        cy.get('button')
            .contains('Edit')
            .click();

        cy.get('tbody > tr')
            .eq(2)
            .get('td')
            .eq(3)
            .children()
            .should('have.length', 0);
    });
});