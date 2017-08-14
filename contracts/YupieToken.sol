pragma solidity ^0.4.11;
import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract YupieToken is StandardToken {
	using SafeMath for uint256;

    // EVENTS
    event CreatedYUPIE(address indexed _creator, uint256 _amountOfYUPIE);

	
	// TOKEN DATA
	string public constant name = "YUPIE";
	string public constant symbol = "YUP";
	uint256 public constant decimals = 18;
	string public version = "1.0";

	// YUPIE TOKEN PURCHASE LIMITS
	uint256 public maxPresaleSupply; 														// MAX TOTAL DURING PRESALE (0.8% of MAXTOTALSUPPLY)

	// PURCHASE DATES
	uint256 public constant preSaleStartTime = 0; //1502784000; 							// GMT: Tuesday, August 15, 2017 8:00:00 AM
	uint256 public constant preSaleEndTime = 1505671200; 									// GMT: Sunday, September 17, 2017 6:00:00 PM
	uint256 public constant saleStartTime = 1509523200; 									// GMT: Wednesday, November 1, 2017 8:00:00 AM
	uint256 public constant saleEndTime = 1512115200; 										// GMT: Friday, December 1, 2017 8:00:00 AM

	// PURCHASE BONUSES
	uint256 public constant tenPercentEtherBonuses = 5 * 1 ether; 							// 5+ Ether
	uint256 public constant fiftenPercentEtherBonuses = 24 * 1 ether; 						// 24+ Ether
	uint256 public constant twentyPercentEtherBonuses = 50 * 1 ether; 						// 50+ Ether
	uint256 public constant twentyPercentDayBonuses = 0; 									// 1-12 Days
	uint256 public constant fifteenPercentDayBonuses = 1036800; 							// 12-24 Days
	uint256 public constant tenPercentDayBonuses = 2073600;									// 24+ Days

	// PRICING INFO
	uint256 public constant YUPIE_PER_ETH_PRE_SALE = 3000;  								// 3000 YUPIE = 1 ETH
	uint256 public constant YUPIE_PER_ETH_SALE = 1000;  									// 1000 YUPIE = 1 ETH
	
	// ADDRESSES
	address public constant ownerAddress = 0x5E31408E65937713883cA60a5396cb4524c9288b; 		// The owners address

	// STATE INFO	
	bool public allowInvestment = true;														// Flag to change if transfering is allowed
	uint256 public totalWEIInvested = 0; 													// Total WEI invested
	uint256 public totalYUPIESAllocated = 0;												// Total YUPIES allocated
	mapping (address => uint256) public WEIContributed; 									// Total WEI Per Account


	// INITIALIZATIONS FUNCTION
	function YupieToken() {
		require(msg.sender == ownerAddress);

		totalSupply = 631*1000000*1000000000000000000; 										// MAX TOTAL YUPIES 631 million
		maxPresaleSupply = totalSupply*8/1000; 											// MAX TOTAL DURING PRESALE (0.8% of MAXTOTALSUPPLY)
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
			amountOfYUPIE = amountOfWei.mul(YUPIE_PER_ETH_PRE_SALE);
			tenPercentBonusTime = preSaleStartTime + tenPercentDayBonuses;
			fifteenPercentBonusTime = preSaleStartTime + fifteenPercentDayBonuses;
			totalYUPIEAvailable = maxPresaleSupply - totalYUPIESAllocated;
		} else if (block.timestamp > saleStartTime && block.timestamp < saleEndTime) {
			// ICO
			amountOfYUPIE = amountOfWei.mul(YUPIE_PER_ETH_SALE);
			tenPercentBonusTime = saleStartTime + tenPercentDayBonuses;
			fifteenPercentBonusTime = saleStartTime + fifteenPercentDayBonuses;
			totalYUPIEAvailable = totalSupply - totalYUPIESAllocated;
		} else {
			// Invalid investment period
			revert();
		}

		// Check that YUPIES calculated greater than zero
		assert(amountOfYUPIE > 0);

		// Apply Bonuses
		if (amountOfWei >= twentyPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE.mul(12).div(10);
		} else if (amountOfWei >= fiftenPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE.mul(115).div(100);
		} else if (amountOfWei >= tenPercentEtherBonuses) {
			amountOfYUPIE = amountOfYUPIE.mul(11).div(10);
		}
		if (block.timestamp >= (tenPercentBonusTime)) {
			amountOfYUPIE = amountOfYUPIE.mul(11).div(10);
		} else if (block.timestamp >= (fifteenPercentBonusTime)) {
			amountOfYUPIE = amountOfYUPIE.mul(115).div(100);
		} else {
			amountOfYUPIE = amountOfYUPIE.mul(12).div(10);
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

		// CREATE EVENT FOR SENDER
		CreatedYUPIE(msg.sender, amountOfYUPIE);
	}
	
	
	

}