pragma solidity ^0.4.4;
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract YupieToken is StandardToken {

    // EVENTS
    event CreatedYUPIE(address indexed _creator, uint256 _amountOfYUPIE);

	
	// TOKEN DATA
	string public constant name = "YUPIE";
	string public constant symbol = "YUP";
	uint256 public constant decimals = 18;
	string public version = "1.0";

	// YUPIE TOKEN PURCHASE LIMITS
	uint256 public constant maxTotalSupply = 631000000; 					// MAX TOTAL YUPIES
	uint256 public constant maxPresaleSupply = maxTotalSupply*8/1000; 		// MAX TOTAL DURING PRESALE (0.8% of MAXTOTALSUPPLY)

	// PURCHASE DATES
	uint256 public constant preSaleStartTime = 1502784000; 					// GMT: Tuesday, August 15, 2017 8:00:00 AM
	uint256 public constant preSaleEndTime = 1505671200; 					// GMT: Sunday, September 17, 2017 6:00:00 PM
	uint256 public constant saleStartTime = 1509523200; 					// GMT: Wednesday, November 1, 2017 8:00:00 AM
	uint256 public constant saleEndTime = 1512115200; 						// GMT: Friday, December 1, 2017 8:00:00 AM

	// PURCHASE BONUSES
	uint256 public constant tenPercentEtherBonuses = 5; 					// 5+ Ether
	uint256 public constant fiftenPercentEtherBonuses = 24; 				// 24+ Ether
	uint256 public constant twentyPercentEtherBonuses = 50; 				// 50+ Ether
	uint256 public constant twentyPercentDayBonuses = 0; 					// 1-12 Days
	uint256 public constant fiftenPercentDayBonuses = 1036800; 				// 12-24 Days
	uint256 public constant tenPercentDayBonuses = 2073600;					// 24+ Days

	// PRICING INFO
	uint256 public constant YUPIE_PER_ETH_PRE_SALE = 3000;  				// 3000 YUPIE = 1 ETH
	uint256 public constant YUPIE_PER_ETH_SALE = 1000;  					// 1000 YUPIE = 1 ETH
	
	// ADDRESSES
	address public contractAddress; 										// This contracts address
	address public crowdholdingAddress;	  									// Crowdholding's wallet

	// STATE INFO	
	bool public allowInvestment = false;										// Flag to change if transfering is allowed
	uint256 public totalETH = 0; 											// Total Ethereum Contributed
	mapping (address => uint256) public ETHContributed; 					// Total Ethereum Per Account


	// INITIALIZATIONS FUNCTION
	function YUPIEToken() {
		
		// CHECK VALID ADDRESSES
		require(contractAddress != address(0x0));
		require(crowdholdingAddress != address(0x0));

		// Set Initial State
		contractAddress = msg.sender;

	}


	// FALL BACK FUNCTION TO ALLOW ETHER DONATIONS
	function() payable {
		// This function is called “fallback function” and it is called when someone just sent Ether to the contract without providing any data or if someone messed up the types so that they tried to call a function that does not exist.

		// The default behaviour (if no fallback function is explicitly given) in these situations is to throw an exception.

		// If the contract is meant to receive Ether with simple transfers, you should implement the fallback function as

		// function() payable { }

		// Another use of the fallback function is to e.g. register that your contract received ether by using an event.

		// Attention: If you implement the fallback function take care that it uses as little gas as possible, because send() will only supply a limited amount.
	}
	

	// INVESTMENT FUNCTION
	function investment() payable external {

		require(allowInvestment);

		// The amount of ether must be greater than 0
		require(msg.value > 0);

		// Investment must be during pre-sale
		require(block.timestamp > preSaleStartTime && block.timestamp < preSaleEndTime);

		// CALCULATE TRANSFER AMOUNTS
		uint256 amountOfYUPIE = msg.value.mul(YUPIE_PER_ETH_PRE_SALE);

		// APPLY BONUSES
		if (msg.value > twentyPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE*12/10;
		} else if (msg.value > fiftenPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE*115/100;
		} else if (msg.value > tenPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE*11/10;
		}
		if (block.timestamp > (preSaleStartTime + tenPercentDayBonuses)) {
			amountOfYUPIE = amountOfYUPIE*11/10;
		} else if (block.timestamp > (preSaleStartTime + fiftenPercentDayBonuses)) {
			amountOfYUPIE = amountOfYUPIE*115/100;
		} else {
			amountOfYUPIE = amountOfYUPIE*12/10;
		}

		// CALCULATE BALANCES
		uint256 totalSupplySafe = totalSupply.add(amountOfYUPIE);
		uint256 balanceSafe = balances[msg.sender].add(amountOfYUPIE);
		uint256 contributedSafe = ETHContributed[msg.sender].add(msg.value);

		// UPDATE BALANCES
		totalSupply = totalSupplySafe;
		balances[msg.sender] = balanceSafe;
		totalETH = totalETH.add(msg.value);
		ETHContributed[msg.sender] = contributedSafe;

		// CHECK VALUES
		assert(totalSupplySafe > 0);
		assert(balanceSafe > 0);
		assert(contributedSafe > 0);

		// TRANSFER BALANCE DURING PRE-SALE
		crowdholdingAddress.transfer(msg.value);

		// CREATE EVENT FOR SENDER
		CreatedYUPIE(msg.sender, amountOfYUPIE);
	}
	
	
	// CHANGE PARAMETERS METHODS
	function changeCrowdholdingAddress(address _newAddress) {
		require(msg.sender == contractAddress);
		crowdholdingAddress = _newAddress;
	}	
	function changeAllowInvestment(bool _allowInvestment) {
		require(msg.sender == contractAddress);
		allowInvestment = _allowInvestment;
	}

}