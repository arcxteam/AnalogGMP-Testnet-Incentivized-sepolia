// this auto compile and auto verify on sepolia & shibuya blockscout explorer

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGateway {
    function sendMessage(bytes calldata _message, address _receiver) external;
}

interface IGmpReceiver {
    /**
     * @dev Handles the receipt of a single GMP message.
     * The contract must verify the msg.sender, it must be the Gateway Contract address.
     *
     * @param id The EIP-712 hash of the message payload, used as GMP unique identifier
     * @param network The chain_id of the source chain that send the message
     * @param source The pubkey/address which sent the GMP message
     * @param payload The message payload with no specified format
     * @return 32-byte result, which will be stored together with the GMP message
     */
    function onGmpReceived(bytes32 id, uint128 network, bytes32 source, bytes calldata payload)
        external
        payable
        returns (bytes32);
}
contract MyGmpContract is IGmpReceiver {
    // network-id 5 is sepolia 0x000000007f56768de3133034fa730a909003a165
    // network-id 7 is shibuya 0x000000007f56768de3133034fa730a909003a165
    IGateway public gateway;
    address public gatewayAddress;

    event MessageSent(address indexed sender, address indexed receiver, bytes message);
    event GmpReceived(bytes32 id, uint128 network, bytes32 source, bytes payload);

    constructor(address _gateway) {
        gateway = IGateway(_gateway);
        gatewayAddress = _gateway;
    }

    function sendMessage(bytes calldata _message, address _receiver) external {
        require(_receiver != address(0), "Receiver address cannot be zero");
        gateway.sendMessage(_message, _receiver);
        emit MessageSent(msg.sender, _receiver, _message);
    }

    function onGmpReceived(bytes32 id, uint128 network, bytes32 source, bytes calldata payload)
        external
        payable
        override
        returns (bytes32)
    {
        require(msg.sender == gatewayAddress, "Invalid sender");
        
        emit GmpReceived(id, network, source, payload);
        
        // Process the payload here
        // Example: Decoding the payload if it contains specific data
        // (string memory decodedMessage) = abi.decode(payload, (string));
        
        // Return a result (example: keccak256 of the id)
        return keccak256(abi.encodePacked(id));
    }
}
