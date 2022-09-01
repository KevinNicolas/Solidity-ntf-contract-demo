const DemoNft = artifacts.require("DemoNft");

module.exports = function (deployer) {
  deployer.deploy(DemoNft);
};
