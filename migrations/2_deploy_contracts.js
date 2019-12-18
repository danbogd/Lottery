/*
const Lottery = artifacts.require("CourseLottery");// название контакта в папке build

module.exports = function(deployer) {
    const ticketsIssued = 0;
    const lotteryStart = now;
    const lotteryDuration = 24 hours;   
deployer.deploy(Lottery,ticketsIssued, lotteryStart, lotteryDuration);
};
*/
const Lottery= artifacts.require("Lottery");// название контакта в папке build

module.exports = function(deployer) {
       
deployer.deploy(Lottery);// название верхней переменной const Lottery
};

