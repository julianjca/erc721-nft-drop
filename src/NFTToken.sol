// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";

error TokenDoesNotExist();
error MaxSupplyReached();
error WrongEtherAmount();
error MaxAmountPerTrxReached();
error NoEthBalance();

/// @title ERC721 NFT Drop
/// @title NFTToken
/// @author Julian <juliancanderson@gmail.com>
contract NFTToken is ERC721, Ownable {
    using Strings for uint256;

    uint256 public totalSupply = 0;
    string public baseURI;

    uint256 public immutable maxSupply = 10000;
    uint256 public immutable price = 0.15 ether;
    uint256 public immutable maxAmountPerTrx = 5;

    address public vaultAddress = 0x06f75da47a438f65b2C4cc7E0ee729d5C67CA174;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Creates an NFT Drop
    /// @param _name The name of the token.
    /// @param _symbol The Symbol of the token.
    /// @param _baseURI The baseURI for the token that will be used for metadata.
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name, _symbol) {
        baseURI = _baseURI;
    }

    /*///////////////////////////////////////////////////////////////
                               MINT FUNCTION
    //////////////////////////////////////////////////////////////*/

    /// @notice Mint NFT function.
    /// @param amount Amount of token that the sender wants to mint.
    function mintNft(uint256 amount) external payable {
        if (amount > maxAmountPerTrx) revert MaxAmountPerTrxReached();
        if (totalSupply + amount > maxSupply) revert MaxSupplyReached();
        if (msg.value < price * amount) revert WrongEtherAmount();

        unchecked {
            for (uint256 index = 0; index < amount; index++) {
                uint256 tokenId = totalSupply + 1;
                _mint(msg.sender, tokenId);
                totalSupply++;
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                            ETH WITHDRAWAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Withdraw all ETH from the contract to the vault addres.
    function withdraw() external onlyOwner {
        if (address(this).balance == 0) revert NoEthBalance();
        SafeTransferLib.safeTransferETH(vaultAddress, address(this).balance);
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
