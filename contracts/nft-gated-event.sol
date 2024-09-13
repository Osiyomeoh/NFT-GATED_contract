// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NFT-Gated Event Management Contract
 * @notice This contract allows users holding a specific NFT to attend events.
 * @dev The contract is designed to manage events, where access is controlled by ownership of an NFT.
 */
contract NFTGatedEvent is Ownable {
    IERC721 public nftContract;

    struct Event {
        string name;
        uint256 date;
        uint256 price;
        uint256 maxAttendees;
        uint256 attendeesCount;
        bool isActive;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => mapping(address => bool)) public eventAttendees;

    event AttendedEvent(address indexed user, uint256 eventId, string eventName);

    /**
     * @notice Constructor to set the NFT contract address for access control
     * @param _nftContract The address of the NFT contract (ERC721)
     */
    constructor(address _nftContract) Ownable(msg.sender) {
        nftContract = IERC721(_nftContract);
    }

    modifier onlyNFTHolder(uint256 tokenId) {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You do not own the required NFT");
        _;
    }

    modifier eventExists(uint256 eventId) {
        require(events[eventId].isActive, "Event does not exist or is not active");
        _;
    }

    function createEvent(
        uint256 eventId,
        string memory name,
        uint256 date,
        uint256 price,
        uint256 maxAttendees
    ) public onlyOwner {
        require(!events[eventId].isActive, "Event already exists");
        events[eventId] = Event(name, date, price, maxAttendees, 0, true);
    }

    function attendEvent(uint256 eventId, uint256 tokenId) 
        public 
        payable 
        eventExists(eventId) 
        onlyNFTHolder(tokenId) 
    {
        Event storage currentEvent = events[eventId];

        require(msg.value >= currentEvent.price, "Insufficient payment");
        require(currentEvent.attendeesCount < currentEvent.maxAttendees, "Event is full");
        require(!eventAttendees[eventId][msg.sender], "You are already attending this event");

        currentEvent.attendeesCount += 1;
        eventAttendees[eventId][msg.sender] = true;

        emit AttendedEvent(msg.sender, eventId, currentEvent.name);
    }

    function withdrawFunds() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function deactivateEvent(uint256 eventId) public onlyOwner {
        require(events[eventId].isActive, "Event is already inactive");
        events[eventId].isActive = false;
    }

    function getEventDetails(uint256 eventId) 
        public 
        view 
        eventExists(eventId) 
        returns (
            string memory name, 
            uint256 date, 
            uint256 price, 
            uint256 maxAttendees, 
            uint256 attendeesCount, 
            bool isActive
        ) 
    {
        Event storage currentEvent = events[eventId];
        return (
            currentEvent.name,
            currentEvent.date,
            currentEvent.price,
            currentEvent.maxAttendees,
            currentEvent.attendeesCount,
            currentEvent.isActive
        );
    }
}
