describe('認証機能', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it('ログインページが正しく表示される', () => {
    cy.get('[data-testid=login-form]').should('be.visible');
    cy.get('[data-testid=username-input]').should('be.visible');
    cy.get('[data-testid=password-input]').should('be.visible');
    cy.get('[data-testid=login-button]').should('be.visible');
  });

  it('正しい認証情報でログインできる', () => {
    cy.get('[data-testid=username-input]').type('admin');
    cy.get('[data-testid=password-input]').type('admin123');
    cy.get('[data-testid=login-button]').click();

    // ダッシュボードにリダイレクトされることを確認
    cy.url().should('eq', Cypress.config().baseUrl + '/');
    cy.get('[data-testid=dashboard]').should('be.visible');
  });

  it('間違った認証情報でログインできない', () => {
    cy.get('[data-testid=username-input]').type('wronguser');
    cy.get('[data-testid=password-input]').type('wrongpass');
    cy.get('[data-testid=login-button]').click();

    // エラーメッセージが表示されることを確認
    cy.get('[data-testid=error-message]').should('be.visible');
    cy.url().should('include', '/login');
  });

  it('ログアウトできる', () => {
    // まずログイン
    cy.get('[data-testid=username-input]').type('admin');
    cy.get('[data-testid=password-input]').type('admin123');
    cy.get('[data-testid=login-button]').click();

    // ログアウトボタンをクリック
    cy.get('[data-testid=logout-button]').click();

    // ログインページにリダイレクトされることを確認
    cy.url().should('include', '/login');
  });

  it('未認証ユーザーは保護されたページにアクセスできない', () => {
    cy.visit('/fields');
    cy.url().should('include', '/login');
  });
}); 