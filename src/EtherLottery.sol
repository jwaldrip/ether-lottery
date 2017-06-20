pragma solidity ^0.4.11;

contract EtherLottery {
	// Constants for gameplay
	uint constant numberOfPicks = 5;
	uint constant maxPickNumber = 50;
	uint constant maxPowerPickNumber = 15;
	uint constant initialTicketPrice = 0.01 ether;
	uint constant ticketIncreaseInterval = 1000; // per # of purchases
	uint constant ticketIncreaseAmount = 0.01 ether;

	// Address of the commissioner, who will receive a tiny portion
	// of the proceeds
	address public commissioner;

	// Stored Variables
	Ticket[] public tickets;
	uint ticketPrice;
	uint private seed;

	// The struct that holds the information regarding the ticket
	struct Ticket {
		address player;
		uint[] picks;
	}

	// Constructor
	function EtherLottery(){
		commissioner = msg.sender;
		ticketPrice = initialTicketPrice;
		seed = now;
		randomNumber();
	}

	// Get the jackpot minus the commission fee (0.1%)
	function getJackpot() public returns (uint fee) {
		return this.balance - (this.balance / 1000);
	}

	// Generate a random number
	function randomNumber() public returns (uint number) {
		address addr;
		if (tickets.length > 0) {
			addr = tickets[tickets.length - 1].player;
		} else {
			addr = commissioner;
		}
		seed = (seed ** 2) % (uint(addr) % 1000000);
		return 1 + (seed % maxPickNumber);
	}

	function randomPicks() public returns (uint[] generatedPicks) {
		uint[] memory picks = new uint[](numberOfPicks);
		for (uint i = 0; i < numberOfPicks; i++) {
			picks[i] = randomNumber();
		}
		if (!validatePicks(picks)) {
			return randomPicks();
		}
		return picks;
	}

	// Validate the tickets
	function validateTicket(Ticket ticket) private returns (Ticket memory t) {
		// Make sure the pick number is correct
		assert(ticket.picks.length == numberOfPicks);
		assert(validatePicks(ticket.picks));
		return ticket;
	}

	// Validate the picks
	function validatePicks(uint[] picks) public returns (bool passed) {
		bool pass = true;

		// Validate each number
		for (uint i1 = 0; i1 < picks.length; i1++) {
			// Number must be greater than 0
			pass = pass && picks[i1] > 0;

			// Number must be less than maxPickNumber or be zero
			pass = pass && picks[i1] < maxPickNumber;

			// Numbers can not be the same as any other number
			for (uint i2 = i1 + 1; i2 < picks.length; i2++) {
				pass = pass && picks[i1] != picks[i2];
			}
		}
		return pass;
	}

  // Buy a ticket with randomly generated numbers
	function buyGenerated() payable public {
		uint value = msg.value;
		while (value > ticketPrice) {
			value = value - ticketPrice;
			generateTicket();
		}
		msg.sender.transfer(value); // Refund any excess funds
	}

	// Generate a random ticket and add it to tickets
	function generateTicket() public {
		issueTicket(randomPicks());
  }

	// Buy a ticket with user provided numbers
	function buyPicks(uint[] picks) payable public {
		// Refund the amount if it is not the exact ticket price
		if (msg.value != ticketPrice) {
			throw;
		}
		issueTicket(picks);
	}

	// Issue a ticket with the given picks
	function issueTicket(uint[] picks) private {
		Ticket memory ticket = validateTicket(
			Ticket(
				msg.sender,
				picks
			)
		);
		tickets.push(ticket);
	}
}
