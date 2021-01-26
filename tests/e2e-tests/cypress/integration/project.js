import {BASE_URL} from "../support";

describe('project', () => {
    before(() => {
        cy.resetDb();
    });

    beforeEach(() => {
        cy.loginOrganisator();
        cy.visit('/admin/projects')
    });

       it('should be able to edit a project title and description', () => {
           let new_title = 'This is the new title'
           let new_description = 'This is the new description'
           cy.get('tbody > tr').contains('Edit').click();
           cy.get('#project_title').clear().type(new_title);
           cy.get('trix-editor').clear().type(new_description)
           cy.get('button').contains('Submit').click();
           cy.get('tbody > tr').contains(new_title)
           cy.get('tbody > tr').contains(new_description)
       })

       it('should not have a create button when edition is ongoing', () => {
           cy.contains('create').should('not.exist')
       })

       it('should have a create button when the edition hasnt started yet', () => {
           cy.loginAdmin();
            cy.visit('/admin/editions')
            cy.get('tbody > tr')
            .eq(1)
            .within(() =>
            cy.get('a')
            .contains('Edit')
            .click()
            )

            cy.get('#edition_start_datetime_year')
            .select('2022');
            cy.get('button')
            .contains('Edit')
            .click();
           cy.loginOrganisator();
            cy.visit('/admin/projects')
            cy.get('.button').contains('Create')
       })

       it('should be able to create a new project when edition hasnt started yet', () => {
            cy.get('.button').contains('Create').click()
            let new_title = 'The newly created project'
            let new_description = 'With a unique description'
            cy.get('#project_title').clear().type(new_title);
            cy.get('trix-editor').clear().type(new_description)
            cy.get('button').contains('Submit').click();
            cy.get('tbody > tr').within(() => {
                cy.contains(new_title)
                cy.contains(new_description)
            })
       })
});