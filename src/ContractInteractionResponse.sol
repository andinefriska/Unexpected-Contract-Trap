// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ContractInteractionResponse {
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function execute(bytes calldata payload) external {
        require(msg.sender == owner, "Not authorized");

        address wallet = abi.decode(payload, (address));

        emit TrapTriggered(wallet);
    }

    event TrapTriggered(address indexed wallet);
}
