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
	uint256 public constant maxTotalSupply = 631*1000000*1000000000000000000; 	// MAX TOTAL YUPIES 631 million
	uint256 public constant maxPresaleSupply = maxTotalSupply*8/1000; 			// MAX TOTAL DURING PRESALE (0.8% of MAXTOTALSUPPLY)

	// PURCHASE DATES
	uint256 public constant preSaleStartTime = 1502784000; 						// GMT: Tuesday, August 15, 2017 8:00:00 AM
	uint256 public constant preSaleEndTime = 1505671200; 						// GMT: Sunday, September 17, 2017 6:00:00 PM
	uint256 public constant saleStartTime = 1509523200; 						// GMT: Wednesday, November 1, 2017 8:00:00 AM
	uint256 public constant saleEndTime = 1512115200; 							// GMT: Friday, December 1, 2017 8:00:00 AM

	// PURCHASE BONUSES
	uint256 public constant tenPercentEtherBonuses = 5 * 1 ether; 				// 5+ Ether
	uint256 public constant fiftenPercentEtherBonuses = 24 * 1 ether; 			// 24+ Ether
	uint256 public constant twentyPercentEtherBonuses = 50 * 1 ether; 			// 50+ Ether
	uint256 public constant twentyPercentDayBonuses = 0; 						// 1-12 Days
	uint256 public constant fifteenPercentDayBonuses = 1036800; 				// 12-24 Days
	uint256 public constant tenPercentDayBonuses = 2073600;						// 24+ Days

	// PRICING INFO
	uint256 public constant YUPIE_PER_WEI_PRE_SALE = 3000 * 1 ether;  			// 3000 YUPIE = 1 ETH
	uint256 public constant YUPIE_PER_WEI_SALE = 1000 * 1 ether;  				// 1000 YUPIE = 1 ETH
	
	// ADDRESSES
	address public contractAddress; 											// This contracts address
	address public crowdholdingAddress;	  										// Crowdholding's wallet

	// STATE INFO	
	bool public allowInvestment = true;											// Flag to change if transfering is allowed
	uint256 public totalWEIInvested = 0; 										// Total WEI invested
	uint256 public totalYUPIESAllocated = 0;									// Total YUPIES allocated
	mapping (address => uint256) public WEIContributed; 						// Total WEI Per Account


	// INITIALIZATIONS FUNCTION
	function YupieToken() {
		
		// CHECK VALID ADDRESSES
		require(contractAddress != address(0x0));
		require(crowdholdingAddress != address(0x0));

		// Set Initial State
		contractAddress = msg.sender;

	}


	// FALL BACK FUNCTION TO ALLOW ETHER DONATIONS
	function() payable {

		require(allowInvestment);

		// The amount of wei must be greater than 0
		uint256 amountOfWei = msg.value;
		require(amountOfWei > 0);

		uint256 amountOfYUPIE = 0;
		uint256 tenPercentBonusTime = 0; 	
		uint256 fifteenPercentBonusTime = 0; 	
		uint256 totalYUPIEAvailable = 0;

		// Investment periods
		if (block.timestamp > preSaleStartTime && block.timestamp < preSaleEndTime) {
			// Pre-sale ICO
			amountOfYUPIE = amountOfWei.mul(YUPIE_PER_WEI_PRE_SALE);
			tenPercentBonusTime = preSaleStartTime + tenPercentDayBonuses;
			fifteenPercentBonusTime = preSaleStartTime + fifteenPercentDayBonuses;
			totalYUPIEAvailable = maxPresaleSupply - totalYUPIESAllocated;
		} else if (block.timestamp > saleStartTime && block.timestamp < saleEndTime) {
			// ICO
			amountOfYUPIE = amountOfWei.mul(YUPIE_PER_WEI_SALE);
			tenPercentBonusTime = saleStartTime + tenPercentDayBonuses;
			fifteenPercentBonusTime = saleStartTime + fifteenPercentDayBonuses;
			totalYUPIEAvailable = maxTotalSupply - totalYUPIESAllocated;
		} else {
			// Invalid investment period
			revert();
		}

		// Check that YUPIES calculated greater than zero
		assert(amountOfYUPIE > 0);

		// Apply Bonuses
		if (amountOfWei > twentyPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE*12/10;
		} else if (amountOfWei > fiftenPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE*115/100;
		} else if (amountOfWei > tenPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE*11/10;
		}
		if (block.timestamp > (tenPercentBonusTime)) {
			amountOfYUPIE = amountOfYUPIE*11/10;
		} else if (block.timestamp > (fifteenPercentBonusTime)) {
			amountOfYUPIE = amountOfYUPIE*115/100;
		} else {
			amountOfYUPIE = amountOfYUPIE*12/10;
		}

		// Max sure it doesn't exceed remaining supply
		assert(amountOfYUPIE <= totalYUPIEAvailable);

		// Update total YUPIE balance
		totalYUPIESAllocated = totalYUPIESAllocated + amountOfYUPIE;

		// Update user YUPIE balance
		uint256 balanceSafe = balances[msg.sender].add(amountOfYUPIE);
		balances[msg.sender] = balanceSafe;

		// Update total WEI Invested
		totalWEIInvested = totalWEIInvested.add(amountOfWei);

		// Update total WEI Invested by account
		uint256 contributedSafe = WEIContributed[msg.sender].add(amountOfWei);
		WEIContributed[msg.sender] = contributedSafe;

		// CHECK VALUES
		assert(totalYUPIESAllocated > 0);
		assert(balanceSafe > 0);
		assert(totalWEIInvested > 0);
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