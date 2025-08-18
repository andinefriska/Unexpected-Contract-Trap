// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract UnexpectedContractTrap is ITrap {
    
    constructor() {}
    
    function collect() external view override returns (bytes memory) {
        // Collect data on contracts that have been interacted with
        // In a real implementation, this would access storage or event logs
        // For a demo, encode dummy data
        address[] memory knownContracts = new address[](3);
        knownContracts[0] = 0x1234567890123456789012345678901234567890;
        knownContracts[1] = 0xaBcDef1234567890123456789012345678901234;
        knownContracts[2] = 0x9876543210987654321098765432109876543210;
        
        return abi.encode(knownContracts, msg.sender);
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length == 0) {
            return (false, abi.encode(address(0), address(0), "No data provided"));
        }
        
        (address[] memory knownContracts, address wallet) = 
            abi.decode(data[0], (address[], address));
        
        bool hasUnknownContract = false;
        address unknownContract = address(0);
        
        if (data.length > 1) {
            address newContract = abi.decode(data[1], (address));
            
            bool isKnown = false;
            for (uint i = 0; i < knownContracts.length; i++) {
                if (knownContracts[i] == newContract) {
                    isKnown = true;
                    break;
                }
            }
            
            if (!isKnown) {
                hasUnknownContract = true;
                unknownContract = newContract;
            }
        }
        
        bytes memory responseData = abi.encode(
            wallet,
            unknownContract,
            hasUnknownContract ? "ALERT: Unexpected contract interaction detected!" : "All interactions are with known contracts"
        );
        
        return (hasUnknownContract, responseData);
    }
}