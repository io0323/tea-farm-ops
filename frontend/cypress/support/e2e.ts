// ***********************************************************
// This example support/e2e.ts is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
import './commands'

// Alternatively you can use CommonJS syntax:
// require('./commands')

// グローバル設定
Cypress.on('uncaught:exception', (err, runnable) => {
  // アプリケーションのエラーでテストが失敗しないようにする
  // 必要に応じて特定のエラーを無視する
  return false
})

// カスタムコマンドの型定義
declare global {
  namespace Cypress {
    interface Chainable {
      // カスタムコマンドの型定義をここに追加
    }
  }
}
