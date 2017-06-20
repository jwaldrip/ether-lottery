pragma solidity ^0.4.11;

import "ds-test/test.sol";

import "./EtherLottery.sol";

contract EtherLotteryTest is DSTest {
	EtherLottery lottery;

	function setUp() {
		lottery = new EtherLottery();
	}

	function testFirstTicket() logs_gas {
		lottery.buyGenerated();
		log_named_address("commissioner", lottery.commissioner());
		fail();
	}

	function testSecondTicket() logs_gas {
		lottery.buyGenerated();
		log_named_address("commissioner", lottery.commissioner());
		fail();
	}
}
