pragma solidity ^0.4.11;
import "./StandardToken.sol";
import "./SafeMath.sol";

contract YUPIEToken is StandardToken {
	using SafeMath for uint256;
	

	// EVENTS
	event CreatedYUPIE(address indexed _creator, uint256 _amountOfYUPIE);

	
	// TOKEN DATA
	string public constant name = "YUPIE";
	string public constant symbol = "YUP";
	uint256 public constant decimals = 18;
	string public version = "1.0";


	// YUPIE TOKEN PURCHASE LIMITS
	uint256 public constant maxTotalSupply; 				// MAX TOTAL YUPIE
	uint256 public constant maxTotalForStartups; 			// MAX TOTAL TO STARTUPS
	uint256 public constant maxTotalForEmployees; 			// MAX TOTAL TO EMPLOYEES
	uint256 public constant maxTotalForCompanyForMarketing; // MAX TOTAL TO COMPANY FOR MARKETING
	uint256 public constant maxTotalForCompanyForGrowth; 	// MAX TOTAL TO COMPANY FOR GROWTH
	uint256 public constant maxTotalForCompanyForReserve; 	// MAX TOTAL TO COMPANY FOR RESERVE
	uint256 public constant maxTotalForPurchase; 			// MAX TOTAL FOR PURCHASE
	uint256 public constant preSaleMaxPurchase; 			// MAX TOTAL ETHER PURCHASE DURING PRESALE


	// ETHER DISTRIBUTION
	address public escrowAccount; 			// 85% goes into escrow multi-sig account
	address public crowdholdingAccount; 	// 15% goes to crowdholding for immediate use


	// PURCHASE DATES
	uint256 public preSaleStartTime = 1502798400; 	// August 15th
	uint256 public preSaleEndTime = 1505649600; 	// September 17th
	uint256 public saleStartTime = 1509537600; 		// November 1st
	uint256 public saleEndTime = 1512129600; 		// December 1st


	// PURCHASE BONUSES
	uint256 public tenPercentEtherBonuses = 5; 			// 5+ Ether
	uint256 public fiftenPercentEtherBonuses = 24; 		// 24+ Ether
	uint256 public twentyPercentEtherBonuses = 50; 		// 50+ Ether
	uint256 public twentyPercentDayBonuses = 0; 		// 1-12 Days
	uint256 public fiftenPercentDayBonuses = 1036800; 	// 12-24 Days
	uint256 public tenPercentDayBonuses = 2073600;		// 24+ Days


	// DISTRIBUTION SCHEDULE
	// EVERY 6 MONTHS COMPANY AND EMPLOYEES GET A DISTRIBUTION
	// STARTUPS DONT GET TOKENS BUT CAN TRANSFER
	uint256 public lastDistributionTime = 0; 	// LAST TIME A DISTRIBUTION TOOK PLACE
	

	// PRICING INFO
	uint256 public constant YUPIE_PER_ETH_PRE_SALE = 1000/0.33;  	// 1000 YUPIE = 0.33 ETH
	uint256 public constant YUPIE_PER_ETH_SALE = 1000/0.99;  		// 1000 YUPIE = 0.99 ETH
	

	// ADDRESSES
	address public contractAddress; // This contracts address
	address public teamETHAddress;  // 
	address public teamYUPIEAddress;


	// STATE INFO	
	bool public preSaleHasEnded;
	bool public saleHasEnded;
	bool public allowTransfer;
	bool public maxPreSale;
	uint256 public totalETH; // Total Ethereum Contributed
	mapping (address => uint256) public ETHContributed; // Total Ethereum Per Account


	
	// INITIALIZATIONS FUNCTION
	function YUPIEToken() {
		
		// CHECK VALID ADDRESSES
		if (contractAddress == address(0x0)) throw;
		if (teamETHAddress == address(0x0)) throw;
		if (teamYUPIEAddress == address(0x0)) throw;


		// ALLOCATION INTIAL SUPPLY
		maxTotalSupply = 631000000; 								// MAX TOTAL YUPIE
		maxTotalForStartups = maxTotalSupply.mul(0.05); 			// 5% of MAX TOTAL TO STARTUPS
		maxTotalForEmployees = maxTotalSupply.mul(0.2); 			// 20% of MAX TOTAL TO EMPLOYEES
		maxTotalForCompanyForMarketing = maxTotalSupply.mul(0.01); 	// 1% of MAX TOTAL TO COMPANY FOR MARKETING
		maxTotalForCompanyForGrowth = maxTotalSupply.mul(0.19); 	// 19% of MAX TOTAL TO COMPANY FOR GROWTH
		maxTotalForCompanyForReserve = maxTotalSupply.mul(0.10); 	// 10% of MAX TOTAL TO COMPANY FOR RESERVE
		maxTotalForPurchase = maxTotalSupply.mul(0.45); 			// 45% of MAX TOTAL
		preSaleMaxPurchase = 1250; 									// 1250 TOTAL ETHER PURCHASE DURING PRESALE


		// Set Initial State
		contractAddress = msg.sender;
		preSaleHasEnded = false;
		saleHasEnded = false;
		allowTransfer = false;
		maxPreSale = false;
		totalETH = 0;
		totalSupply = 0;


		//
	}


	// FALL BACK FUNCTION TO ALLOW ETHER DONATIONS
	function() payable {
		//TODO: Attention: If you implement the fallback function take care that it uses as little gas as possible, because send() will only supply a limited amount.
	}
	

	// INVESTMENT FUNCTION
	function investment() payable external {

		// Do not do anything if the amount of ether sent is 0
		if (msg.value <= 0) throw;


		uint256 newEtherBalance = totalETH.add(msg.value);
		

		// CHECK PRESALE AND SALE DATES
		uint256 _conversionRate;
		uint256 _saleStartTime;		
		if (block.timestamp > preSaleStartTime && block.timestamp < preSaleEndTime) {
			if (preSaleHasEnded) throw;
			if (newEtherBalance > preSaleMaxPurchase) throw;

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
		totalETH = newEtherBalance;
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