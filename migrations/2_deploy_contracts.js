
const Lottery = artifacts.require("Lottery");// название контакта в папке build

module.exports = function(deployer) {
    
deployer.deploy(Lottery);
};



