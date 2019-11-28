pragma solidity ^0.5.0;

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract CourseLottery is Ownable{
    
    using SafeMath for uint256;
    
    struct TicketHolder {
        address _holderAddress;
        uint _numTickets;
    }

    //----------Variables------------
    // Mapping of tickets issued to each address
    mapping (address => uint) public ticketHolders;
    address payable []  public holders;

    // Array of previous winners.
    // TODO: Only hold last 10 winners
    address[] public prevWinners;

    // Winner of the current lottery
    address payable winner;

    // Total number of tickets issued
    uint public ticketsIssued;

    // Total balance of the smart contract
    uint public contractBalance;

    // address of lotery owner
    address payable public addressLotteryOwner = 0x65D069D418E7d56bFc2C1d6D78c5dAd8A32D1882;

    // When the lottery started
    uint public lotteryStart;

    // Duration the lottery will be active for
    uint public lotteryDuration;

    // Flag that the lottery is now over
    bool public lotteryEnded;

    // Total Eth that has been won from users using the contract
    uint public totalEthWon;

    //----------Events---------------
    // Event for when tickets are bought
    event TicketsBought(address indexed _from, uint _quantity);

    // Event for declaring the winner
    event AwardWinnings(address _to, uint _winnings);

    // Event for lottery reset
    event ResetLottery();
    
    event ChangeAddressOfLotteryOwner (address indexed previousLotteryOwner, address indexed newLotteryOwner);

    //---------Modifiers---------------

    // Checks if still in lottery contribution period
    modifier lotteryOngoing() {
        require(now < lotteryStart + lotteryDuration);
        _;
    }

    // Checks if lottery has finished
    modifier lotteryFinished() {
        require(now > lotteryStart + lotteryDuration);
        _;
    }

    //---------Functions----------------
    
    //Create the lottery, each one lasts for 24 hours
    constructor () public {
        ticketsIssued = 0;
        lotteryStart = now;
        lotteryDuration = 24 hours;
    }

    // Fallback function calls buyTickets
    function () payable external {
        buyTickets();
    }
    // Award users tickets for eth, 1 finney = 1 ticket
    function buyTickets() payable public lotteryOngoing returns (bool success) {
        ticketHolders[msg.sender] = msg.value / (10**15);
        ticketsIssued = ticketsIssued.add(ticketHolders[msg.sender]);
        holders.push(msg.sender);
        contractBalance = contractBalance.add(msg.value);
        emit TicketsBought(msg.sender, ticketHolders[msg.sender]);
        return true;
    }

    // After winners have been declared and awarded, clear the arrays and reset the balances
    function resetLottery() internal lotteryFinished returns (bool success) {
        lotteryEnded = false;
        lotteryStart = now;
        lotteryDuration = 24 hours;
        emit ResetLottery();
        return true;
    }


    // change the lottery owner account
    function NewAccountOfLotteryOwner(address payable _addressLotteryOwner) public onlyOwner {
        require (_addressLotteryOwner != address(0), "New lottery owner is the zero address");      
        addressLotteryOwner = _addressLotteryOwner;
        emit ChangeAddressOfLotteryOwner(addressLotteryOwner, _addressLotteryOwner);
        
    }  
   
    
     // This will distribute the correct winnings to each winner
    function awardWinnings(address payable _winner) internal lotteryOngoing returns (bool success) {
        uint256 winner_part_value = contractBalance.mul(99).div(100);
        uint256 amount = contractBalance.sub(winner_part_value);
        
        addressLotteryOwner.transfer(amount); 
        _winner.transfer(contractBalance);
        
        emit AwardWinnings(_winner, contractBalance);
        contractBalance = 0;
        resetLottery();
        return true;
    }

    //Generate the winners by random using tickets bought as weight
    function generateWinners() public lotteryFinished returns (uint winningTicket) {

        //Need to make this truly random - This is temp solution for testing
        uint randNum = uint(blockhash(block.number - 1)) % ticketsIssued + 1;
        winner = holders[randNum];
        prevWinners.push(winner);
        awardWinnings(winner);
        return randNum;
    }

    function getTicketBalance(address _account) public view returns (uint balance) {
        return ticketHolders[_account];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}