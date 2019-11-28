
const lottery = artifacts.require("Ownable");// название контакта в папке build

module.exports = function(deployer) {
    
deployer.deploy(lottery);
};



