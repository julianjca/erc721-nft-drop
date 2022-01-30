// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {NFTToken} from "../NFTToken.sol";

contract NFTTokenTest is DSTestPlus {
    NFTToken nftToken;

    function setUp() public {
        nftToken = new NFTToken("My NFT", "MNFT", "https://");
    }

    function testMint() public {
        nftToken.mintNft{value: nftToken.price() * 5}(5);
        assertEq(nftToken.balanceOf(address(this)), 5);
        assertEq(nftToken.totalSupply(), 5);
    }

    function testSingleMint() public {
        nftToken.mintNft{value: nftToken.price() * 1}(1);
        assertEq(nftToken.totalSupply(), 1);
        assertEq(nftToken.balanceOf(address(this)), 1);
    }

    function testWithdraw() public {
        nftToken.mintNft{value: nftToken.price() * 1}(1);
        nftToken.withdraw();
        assertEq(address(nftToken.vaultAddress()).balance, 0.15 ether);
        assertEq(address(nftToken).balance, 0);
    }

    function testMintMoreThanLimit() public {
        vm.expectRevert(abi.encodeWithSignature("MaxAmountPerTrxReached()"));

        nftToken.mintNft{value: 1.2 ether}(8);
    }

    function testMintWithoutEtherValue() public {
        vm.expectRevert(abi.encodeWithSignature("WrongEtherAmount()"));

        nftToken.mintNft(1);
    }

    function testOutOfToken() public {
        vm.store(
            address(nftToken),
            bytes32(uint256(7)),
            bytes32(uint256(10000))
        );

        vm.expectRevert(abi.encodeWithSignature("MaxSupplyReached()"));

        nftToken.mintNft{value: 0.15 ether}(1);
    }

    function testOutOfTokenWhenSupplyNotMet() public {
        vm.store(
            address(nftToken),
            bytes32(uint256(7)),
            bytes32(uint256(9998))
        );

        vm.expectRevert(abi.encodeWithSignature("MaxSupplyReached()"));

        nftToken.mintNft{value: 0.45 ether}(3);
    }
}
