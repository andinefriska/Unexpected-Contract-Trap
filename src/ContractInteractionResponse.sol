// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ContractInteractionResponse {
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function executeTrap(bool shouldTrigger, bytes memory responseData) external {
        require(msg.sender == owner, "Not authorized");

        if (shouldTrigger) {
            (address wallet, address suspiciousContract, string memory message) =
                abi.decode(responseData, (address, address, string));

            emit TrapTriggered(wallet, suspiciousContract, block.timestamp, message);
        } else {
            emit NormalInteraction(msg.sender, block.timestamp);
        }
    }

    event TrapTriggered(address indexed wallet, address indexed suspiciousContract, uint256 timestamp, string message);
    event NormalInteraction(address indexed caller, uint256 timestamp);
}