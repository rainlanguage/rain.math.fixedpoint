// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {LibFixedPointDecimalParse} from "src/lib/parse/LibFixedPointDecimalParse.sol";
import {ParseDecimalInvalidString, ParseDecimalPrecisionLoss} from "src/error/ErrParse.sol";
import {ParseEmptyDecimalString, ParseDecimalOverflow} from "rain.string/error/ErrParse.sol";

contract LibFixedPointDecimalParseTest is Test {
    function checkDecimalStringToFixedPoint(string memory value, uint256 expected) internal pure {
        (bytes4 errorSelector, uint256 parsed) = LibFixedPointDecimalParse.decimalStringTofixedPoint(value);
        assertEq(errorSelector, 0);
        assertEq(parsed, expected);
    }

    function checkDecimalStringToFixedPointFailure(string memory value, bytes4 expected) internal pure {
        (bytes4 errorSelector,) = LibFixedPointDecimalParse.decimalStringTofixedPoint(value);
        assertEq(errorSelector, expected);
    }

    function testDecimalStringToFixedPointExamples() external pure {
        checkDecimalStringToFixedPoint("0", 0);
        checkDecimalStringToFixedPoint("0.0", 0);
        checkDecimalStringToFixedPoint("1", 1e18);
        checkDecimalStringToFixedPoint("1.0", 1e18);
        checkDecimalStringToFixedPoint("10", 10e18);
        checkDecimalStringToFixedPoint("10.0", 10e18);
        checkDecimalStringToFixedPoint("100", 100e18);
        checkDecimalStringToFixedPoint("1000", 1000e18);
        checkDecimalStringToFixedPoint("10000", 10000e18);
        checkDecimalStringToFixedPoint("0.1", 0.1e18);
        checkDecimalStringToFixedPoint("0.01", 0.01e18);
        checkDecimalStringToFixedPoint("0.001", 0.001e18);
        checkDecimalStringToFixedPoint("0.0001", 0.0001e18);
        checkDecimalStringToFixedPoint("0.00001", 0.00001e18);
        checkDecimalStringToFixedPoint("0.000001", 0.000001e18);
        checkDecimalStringToFixedPoint("0.0000001", 0.0000001e18);
        checkDecimalStringToFixedPoint("0.00000001", 0.00000001e18);
        checkDecimalStringToFixedPoint("0.000000001", 0.000000001e18);
        checkDecimalStringToFixedPoint("0.0000000001", 0.0000000001e18);
        checkDecimalStringToFixedPoint("0.00000000001", 0.00000000001e18);
        checkDecimalStringToFixedPoint("0.000000000001", 0.000000000001e18);
        checkDecimalStringToFixedPoint("0.0000000000001", 0.0000000000001e18);
        checkDecimalStringToFixedPoint("0.00000000000001", 0.00000000000001e18);
        checkDecimalStringToFixedPoint("0.000000000000001", 0.000000000000001e18);
        checkDecimalStringToFixedPoint("0.0000000000000001", 0.0000000000000001e18);
        checkDecimalStringToFixedPoint("0.00000000000000001", 0.00000000000000001e18);
        checkDecimalStringToFixedPoint("0.000000000000000001", 0.000000000000000001e18);
        checkDecimalStringToFixedPoint("1.1", 1.1e18);
        checkDecimalStringToFixedPoint("1.10101010101010101", 1.10101010101010101e18);
        checkDecimalStringToFixedPoint(
            "115792089237316195423570985008687907853269984665640564039457.584007913129639935", type(uint256).max
        );
        checkDecimalStringToFixedPoint("0.010101010101010101", 10101010101010101);

        // Trailing zeros.
        checkDecimalStringToFixedPoint("1.000000000000000000", 1e18);
        checkDecimalStringToFixedPoint("1.100000000000000000", 1.1e18);
        checkDecimalStringToFixedPoint("1.101010101010101010", 1.10101010101010101e18);
        checkDecimalStringToFixedPoint(
            "115792089237316195423570985008687907853269984665640564039457.5840079131296399350", type(uint256).max
        );
        checkDecimalStringToFixedPoint(
            "115792089237316195423570985008687907853269984665640564039457.58400791312963993500000000", type(uint256).max
        );

        // Leading zeros.
        checkDecimalStringToFixedPoint("0000001", 1e18);
        checkDecimalStringToFixedPoint("0000001.000000000000000000", 1e18);
        checkDecimalStringToFixedPoint("0000001.100000000000000000", 1.1e18);
        checkDecimalStringToFixedPoint("0000001.101010101010101010", 1.10101010101010101e18);
        checkDecimalStringToFixedPoint(
            "000000115792089237316195423570985008687907853269984665640564039457.584007913129639935", type(uint256).max
        );

        // Leading and trailing zeros.
        checkDecimalStringToFixedPoint("0000001.000000000000000000", 1e18);
        checkDecimalStringToFixedPoint("0000001.100000000000000000", 1.1e18);
        checkDecimalStringToFixedPoint("0000001.101010101010101010", 1.10101010101010101e18);
        checkDecimalStringToFixedPoint(
            "000000115792089237316195423570985008687907853269984665640564039457.5840079131296399350000",
            type(uint256).max
        );
    }

    /// Failure due to corrupt integer.
    function testDecimalStringToFixedPointFailureCorruptInteger() external pure {
        checkDecimalStringToFixedPointFailure("1a1.1", ParseDecimalInvalidString.selector);
        checkDecimalStringToFixedPointFailure("1.1a1", ParseDecimalInvalidString.selector);
        checkDecimalStringToFixedPointFailure("1.1.1", ParseDecimalInvalidString.selector);
        checkDecimalStringToFixedPointFailure("a1.1", ParseEmptyDecimalString.selector);
    }

    /// Failure due to precision loss.
    function testDecimalStringToFixedPointFailurePrecisionLoss() external pure {
        checkDecimalStringToFixedPointFailure(
            "115792089237316195423570985008687907853269984665640564039457.5840079131296399355",
            ParseDecimalPrecisionLoss.selector
        );
    }

    /// Failure due to overflow.
    function testDecimalStringToFixedPointFailureOverflow() external pure {
        checkDecimalStringToFixedPointFailure(
            "115792089237316195423570985008687907853269984665640564039457.584007913129639936",
            ParseDecimalOverflow.selector
        );
        checkDecimalStringToFixedPointFailure(
            "1115792089237316195423570985008687907853269984665640564039457.584007913129639935",
            ParseDecimalOverflow.selector
        );
    }
}
