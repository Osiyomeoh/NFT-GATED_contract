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
    /// @notice The NFT contract used to gate event access
    IERC721 public nftContract;

    /// @notice Event struct to store event details
    struct Event {
        string name;
        uint256 date;
        uint256 price;
        uint256 maxAttendees;
        uint256 attendeesCount;
        bool isActive;
    }

    /// @notice Mapping of eventId to Event struct
    mapping(uint256 => Event) public events;

    /// @notice Mapping to track attendance of users for each event
    mapping(uint256 => mapping(address => bool)) public eventAttendees;

    /// @notice Emitted when a user successfully attends an event
    /// @param user The address of the user attending the event
    /// @param eventId The ID of the event
    /// @param eventName The name of the event
    event AttendedEvent(address indexed user, uint256 eventId, string eventName);

    /**
     * @notice Constructor to set the NFT contract address for access control
     * @param _nftContract The address of the NFT contract (ERC721)
     */
    constructor(address _nftContract) {
        nftContract = IERC721(_nftContract);
    }

    /**
     * @dev Modifier to check if the caller holds the required NFT
     * @param tokenId The ID of the NFT token that grants access
     */
    modifier onlyNFTHolder(uint256 tokenId) {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You do not own the required NFT");
        _;
    }

    /**
     * @dev Modifier to check if the event exists and is active
     * @param eventId The ID of the event to check
     */
    modifier eventExists(uint256 eventId) {
        require(events[eventId].isActive, "Event does not exist or is not active");
        _;
    }

    /**
     * @notice Create a new event
     * @dev Only the contract owner can create events
     * @param eventId Unique ID for the event
     * @param name The name of the event
     * @param date The date of the event (as a timestamp)
     * @param price The price to attend the event (in wei)
     * @param maxAttendees The maximum number of attendees allowed
     */
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

    /**
     * @notice Attend an event if the user holds the required NFT
     * @param eventId The ID of the event the user wants to attend
     * @param tokenId The ID of the NFT the user holds to access the event
     * @dev The user must hold the required NFT, and the event must not be full
     */
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

    /**
     * @notice Withdraw the funds collected from event attendance fees
     * @dev Only the contract owner can withdraw funds
     */
    function withdrawFunds() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @notice Deactivate an event, making it no longer available
     * @dev Only the contract owner can deactivate an event
     * @param eventId The ID of the event to deactivate
     */
    function deactivateEvent(uint256 eventId) public onlyOwner {
        require(events[eventId].isActive, "Event is already inactive");
        events[eventId].isActive = false;
    }

    /**
     * @notice Get the details of a specific event
     * @param eventId The ID of the event to retrieve details for
     * @return name The name of the event
     * @return date The date of the event (timestamp)
     * @return price The price to attend the event (in wei)
     * @return maxAttendees The maximum number of attendees allowed
     * @return attendeesCount The current number of attendees
     * @return isActive Boolean indicating if the event is active
     */
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
