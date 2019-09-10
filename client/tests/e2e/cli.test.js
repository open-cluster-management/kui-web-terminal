/*******************************************************************************
 * Licensed Materials - Property of IBM
 * (c) Copyright IBM Corporation 2019. All Rights Reserved.
 *
 * Note to U.S. Government Users Restricted Rights:
 * Use, duplication or disclosure restricted by GSA ADP Schedule
 * Contract with IBM Corp.
 *******************************************************************************/

const supportedClis = ['kubectl', 'helm', 'cloudctl', 'istioctl']
process.env.JOBNAME === 'AMD64' && supportedClis.push('oc')

module.exports = {
  before: function (browser) {
    const KUI =  browser.page.KUI()
    const loginPage = browser.page.LoginPage()
    if (process.env.TEST_URL && !process.env.TEST_URL.includes('localhost')) {
      loginPage.navigate()
      loginPage.authenticate()
    }
    KUI.navigate()
    KUI.waitForPageLoad(browser)
    KUI.verifyWebsocketConnection(browser)
  },

  'Verify supported CLIs can execute': browser => {
    const KUI = browser.page.KUI()
    supportedClis.forEach(cli => {
      KUI.executeCommand(browser, `${cli} help`)
      KUI.verifyOutputSuccess(browser)
    })
  },

  'Verify kubectl': browser => {
    const KUI = browser.page.KUI()
    const CLI = browser.page.CLI()
    const commands = ['get secrets', 'get pods', 'get deployments'] 
    commands.forEach(command => {
      KUI.executeCommand(browser, `kubectl ${command} -n kube-system`)
      CLI.verifyTableOutput(browser)
      KUI.verifyDetailSidecar(browser)
    })
  },

  'Verify oc': browser => {
    const KUI = browser.page.KUI()
    const CLI = browser.page.CLI()
    KUI.executeCommand(browser, 'oc get pods -n kube-system')
    CLI.verifyTableOutput(browser)
    KUI.verifyDetailSidecar(browser)
  },

  'Verify cloudctl': browser => {
    const KUI = browser.page.KUI()
    const CLI = browser.page.CLI()
    const commands = ['catalog charts', 'iam roles']
    commands.forEach(command => {
        KUI.executeCommand(browser, `cloudctl  ${command}`)
        CLI.verifyTableOutput(browser)
    })
  },

  'Verify helm': browser => {
    const KUI = browser.page.KUI()
    const CLI = browser.page.CLI()
    const commands = ['list', 'list repo']
    commands.forEach(command => {
      KUI.executeCommand(browser, `helm ${command}`)
      CLI.verifyTableOutput(browser)
      KUI.verifyDetailSidecar(browser)
    })
  },

  after: function (browser, done) {
    setTimeout(() => {
      if (browser.sessionId) {
        browser.end()
        done()
      } else {
        done()
      }
    })
  }
}
