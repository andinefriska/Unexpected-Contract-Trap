// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract UnexpectedContractTrap is ITrap {
    constructor() {}

    function collect() external view override returns (bytes memory) {
        return abi.encode(msg.sender);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, abi.encode(address(0), "Not enough history"));
        }

        address newContract = abi.decode(data[data.length - 1], (address));
        address oldContract = abi.decode(data[data.length - 2], (address));

        bool hasUnexpected = (newContract != oldContract);

        bytes memory responseData = abi.encode(
            newContract,
            hasUnexpected
                ? "ALERT: Unexpected contract interaction detected!"
                : "No change, interaction consistent"
        );

        return (hasUnexpected, responseData);
    }
}