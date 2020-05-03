import AuthenticationContract from '../../../../build/contracts/Authentication.json'
import { browserHistory } from 'react-router'
import store from '../../../store'
const contract = require('truffle-contract')
export const USER_LOGGED_IN = 'USER_LOGGED_IN'
function userLoggedIn(user) {
  return {
    type: USER_LOGGED_IN,
    payload: user
  }
}
export function loginUser() {
  let web3 = store.getState().web3.web3Instance
  if (typeof web3 !== 'undefined') {
    return function(dispatch) {
      const authentication = contract(AuthenticationContract)
      authentication.setProvider(web3.currentProvider)
      var authenticationInstance
      // Get current ethereum wallet.
      web3.eth.getCoinbase((error, coinbase) => {
        if (error) {
          console.error(error);
        }
        authentication.deployed().then(function(instance) {
          authenticationInstance = instance
          // Attempt to login user.
          authenticationInstance.login({from: coinbase})
          .then(function(result) {
            var userName = web3.toUtf8(result)
            dispatch(userLoggedIn({"name": userName}))

            var currentLocation = browserHistory.getCurrentLocation()
            if ('redirect' in currentLocation.query)
            {
              return browserHistory.push(decodeURIComponent(currentLocation.query.redirect))
            }
            return browserHistory.push('/dashboard')
          })
          .catch(function(result) {
            // If error, go to signup page.
            console.error('Wallet ' + coinbase + ' does not have an account!')
            return browserHistory.push('/signup')
          })
        })
      })
    }
  } else {
    console.error('Web3 is not initialized.');
  }
}
