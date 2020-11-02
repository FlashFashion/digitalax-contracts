// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./ERC1155/ERC1155.sol";
import "./DigitalaxAccessControls.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract DigitalaxMaterials is ERC1155 {
    using SafeMath for uint256;

    event DigitalaxMaterialsDeployed();

    string public name;
    string public symbol;

    uint256 internal tokenIdPointer;

    DigitalaxAccessControls public accessControls;

    constructor(string memory _name, string memory _symbol, DigitalaxAccessControls _accessControls) public {
        name = _name;
        symbol = _symbol;
        accessControls = _accessControls;
        emit DigitalaxMaterialsDeployed();
    }

    function createStrand(string calldata _uri) external returns (uint256) {
        require(
            accessControls.hasSmartContractRole(_msgSender()),
            "DigitalaxMaterials.createStrand: Sender must be smart contract"
        );

        require(bytes(_uri).length > 0, "DigitalaxMaterials.createStrand: URI is a blank string");

        tokenIdPointer = tokenIdPointer.add(1);

        uint256 strandId = tokenIdPointer;
        _setURI(strandId, _uri);

        return strandId;
    }

    function batchCreateStrands(string[] calldata _uris) external returns (uint256[] memory strandIds) {
        require(
            accessControls.hasSmartContractRole(_msgSender()),
            "DigitalaxMaterials.batchCreateStrands: Sender must be smart contract"
        );

        require(_uris.length > 0, "DigitalaxMaterials.batchCreateStrands: No data supplied in array");

        strandIds = new uint256[](_uris.length);
        for(uint i = 0; i < _uris.length; i++) {
            string memory uri = _uris[i];
            require(bytes(uri).length > 0, "DigitalaxMaterials.batchCreateStrands: URI is a blank string");

            tokenIdPointer = tokenIdPointer.add(1);
            uint256 strandId = tokenIdPointer;

            _setURI(strandId, uri);

            strandIds[i] = strandId;
        }
    }

    function mintStrand(uint256 _strandId, uint256 _amount, address _beneficiary, bytes calldata _data) external {
        require(
            accessControls.hasSmartContractRole(_msgSender()),
            "DigitalaxMaterials.mintStrand: Sender must be smart contract"
        );

        require(bytes(tokenUris[_strandId]).length > 0, "DigitalaxMaterials.mintStrand: Strand does not exist");
        require(_amount > 0, "DigitalaxMaterials.mintStrand: No amount specified");
        _mint(_beneficiary, _strandId, _amount, _data);
    }

    function batchMintStrands(
        uint256[] calldata _strandIds,
        uint256[] calldata _amounts,
        address _beneficiary,
        bytes calldata _data
    ) external {
        require(
            accessControls.hasSmartContractRole(_msgSender()),
            "DigitalaxMaterials.batchMintStrands: Sender must be smart contract"
        );

        require(_strandIds.length == _amounts.length, "DigitalaxMaterials.batchMintStrands: Array lengths are invalid");
        require(_strandIds.length > 0, "DigitalaxMaterials.batchMintStrands: No data supplied in arrays");

        // Check the strands exist and no zero amounts
        for(uint i = 0; i < _strandIds.length; i++) {
            uint256 strandId = _strandIds[i];
            require(bytes(tokenUris[strandId]).length > 0, "DigitalaxMaterials.batchMintStrands: Strand does not exist");

            uint256 amount = _amounts[i];
            require(amount > 0, "DigitalaxMaterials.batchMintStrands: Invalid amount");
        }

        _mintBatch(_beneficiary, _strandIds, _amounts, _data);
    }

    // todo admin update tokenURI

    function updateAccessControls(DigitalaxAccessControls _accessControls) external {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxMaterials.updateAccessControls: Sender must be admin"
        );

        require(
            address(_accessControls) != address(0),
            "DigitalaxMaterials.updateAccessControls: New access controls cannot be ZERO address"
        );

        accessControls = _accessControls;
    }
}
