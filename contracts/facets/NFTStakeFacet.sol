// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import "./ERC721Facet.sol";

contract NFTStakeFacet {
    event NftStaked(address indexed onwer, address indexed nft, uint tokenId);

    function initialiseFacet(uint8 _rate) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (msg.sender != ds.contractOwner) revert LibDiamond.NotDiamondOwner();

        ds.interestRate = _rate;
    }

    function addSupportedNft(address _nft, uint _amount) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (_nft == address(0)) revert LibDiamond.NoZeroAddress();
        if (msg.sender != ds.contractOwner) revert LibDiamond.NotDiamondOwner();

        ds.supportedNfts[_nft] = _amount;
    }

    function stakeNft(address _nft, uint _tokenId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint nftValue = verifyNftValidity(_nft);

        if (nftValue == 0) revert LibDiamond.UnsupportedNFT();

        ERC721Facet(_nft).safeTransferFrom(msg.sender, address(this), _tokenId);

        LibDiamond.Position memory _position;
        _position.nft = _nft;
        _position.nftValue = nftValue;

        ds.positions[msg.sender] = _position;

        emit NftStaked(msg.sender, _nft, _tokenId);
    }

    function verifyNftValidity(address _nft) internal view returns (uint) {
        if (_nft == address(0)) revert LibDiamond.NoZeroAddress();

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        return ds.supportedNfts[_nft];
    }
}