// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {UnexpectedContractTrap} from "../src/UnexpectedContractTrap.sol";

contract UnexpectedContractTrapTest is Test {
    UnexpectedContractTrap public trap;
    
    address public testWallet = address(0x1111);
    address public knownContract1 = 0x1234567890123456789012345678901234567890;
    address public knownContract2 = 0xaBcDef1234567890123456789012345678901234;
    address public knownContract3 = 0x9876543210987654321098765432109876543210;
    address public unknownContract = address(0x2222);
    
    function setUp() public {
        trap = new UnexpectedContractTrap();
    }
    
    function testCollectFunction() public {
        vm.prank(testWallet);
        bytes memory collectData = trap.collect();
        
        (address[] memory knownContracts, address wallet) = 
            abi.decode(collectData, (address[], address));
        
        assertEq(wallet, testWallet);
        assertEq(knownContracts.length, 3);
        assertEq(knownContracts[0], knownContract1);
        assertEq(knownContracts[1], knownContract2);
        assertEq(knownContracts[2], knownContract3);
    }
    
    function testShouldRespondWithNoData() public view {
        bytes[] memory emptyData = new bytes[](0);
        
        (bool shouldRespond, bytes memory responseData) = trap.shouldRespond(emptyData);
        
        assertEq(shouldRespond, false);
        
        (address wallet, address suspiciousContract, string memory message) = 
            abi.decode(responseData, (address, address, string));
        
        assertEq(wallet, address(0));
        assertEq(suspiciousContract, address(0));
        assertEq(message, "No data provided");
    }
    
    function testShouldRespondWithKnownContract() public {
        vm.prank(testWallet);
        bytes memory collectData = trap.collect();
        
        bytes[] memory data = new bytes[](2);
        data[0] = collectData;
        data[1] = abi.encode(knownContract1);
        
        (bool shouldRespond, bytes memory responseData) = trap.shouldRespond(data);
        
        assertEq(shouldRespond, false);
        
        (address wallet, address suspiciousContract, string memory message) = 
            abi.decode(responseData, (address, address, string));
        
        assertEq(wallet, testWallet);
        assertEq(suspiciousContract, address(0));
        assertEq(message, "All interactions are with known contracts");
    }
    
    function testShouldRespondWithUnknownContract() public {
        vm.prank(testWallet);
        bytes memory collectData = trap.collect();
        
        bytes[] memory data = new bytes[](2);
        data[0] = collectData;
        data[1] = abi.encode(unknownContract);
        
        (bool shouldRespond, bytes memory responseData) = trap.shouldRespond(data);
        
        assertEq(shouldRespond, true);
        
        (address wallet, address suspiciousContract, string memory message) = 
            abi.decode(responseData, (address, address, string));
        
        assertEq(wallet, testWallet);
        assertEq(suspiciousContract, unknownContract);
        assertEq(message, "ALERT: Unexpected contract interaction detected!");
    }
    
    function testShouldRespondWithOnlyCollectData() public {
        vm.prank(testWallet);
        bytes memory collectData = trap.collect();
        
        bytes[] memory data = new bytes[](1);
        data[0] = collectData;
        
        (bool shouldRespond, bytes memory responseData) = trap.shouldRespond(data);
        
        assertEq(shouldRespond, false);
        
        (address wallet, address suspiciousContract, string memory message) = 
            abi.decode(responseData, (address, address, string));
        
        assertEq(wallet, testWallet);
        assertEq(suspiciousContract, address(0));
        assertEq(message, "All interactions are with known contracts");
    }
    
    function testMultipleKnownContractsCheck() public {
        vm.prank(testWallet);
        bytes memory collectData = trap.collect();
        
        address[3] memory testContracts = [knownContract1, knownContract2, knownContract3];
        
        for (uint i = 0; i < testContracts.length; i++) {
            bytes[] memory data = new bytes[](2);
            data[0] = collectData;
            data[1] = abi.encode(testContracts[i]);
            
            (bool shouldRespond,) = trap.shouldRespond(data);
            assertEq(shouldRespond, false, "Known contract should not trigger");
        }
    }
    
    function testFuzzUnknownContracts(address randomContract) public {
        vm.assume(randomContract != knownContract1);
        vm.assume(randomContract != knownContract2);
        vm.assume(randomContract != knownContract3);
        
        vm.prank(testWallet);
        bytes memory collectData = trap.collect();
        
        bytes[] memory data = new bytes[](2);
        data[0] = collectData;
        data[1] = abi.encode(randomContract);
        
        (bool shouldRespond, bytes memory responseData) = trap.shouldRespond(data);
        
        assertEq(shouldRespond, true);
        
        (address wallet, address suspiciousContract, string memory message) = 
            abi.decode(responseData, (address, address, string));
        
        assertEq(wallet, testWallet);
        assertEq(suspiciousContract, randomContract);
        assertEq(message, "ALERT: Unexpected contract interaction detected!");
    }
    
    function testCollectFromDifferentWallets() public {
        address wallet1 = address(0x1111);
        address wallet2 = address(0x2222);
        
        vm.prank(wallet1);
        bytes memory collectData1 = trap.collect();
        
        vm.prank(wallet2);
        bytes memory collectData2 = trap.collect();
        
        (address[] memory knownContracts1, address returnedWallet1) = 
            abi.decode(collectData1, (address[], address));
        (address[] memory knownContracts2, address returnedWallet2) = 
            abi.decode(collectData2, (address[], address));
        
        assertEq(returnedWallet1, wallet1);
        assertEq(returnedWallet2, wallet2);
        
        assertEq(knownContracts1.length, knownContracts2.length);
        for (uint i = 0; i < knownContracts1.length; i++) {
            assertEq(knownContracts1[i], knownContracts2[i]);
        }
    }
}