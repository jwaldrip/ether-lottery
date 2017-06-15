pragma solidity ^0.4.11;

import "ds-test/test.sol";

import "./EtherLottery.sol";

contract EtherLotteryTest is DSTest {
	EtherLottery lottery;

	function setUp() {
		lottery = new EtherLottery();
	}

	function testFail_basic_sanity() {
		assert(false);
	}

	function test_basic_sanity() {
		assert(true);
	}
}
