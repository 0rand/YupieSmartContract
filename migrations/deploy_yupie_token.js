var Migrations = artifacts.require("./YupieToken.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
