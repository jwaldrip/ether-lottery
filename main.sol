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
	address commissioner;
	uint commissionFee = uint(0.001);

	// Stored Variables
	Ticket[] tickets;
	uint ticketPrice;

	struct Ticket {
		address player;
		uint[] picks;
		uint powerPick;
	}

	function EtherLottery(){
		commissioner = msg.sender;
		ticketPrice = initialTicketPrice;
	}

	function randomNumber(uint seed) returns (uint number) {
		address addr;
		if (tickets.length > 0) {
			addr = tickets[tickets.length / 2].player;
		} else {
			addr = commissioner;
		}
		return 1 + ((uint(addr) ** seed) % maxPickNumber + 1);
	}

	// Validate the picks
	function validatePicks(Ticket ticket) private returns (Ticket memory t) {
		// Make sure the pick number is correct
		assert(tickets.length == numberOfPicks);

		// Validate each number
		for (uint i1 = 0; i1 < numberOfPicks; i1++) {
			// Number must be greater than 0
			assert(ticket.picks[i1] > 0);

			// Number must be less than maxPickNumber
			assert(ticket.picks[i1] < maxPickNumber);

			// Numbers can not be the same as any other number
			for (uint i2 = i1 + 1; i2 < numberOfPicks; i2++) {
				assert(ticket.picks[i1] == ticket.picks[i2]);
			}
		}
		return ticket;
	}

  // Buy a ticket with randomly generated numbers
	function buyGenerated(bool buyPowerPick) {
		uint value = msg.value;
		while (value > ticketPrice) {
			value = value - ticketPrice;
			generateTicket(buyPowerPick);
		}
		msg.sender.transfer(value); // Refund any excess funds
	}

	function generateTicket(bool buyPowerPick) private {
		uint powerPick;
		uint[] memory picks = new uint[](numberOfPicks);
		for (uint i = 0; i < numberOfPicks; i++) {
			picks[i] = randomNumber(i + 1);
		}
		if (buyPowerPick) {
			powerPick = randomNumber(picks.length + 1);
		}
		issueTicket(picks, powerPick);
  }

	// Buy a ticket with user provided numbers
	function buyPicks(uint[] picks, uint powerPick) {
		// Refund the amount if it is not the exact ticket price
		if (msg.value != ticketPrice) {
			throw;
		}
		issueTicket(picks, powerPick);
	}

	function issueTicket(uint[] picks, uint powerPick) private {
		Ticket memory ticket = validatePicks(Ticket(
			msg.sender,
			picks,
			powerPick
			));
		tickets.push(ticket);
	}
}
