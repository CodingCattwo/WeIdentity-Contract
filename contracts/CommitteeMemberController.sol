pragma solidity ^0.4.4;
/*
 *       Copyright© (2018) WeBank Co., Ltd.
 *
 *       This file is part of weidentity-contract.
 *
 *       weidentity-contract is free software: you can redistribute it and/or modify
 *       it under the terms of the GNU Lesser General Public License as published by
 *       the Free Software Foundation, either version 3 of the License, or
 *       (at your option) any later version.
 *
 *       weidentity-contract is distributed in the hope that it will be useful,
 *       but WITHOUT ANY WARRANTY; without even the implied warranty of
 *       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *       GNU Lesser General Public License for more details.
 *
 *       You should have received a copy of the GNU Lesser General Public License
 *       along with weidentity-contract.  If not, see <https://www.gnu.org/licenses/>.
 */

import "./CommitteeMemberData.sol";
import "./RoleController.sol";

/**
 * @title CommitteeMemberController
 * Issuer contract manages authority issuer info.
 */

contract CommitteeMemberController {

    CommitteeMemberData private committeeMemberData;
    RoleController private roleController;

    // Event structure to store tx records
    uint constant private OPERATION_ADD = 0;
    uint constant private OPERATION_REMOVE = 1;
    uint constant private RETURN_CODE_SUCCESS = 0;
    uint constant private RETURN_CODE_FAILURE_ALREADY_EXISTS = 500251;
    uint constant private RETURN_CODE_FAILURE_NOT_EXIST = 500252;
    uint constant private RETURN_CODE_FAILURE_NO_PERMISSION = 500253;
    
    event CommitteeRetLog(uint operation, uint retCode, address addr);

    // Constructor.
    function CommitteeMemberController(
        address committeeMemberDataAddress,
        address roleControllerAddress
    )
        public 
    {
        committeeMemberData = CommitteeMemberData(committeeMemberDataAddress);
        roleController = RoleController(roleControllerAddress);
    }
    
    function addCommitteeMember(
        address addr
    ) 
        public 
    {
        if (committeeMemberData.isCommitteeMember(addr)) {
            CommitteeRetLog(OPERATION_ADD, RETURN_CODE_FAILURE_ALREADY_EXISTS, addr);
            return;
        } else if (!roleController.checkPermission(tx.origin, roleController.MODIFY_COMMITTEE())) {
            CommitteeRetLog(OPERATION_ADD, RETURN_CODE_FAILURE_NO_PERMISSION, addr);
            return;
        } else {
            committeeMemberData.addCommitteeMemberFromAddress(addr);
            CommitteeRetLog(OPERATION_ADD, RETURN_CODE_SUCCESS, addr);
        }
    }
    
    function removeCommitteeMember(
        address addr
    ) 
        public 
    {
        if (!committeeMemberData.isCommitteeMember(addr)) {
            CommitteeRetLog(OPERATION_REMOVE, RETURN_CODE_FAILURE_NOT_EXIST, addr);
            return;
        } else if (!roleController.checkPermission(tx.origin, roleController.MODIFY_COMMITTEE())) {
            CommitteeRetLog(OPERATION_REMOVE, RETURN_CODE_FAILURE_NO_PERMISSION, addr);
            return;
        } else {
            committeeMemberData.deleteCommitteeMemberFromAddress(addr);
            CommitteeRetLog(OPERATION_REMOVE, RETURN_CODE_SUCCESS, addr);
        }
    }

    function getAllCommitteeMemberAddress() 
        public 
        constant 
        returns (address[]) 
    {
        // Per-index access
        uint datasetLength = committeeMemberData.getDatasetLength();
        address[] memory memberArray = new address[](datasetLength);
        for (uint index = 0; index < datasetLength; index++) {
            memberArray[index] = committeeMemberData.getCommitteeMemberAddressFromIndex(index);
        }
        return memberArray;
    }

    function isCommitteeMember(
        address addr
    ) 
        public 
        constant 
        returns (bool) 
    {
        return committeeMemberData.isCommitteeMember(addr);
    }
}