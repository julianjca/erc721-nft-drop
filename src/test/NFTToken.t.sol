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
        nftToken.mintNft{value: 0.3 ether}(2);
        assertEq(nftToken.totalSupply(), 2);
    }
}
