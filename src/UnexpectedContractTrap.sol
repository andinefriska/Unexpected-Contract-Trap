// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Trap, EventFilter, EventLog, EventFilterLib} from "drosera-contracts/Trap.sol";

contract UnexpectedContractTrap is Trap {
    using EventFilterLib for EventFilter;

    address public constant MONITORED_CONTRACT = 0x1111111111111111111111111111111111111111;

    // Event signature for interaction tracking
    string public constant EVENT_SIG = "SomeInteraction(address,address,bytes)";

    address constant WHITELIST1 = 0x0000000000000000000000000000000000000001;
    address constant WHITELIST2 = 0x0000000000000000000000000000000000000002;
    address constant WHITELIST3 = 0x0000000000000000000000000000000000000003;

    function eventLogFilters() public pure override returns (EventFilter[] memory) {
        EventFilter[] memory filters = new EventFilter[](1);
        filters[0] = EventFilter({
            contractAddress: MONITORED_CONTRACT,
            signature: EVENT_SIG
        });
        return filters;
    }

    function collect() external view override returns (bytes memory) {
        EventLog[] memory logs = getEventLogs();
        return abi.encode(logs, block.number);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length == 0) return (false, "");

        (EventLog[] memory logs, uint256 blk) = abi.decode(data[0], (EventLog[], uint256));
        
        if (logs.length == 0) return (false, "");
        
        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics.length < 2) continue;
            
            address caller = address(uint160(uint256(logs[i].topics[1])));
            bool whitelisted = (caller == WHITELIST1 || caller == WHITELIST2 || caller == WHITELIST3);
            if (!whitelisted) {
                return (true, abi.encode(caller, blk));
            }
        }
        return (false, "");
    }
}
