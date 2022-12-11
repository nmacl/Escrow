// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    address public owner;

    modifier isOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }


    struct Escrow {
        address seller;
        uint owed;
        uint expiration;
    }

    mapping(address => Escrow) actives;

    function deposit(address seller, uint expiration) external payable {
        uint owed = msg.value;
        require(actives[msg.sender].owed == 0, "Address already has an active escrow!");
        require(actives[msg.sender].expiration == 0, "Address previous escrow hasn't expired.");
        require(seller != msg.sender, "Cannot create escrow with yourself.");
        require(owed > 0, "Must deposit more than 0 ether.");
        require(seller != address(0), "Cannot create escrow with 0 address.");
        actives[msg.sender].seller = seller;
        actives[msg.sender].owed = owed;
        actives[msg.sender].expiration = block.number + expiration;
    }

    function adminCancel(address payable buyer) public isOwner {
        uint owed = actives[buyer].owed;
        require(owed > 0, "Escrow doesn't exist.");
        buyer.transfer(owed);
        reset(buyer);
    }

    function userCancel(address payable buyer) public {
        require(buyer == msg.sender || actives[buyer].seller == msg.sender, "Escrow can only be cancelled by the seller or buyer.");
        uint expiration = actives[buyer].expiration;
        require(expiration != 0, "Escrow doesn't exist");
        require(block.number >= expiration, "Expiration date not reached");
        uint owed = actives[buyer].owed;
        require(owed > 0, "Escrow doesn't exist.");
        buyer.transfer(owed);
        reset(buyer);
    }

    function getEscrow(address buyer) public returns(uint owe, uint exp, address seller) {
        return(actives[buyer].owed, actives[buyer].expiration, actives[buyer].seller);
    }

    function complete(address buyer) public isOwner {
        uint owed = actives[buyer].owed;
        require(owed > 0, "Escrow doesn't exist.");
        address payable seller = payable(actives[buyer].seller);
        seller.transfer(owed);
        reset(buyer);
    }

    function reset(address buyer) private {
        actives[buyer].seller = address(0);
        actives[buyer].owed = 0;
        actives[buyer].expiration = 0;
    }

}