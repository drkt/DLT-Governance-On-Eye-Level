
// SPDX-License-Identifier: MIT
// Proof of Concept
pragma solidity ^0.8.20;

contract SealedBidAuction {
    address public owner;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    struct Bid {
        bytes32 blindedBid;
        uint deposit;
        bool revealed;
    }

    mapping(address => Bid) public bids;
    address public highestBidder;
    uint public highestBid;

    constructor(uint _biddingTime, uint _revealTime) {
        owner = msg.sender;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    function bid(bytes32 _blindedBid) external payable {
        require(block.timestamp < biddingEnd, "Bidding period is over");
        bids[msg.sender] = Bid({
            blindedBid: _blindedBid,
            deposit: msg.value,
            revealed: false
        });
    }

    function reveal(uint _value, bytes32 _secret) external {
        require(block.timestamp >= biddingEnd, "Bidding not yet ended");
        require(block.timestamp < revealEnd, "Reveal period is over");

        Bid storage bidToCheck = bids[msg.sender];
        require(!bidToCheck.revealed, "Already revealed");
        require(
            bidToCheck.blindedBid == keccak256(abi.encodePacked(_value, _secret)),
            "Invalid bid reveal"
        );

        bidToCheck.revealed = true;

        if (bidToCheck.deposit >= _value && _value > highestBid) {
            highestBid = _value;
            highestBidder = msg.sender;
        }
    }

    function auctionEnd() external {
        require(block.timestamp >= revealEnd, "Reveal period not yet ended");
        require(!ended, "Auction already ended");

        ended = true;
        payable(owner).transfer(highestBid);
    }
}
