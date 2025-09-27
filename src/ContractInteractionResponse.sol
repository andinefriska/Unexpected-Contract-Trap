// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ContractInteractionResponse {
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function execute(bytes calldata payload) external {
        require(msg.sender == owner, "Not authorized");

        (address wallet, uint256 blockNumber) = abi.decode(payload, (address, uint256));

        emit TrapTriggered(wallet, blockNumber);
    }

    event TrapTriggered(address indexed wallet, uint256 blockNumber);
}
