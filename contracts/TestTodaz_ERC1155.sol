// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestToadz is ERC1155, Ownable {
    uint256 public constant maxTokens = 6969;
    uint256 public numAvailableTokens = 6969;
    uint256 public constant maxMintsPerTx = 5;
    bool public devMintLocked = false;
    uint256[10000] private _availableTokens;

    constructor() ERC1155("ipfs://QmWEFSMku6yGLQ9TQr66HjSd9kay8ZDYKbBEfjNi4pLtrr/{id}") {}

    function getNumAvailableTokens() public view returns (uint256) {
        return numAvailableTokens;
    }

    //Minting
    function mint(uint256 quantity, uint256 amount) public {
        uint256 updatedNumAvailableTokens = numAvailableTokens;
        require(
            block.timestamp >= 1337133769,
            "Sale starts at whatever this time is"
        );
        require(
            quantity <= maxMintsPerTx,
            "There is a limit on minting too many at a time!"
        );
        require(
            updatedNumAvailableTokens - quantity >= 0,
            "Minting this many would exceed supply!"
        );
        require(msg.sender == tx.origin, "No contracts!");

        uint256[] memory ids = new uint256[](quantity);
        uint256[] memory amounts = new uint256[](quantity);

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = getRandomSerialToken(quantity, i);
            ids[i] = tokenId;
            amounts[i] = amount;
            updatedNumAvailableTokens--;
        }

        _mintBatch(msg.sender, ids, amounts, "");
        numAvailableTokens = updatedNumAvailableTokens;
    }

    //Dev mint special tokens
    function mintSpecial(uint256[] memory specialIds, uint256[] memory amounts ) external onlyOwner {
        require(!devMintLocked, "Dev Mint Permanently Locked");

        _mintBatch(msg.sender, specialIds, amounts, "");
    }

    function getRandomSerialToken(uint256 _numToFetch, uint256 _i)
        internal
        returns (uint256)
    {
        uint256 randomNum = uint256(
            keccak256(
                abi.encode(
                    msg.sender,
                    tx.gasprice,
                    block.number,
                    block.timestamp,
                    blockhash(block.number - 1),
                    _numToFetch,
                    _i
            )
        )
    );
    uint256 randomIndex = randomNum % numAvailableTokens;
    uint256 valAtIndex = _availableTokens[randomIndex];
    uint256 result;
    if (valAtIndex == 0) {
        result = randomIndex;
    } else {
        result = valAtIndex;
    }

    uint256 lastIndex = numAvailableTokens - 1;
    if (randomIndex != lastIndex) {
        uint256 lastValInArray = _availableTokens[lastIndex];
        if (lastValInArray == 0) {
            _availableTokens[randomIndex] = lastIndex;
        } else {
            _availableTokens[randomIndex] = lastValInArray;
        }
    }

    numAvailableTokens--;
    return result;
}

function lockDevMint() public onlyOwner {
    devMintLocked = true;
}
}