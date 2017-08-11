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
	bool public allowTransfer = false;										// Flag to change if transfering is allowed
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

		// The amount of ether must be greater than 0
		require(msg.value > 0);


		// Calculate the new ether balance after investment
		uint256 _newEtherBalance = totalETH.add(msg.value);
		

		// CHECK PRESALE AND SALE DATES
		uint256 _conversionRate;
		uint256 _saleStartTime;		
		if (block.timestamp > preSaleStartTime && block.timestamp < preSaleEndTime) {
		
			// Pre-sale flag must be valid
			require(!preSaleHasEnded);
			require(_newEtherBalance > preSaleMaxPurchase);

			_conversionRate = YUPIE_PER_ETH_PRE_SALE;
			_saleStartTime = preSaleStartTime;
		} else if (block.timestamp > saleStartTime && block.timestamp < saleEndTime) {
			if (saleHasEnded) throw;

			_conversionRate = YUPIE_PER_ETH_SALE;
			_saleStartTime = saleStartTime;
		} else {
			throw;
		}


		// CALCULATE TRANSFER AMOUNTS
		uint256 amountOfYUPIE = msg.value.mul(_conversionRate);


		// APPLY BONUSES
		// ETHER BONUS
		if (msg.value > twentyPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE.mul(1.2);
		} else if (msg.value > fiftenPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE.mul(1.15);
		} else if (msg.value > tenPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE.mul(1.1);
		}
		// TIME BONUS
		if (block.timestamp > (_saleStartTime + tenPercentDayBonuses)) {
			amountOfYUPIE = amountOfYUPIE.mul(1.1);
		} else if (block.timestamp > (_saleStartTime + fiftenPercentDayBonuses)) {
			amountOfYUPIE = amountOfYUPIE.mul(1.15);
		} else {
			amountOfYUPIE = amountOfYUPIE.mul(1.2);
		}


		// TODO: CALCULATE BUY AMOUNT RESTRICTIONS
		


		// CALCULATE BALANCES
		uint256 totalSupplySafe = totalSupply.add(amountOfYUPIE);
		uint256 balanceSafe = balances[msg.sender].add(amountOfYUPIE);
		uint256 contributedSafe = ETHContributed[msg.sender].add(msg.value);


		// UPDATE BALANCES
		totalSupply = totalSupplySafe;
		balances[msg.sender] = balanceSafe;
		totalETH = _newEtherBalance;
		ETHContributed[msg.sender] = contributedSafe;


		// TRANSFER BALANCE DURING PRE-SALE
		if (!preSaleHasEnded) teamETHAddress.transfer(msg.value);



		// CREATE EVENT FOR SENDER
		CreatedYUPIE(msg.sender, amountOfYUPIE);
	}
	

	// UPDATE STATE FUNCTIONS
	function endPreSale() {
		// Do not end an already ended sale
		if (preSaleHasEnded) throw;
		
		// Only allow the owner
		if (msg.sender != contractAddress) throw;
		
		preSaleHasEnded = true;
	}
	function endSale() {
		
		
	}
	
	
	// CHANGE PARAMETERS METHODS
	function changeTeamETHAddress(address _newAddress) {
		if (msg.sender != contractAddress) throw;
		teamETHAddress = _newAddress;
	}	
	function changeAllowTransfer(bool _allowTransfer) {
		if (msg.sender != contractAddress) throw;
		allowTransfer = _allowTransfer;
	}
	function changeSaleStartTime(uint256 _saleStartTime) {
		if (msg.sender != contractAddress) throw;
        saleStartTime = _saleStartTime;
	}	
	function changeSaleEndBlock(uint256 _saleEndTime) {
		if (msg.sender != contractAddress) throw;
        saleEndTime = _saleEndTime;
	}
	
	
	// TRANSFER METHODS
	function transfer(address _to, uint _value) {
		// Cannot transfer unless the minimum cap is hit
		if (!allowTransfer) throw;
		
		super.transfer(_to, _value);
	}	
	function transferFrom(address _from, address _to, uint _value) {
		// Cannot transfer unless the minimum cap is hit
		if (!allowTransfer) throw;
		
		super.transferFrom(_from, _to, _value);
	}

}