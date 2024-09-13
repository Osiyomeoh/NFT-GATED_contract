import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const EventTicketModule = buildModule("EventTicketModule", (m) => {
  const name = m.getParameter("name", "Event Ticket");
  const symbol = m.getParameter("symbol", "ETK");
  const maxSupply = m.getParameter("maxSupply", 1000); // Set the maximum supply of tickets
  const baseURI = m.getParameter("baseURI", "https://example.com/metadata/");

  // Deploy the EventTicketNFT contract with the constructor parameters
  const eventTicketNFT = m.contract("EventTicketNFT", [name, symbol, maxSupply, baseURI]);

  return { eventTicketNFT };
});

export default EventTicketModule;
