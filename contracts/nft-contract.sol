// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title EventTicketNFT
 * @notice This contract represents an NFT that acts as a ticket for an event.
 * @dev The contract is ERC721-compliant and allows minting of unique NFTs for events.
 */
contract EventTicketNFT is ERC721URIStorage, Ownable {
    uint256 public nextTokenId;
    uint256 public maxSupply;
    string public baseURI;

    /// @notice Event emitted when a new ticket is minted
    /// @param recipient The address receiving the minted NFT
    /// @param tokenId The ID of the newly minted NFT
    event TicketMinted(address indexed recipient, uint256 tokenId);

    /**
     * @notice Constructor to initialize the NFT contract
     * @param name The name of the NFT collection (e.g., "Event Ticket")
     * @param symbol The symbol of the NFT (e.g., "ETK")
     * @param _maxSupply The maximum number of tickets that can be minted
     * @param initialBaseURI The initial base URI for the NFT metadata
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        string memory initialBaseURI
    ) ERC721(name, symbol) Ownable(msg.sender) {
        maxSupply = _maxSupply;
        baseURI = initialBaseURI;
        nextTokenId = 1;
    }

    /**
     * @notice Mint a new NFT ticket for an event
     * @param recipient The address that will receive the minted NFT
     * @dev Only the owner (event organizer) can mint tickets. Ensures supply limit.
     */
    function mintTicket(address recipient, string memory tokenURI) public onlyOwner {
        require(nextTokenId <= maxSupply, "Max ticket supply reached");

        uint256 tokenId = nextTokenId;
        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);

        emit TicketMinted(recipient, tokenId);

        nextTokenId++;
    }

    /**
     * @notice Override to return the base URI for computing tokenURI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
     * @notice Update the base URI for all NFTs
     * @param _newBaseURI The new base URI to be set
     * @dev Only the contract owner can update the base URI
     */
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
}
//EventTicketModule#EventTicketNFT - 0x2Ee46Fd1A59D878A8179BC87d706714FFa201e09