# Escrow
I haven't tested this on a testnet or a mainnet. Susceptible to re entrancy attacks. Deploy on your favorite solidity supported block chain.

# Purpose
Create an escrow between a buyer and seller. Primarily managed by the admins, or contract owner. Buyer or seller can cancel the escrow once expiration block is reached.

# Functions
Deposit(address seller, uint expiration) - Creates mapping with Escrow struct as value, sender (buyer) address as key. To be called by the buyer. Input the seller's ethereum address, as well as an expiration for when the escrow can be cancelled by the buyer or the seller. 1 block every 12 seconds. 5 blocks = 1 minute. 300 blocks = 1 hour. Approximation.

adminCancel(address buyer) - Cancel an escrow. Escrows are identified by the buyer's address. Owner only.

userCancel(address buyer) - Cancel an escrow. Callable only by seller or buyer. Can only be called after expiration date has been reached. Returns ether to buyer.

getEscrow(address buyer) - Gets an escrow from mapping. Returns seller address, uint owed (wei), and expiration in blocks.

