// Import the modules you want from @openzeppelin/test-helpers
const { BN, constants, balance, expectEvent, expectRevert } = require('openzeppelin-test-helpers');

// Optionally import Chai to write your assertions (must be installed separately)
const { expect } = require('chai');

const Lottery = artifacts.require('Lottery');

contract('Lottery', function ([sender, receiver]) {
  beforeEach(async function () {
    this.lottery = await Lottery.new();
    this.value = new BN(1); // The bundled BN library is the same one truffle and web3 use under the hood
  });

  /*
  it('reverts when transferring tokens to the zero address', async function () {
    // Conditions that trigger a require statement can be precisely tested
    await expectRevert(
      this.erc20.transfer(constants.ZERO_ADDRESS, this.value, { from: sender }),
      'ERC20: transfer to the zero address',
    );
  });

  */

  it('emits a ChangeAddressOfLotteryOwner event', async function () {
    const receipt = await this.lottery.NewAccountOfLotteryOwner(sender, { from: receiver});
/*
    // Event assertions can verify that the arguments are the expected ones
    expectEvent(receipt, 'ChangeAddressOfLotteryOwner', {
      
      
    });
    */
  });

  /*

  it('updates balances on successful transfers', async function () {
    this.erc20.transfer(receiver, this.value, { from: sender });

    // If Chai is installed, big number assertions are automatically available thanks to chai-bn
    assert(await balance(receiver)).to.be.bignumber.equal(this.value);
  });

  */
});