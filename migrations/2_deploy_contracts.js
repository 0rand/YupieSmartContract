var TutorialToken = artifacts.require("./YupieToken.sol");

module.exports = function(deployer) {
  deployer.deploy(TutorialToken);
};