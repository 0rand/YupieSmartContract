var YupieToken = artifacts.require("YupieToken");

contract('YupieToken', function(accounts) {
  var yupie;
  it("should initialize with 631 million YUPIES", function() {
    return YupieToken.deployed().then(function(instance) {
      yupie = instance;
      return yupie.maxTotalSupply.call();
    }).then(function(balance) {
      assert.equal(balance.valueOf(), 6.31e+26);
      return yupie.maxPresaleSupply.call();
    }).then(function(balance) {
      assert.equal(balance.valueOf(), 5.048e+24);
    });
  });
  it("should send coin correctly", function() {
    var yupie;
    return YupieToken.deployed().then(function(instance) {
      yupie = instance;
      return yupie.totalYUPIESAllocated();
    }).then(function(totalYupies) {
      assert.equal(totalYupies.toString(), '0');
      return yupie.sendTransaction({from:accounts[0],value:5});
    }).then(function(balance) {
      return yupie.totalWEIInvested();
    }).then(function(totalWei) {
      assert.equal(totalWei.toString(), '5');
      return yupie.totalYUPIESAllocated();
    }).then(function(totalYupies) {
      assert.equal(totalYupies.toString(), '16500');
      return yupie.WEIContributed(accounts[0]);
    }).then(function(weiContributed) {
      assert.equal(weiContributed.toString(), '5');
      return yupie.sendTransaction({from:accounts[1],value:5000});
    }).then(function(balance) {
      return yupie.totalWEIInvested();
    }).then(function(totalWei) {
      assert.equal(totalWei.toString(), '5005');
      return yupie.totalYUPIESAllocated();
    }).then(function(totalYupies) {
      assert.equal(totalYupies.toString(), '16516500');
      return yupie.WEIContributed(accounts[1]);
    }).then(function(weiContributed) {
      assert.equal(weiContributed.toString(), '5000');
      return yupie.balanceOf(accounts[0]);
    }).then(function(balance) {
      assert.equal(balance.toString(), '16500');
      return yupie.balanceOf(accounts[1]);
    }).then(function(balance) {
      assert.equal(balance.toString(), '16500000');
      return yupie.sendTransaction({from:accounts[0],value:5000000000000000000});
    }).then(function(balance) {
      return yupie.totalWEIInvested();
    }).then(function(totalWei) {
      assert.equal(totalWei.toString(), '5000000000000005005');
      return yupie.totalYUPIESAllocated();
    }).then(function(totalYupies) {
      assert.equal(totalYupies.toString(), '1.81500000000000165165e+22');
      return yupie.WEIContributed(accounts[0]);
    }).then(function(weiContributed) {
      assert.equal(weiContributed.toString(), '5000000000000000005');
      return yupie.balanceOf(accounts[0]);
    }).then(function(balance) {
      assert.equal(balance.toString(), '1.81500000000000000165e+22');
      return yupie.sendTransaction({from:accounts[1],value:5000000000000000000});
    }).then(function(balance) {
      return yupie.totalWEIInvested();
    }).then(function(totalWei) {
      assert.equal(totalWei.toString(), '55000000000000005005');
      return yupie.totalYUPIESAllocated();
    }).then(function(totalYupies) {
      assert.equal(totalYupies.toString(), '1.81500000000000165165e+22');
      return yupie.WEIContributed(accounts[1]);
    }).then(function(weiContributed) {
      assert.equal(weiContributed.toString(), '5000000000000000005');
      return yupie.balanceOf(accounts[1]);
    }).then(function(balance) {
      assert.equal(balance.toString(), '1.81500000000000000165e+22');
    })
  });
});