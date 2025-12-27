// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/**
 * @title AuthorizationManager
 * @notice Validates off-chain withdrawal authorizations and prevents replay
 */
contract AuthorizationManager {
    using ECDSA for bytes32;

    /// @notice Tracks consumed authorizations (replay protection)
    mapping(bytes32 => bool) public consumedAuthorizations;

    /// @notice Authorized vault contract
    address public vault;

    /// @notice Initialization guard
    bool public initialized;

    event AuthorizationConsumed(bytes32 indexed authorizationHash);
    event VaultInitialized(address indexed vault);

    /**
     * @notice One-time initialization with vault address
     */
    function initialize(address _vault) external {
        require(!initialized, "Already initialized");
        require(_vault != address(0), "Invalid vault");

        vault = _vault;
        initialized = true;

        emit VaultInitialized(_vault);
    }

    /**
     * @notice Verifies a withdrawal authorization
     * @dev Callable only by the vault
     */
    function verifyAuthorization(
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external returns (bool) {
        require(initialized, "Not initialized");
        require(msg.sender == vault, "Only vault can call");

        // Build deterministic authorization hash
        bytes32 authorizationHash = keccak256(
            abi.encode(
                vault,
                block.chainid,
                recipient,
                amount,
                nonce
            )
        );

        // Prevent replay
        require(
            !consumedAuthorizations[authorizationHash],
            "Authorization already used"
        );

        // Convert to EIP-191 signed message hash
        bytes32 ethSignedHash =
            MessageHashUtils.toEthSignedMessageHash(authorizationHash);

        // Recover signer
        address signer = ECDSA.recover(ethSignedHash, signature);
        require(signer != address(0), "Invalid signature");

        // Mark authorization as consumed BEFORE returning
        consumedAuthorizations[authorizationHash] = true;
        emit AuthorizationConsumed(authorizationHash);

        return true;
    }
}
