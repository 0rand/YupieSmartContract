var YupieToken = artifacts.require("YupieToken");

contract('YupieToken', function(accounts) {
  it("should initialize with 631 million YUPIES", function() {
    return YupieToken.deployed().then(function(instance) {
      // console.log('initialize')
      // console.log(accounts);
      // console.log(web3);
      return instance.maxTotalSupply.call();
    }).then(function(balance) {
      // console.log('returned')
      // console.log(balance.valueOf())
      assert.equal(balance.valueOf(), 6.31e+26, "6.31e+26 wasn't in the first account");
    });
  });
  it("should send coin correctly", function() {
    var yupie;

    // Get initial balances of first and second account.
    var account_one = accounts[0];
    var account_two = accounts[1];

    var account_one_starting_balance;
    var account_two_starting_balance;
    var account_one_ending_balance;
    var account_two_ending_balance;

    var amount = 10;

    return YupieToken.deployed().then(function(instance) {
      yupie = instance;
      return yupie.totalYUPIESAllocated();
    }).then(function(totalYupies) {
      assert.equal(totalYupies.toString(), '0', 'Was not zero balance');
      console.log(totalYupies.toString())
      return yupie.sendTransaction({from:account_one,value:5});
    }).then(function(balance) {
      return yupie.totalWEIInvested();
    }).then(function(totalWei) {
      assert.equal(totalWei.toString(), '5', 'Total wei was not 5');
      return yupie.totalYUPIESAllocated();
    }).then(function(totalYupies) {
      console.log(totalYupies.toString())
      assert.equal(totalYupies.toString(), '16500', 'Was not zero balance');
    });
  });
});