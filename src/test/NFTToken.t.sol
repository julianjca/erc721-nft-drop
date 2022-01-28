// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {NFTToken} from "../NFTToken.sol";

error MaxSupplyReached();
error MaxAmountPerTrxReached();

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
    }
}
