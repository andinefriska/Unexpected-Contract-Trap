// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ContractInteractionResponse {
    address public owner;
    mapping(address => bool) public operators;

    event TrapTriggered(address indexed wallet, uint256 blockNumber, address indexed caller);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() { 
        require(msg.sender == owner, "Not authorized"); 
        _; 
    }

    function setOperator(address op, bool ok) external onlyOwner {
        operators[op] = ok;
    }

    function execute(bytes calldata payload) external {
        require(operators[msg.sender], "Not authorized");
        (address wallet, uint256 blockNumber) = abi.decode(payload, (address, uint256));
        emit TrapTriggered(wallet, blockNumber, msg.sender);
    }
}
