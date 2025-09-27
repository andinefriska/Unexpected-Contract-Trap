// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract UnexpectedContractTrap is ITrap {
    address constant YOUR_WALLET = 0x1111111111111111111111111111111111111111;

    // Hardcode whitelist
    address constant WHITELIST1 = 0x0000000000000000000000000000000000000001;
    address constant WHITELIST2 = 0x0000000000000000000000000000000000000002;
    address constant WHITELIST3 = 0x0000000000000000000000000000000000000003;

    function collect() external view override returns (bytes memory) {
        return abi.encode(YOUR_WALLET);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length == 0) return (false, "");

        address wallet = abi.decode(data[0], (address));

        bool isWhitelisted = (
            wallet == WHITELIST1 ||
            wallet == WHITELIST2 ||
            wallet == WHITELIST3
        );

        if (!isWhitelisted) {
            return (true, abi.encode(wallet, block.number));
        }

        return (false, "");
    }
}
