// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {LibFixedPointDecimalParse} from "src/lib/parse/LibFixedPointDecimalParse.sol";
import {LibFixedPointDecimalFormat} from "src/lib/format/LibFixedPointDecimalFormat.sol";

contract LibFixedPointDecimalFormatTest is Test {
    function checkFixedPointToDecimalString(uint256 value, string memory expected) internal pure {
        assertEq(LibFixedPointDecimalFormat.fixedPointToDecimalString(value), expected);
    }

    function testFixedPointToDecimalStringExamples() external pure {
        checkFixedPointToDecimalString(0, "0");
        checkFixedPointToDecimalString(1e18, "1");
        checkFixedPointToDecimalString(10e18, "10");
        checkFixedPointToDecimalString(100e18, "100");
        checkFixedPointToDecimalString(1000e18, "1000");
        checkFixedPointToDecimalString(10000e18, "10000");
        checkFixedPointToDecimalString(0.1e18, "0.1");
        checkFixedPointToDecimalString(0.01e18, "0.01");
        checkFixedPointToDecimalString(0.001e18, "0.001");
        checkFixedPointToDecimalString(0.0001e18, "0.0001");
        checkFixedPointToDecimalString(0.00001e18, "0.00001");
        checkFixedPointToDecimalString(0.000001e18, "0.000001");
        checkFixedPointToDecimalString(0.0000001e18, "0.0000001");
        checkFixedPointToDecimalString(0.00000001e18, "0.00000001");
        checkFixedPointToDecimalString(0.000000001e18, "0.000000001");
        checkFixedPointToDecimalString(0.0000000001e18, "0.0000000001");
        checkFixedPointToDecimalString(0.00000000001e18, "0.00000000001");
        checkFixedPointToDecimalString(0.000000000001e18, "0.000000000001");
        checkFixedPointToDecimalString(0.0000000000001e18, "0.0000000000001");
        checkFixedPointToDecimalString(0.00000000000001e18, "0.00000000000001");
        checkFixedPointToDecimalString(0.000000000000001e18, "0.000000000000001");
        checkFixedPointToDecimalString(0.0000000000000001e18, "0.0000000000000001");
        checkFixedPointToDecimalString(0.00000000000000001e18, "0.00000000000000001");
        checkFixedPointToDecimalString(0.000000000000000001e18, "0.000000000000000001");
        checkFixedPointToDecimalString(1, "0.000000000000000001");
        checkFixedPointToDecimalString(1.1e18, "1.1");
        checkFixedPointToDecimalString(
            type(uint256).max, "115792089237316195423570985008687907853269984665640564039457.584007913129639935"
        );
        checkFixedPointToDecimalString(10101010101010101, "0.010101010101010101");
        checkFixedPointToDecimalString(1.10101010101010101e18, "1.10101010101010101");
    }

    function testStringRoundTripFuzz(uint256 value) external pure {
        string memory str = LibFixedPointDecimalFormat.fixedPointToDecimalString(value);
        (bytes4 errorSelector, uint256 parsed) = LibFixedPointDecimalParse.decimalStringTofixedPoint(str);
        assertEq(errorSelector, 0);
        assertEq(value, parsed);
    }
}
