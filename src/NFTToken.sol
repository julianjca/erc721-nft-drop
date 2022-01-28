// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";

error TokenDoesNotExist();
error MaxSupplyReached();
error WrongEtherAmount();
error MaxAmountPerTrxReached();

/// @title NFTToken
/// @author Julian <juliancanderson@gmail.com>
contract NFTToken is ERC721 {
    using Strings for uint256;

    uint256 public totalSupply = 0;
    string public baseURI;

    uint256 public immutable maxSupply = 10000;
    uint256 public immutable price = 0.15 ether;
    uint256 public immutable maxAmountPerTrx = 5;

    address public vaultAddress;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name, _symbol) {
        baseURI = _baseURI;
    }

    function mintNft(uint16 amount) external payable {
        if (totalSupply + amount > maxSupply) revert MaxSupplyReached();
        if (msg.value < price * amount) revert WrongEtherAmount();
        if (amount > maxAmountPerTrx) revert MaxAmountPerTrxReached();

        unchecked {
            for (uint256 index = 0; index < amount; index++) {
                uint256 tokenId = totalSupply + 1;
                _mint(msg.sender, tokenId);
                totalSupply++;
            }
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (ownerOf[tokenId] == address(0)) {
            revert TokenDoesNotExist();
        }

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }
}
