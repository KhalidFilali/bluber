pragma solidity ^0.6.6;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Authentication.sol";
contract TestAuthentication {
  function testUserCanSignUpAndLogin() {
    Authentication authentication = Authentication(DeployedAddresses.Authentication());
    authentication.signup('testuser');
    bytes32 expected = 'testuser';
    Assert.equal(authentication.login(), expected, "sign up+ login");
  }
}
