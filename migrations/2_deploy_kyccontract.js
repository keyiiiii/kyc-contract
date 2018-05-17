const KYCContract = artifacts.require('./KYCContract.sol');

module.exports = function(deployer) {
  deployer.deploy(KYCContract, {
    gas: 2000000
  })
};