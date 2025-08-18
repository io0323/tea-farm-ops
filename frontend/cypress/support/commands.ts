// ***********************************************
// This example commands.ts shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************

// カスタムコマンドの例
Cypress.Commands.add('login', (email: string, password: string) => {
  cy.visit('/login')
  cy.get('[data-testid=email-input]').type(email)
  cy.get('[data-testid=password-input]').type(password)
  cy.get('[data-testid=login-button]').click()
})

// フィールド作成のカスタムコマンド
Cypress.Commands.add('createField', (fieldName: string, area: number, location: string) => {
  cy.visit('/fields/create')
  cy.get('[data-testid=field-name-input]').type(fieldName)
  cy.get('[data-testid=field-area-input]').type(area.toString())
  cy.get('[data-testid=field-location-input]').type(location)
  cy.get('[data-testid=submit-button]').click()
})

// タスク作成のカスタムコマンド
Cypress.Commands.add('createTask', (taskType: string, fieldName: string, worker: string) => {
  cy.visit('/tasks/create')
  cy.get('[data-testid=task-type-select]').select(taskType)
  cy.get('[data-testid=field-select]').select(fieldName)
  cy.get('[data-testid=worker-input]').type(worker)
  cy.get('[data-testid=submit-button]').click()
})

// データクリーンアップのカスタムコマンド
Cypress.Commands.add('cleanupTestData', () => {
  // テストデータのクリーンアップ処理
  // 必要に応じて実装
})

// 型定義の拡張
declare global {
  namespace Cypress {
    interface Chainable {
      login(email: string, password: string): Chainable<void>
      createField(fieldName: string, area: number, location: string): Chainable<void>
      createTask(taskType: string, fieldName: string, worker: string): Chainable<void>
      cleanupTestData(): Chainable<void>
    }
  }
}
