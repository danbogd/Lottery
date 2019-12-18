// Import the modules you want from @openzeppelin/test-helpers
const { BN, constants, balance, send, setup, ether, expectEvent, shouldFail } = require('openzeppelin-test-helpers'); // не видит какие установлены
const { ZERO_ADDRESS } = constants;

// Optionally import Chai to write your assertions (must be installed separately)
const { expect } = require('chai');

const Lottery = artifacts.require('Lottery');

const value = ether('1');
const smallValue = ether('0.0001');

contract('Lottery', function ([owner, new_owner, client]) {// прописываем адреса участников
  beforeEach(async function () {
    this.lottery = await Lottery.new();
    
  });

  

  it('emits a  ChangeAddressOfLotteryOwner event', async function () {
    const {logs} = await this.lottery.NewAccountOfLotteryOwner(new_owner); // принимаем лог  , { from: sender }

    // Event assertions can verify that the arguments are the expected ones
    expectEvent.inLogs(logs, 'ChangeAddressOfLotteryOwner', {  // У expectEvent есть функция inLogs
      
      previousLotteryOwner: new_owner,
      newLotteryOwner: new_owner,
      
    });
  });

  
  it('reverts when zero address', async function () {
    // Conditions that trigger a require statement can be precisely tested
    await shouldFail.reverting(this.lottery.NewAccountOfLotteryOwner(ZERO_ADDRESS));
  });


  it('contract should accept payments from client', async function () {
    await this.lottery.send(value, { from: client });
  });

  
  it('reverts on zero-valued payments', async function () {
    await shouldFail.reverting.withMessage(this.lottery.send(0, { from: client }), 'require minimum 1 finney');
  });
        
  it('reverts on payments under 1 finney', async function () {
    await shouldFail.reverting.withMessage(this.lottery.send(smallValue, { from: client }), 'require minimum 1 finney');
  });

  it('get clients ticket Balance', async function () {
    await this.lottery.send(value, { from: client });
    ticketBalance = await this.lottery.getTicketBalance(client);
    expect(ticketBalance).to.be.bignumber.equal('1000');
  });

  it('emits a  TicketsBought event', async function () {
   const {logs} = await this.lottery.send(value, { from: client }); 
  expectEvent.inLogs(logs, 'TicketsBought', {  
      
      _from: client,
      _quantity: '1000',
      
    });
  });


});