var Authentication = artifacts.require("./Authentication.sol");
contract('Authentication', function(accounts) {
  it("...sign up +log in", function() {
    return Authentication.deployed().then(function(instance) {
      authenticationInstance = instance;
      return authenticationInstance.signup('testuser', {from: accounts[0]});
    }).then(function() {
      return authenticationInstance.login.call();
    }).then(function(userName) {
      assert.equal(web3.toUtf8(userName), 'testuser',"The user was not signed up.");
    });
  });

});
