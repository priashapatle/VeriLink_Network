// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VeriLink Network - Simple on-chain link verification registry
/// @notice Allows users to register resources (links) and mark them as verified.
contract Project {
    struct LinkRecord {
        address owner;       // Address that registered the link
        string resourceURI;  // URI / URL / identifier for the resource
        string metadata;     // Optional description or hash
        bool isVerified;     // Whether the link has been verified
    }

    address public admin;
    uint256 public linkCount;
    mapping(uint256 => LinkRecord) private links;

    event LinkRegistered(uint256 indexed linkId, address indexed owner, string resourceURI);
    event LinkVerified(uint256 indexed linkId, address indexed verifier);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Register a new resource/link on-chain
    /// @param resourceURI The URL or identifier of the resource
    /// @param metadata Optional human-readable description or off-chain hash
    /// @return linkId The ID of the newly created link record
    function registerLink(string calldata resourceURI, string calldata metadata)
        external
        returns (uint256 linkId)
    {
        require(bytes(resourceURI).length > 0, "Resource URI required");

        linkId = ++linkCount;

        links[linkId] = LinkRecord({
            owner: msg.sender,
            resourceURI: resourceURI,
            metadata: metadata,
            isVerified: false
        });

        emit LinkRegistered(linkId, msg.sender, resourceURI);
    }

    /// @notice Mark a link as verified
    /// @dev Only the admin can verify links (could be an oracle or governance address)
    /// @param linkId The ID of the link to verify
    function verifyLink(uint256 linkId) external onlyAdmin {
        require(linkId > 0 && linkId <= linkCount, "Invalid linkId");
        require(!links[linkId].isVerified, "Already verified");

        links[linkId].isVerified = true;

        emit LinkVerified(linkId, msg.sender);
    }

    /// @notice Fetch details of a stored link
    /// @param linkId The ID of the link
    /// @return owner Address that registered the link
    /// @return resourceURI URI / URL of the resource
    /// @return metadata Optional description
    /// @return isVerified Verification status
    function getLink(uint256 linkId)
        external
        view
        returns (
            address owner,
            string memory resourceURI,
            string memory metadata,
            bool isVerified
        )
    {
        require(linkId > 0 && linkId <= linkCount, "Invalid linkId");

        LinkRecord memory record = links[linkId];
        return (record.owner, record.resourceURI, record.metadata, record.isVerified);
    }
}

